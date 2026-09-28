use crate::{ApiRequest, AshClient};
use jni::errors::ThrowRuntimeExAndDefault;
use jni::objects::{JClass, JString};
use jni::strings::JNIString;
use jni::sys::{jboolean, jlong};
use jni::{Env, EnvUnowned};
use serde_json::Value;
use std::collections::HashMap;
use std::sync::atomic::{AtomicI64, Ordering};
use std::sync::{Arc, Mutex, OnceLock};

static NEXT_HANDLE: AtomicI64 = AtomicI64::new(1);
static CLIENTS: OnceLock<Mutex<HashMap<i64, Arc<AshClient>>>> = OnceLock::new();

fn clients() -> &'static Mutex<HashMap<i64, Arc<AshClient>>> {
    CLIENTS.get_or_init(|| Mutex::new(HashMap::new()))
}

fn get_client(handle: jlong) -> Result<Arc<AshClient>, String> {
    let guard = clients()
        .lock()
        .map_err(|_| "KoLmafia ASH client registry lock poisoned".to_string())?;
    guard
        .get(&handle)
        .cloned()
        .ok_or_else(|| format!("unknown or closed KoLmafia ASH handle: {handle}"))
}

fn throw(env: &mut Env<'_>, class: &str, message: &str) -> jni::errors::Result<()> {
    let class = JNIString::new(class);
    let message = JNIString::new(message);
    env.throw_new(&class, &message)
}

fn throw_and_zero(
    env: &mut Env<'_>,
    class: &str,
    message: impl AsRef<str>,
) -> jni::errors::Result<jlong> {
    throw(env, class, message.as_ref())?;
    Ok(0)
}

fn throw_and_null<'local>(
    env: &mut Env<'local>,
    class: &str,
    message: impl AsRef<str>,
) -> jni::errors::Result<JString<'local>> {
    throw(env, class, message.as_ref())?;
    Ok(JString::null())
}

#[no_mangle]
pub extern "system" fn Java_dev_kolmafia_ash_NativeBridge_nativeCreate<'caller>(
    mut unowned_env: EnvUnowned<'caller>,
    _class: JClass<'caller>,
    base_url: JString<'caller>,
    pwd: JString<'caller>,
    allow_non_loopback: jboolean,
) -> jlong {
    unowned_env
        .with_env(|env| -> jni::errors::Result<jlong> {
            let base_url = base_url.try_to_string(env)?;
            let pwd = pwd.try_to_string(env)?;

            let client = match AshClient::with_remote_policy(
                &base_url,
                pwd,
                allow_non_loopback != 0,
            ) {
                Ok(client) => Arc::new(client),
                Err(error) => {
                    return throw_and_zero(
                        env,
                        "java/lang/IllegalArgumentException",
                        error.to_string(),
                    )
                }
            };

            let handle = NEXT_HANDLE.fetch_add(1, Ordering::Relaxed);
            match clients().lock() {
                Ok(mut guard) => {
                    guard.insert(handle, client);
                    Ok(handle)
                }
                Err(_) => throw_and_zero(
                    env,
                    "java/lang/IllegalStateException",
                    "KoLmafia ASH client registry lock poisoned",
                ),
            }
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

#[no_mangle]
pub extern "system" fn Java_dev_kolmafia_ash_NativeBridge_nativeDestroy<'caller>(
    mut unowned_env: EnvUnowned<'caller>,
    _class: JClass<'caller>,
    handle: jlong,
) {
    unowned_env
        .with_env(|env| -> jni::errors::Result<()> {
            match clients().lock() {
                Ok(mut guard) => {
                    guard.remove(&handle);
                    Ok(())
                }
                Err(_) => throw(
                    env,
                    "java/lang/IllegalStateException",
                    "KoLmafia ASH client registry lock poisoned",
                ),
            }
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

#[no_mangle]
pub extern "system" fn Java_dev_kolmafia_ash_NativeBridge_nativeCallJson<'caller>(
    mut unowned_env: EnvUnowned<'caller>,
    _class: JClass<'caller>,
    handle: jlong,
    ash_name: JString<'caller>,
    args_json: JString<'caller>,
) -> JString<'caller> {
    unowned_env
        .with_env(|env| -> jni::errors::Result<JString<'caller>> {
            let client = match get_client(handle) {
                Ok(client) => client,
                Err(error) => {
                    return throw_and_null(env, "java/lang/IllegalStateException", error)
                }
            };
            let ash_name = ash_name.try_to_string(env)?;
            let args_json = args_json.try_to_string(env)?;
            let args: Vec<Value> = match serde_json::from_str(&args_json) {
                Ok(args) => args,
                Err(error) => {
                    return throw_and_null(
                        env,
                        "java/lang/IllegalArgumentException",
                        error.to_string(),
                    )
                }
            };

            let value = match client.call_value(&ash_name, args) {
                Ok(value) => value,
                Err(error) => {
                    return throw_and_null(env, "java/io/IOException", error.to_string())
                }
            };

            let json = match serde_json::to_string(&value) {
                Ok(json) => json,
                Err(error) => {
                    return throw_and_null(
                        env,
                        "java/lang/IllegalStateException",
                        error.to_string(),
                    )
                }
            };

            JString::from_str(env, json)
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}

#[no_mangle]
pub extern "system" fn Java_dev_kolmafia_ash_NativeBridge_nativeExecuteJson<'caller>(
    mut unowned_env: EnvUnowned<'caller>,
    _class: JClass<'caller>,
    handle: jlong,
    request_json: JString<'caller>,
) -> JString<'caller> {
    unowned_env
        .with_env(|env| -> jni::errors::Result<JString<'caller>> {
            let client = match get_client(handle) {
                Ok(client) => client,
                Err(error) => {
                    return throw_and_null(env, "java/lang/IllegalStateException", error)
                }
            };
            let request_json = request_json.try_to_string(env)?;
            let request: ApiRequest = match serde_json::from_str(&request_json) {
                Ok(request) => request,
                Err(error) => {
                    return throw_and_null(
                        env,
                        "java/lang/IllegalArgumentException",
                        error.to_string(),
                    )
                }
            };

            let value = match client.execute(&request) {
                Ok(value) => value,
                Err(error) => {
                    return throw_and_null(env, "java/io/IOException", error.to_string())
                }
            };

            let json = match serde_json::to_string(&value) {
                Ok(json) => json,
                Err(error) => {
                    return throw_and_null(
                        env,
                        "java/lang/IllegalStateException",
                        error.to_string(),
                    )
                }
            };

            JString::from_str(env, json)
        })
        .resolve::<ThrowRuntimeExAndDefault>()
}
