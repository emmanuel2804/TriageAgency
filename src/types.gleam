// Types module: Shared types for the TriageAgency project

/// Intent type: Represents the classification of user queries
pub type Intent {
  Tech
  Creative
}

/// AgencyError: Custom error type covering all possible errors
pub type AgencyError {
  ApiKeyMissing
  HttpError(String)
  JsonParseError(String)
  InvalidIntent(String)
  StreamError(String)
}

/// Convert Intent to String for display/logging
pub fn intent_to_string(intent: Intent) -> String {
  case intent {
    Tech -> "tech"
    Creative -> "creative"
  }
}

/// Convert String to Intent (for parsing)
pub fn string_to_intent(str: String) -> Result(Intent, AgencyError) {
  case str {
    "tech" -> Ok(Tech)
    "creative" -> Ok(Creative)
    _ -> Error(InvalidIntent("Expected 'tech' or 'creative', got: " <> str))
  }
}

/// Convert AgencyError to String for display
pub fn error_to_string(error: AgencyError) -> String {
  case error {
    ApiKeyMissing -> "API key is missing. Set OPENROUTER_API_KEY environment variable."
    HttpError(msg) -> "HTTP error: " <> msg
    JsonParseError(msg) -> "JSON parse error: " <> msg
    InvalidIntent(msg) -> "Invalid intent: " <> msg
    StreamError(msg) -> "Stream error: " <> msg
  }
}
