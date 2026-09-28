use crate::error::{AshError, Result};
use crate::types::{ash_name_to_js, ApiRequest, AshBatch, FunctionCall};
use reqwest::blocking::Client;
use reqwest::Url;
use serde::de::DeserializeOwned;
use serde_json::{json, Value};
use std::time::Duration;

#[derive(Clone)]
pub struct AshClient {
    base_url: Url,
    pwd: String,
    http: Client,
}

impl AshClient {
    pub fn new(base_url: &str, pwd: impl Into<String>) -> Result<Self> {
        Self::with_remote_policy(base_url, pwd, false)
    }

    /// `allow_non_loopback` should normally remain false. For Android device
    /// development, prefer `adb reverse tcp:60080 tcp:60080` and keep the
    /// endpoint at http://127.0.0.1:60080.
    pub fn with_remote_policy(
        base_url: &str,
        pwd: impl Into<String>,
        allow_non_loopback: bool,
    ) -> Result<Self> {
        let pwd = pwd.into();
        if pwd.is_empty() {
            return Err(AshError::EmptyPasswordHash);
        }

        let mut base_url = Url::parse(base_url)
            .map_err(|error| AshError::InvalidBaseUrl(error.to_string()))?;

        let host = base_url
            .host_str()
            .ok_or_else(|| AshError::InvalidBaseUrl("URL has no host".into()))?;

        if !allow_non_loopback && !is_loopback_host(host) {
            return Err(AshError::NonLoopbackRejected(host.to_string()));
        }

        if base_url.scheme() != "http" && base_url.scheme() != "https" {
            return Err(AshError::InvalidBaseUrl(format!(
                "unsupported URL scheme: {}",
                base_url.scheme()
            )));
        }

        // Make joining `KoLmafia/jsonApi` deterministic regardless of whether
        // the caller supplied a trailing slash.
        if !base_url.path().ends_with('/') {
            let mut path = base_url.path().to_string();
            path.push('/');
            base_url.set_path(&path);
        }

        let http = Client::builder()
            .connect_timeout(Duration::from_secs(5))
            .timeout(Duration::from_secs(30))
            .build()?;

        Ok(Self {
            base_url,
            pwd,
            http,
        })
    }

    pub fn loopback(pwd: impl Into<String>) -> Result<Self> {
        Self::new("http://127.0.0.1:60080", pwd)
    }

    pub fn base_url(&self) -> &Url {
        &self.base_url
    }

    pub fn execute(&self, request: &ApiRequest) -> Result<Value> {
        let endpoint = self
            .base_url
            .join("KoLmafia/jsonApi")
            .map_err(|error| AshError::InvalidBaseUrl(error.to_string()))?;
        let body = serde_json::to_string(request)?;

        let response = self
            .http
            .post(endpoint)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .form(&[("body", body.as_str()), ("pwd", self.pwd.as_str())])
            .send()?;

        let status = response.status();
        let text = response.text()?;

        if !status.is_success() {
            return Err(AshError::HttpStatus {
                status: status.as_u16(),
                body: text,
            });
        }

        let value: Value = serde_json::from_str(&text)?;
        if let Some(message) = value.get("error").and_then(Value::as_str) {
            return Err(AshError::Api(message.to_string()));
        }

        Ok(value)
    }

    pub fn execute_batch(&self, batch: &AshBatch) -> Result<Value> {
        self.execute(batch.as_request())
    }

    pub fn call_value(&self, ash_name: &str, args: Vec<Value>) -> Result<Value> {
        let request = ApiRequest {
            properties: Vec::new(),
            functions: vec![FunctionCall {
                name: ash_name_to_js(ash_name),
                args,
            }],
        };

        let response = self.execute(&request)?;
        response
            .get("functions")
            .and_then(Value::as_array)
            .and_then(|values| values.first())
            .cloned()
            .ok_or_else(|| {
                AshError::InvalidResponse(
                    "response did not contain the first requested function result".into(),
                )
            })
    }

    pub fn call<T: DeserializeOwned>(&self, ash_name: &str, args: Vec<Value>) -> Result<T> {
        let value = self.call_value(ash_name, args)?;
        Ok(serde_json::from_value(value)?)
    }

    pub fn property_value(&self, name: &str) -> Result<Value> {
        let request = ApiRequest {
            properties: vec![name.to_string()],
            functions: Vec::new(),
        };
        let response = self.execute(&request)?;
        response
            .get("properties")
            .and_then(Value::as_array)
            .and_then(|values| values.first())
            .cloned()
            .ok_or_else(|| {
                AshError::InvalidResponse(
                    "response did not contain the first requested property result".into(),
                )
            })
    }

    pub fn property<T: DeserializeOwned>(&self, name: &str) -> Result<T> {
        Ok(serde_json::from_value(self.property_value(name)?)?)
    }

    // Common read-only conveniences.
    pub fn my_name(&self) -> Result<String> {
        self.call("my_name", vec![])
    }

    pub fn my_level(&self) -> Result<i64> {
        self.call("my_level", vec![])
    }

    pub fn my_adventures(&self) -> Result<i64> {
        self.call("my_adventures", vec![])
    }

    pub fn my_meat(&self) -> Result<i64> {
        self.call("my_meat", vec![])
    }

    pub fn available_amount(&self, item: Value) -> Result<i64> {
        self.call("available_amount", vec![item])
    }

    pub fn get_property(&self, name: &str) -> Result<String> {
        self.call("get_property", vec![json!(name)])
    }

    // Explicitly effectful surfaces. Keep policy/confirmation gates above
    // these methods when embedding this crate into an agent-controlled app.
    pub fn set_property(&self, name: &str, value: &str) -> Result<Value> {
        self.call_value("set_property", vec![json!(name), json!(value)])
    }

    pub fn cli_execute(&self, command: &str) -> Result<bool> {
        self.call("cli_execute", vec![json!(command)])
    }

    pub fn visit_url(&self, url: &str) -> Result<String> {
        self.call("visit_url", vec![json!(url)])
    }
}

fn is_loopback_host(host: &str) -> bool {
    if host.eq_ignore_ascii_case("localhost") || host == "::1" {
        return true;
    }

    host.parse::<std::net::IpAddr>()
        .map(|address| address.is_loopback())
        .unwrap_or(false)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn loopback_is_accepted() {
        assert!(AshClient::new("http://127.0.0.1:60080", "hash").is_ok());
        assert!(AshClient::new("http://localhost:60080", "hash").is_ok());
        assert!(AshClient::new("http://[::1]:60080", "hash").is_ok());
    }

    #[test]
    fn remote_is_rejected_by_default() {
        let error = AshClient::new("http://192.168.1.20:60080", "hash").unwrap_err();
        assert!(matches!(error, AshError::NonLoopbackRejected(_)));
    }

    #[test]
    fn remote_can_be_explicitly_enabled() {
        assert!(AshClient::with_remote_policy(
            "http://192.168.1.20:60080",
            "hash",
            true
        )
        .is_ok());
    }
}
