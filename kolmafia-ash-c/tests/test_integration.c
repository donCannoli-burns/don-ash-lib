#include "kolmafia_ash.h"

#include <assert.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    km_ash_client *client = km_ash_client_new("http://127.0.0.1:61880", "test-pwd");
    assert(client != NULL);

    char *name = NULL;
    int64_t level = 0;
    int64_t amount = 0;

    assert(km_ash_my_name(client, &name) == 0);
    assert(strcmp(name, "Fake Cannoli") == 0);
    km_ash_free(name);

    assert(km_ash_my_level(client, &level) == 0);
    assert(level == 13);

    /* Void-returning ASH functions are represented as JSON null and still succeed. */
    assert(km_ash_set_property(client, "fakeProperty", "fakeValue") == 0);

    struct json_object *item = km_ash_item("seal-clubbing club");
    assert(km_ash_available_amount(client, item, &amount) == 0);
    assert(amount == 2);
    json_object_put(item);

    struct json_object *request = km_ash_request_new();
    assert(km_ash_request_add_property(request, "kingLiberated") == 0);
    assert(km_ash_request_add_call(request, "my_meat", NULL) == 0);
    struct json_object *response = NULL;
    assert(km_ash_request_execute(client, request, &response) == 0);

    struct json_object *properties = NULL;
    struct json_object *functions = NULL;
    assert(json_object_object_get_ex(response, "properties", &properties));
    assert(json_object_get_boolean(json_object_array_get_idx(properties, 0)) == 1);
    assert(json_object_object_get_ex(response, "functions", &functions));
    assert(json_object_get_int64(json_object_array_get_idx(functions, 0)) == 123456);

    json_object_put(response);
    json_object_put(request);
    km_ash_client_free(client);

    puts("integration tests: PASS");
    return 0;
}
