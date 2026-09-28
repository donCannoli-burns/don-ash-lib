use kolmafia_ash_android::{ash_name_to_js, item, ApiRequest, AshBatch};
use serde_json::json;

#[test]
fn public_helpers_have_expected_shape() {
    assert_eq!(ash_name_to_js("get_property"), "getProperty");
    assert_eq!(
        item("seal-clubbing club"),
        json!({
            "objectType": "Item",
            "identifierString": "seal-clubbing club"
        })
    );

    let batch = AshBatch::new()
        .property("kingLiberated")
        .call("my_name", std::iter::empty())
        .call("available_amount", [item("seal-clubbing club")]);

    let request: &ApiRequest = batch.as_request();
    assert_eq!(request.functions[0].name, "myName");
    assert_eq!(request.functions[1].name, "availableAmount");
}
