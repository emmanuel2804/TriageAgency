// Agency module: Orchestrates the triage and agent flow

import gleam/io
import agents
import triage
import types.{type AgencyError, Creative, Tech}

/// Main agency function: Orchestrates triage → final agent flow
/// 1. Calls triage to classify the query
/// 2. Prints the decision
/// 3. Calls the appropriate final agent (tech or creative)
/// 4. Prints the response (complete in no-stream, progressive in stream mode)
/// Returns Ok(Nil) or an error
pub fn agency(
  query: String,
  stream: Bool,
  api_key: String,
) -> Result(Nil, AgencyError) {
  // Step 1: Triage the query
  case triage.triage(query, api_key) {
    Ok(intent) -> {
      // Step 2: Print the decision
      io.println("🤖 Triage decision: " <> types.intent_to_string(intent))
      io.println("")

      // Step 3: Call the appropriate agent
      case intent {
        Tech -> {
          case agents.tech_agent(query, api_key) {
            Ok(response) -> {
              // Step 4: Print the response (no-stream for now)
              io.println(response)
              Ok(Nil)
            }
            Error(e) -> Error(e)
          }
        }
        Creative -> {
          case agents.creative_agent(query, api_key) {
            Ok(response) -> {
              // Step 4: Print the response (no-stream for now)
              io.println(response)
              Ok(Nil)
            }
            Error(e) -> Error(e)
          }
        }
      }
    }
    Error(e) -> Error(e)
  }
}
