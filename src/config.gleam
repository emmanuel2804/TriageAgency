// Config module: Handles environment variables and configuration

import envoy
import types.{type AgencyError, ApiKeyMissing}

/// Get the OpenRouter API key from environment variable
/// Returns ApiKeyMissing error if the variable is not set
pub fn get_api_key() -> Result(String, AgencyError) {
  case envoy.get("OPENROUTER_API_KEY") {
    Ok(key) if key != "" -> Ok(key)
    _ -> Error(ApiKeyMissing)
  }
}
