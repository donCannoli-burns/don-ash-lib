use thiserror::Error;

#[derive(Debug, Error)]
pub enum AshError {
    #[error("invalid KoLmafia base URL: {0}")]
    InvalidBaseUrl(String),

    #[error("non-loopback KoLmafia endpoint rejected: {0}")]
    NonLoopbackRejected(String),

    #[error("KoLmafia password hash is empty")]
    EmptyPasswordHash,

    #[error("HTTP request failed: {0}")]
    Http(#[from] reqwest::Error),

    #[error("KoLmafia returned HTTP {status}: {body}")]
    HttpStatus { status: u16, body: String },

    #[error("KoLmafia JSON API error: {0}")]
    Api(String),

    #[error("invalid JSON API response: {0}")]
    InvalidResponse(String),

    #[error("JSON conversion failed: {0}")]
    Json(#[from] serde_json::Error),
}

pub type Result<T> = std::result::Result<T, AshError>;
