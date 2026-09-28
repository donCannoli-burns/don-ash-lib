#include "kolmafia_ash.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    char *name = km_ash_name_to_js("available_amount");
    assert(name != NULL);
    assert(strcmp(name, "availableAmount") == 0);
    km_ash_free(name);

    name = km_ash_name_to_js("my_adventures");
    assert(strcmp(name, "myAdventures") == 0);
    km_ash_free(name);

    name = km_ash_name_to_js("identity");
    assert(strcmp(name, "identity") == 0);
    km_ash_free(name);

    struct json_object *item = km_ash_item("seal-clubbing club");
    assert(item != NULL);
    struct json_object *field = NULL;
    assert(json_object_object_get_ex(item, "objectType", &field));
    assert(strcmp(json_object_get_string(field), "Item") == 0);
    assert(json_object_object_get_ex(item, "identifierString", &field));
    assert(strcmp(json_object_get_string(field), "seal-clubbing club") == 0);

    struct json_object *args = json_object_new_array();
    json_object_array_add(args, json_object_get(item));
    struct json_object *request = km_ash_request_new();
    assert(km_ash_request_add_property(request, "kingLiberated") == 0);
    assert(km_ash_request_add_call(request, "available_amount", args) == 0);

    const char *wire = json_object_to_json_string_ext(request, JSON_C_TO_STRING_PLAIN);
    assert(strstr(wire, "availableAmount") != NULL);
    assert(strstr(wire, "kingLiberated") != NULL);
    assert(strstr(wire, "identifierString") != NULL);

    json_object_put(request);
    json_object_put(args);
    json_object_put(item);

    /* Loopback default must not accept lookalike hostnames. */
    km_ash_client *blocked = km_ash_client_new("http://localhost.evil.example:60080", "x");
    assert(blocked == NULL);
    km_ash_client *loopback = km_ash_client_new("http://localhost:60080", "x");
    assert(loopback != NULL);
    km_ash_client_free(loopback);

    puts("unit tests: PASS");
    return 0;
}
