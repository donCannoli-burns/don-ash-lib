use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq)]
pub struct FunctionCall {
    pub name: String,
    #[serde(default)]
    pub args: Vec<Value>,
}

#[derive(Clone, Debug, Default, Serialize, Deserialize, PartialEq)]
pub struct ApiRequest {
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub properties: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub functions: Vec<FunctionCall>,
}

#[derive(Clone, Debug, Default)]
pub struct AshBatch {
    request: ApiRequest,
}

impl AshBatch {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn property(mut self, name: impl Into<String>) -> Self {
        self.request.properties.push(name.into());
        self
    }

    pub fn call(
        mut self,
        ash_name: impl AsRef<str>,
        args: impl IntoIterator<Item = Value>,
    ) -> Self {
        self.request.functions.push(FunctionCall {
            name: ash_name_to_js(ash_name.as_ref()),
            args: args.into_iter().collect(),
        });
        self
    }

    pub fn push_property(&mut self, name: impl Into<String>) {
        self.request.properties.push(name.into());
    }

    pub fn push_call(
        &mut self,
        ash_name: impl AsRef<str>,
        args: impl IntoIterator<Item = Value>,
    ) {
        self.request.functions.push(FunctionCall {
            name: ash_name_to_js(ash_name.as_ref()),
            args: args.into_iter().collect(),
        });
    }

    pub fn as_request(&self) -> &ApiRequest {
        &self.request
    }

    pub fn into_request(self) -> ApiRequest {
        self.request
    }
}

/// Convert the spelling users see in ASH/ashref to the JavaScript-style name
/// accepted by /KoLmafia/jsonApi.
pub fn ash_name_to_js(name: &str) -> String {
    let mut output = String::with_capacity(name.len());
    let mut uppercase_next = false;

    for ch in name.chars() {
        if ch == '_' {
            uppercase_next = true;
            continue;
        }

        if uppercase_next {
            output.extend(ch.to_uppercase());
            uppercase_next = false;
        } else {
            output.push(ch);
        }
    }

    output
}

pub fn enum_string(object_type: &str, identifier: &str) -> Value {
    json!({
        "objectType": object_type,
        "identifierString": identifier,
    })
}

pub fn enum_id(object_type: &str, identifier: i64) -> Value {
    json!({
        "objectType": object_type,
        "identifierNumber": identifier,
    })
}

macro_rules! enum_helpers {
    ($(($string_fn:ident, $id_fn:ident, $kind:literal)),+ $(,)?) => {
        $(
            pub fn $string_fn(identifier: &str) -> Value {
                enum_string($kind, identifier)
            }

            pub fn $id_fn(identifier: i64) -> Value {
                enum_id($kind, identifier)
            }
        )+
    };
}

enum_helpers!(
    (item, item_id, "Item"),
    (skill, skill_id, "Skill"),
    (effect, effect_id, "Effect"),
    (familiar, familiar_id, "Familiar"),
    (location, location_id, "Location"),
    (monster, monster_id, "Monster"),
    (path, path_id, "Path"),
    (class, class_id, "Class"),
    (stat, stat_id, "Stat"),
    (slot, slot_id, "Slot"),
    (coinmaster, coinmaster_id, "Coinmaster"),
    (thrall, thrall_id, "Thrall"),
);

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn converts_ash_names_to_js_names() {
        assert_eq!(ash_name_to_js("my_name"), "myName");
        assert_eq!(ash_name_to_js("available_amount"), "availableAmount");
        assert_eq!(ash_name_to_js("visit_url"), "visitUrl");
        assert_eq!(ash_name_to_js("alreadyCamel"), "alreadyCamel");
    }

    #[test]
    fn creates_enumerated_placeholders() {
        assert_eq!(
            item("seal-clubbing club"),
            json!({"objectType":"Item","identifierString":"seal-clubbing club"})
        );
        assert_eq!(
            familiar_id(7),
            json!({"objectType":"Familiar","identifierNumber":7})
        );
    }

    #[test]
    fn batch_translates_function_names() {
        let batch = AshBatch::new().property("kingLiberated").call(
            "available_amount",
            [item("seal-clubbing club")],
        );
        let request = batch.as_request();
        assert_eq!(request.properties, vec!["kingLiberated"]);
        assert_eq!(request.functions[0].name, "availableAmount");
    }
}
