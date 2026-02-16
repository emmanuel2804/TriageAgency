// Triage module: Classifies user queries into tech or creative

import gleam/string
import http_client
import prompts
import types.{type AgencyError, type Intent}

/// Model to use for triage (free router from OpenRouter)
const triage_model = "openrouter/free"

/// Triage function: Classifies a user query as Tech or Creative
/// Makes exactly 1 call to OpenRouter with stream=false
/// Returns the Intent or an error
pub fn triage(query: String, api_key: String) -> Result(Intent, AgencyError) {
  // Build messages with system prompt and user query
  let messages = [
    http_client.Message(role: "system", content: prompts.triage_system_prompt),
    http_client.Message(role: "user", content: query),
  ]

  // Call OpenRouter API (non-streaming)
  case http_client.call_openrouter(triage_model, messages, api_key, False) {
    Ok(response_body) -> {
      // Parse the JSON response to extract content
      case http_client.parse_response(response_body) {
        Ok(content) -> {
          // Clean up the response and convert to Intent
          let trimmed = string.trim(string.lowercase(content))
          types.string_to_intent(trimmed)
        }
        Error(e) -> Error(e)
      }
    }
    Error(e) -> Error(e)
  }
}
