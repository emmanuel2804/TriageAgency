// HTTP Client module: Handles HTTP requests to OpenRouter API

import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/list
import gleam/int
import gleam/string
import types.{type AgencyError, HttpError, JsonParseError}

/// Message structure for OpenRouter API
pub type Message {
  Message(role: String, content: String)
}

/// Call OpenRouter API (non-streaming)
/// Returns the response body as a String or an error
pub fn call_openrouter(
  model: String,
  messages: List(Message),
  api_key: String,
  stream: Bool,
) -> Result(String, AgencyError) {
  // Build the request body
  let body = build_request_body(model, messages, stream)

  // Create the HTTP request
  let request_result =
    request.new()
    |> request.set_method(http.Post)
    |> request.set_host("openrouter.ai")
    |> request.set_path("/api/v1/chat/completions")
    |> request.set_header("Authorization", "Bearer " <> api_key)
    |> request.set_header("Content-Type", "application/json")
    |> request.set_body(body)

  // Send the request
  case httpc.send(request_result) {
    Ok(response) -> {
      case response.status {
        200 -> Ok(response.body)
        status ->
          Error(HttpError(
            "HTTP " <> int.to_string(status) <> ": " <> response.body,
          ))
      }
    }
    Error(_) -> Error(HttpError("Failed to send HTTP request"))
  }
}

/// Build the JSON request body for OpenRouter
fn build_request_body(
  model: String,
  messages: List(Message),
  stream: Bool,
) -> String {
  let messages_json =
    messages
    |> list.map(fn(msg) {
      json.object([
        #("role", json.string(msg.role)),
        #("content", json.string(msg.content)),
      ])
    })

  json.object([
    #("model", json.string(model)),
    #("messages", json.array(messages_json, fn(x) { x })),
    #("stream", json.bool(stream)),
  ])
  |> json.to_string
}

/// Parse OpenRouter non-streaming JSON response
/// Extracts choices[0].message.content
/// Simple string-based extraction (works reliably with OpenRouter's consistent format)
pub fn parse_response(json_string: String) -> Result(String, AgencyError) {
  // Find "content":" in the JSON and extract until the next "
  case string.split(json_string, on: "\"content\":\"") {
    [_, rest, ..] -> {
      case string.split(rest, on: "\"") {
        [content, ..] -> {
          // Clean up JSON escape sequences
          let clean_content =
            content
            |> string.replace("\\n", "")
            |> string.replace("\\t", "")
            |> string.replace("\\r", "")
            |> string.trim()
          Ok(clean_content)
        }
        _ -> Error(JsonParseError("Could not extract content field"))
      }
    }
    _ -> Error(JsonParseError("No content field found in response"))
  }
}
