#include "kolmafia_ash.h"

#include <ctype.h>
#include <curl/curl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct km_ash_client {
    CURL *curl;
    char *base_url;
    char *pwd;
    char *endpoint;
    long timeout_ms;
    char error[512];
};

struct km_buffer {
    char *data;
    size_t size;
};

static char *km_strdup(const char *s) {
    if (!s) {
        return NULL;
    }
    size_t n = strlen(s) + 1;
    char *copy = (char *)malloc(n);
    if (copy) {
        memcpy(copy, s, n);
    }
    return copy;
}

static void set_error(km_ash_client *client, const char *message) {
    if (!client) {
        return;
    }
    snprintf(client->error, sizeof(client->error), "%s", message ? message : "unknown error");
}

static void set_errorf(km_ash_client *client, const char *prefix, const char *detail) {
    if (!client) {
        return;
    }
    snprintf(client->error,
             sizeof(client->error),
             "%s%s%s",
             prefix ? prefix : "",
             (prefix && detail) ? ": " : "",
             detail ? detail : "");
}

static bool prefix_is_exact_host(const char *url, const char *prefix) {
    size_t n = strlen(prefix);
    if (strncmp(url, prefix, n) != 0) {
        return false;
    }
    char next = url[n];
    return next == '\0' || next == ':' || next == '/';
}

static bool is_loopback_url(const char *url) {
    if (!url) {
        return false;
    }
    return prefix_is_exact_host(url, "http://127.0.0.1") ||
           prefix_is_exact_host(url, "http://localhost") ||
           prefix_is_exact_host(url, "http://[::1]") ||
           prefix_is_exact_host(url, "https://127.0.0.1") ||
           prefix_is_exact_host(url, "https://localhost") ||
           prefix_is_exact_host(url, "https://[::1]");
}

static char *make_endpoint(const char *base_url) {
    static const char suffix[] = "/KoLmafia/jsonApi";
    size_t n = strlen(base_url);
    bool trailing = n > 0 && base_url[n - 1] == '/';
    size_t suffix_offset = trailing ? 1 : 0;
    size_t total = n + strlen(suffix) - suffix_offset + 1;
    char *out = (char *)malloc(total);
    if (!out) {
        return NULL;
    }
    snprintf(out, total, "%s%s", base_url, suffix + suffix_offset);
    return out;
}

static size_t write_callback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t incoming = size * nmemb;
    struct km_buffer *buffer = (struct km_buffer *)userp;
    char *grown = (char *)realloc(buffer->data, buffer->size + incoming + 1);
    if (!grown) {
        return 0;
    }
    buffer->data = grown;
    memcpy(buffer->data + buffer->size, contents, incoming);
    buffer->size += incoming;
    buffer->data[buffer->size] = '\0';
    return incoming;
}

km_ash_client *km_ash_client_new(const char *base_url, const char *pwd) {
    return km_ash_client_new_ex(base_url, pwd, false);
}

km_ash_client *km_ash_client_new_ex(const char *base_url,
                                    const char *pwd,
                                    bool allow_non_loopback) {
    const char *resolved_base = base_url ? base_url : KM_ASH_DEFAULT_BASE_URL;
    if (!pwd || pwd[0] == '\0') {
        return NULL;
    }
    if (!allow_non_loopback && !is_loopback_url(resolved_base)) {
        return NULL;
    }

    static bool curl_global_ready = false;
    if (!curl_global_ready) {
        if (curl_global_init(CURL_GLOBAL_DEFAULT) != CURLE_OK) {
            return NULL;
        }
        curl_global_ready = true;
    }

    km_ash_client *client = (km_ash_client *)calloc(1, sizeof(*client));
    if (!client) {
        return NULL;
    }

    client->curl = curl_easy_init();
    client->base_url = km_strdup(resolved_base);
    client->pwd = km_strdup(pwd);
    client->endpoint = make_endpoint(resolved_base);
    client->timeout_ms = 15000;

    if (!client->curl || !client->base_url || !client->pwd || !client->endpoint) {
        km_ash_client_free(client);
        return NULL;
    }

    client->error[0] = '\0';
    return client;
}

void km_ash_client_free(km_ash_client *client) {
    if (!client) {
        return;
    }
    if (client->curl) {
        curl_easy_cleanup(client->curl);
    }
    free(client->base_url);
    free(client->pwd);
    free(client->endpoint);
    free(client);
}

void km_ash_client_set_timeout_ms(km_ash_client *client, long timeout_ms) {
    if (client && timeout_ms > 0) {
        client->timeout_ms = timeout_ms;
    }
}

const char *km_ash_last_error(const km_ash_client *client) {
    return client ? client->error : "client is NULL";
}

void km_ash_free(void *ptr) {
    free(ptr);
}

char *km_ash_name_to_js(const char *ash_name) {
    if (!ash_name) {
        return NULL;
    }
    size_t n = strlen(ash_name);
    char *out = (char *)malloc(n + 1);
    if (!out) {
        return NULL;
    }

    size_t w = 0;
    bool uppercase_next = false;
    for (size_t i = 0; i < n; ++i) {
        unsigned char c = (unsigned char)ash_name[i];
        if (c == '_') {
            uppercase_next = true;
            continue;
        }
        if (uppercase_next) {
            out[w++] = (char)toupper(c);
            uppercase_next = false;
        } else {
            out[w++] = (char)c;
        }
    }
    out[w] = '\0';
    return out;
}

struct json_object *km_ash_enum_string(const char *object_type,
                                       const char *identifier) {
    if (!object_type || !identifier) {
        return NULL;
    }
    struct json_object *obj = json_object_new_object();
    if (!obj) {
        return NULL;
    }
    json_object_object_add(obj, "objectType", json_object_new_string(object_type));
    json_object_object_add(obj, "identifierString", json_object_new_string(identifier));
    return obj;
}

struct json_object *km_ash_enum_number(const char *object_type,
                                       int64_t identifier) {
    if (!object_type) {
        return NULL;
    }
    struct json_object *obj = json_object_new_object();
    if (!obj) {
        return NULL;
    }
    json_object_object_add(obj, "objectType", json_object_new_string(object_type));
    json_object_object_add(obj, "identifierNumber", json_object_new_int64(identifier));
    return obj;
}

#define ENUM_STRING_HELPER(fn, type_name) \
    struct json_object *fn(const char *name) { return km_ash_enum_string(type_name, name); }

ENUM_STRING_HELPER(km_ash_item, "Item")
ENUM_STRING_HELPER(km_ash_skill, "Skill")
ENUM_STRING_HELPER(km_ash_effect, "Effect")
ENUM_STRING_HELPER(km_ash_familiar, "Familiar")
ENUM_STRING_HELPER(km_ash_location, "Location")
ENUM_STRING_HELPER(km_ash_monster, "Monster")
ENUM_STRING_HELPER(km_ash_path, "Path")
ENUM_STRING_HELPER(km_ash_class, "Class")
ENUM_STRING_HELPER(km_ash_stat, "Stat")
ENUM_STRING_HELPER(km_ash_slot, "Slot")

struct json_object *km_ash_item_id(int64_t id) {
    return km_ash_enum_number("Item", id);
}

struct json_object *km_ash_request_new(void) {
    return json_object_new_object();
}

int km_ash_request_add_property(struct json_object *request,
                                const char *property_name) {
    if (!request || !property_name) {
        return -1;
    }

    struct json_object *properties = NULL;
    if (!json_object_object_get_ex(request, "properties", &properties)) {
        properties = json_object_new_array();
        if (!properties) {
            return -1;
        }
        json_object_object_add(request, "properties", properties);
    }
    if (!json_object_is_type(properties, json_type_array)) {
        return -1;
    }
    return json_object_array_add(properties, json_object_new_string(property_name));
}

int km_ash_request_add_call(struct json_object *request,
                            const char *ash_function_name,
                            struct json_object *args_array) {
    if (!request || !ash_function_name) {
        return -1;
    }
    if (args_array && !json_object_is_type(args_array, json_type_array)) {
        return -1;
    }

    struct json_object *functions = NULL;
    if (!json_object_object_get_ex(request, "functions", &functions)) {
        functions = json_object_new_array();
        if (!functions) {
            return -1;
        }
        json_object_object_add(request, "functions", functions);
    }
    if (!json_object_is_type(functions, json_type_array)) {
        return -1;
    }

    char *js_name = km_ash_name_to_js(ash_function_name);
    if (!js_name) {
        return -1;
    }

    struct json_object *call = json_object_new_object();
    if (!call) {
        free(js_name);
        return -1;
    }
    json_object_object_add(call, "name", json_object_new_string(js_name));
    free(js_name);

    if (args_array) {
        json_object_object_add(call, "args", json_object_get(args_array));
    } else {
        json_object_object_add(call, "args", json_object_new_array());
    }

    if (json_object_array_add(functions, call) != 0) {
        json_object_put(call);
        return -1;
    }
    return 0;
}

static int post_json_api(km_ash_client *client,
                         struct json_object *request,
                         struct json_object **response_out) {
    if (!client || !request || !response_out) {
        return -1;
    }
    *response_out = NULL;
    client->error[0] = '\0';

    const char *request_json = json_object_to_json_string_ext(request, JSON_C_TO_STRING_PLAIN);
    char *escaped_body = curl_easy_escape(client->curl, request_json, 0);
    char *escaped_pwd = curl_easy_escape(client->curl, client->pwd, 0);
    if (!escaped_body || !escaped_pwd) {
        if (escaped_body) curl_free(escaped_body);
        if (escaped_pwd) curl_free(escaped_pwd);
        set_error(client, "failed to URL-encode request");
        return -1;
    }

    size_t form_len = strlen("body=&pwd=") + strlen(escaped_body) + strlen(escaped_pwd) + 1;
    char *form = (char *)malloc(form_len);
    if (!form) {
        curl_free(escaped_body);
        curl_free(escaped_pwd);
        set_error(client, "out of memory");
        return -1;
    }
    snprintf(form, form_len, "body=%s&pwd=%s", escaped_body, escaped_pwd);
    curl_free(escaped_body);
    curl_free(escaped_pwd);

    struct km_buffer buffer = {0};
    struct curl_slist *headers = NULL;
    headers = curl_slist_append(headers, "Content-Type: application/x-www-form-urlencoded");

    curl_easy_reset(client->curl);
    curl_easy_setopt(client->curl, CURLOPT_URL, client->endpoint);
    curl_easy_setopt(client->curl, CURLOPT_POST, 1L);
    curl_easy_setopt(client->curl, CURLOPT_POSTFIELDS, form);
    curl_easy_setopt(client->curl, CURLOPT_POSTFIELDSIZE, (long)strlen(form));
    curl_easy_setopt(client->curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(client->curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(client->curl, CURLOPT_WRITEDATA, &buffer);
    curl_easy_setopt(client->curl, CURLOPT_TIMEOUT_MS, client->timeout_ms);
    curl_easy_setopt(client->curl, CURLOPT_NOSIGNAL, 1L);

    CURLcode code = curl_easy_perform(client->curl);
    long http_code = 0;
    curl_easy_getinfo(client->curl, CURLINFO_RESPONSE_CODE, &http_code);

    curl_slist_free_all(headers);
    free(form);

    if (code != CURLE_OK) {
        set_errorf(client, "HTTP transport failed", curl_easy_strerror(code));
        free(buffer.data);
        return -1;
    }
    if (http_code < 200 || http_code >= 300) {
        char detail[128];
        snprintf(detail, sizeof(detail), "HTTP %ld", http_code);
        set_error(client, detail);
        free(buffer.data);
        return -1;
    }
    if (!buffer.data) {
        set_error(client, "empty JSON API response");
        return -1;
    }

    enum json_tokener_error parse_error = json_tokener_success;
    struct json_object *response = json_tokener_parse_verbose(buffer.data, &parse_error);
    free(buffer.data);
    if (!response) {
        set_errorf(client, "invalid JSON response", json_tokener_error_desc(parse_error));
        return -1;
    }

    struct json_object *api_error = NULL;
    if (json_object_object_get_ex(response, "error", &api_error)) {
        set_errorf(client, "KoLmafia JSON API error", json_object_get_string(api_error));
        json_object_put(response);
        return -1;
    }

    *response_out = response;
    return 0;
}

int km_ash_request_execute(km_ash_client *client,
                           struct json_object *request,
                           struct json_object **response_out) {
    return post_json_api(client, request, response_out);
}

static int extract_first(struct json_object *response,
                         const char *key,
                         struct json_object **result_out) {
    struct json_object *array = NULL;
    if (!json_object_object_get_ex(response, key, &array) ||
        !json_object_is_type(array, json_type_array) ||
        json_object_array_length(array) < 1) {
        return -1;
    }
    struct json_object *value = json_object_array_get_idx(array, 0);
    /* json-c represents a JSON null array element as a NULL pointer. */
    *result_out = value ? json_object_get(value) : NULL;
    return 0;
}

int km_ash_call_json(km_ash_client *client,
                     const char *ash_function_name,
                     struct json_object *args_array,
                     struct json_object **result_out) {
    if (!result_out) {
        return -1;
    }
    *result_out = NULL;

    struct json_object *request = km_ash_request_new();
    if (!request) {
        set_error(client, "out of memory");
        return -1;
    }
    if (km_ash_request_add_call(request, ash_function_name, args_array) != 0) {
        json_object_put(request);
        set_error(client, "failed to build function request");
        return -1;
    }

    struct json_object *response = NULL;
    int rc = post_json_api(client, request, &response);
    json_object_put(request);
    if (rc != 0) {
        return rc;
    }

    rc = extract_first(response, "functions", result_out);
    json_object_put(response);
    if (rc != 0) {
        set_error(client, "response missing function result");
    }
    return rc;
}

int km_ash_property_json(km_ash_client *client,
                         const char *property_name,
                         struct json_object **result_out) {
    if (!result_out) {
        return -1;
    }
    *result_out = NULL;

    struct json_object *request = km_ash_request_new();
    if (!request) {
        set_error(client, "out of memory");
        return -1;
    }
    if (km_ash_request_add_property(request, property_name) != 0) {
        json_object_put(request);
        set_error(client, "failed to build property request");
        return -1;
    }

    struct json_object *response = NULL;
    int rc = post_json_api(client, request, &response);
    json_object_put(request);
    if (rc != 0) {
        return rc;
    }

    rc = extract_first(response, "properties", result_out);
    json_object_put(response);
    if (rc != 0) {
        set_error(client, "response missing property result");
    }
    return rc;
}

int km_ash_call_bool(km_ash_client *client,
                     const char *ash_function_name,
                     struct json_object *args_array,
                     bool *value_out) {
    if (!value_out) return -1;
    struct json_object *value = NULL;
    int rc = km_ash_call_json(client, ash_function_name, args_array, &value);
    if (rc != 0) return rc;
    if (!json_object_is_type(value, json_type_boolean)) {
        json_object_put(value);
        set_error(client, "function result is not boolean");
        return -1;
    }
    *value_out = json_object_get_boolean(value) != 0;
    json_object_put(value);
    return 0;
}

int km_ash_call_int64(km_ash_client *client,
                      const char *ash_function_name,
                      struct json_object *args_array,
                      int64_t *value_out) {
    if (!value_out) return -1;
    struct json_object *value = NULL;
    int rc = km_ash_call_json(client, ash_function_name, args_array, &value);
    if (rc != 0) return rc;
    if (!json_object_is_type(value, json_type_int)) {
        json_object_put(value);
        set_error(client, "function result is not integer");
        return -1;
    }
    *value_out = json_object_get_int64(value);
    json_object_put(value);
    return 0;
}

int km_ash_call_double(km_ash_client *client,
                       const char *ash_function_name,
                       struct json_object *args_array,
                       double *value_out) {
    if (!value_out) return -1;
    struct json_object *value = NULL;
    int rc = km_ash_call_json(client, ash_function_name, args_array, &value);
    if (rc != 0) return rc;
    enum json_type type = json_object_get_type(value);
    if (type != json_type_double && type != json_type_int) {
        json_object_put(value);
        set_error(client, "function result is not numeric");
        return -1;
    }
    *value_out = json_object_get_double(value);
    json_object_put(value);
    return 0;
}

int km_ash_call_string(km_ash_client *client,
                       const char *ash_function_name,
                       struct json_object *args_array,
                       char **value_out) {
    if (!value_out) return -1;
    *value_out = NULL;
    struct json_object *value = NULL;
    int rc = km_ash_call_json(client, ash_function_name, args_array, &value);
    if (rc != 0) return rc;
    if (!json_object_is_type(value, json_type_string)) {
        json_object_put(value);
        set_error(client, "function result is not string");
        return -1;
    }
    *value_out = km_strdup(json_object_get_string(value));
    json_object_put(value);
    if (!*value_out) {
        set_error(client, "out of memory");
        return -1;
    }
    return 0;
}

int km_ash_my_name(km_ash_client *client, char **name_out) {
    return km_ash_call_string(client, "my_name", NULL, name_out);
}

int km_ash_my_level(km_ash_client *client, int64_t *level_out) {
    return km_ash_call_int64(client, "my_level", NULL, level_out);
}

int km_ash_my_meat(km_ash_client *client, int64_t *meat_out) {
    return km_ash_call_int64(client, "my_meat", NULL, meat_out);
}

int km_ash_available_amount(km_ash_client *client,
                            struct json_object *item_placeholder,
                            int64_t *amount_out) {
    if (!item_placeholder) {
        set_error(client, "item placeholder is NULL");
        return -1;
    }
    struct json_object *args = json_object_new_array();
    if (!args) return -1;
    json_object_array_add(args, json_object_get(item_placeholder));
    int rc = km_ash_call_int64(client, "available_amount", args, amount_out);
    json_object_put(args);
    return rc;
}

int km_ash_get_property(km_ash_client *client,
                        const char *property_name,
                        char **value_out) {
    struct json_object *args = json_object_new_array();
    if (!args) return -1;
    json_object_array_add(args, json_object_new_string(property_name));
    int rc = km_ash_call_string(client, "get_property", args, value_out);
    json_object_put(args);
    return rc;
}

int km_ash_set_property(km_ash_client *client,
                        const char *property_name,
                        const char *value) {
    if (!property_name || !value) return -1;
    struct json_object *args = json_object_new_array();
    if (!args) return -1;
    json_object_array_add(args, json_object_new_string(property_name));
    json_object_array_add(args, json_object_new_string(value));
    struct json_object *result = NULL;
    int rc = km_ash_call_json(client, "set_property", args, &result);
    json_object_put(args);
    if (result) json_object_put(result);
    return rc;
}

int km_ash_cli_execute(km_ash_client *client,
                       const char *command,
                       bool *success_out) {
    if (!command || !success_out) return -1;
    struct json_object *args = json_object_new_array();
    if (!args) return -1;
    json_object_array_add(args, json_object_new_string(command));
    int rc = km_ash_call_bool(client, "cli_execute", args, success_out);
    json_object_put(args);
    return rc;
}

int km_ash_visit_url(km_ash_client *client,
                     const char *url,
                     char **response_text_out) {
    if (!url || !response_text_out) return -1;
    struct json_object *args = json_object_new_array();
    if (!args) return -1;
    json_object_array_add(args, json_object_new_string(url));
    int rc = km_ash_call_string(client, "visit_url", args, response_text_out);
    json_object_put(args);
    return rc;
}
