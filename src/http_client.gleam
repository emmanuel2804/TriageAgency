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

/// Process streaming response from OpenRouter
/// Parses SSE format (data: {...}) and extracts delta content
pub fn process_streaming_response(response_body: String) -> Result(Nil, AgencyError) {
  // Split response into lines
  let lines = string.split(response_body, on: "\n")

  // Process each line
  list.each(lines, fn(line) {
    case parse_stream_chunk(line) {
      Ok(content) if content != "" -> {
        // Print chunk immediately (simulating streaming)
        print_chunk(content)
      }
      Ok(_) -> Nil  // Empty chunk or [DONE]
      Error(_) -> Nil  // Skip malformed chunks
    }
  })

  Ok(Nil)
}

/// Parse a single SSE chunk line
/// Returns content string if valid, empty string if empty/done, Error if malformed
fn parse_stream_chunk(line: String) -> Result(String, AgencyError) {
  let trimmed = string.trim(line)

  // Skip empty lines
  case trimmed {
    "" -> Ok("")
    _ -> {
      // Check for "data: " prefix
      case string.starts_with(trimmed, "data: ") {
        True -> {
          let data = string.drop_start(trimmed, 6)

          // Check for [DONE] marker
          case data {
            "[DONE]" -> Ok("")
            _ -> parse_delta_content(data)
          }
        }
        False -> Ok("")  // Skip lines without "data: " prefix
      }
    }
  }
}

/// Parse delta content from streaming chunk
/// Extracts choices[0].delta.content
fn parse_delta_content(json_string: String) -> Result(String, AgencyError) {
  // Look for "content":" in delta
  case string.contains(json_string, "\"content\":\"") {
    True -> {
      case string.split(json_string, on: "\"content\":\"") {
        [_, rest, ..] -> {
          case string.split(rest, on: "\"") {
            [content, ..] -> {
              // Clean up JSON escape sequences
              let clean_content =
                content
                |> string.replace("\\n", "\n")
                |> string.replace("\\t", "\t")
                |> string.replace("\\r", "\r")

              Ok(clean_content)
            }
            _ -> Ok("")
          }
        }
        _ -> Ok("")
      }
    }
    False -> Ok("")  // No content in this chunk
  }
}

/// Print a chunk to stdout (simulating streaming)
@external(erlang, "io", "put_chars")
fn print_chunk(text: String) -> Nil
