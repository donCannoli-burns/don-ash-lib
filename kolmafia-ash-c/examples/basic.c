#include "kolmafia_ash.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

static void die(km_ash_client *client, const char *what) {
    fprintf(stderr, "%s: %s\n", what, km_ash_last_error(client));
    exit(1);
}

int main(void) {
    const char *pwd = getenv("KOLMAFIA_PWD");
    if (!pwd || !*pwd) {
        fprintf(stderr, "Set KOLMAFIA_PWD to your active KoLmafia pwd hash.\n");
        return 2;
    }

    km_ash_client *mafia = km_ash_client_new(NULL, pwd);
    if (!mafia) {
        fprintf(stderr, "Could not create KoLmafia ASH client.\n");
        return 1;
    }

    char *name = NULL;
    int64_t level = 0;
    int64_t meat = 0;
    if (km_ash_my_name(mafia, &name) != 0) die(mafia, "my_name");
    if (km_ash_my_level(mafia, &level) != 0) die(mafia, "my_level");
    if (km_ash_my_meat(mafia, &meat) != 0) die(mafia, "my_meat");

    printf("%s — level %" PRId64 ", %" PRId64 " Meat\n", name, level, meat);
    km_ash_free(name);

    struct json_object *item = km_ash_item("seal-clubbing club");
    int64_t amount = 0;
    if (!item || km_ash_available_amount(mafia, item, &amount) != 0) {
        if (item) json_object_put(item);
        die(mafia, "available_amount");
    }
    printf("seal-clubbing club available_amount = %" PRId64 "\n", amount);
    json_object_put(item);

    /* Batched request: one property + two functions in one HTTP round-trip. */
    struct json_object *request = km_ash_request_new();
    km_ash_request_add_property(request, "kingLiberated");
    km_ash_request_add_call(request, "my_name", NULL);
    km_ash_request_add_call(request, "my_adventures", NULL);

    struct json_object *response = NULL;
    if (km_ash_request_execute(mafia, request, &response) != 0) {
        json_object_put(request);
        die(mafia, "batch");
    }
    printf("batch = %s\n", json_object_to_json_string_ext(response, JSON_C_TO_STRING_PRETTY));
    json_object_put(response);
    json_object_put(request);

    km_ash_client_free(mafia);
    return 0;
}
