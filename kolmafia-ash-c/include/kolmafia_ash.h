#ifndef KOLMAFIA_ASH_H
#define KOLMAFIA_ASH_H

#include <stdbool.h>
#include <stdint.h>

#include <json-c/json.h>

#ifdef __cplusplus
extern "C" {
#endif

#define KM_ASH_DEFAULT_BASE_URL "http://127.0.0.1:60080"

typedef struct km_ash_client km_ash_client;

/*
 * Client lifecycle.
 *
 * km_ash_client_new() is loopback-only by default. Use _new_ex(..., true)
 * only when you intentionally want to connect to a non-loopback endpoint.
 */
km_ash_client *km_ash_client_new(const char *base_url, const char *pwd);
km_ash_client *km_ash_client_new_ex(const char *base_url,
                                    const char *pwd,
                                    bool allow_non_loopback);
void km_ash_client_free(km_ash_client *client);
void km_ash_client_set_timeout_ms(km_ash_client *client, long timeout_ms);
const char *km_ash_last_error(const km_ash_client *client);

/* Free strings returned by this library. */
void km_ash_free(void *ptr);

/* Convert ASH snake_case names to KoLmafia JSON API lowerCamelCase. */
char *km_ash_name_to_js(const char *ash_name);

/* KoL enumerated-value placeholders. Returned object is owned by caller. */
struct json_object *km_ash_enum_string(const char *object_type,
                                       const char *identifier);
struct json_object *km_ash_enum_number(const char *object_type,
                                       int64_t identifier);

/* Common enum helpers. Returned object is owned by caller. */
struct json_object *km_ash_item(const char *name);
struct json_object *km_ash_item_id(int64_t id);
struct json_object *km_ash_skill(const char *name);
struct json_object *km_ash_effect(const char *name);
struct json_object *km_ash_familiar(const char *name);
struct json_object *km_ash_location(const char *name);
struct json_object *km_ash_monster(const char *name);
struct json_object *km_ash_path(const char *name);
struct json_object *km_ash_class(const char *name);
struct json_object *km_ash_stat(const char *name);
struct json_object *km_ash_slot(const char *name);

/*
 * Request builder for batched property reads + ASH function calls.
 * add_call borrows args and takes its own json-c reference; caller may json_object_put(args).
 */
struct json_object *km_ash_request_new(void);
int km_ash_request_add_property(struct json_object *request,
                                const char *property_name);
int km_ash_request_add_call(struct json_object *request,
                            const char *ash_function_name,
                            struct json_object *args_array);

/*
 * Execute a prepared request against /KoLmafia/jsonApi.
 * On success, *response_out is a new json-c object owned by caller.
 */
int km_ash_request_execute(km_ash_client *client,
                           struct json_object *request,
                           struct json_object **response_out);

/* Raw one-shot calls. Returned JSON values are owned by caller. */
int km_ash_call_json(km_ash_client *client,
                     const char *ash_function_name,
                     struct json_object *args_array,
                     struct json_object **result_out);
int km_ash_property_json(km_ash_client *client,
                         const char *property_name,
                         struct json_object **result_out);

/* Typed one-shot helpers. */
int km_ash_call_bool(km_ash_client *client,
                     const char *ash_function_name,
                     struct json_object *args_array,
                     bool *value_out);
int km_ash_call_int64(km_ash_client *client,
                      const char *ash_function_name,
                      struct json_object *args_array,
                      int64_t *value_out);
int km_ash_call_double(km_ash_client *client,
                       const char *ash_function_name,
                       struct json_object *args_array,
                       double *value_out);
int km_ash_call_string(km_ash_client *client,
                       const char *ash_function_name,
                       struct json_object *args_array,
                       char **value_out);

/* A few ergonomic wrappers. */
int km_ash_my_name(km_ash_client *client, char **name_out);
int km_ash_my_level(km_ash_client *client, int64_t *level_out);
int km_ash_my_meat(km_ash_client *client, int64_t *meat_out);
int km_ash_available_amount(km_ash_client *client,
                            struct json_object *item_placeholder,
                            int64_t *amount_out);
int km_ash_get_property(km_ash_client *client,
                        const char *property_name,
                        char **value_out);

/*
 * Explicit potentially-mutating surfaces. These are intentionally named and
 * not mixed into the read-only convenience API.
 */
int km_ash_set_property(km_ash_client *client,
                        const char *property_name,
                        const char *value);
int km_ash_cli_execute(km_ash_client *client,
                       const char *command,
                       bool *success_out);
int km_ash_visit_url(km_ash_client *client,
                     const char *url,
                     char **response_text_out);

#ifdef __cplusplus
}
#endif

#endif
