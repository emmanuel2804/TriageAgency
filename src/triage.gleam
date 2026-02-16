// Triage module: Classifies user queries into tech or creative

import gleam/string
import http_client
import prompts
import types.{type AgencyError, type Intent}

/// Model to use for triage (Aurora Alpha from OpenRouter)
const triage_model = "openrouter/aurora-alpha"

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
          // Robust parsing: look for "tech" or "creative" anywhere in the response
          let normalized = string.trim(string.lowercase(content))

          // Check if response contains "tech" or "creative"
          let has_tech = string.contains(normalized, "tech")
          let has_creative = string.contains(normalized, "creative")

          case has_tech, has_creative {
            // If only one is present, use it
            True, False -> Ok(types.Tech)
            False, True -> Ok(types.Creative)

            // If both are present, find which comes first
            True, True -> {
              case string.split(normalized, on: "tech"), string.split(normalized, on: "creative") {
                [before_tech, ..], [before_creative, ..] -> {
                  case string.length(before_tech) < string.length(before_creative) {
                    True -> Ok(types.Tech)
                    False -> Ok(types.Creative)
                  }
                }
                _, _ -> types.string_to_intent(normalized)
              }
            }

            // If neither is present, try exact match as fallback
            False, False -> types.string_to_intent(normalized)
          }
        }
        Error(e) -> Error(e)
      }
    }
    Error(e) -> Error(e)
  }
}
