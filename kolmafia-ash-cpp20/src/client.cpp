#include "kolmafia_ash/client.hpp"

#include <curl/curl.h>

#include <algorithm>
#include <cstdint>
#include <mutex>
#include <sstream>
#include <utility>

namespace kolmafia::ash {
namespace {

std::once_flag curl_init_once;

void ensure_curl() {
  std::call_once(curl_init_once, [] {
    const auto rc = curl_global_init(CURL_GLOBAL_DEFAULT);
    if (rc != CURLE_OK) {
      throw Error(std::string("curl_global_init failed: ") + curl_easy_strerror(rc));
    }
  });
}

size_t append_body(char* ptr, size_t size, size_t nmemb, void* userdata) {
  const auto bytes = size * nmemb;
  auto* out = static_cast<std::string*>(userdata);
  out->append(ptr, bytes);
  return bytes;
}

boost::json::array strings_to_json(const std::vector<std::string>& values) {
  boost::json::array out;
  out.reserve(values.size());
  for (const auto& v : values) out.emplace_back(v);
  return out;
}

boost::json::object request_to_json(const Request& request) {
  boost::json::object root;
  if (!request.properties.empty()) root["properties"] = strings_to_json(request.properties);

  if (!request.functions.empty()) {
    boost::json::array functions;
    functions.reserve(request.functions.size());
    for (const auto& call : request.functions) {
      boost::json::object fn;
      fn["name"] = call.name;
      fn["args"] = call.args;
      functions.emplace_back(std::move(fn));
    }
    root["functions"] = std::move(functions);
  }
  return root;
}

std::vector<boost::json::value> array_copy(const boost::json::value* value,
                                            std::string_view field) {
  if (!value) return {};
  if (!value->is_array()) {
    throw ApiError("KoLmafia response field '" + std::string(field) + "' was not an array");
  }
  std::vector<boost::json::value> out;
  const auto& arr = value->as_array();
  out.reserve(arr.size());
  for (const auto& v : arr) out.push_back(v);
  return out;
}

std::string require_string(const boost::json::value& value, std::string_view function) {
  if (!value.is_string()) {
    throw ApiError("Expected string result from " + std::string(function));
  }
  return std::string(value.as_string());
}

std::int64_t require_int(const boost::json::value& value, std::string_view function) {
  if (value.is_int64()) return value.as_int64();
  if (value.is_uint64()) {
    const auto v = value.as_uint64();
    if (v <= static_cast<std::uint64_t>(INT64_MAX)) return static_cast<std::int64_t>(v);
  }
  throw ApiError("Expected integer result from " + std::string(function));
}

} // namespace

HttpError::HttpError(long status, std::string message)
    : Error(std::move(message)), status_(status) {}

Client::Client(ClientOptions options) : options_(std::move(options)) {
  if (options_.base_url.empty()) throw Error("base_url must not be empty");
  while (!options_.base_url.empty() && options_.base_url.back() == '/') {
    options_.base_url.pop_back();
  }
  if (!options_.pwd_provider) {
    throw Error("pwd_provider is required; do not hard-code the KoLmafia session hash");
  }
  ensure_curl();
}

Response Client::request(const Request& request) const {
  const std::string pwd = options_.pwd_provider();
  if (pwd.empty()) throw Error("pwd_provider returned an empty KoLmafia session hash");

  const std::string body_json = boost::json::serialize(request_to_json(request));
  const std::string url = options_.base_url + "/KoLmafia/jsonApi";

  CURL* curl = curl_easy_init();
  if (!curl) throw Error("curl_easy_init failed");

  struct CurlCleanup {
    CURL* handle;
    ~CurlCleanup() { if (handle) curl_easy_cleanup(handle); }
  } cleanup{curl};

  char* encoded_pwd = curl_easy_escape(curl, pwd.c_str(), static_cast<int>(pwd.size()));
  char* encoded_body = curl_easy_escape(curl, body_json.c_str(), static_cast<int>(body_json.size()));
  if (!encoded_pwd || !encoded_body) {
    if (encoded_pwd) curl_free(encoded_pwd);
    if (encoded_body) curl_free(encoded_body);
    throw Error("curl_easy_escape failed");
  }

  std::string post_fields = "pwd=";
  post_fields += encoded_pwd;
  post_fields += "&body=";
  post_fields += encoded_body;
  curl_free(encoded_pwd);
  curl_free(encoded_body);

  std::string response_body;
  struct curl_slist* headers = nullptr;
  headers = curl_slist_append(headers, "Content-Type: application/x-www-form-urlencoded");
  struct HeaderCleanup {
    curl_slist* headers;
    ~HeaderCleanup() { if (headers) curl_slist_free_all(headers); }
  } header_cleanup{headers};

  curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
  curl_easy_setopt(curl, CURLOPT_POST, 1L);
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post_fields.c_str());
  curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, static_cast<long>(post_fields.size()));
  curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, append_body);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response_body);
  curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, static_cast<long>(options_.timeout.count()));
  curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);

  const CURLcode rc = curl_easy_perform(curl);
  if (rc != CURLE_OK) {
    throw Error(std::string("KoLmafia request failed: ") + curl_easy_strerror(rc));
  }

  long http_status = 0;
  curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_status);
  if (http_status < 200 || http_status >= 300) {
    throw HttpError(http_status,
                    "KoLmafia returned HTTP " + std::to_string(http_status) +
                    (response_body.empty() ? std::string{} : ": " + response_body));
  }

  boost::system::error_code ec;
  boost::json::value parsed = boost::json::parse(response_body, ec);
  if (ec || !parsed.is_object()) {
    throw ApiError("KoLmafia returned invalid JSON: " + response_body);
  }

  auto raw = parsed.as_object();
  if (const auto* error = raw.if_contains("error")) {
    if (error->is_string()) throw ApiError(std::string(error->as_string()));
    throw ApiError("KoLmafia returned an API error: " + boost::json::serialize(*error));
  }

  Response response;
  response.properties = array_copy(raw.if_contains("properties"), "properties");
  response.functions = array_copy(raw.if_contains("functions"), "functions");
  response.raw = std::move(raw);
  return response;
}

boost::json::value Client::call(std::string_view name, boost::json::array call_args) const {
  Request req;
  req.functions.push_back(FunctionCall{std::string(name), std::move(call_args)});
  Response response = request(req);
  if (response.functions.size() != 1) {
    throw ApiError("KoLmafia returned an unexpected function result count");
  }
  return std::move(response.functions.front());
}

std::vector<boost::json::value> Client::call_many(std::span<const FunctionCall> calls) const {
  Request req;
  req.functions.assign(calls.begin(), calls.end());
  Response response = request(req);
  if (response.functions.size() != calls.size()) {
    throw ApiError("KoLmafia returned an unexpected function result count");
  }
  return response.functions;
}

boost::json::value Client::property(std::string_view name) const {
  Request req;
  req.properties.emplace_back(name);
  Response response = request(req);
  if (response.properties.size() != 1) {
    throw ApiError("KoLmafia returned an unexpected property result count");
  }
  return std::move(response.properties.front());
}

std::string Client::my_name() const { return require_string(call("myName"), "myName"); }
std::int64_t Client::my_meat() const { return require_int(call("myMeat"), "myMeat"); }
std::int64_t Client::my_adventures() const {
  return require_int(call("myAdventures"), "myAdventures");
}
std::int64_t Client::turns_played() const {
  return require_int(call("turnsPlayed"), "turnsPlayed");
}
std::int64_t Client::available_amount(const EnumRef& item) const {
  return require_int(call("availableAmount", args(item)), "availableAmount");
}
boost::json::object Client::identity(const EnumRef& value) const {
  auto result = call("identity", args(value));
  if (!result.is_object()) throw ApiError("Expected object result from identity");
  return result.as_object();
}

} // namespace kolmafia::ash
