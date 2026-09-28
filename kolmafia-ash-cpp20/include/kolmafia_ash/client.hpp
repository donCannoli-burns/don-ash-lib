#pragma once

#include "kolmafia_ash/types.hpp"

#include <boost/json.hpp>
#include <chrono>
#include <functional>
#include <initializer_list>
#include <optional>
#include <span>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

namespace kolmafia::ash {

class Error : public std::runtime_error {
 public:
  using std::runtime_error::runtime_error;
};

class HttpError : public Error {
 public:
  HttpError(long status, std::string message);
  [[nodiscard]] long status() const noexcept { return status_; }

 private:
  long status_;
};

class ApiError : public Error {
 public:
  using Error::Error;
};

struct FunctionCall {
  std::string name; // Browser JSON API / JS-style name, e.g. myMeat
  boost::json::array args;
};

struct Request {
  std::vector<std::string> properties;
  std::vector<FunctionCall> functions;
};

struct Response {
  std::vector<boost::json::value> properties;
  std::vector<boost::json::value> functions;
  boost::json::object raw;
};

struct ClientOptions {
  std::string base_url = "http://127.0.0.1:60080";
  std::chrono::milliseconds timeout{5000};

  // Return the current KoLmafia pwd/session hash. Deliberately a callback so
  // callers can source it from their existing runtime without persisting it
  // in this library or a config file.
  std::function<std::string()> pwd_provider;
};

class Client {
 public:
  explicit Client(ClientOptions options);

  [[nodiscard]] Response request(const Request& request) const;
  [[nodiscard]] boost::json::value call(std::string_view name,
                                        boost::json::array args = {}) const;
  [[nodiscard]] std::vector<boost::json::value> call_many(
      std::span<const FunctionCall> calls) const;
  [[nodiscard]] boost::json::value property(std::string_view name) const;

  // Common read-only conveniences. These intentionally cover only a small,
  // obviously inspectable surface. The generic call() method exposes the full
  // Browser JSON API when the application chooses to use it.
  [[nodiscard]] std::string my_name() const;
  [[nodiscard]] std::int64_t my_meat() const;
  [[nodiscard]] std::int64_t my_adventures() const;
  [[nodiscard]] std::int64_t turns_played() const;
  [[nodiscard]] std::int64_t available_amount(const EnumRef& item) const;
  [[nodiscard]] boost::json::object identity(const EnumRef& value) const;

  [[nodiscard]] const ClientOptions& options() const noexcept { return options_; }

 private:
  ClientOptions options_;
};

// Helper for concise argument construction.
template <typename... Args>
boost::json::array args(Args&&... values) {
  boost::json::array out;
  out.reserve(sizeof...(Args));
  (out.emplace_back(json_value(std::forward<Args>(values))), ...);
  return out;
}

} // namespace kolmafia::ash
