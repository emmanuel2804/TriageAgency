// Agents module: Final agents (Tech and Creative)

import http_client
import prompts
import types.{type AgencyError}

/// Model to use for final agents (free router from OpenRouter)
const agent_model = "openrouter/free"

/// Tech Agent: Provides technical assistance (non-streaming)
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

/// Tech Agent: Provides technical assistance (streaming)
/// Makes 1 call to OpenRouter with stream=true
/// Prints response progressively to stdout
pub fn tech_agent_stream(query: String, api_key: String) -> Result(Nil, AgencyError) {
  let messages = [
    http_client.Message(role: "system", content: prompts.tech_system_prompt),
    http_client.Message(role: "user", content: query),
  ]

  case http_client.call_openrouter(agent_model, messages, api_key, True) {
    Ok(response_body) -> http_client.process_streaming_response(response_body)
    Error(e) -> Error(e)
  }
}

/// Creative Agent: Assists with creative writing and content creation (non-streaming)
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

/// Creative Agent: Assists with creative writing and content creation (streaming)
/// Makes 1 call to OpenRouter with stream=true
/// Prints response progressively to stdout
pub fn creative_agent_stream(query: String, api_key: String) -> Result(Nil, AgencyError) {
  let messages = [
    http_client.Message(role: "system", content: prompts.creative_system_prompt),
    http_client.Message(role: "user", content: query),
  ]

  case http_client.call_openrouter(agent_model, messages, api_key, True) {
    Ok(response_body) -> http_client.process_streaming_response(response_body)
    Error(e) -> Error(e)
  }
}
