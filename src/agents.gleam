// Agents module: Final agents (Tech and Creative)

import http_client
import prompts
import types.{type AgencyError}

/// Model to use for final agents (free model from OpenRouter)
const agent_model = "meta-llama/llama-3.1-8b-instruct:free"

/// Tech Agent: Provides technical assistance
/// Makes 1 call to OpenRouter with stream=false
/// Returns the complete response content
pub fn tech_agent(query: String, api_key: String) -> Result(String, AgencyError) {
  let messages = [
    http_client.Message(role: "system", content: prompts.tech_system_prompt),
    http_client.Message(role: "user", content: query),
  ]

  case http_client.call_openrouter(agent_model, messages, api_key, False) {
    Ok(response_body) -> http_client.parse_response(response_body)
    Error(e) -> Error(e)
  }
}

/// Creative Agent: Assists with creative writing and content creation
/// Makes 1 call to OpenRouter with stream=false
/// Returns the complete response content
pub fn creative_agent(query: String, api_key: String) -> Result(String, AgencyError) {
  let messages = [
    http_client.Message(role: "system", content: prompts.creative_system_prompt),
    http_client.Message(role: "user", content: query),
  ]

  case http_client.call_openrouter(agent_model, messages, api_key, False) {
    Ok(response_body) -> http_client.parse_response(response_body)
    Error(e) -> Error(e)
  }
}
