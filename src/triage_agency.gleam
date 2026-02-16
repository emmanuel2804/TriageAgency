import gleam/io
import gleam/list
import gleam/string
import agency
import config
import types

pub fn main() {
  // Get API key from environment
  case config.get_api_key() {
    Ok(api_key) -> {
      // Parse CLI arguments
      case parse_args() {
        Ok(#(query, stream)) -> {
          // Call agency
          case agency.agency(query, stream, api_key) {
            Ok(_) -> halt(0)
            Error(error) -> {
              io.println_error("❌ Error: " <> types.error_to_string(error))
              halt(1)
            }
          }
        }
        Error(msg) -> {
          io.println_error("❌ " <> msg)
          print_usage()
          halt(1)
        }
      }
    }
    Error(error) -> {
      io.println_error("❌ " <> types.error_to_string(error))
      halt(1)
    }
  }
}

/// Parse CLI arguments (--query "text" --stream true|false)
/// Returns (query, stream) or an error message
fn parse_args() -> Result(#(String, Bool), String) {
  let args = get_args()

  case get_flag_value(args, "--query") {
    Ok(query) -> {
      let stream = case get_flag_value(args, "--stream") {
        Ok("true") -> True
        _ -> False
      }
      Ok(#(query, stream))
    }
    Error(_) -> Error("Missing required argument: --query \"your question here\"")
  }
}

/// Get the value after a flag (e.g., --query "text")
fn get_flag_value(args: List(String), flag: String) -> Result(String, Nil) {
  case list.index_fold(args, Error(Nil), fn(acc, arg, idx) {
    case acc {
      Ok(_) -> acc
      Error(_) -> {
        case arg == flag {
          True -> {
            case list_at(args, idx + 1) {
              Ok(value) -> Ok(value)
              Error(_) -> Error(Nil)
            }
          }
          False -> Error(Nil)
        }
      }
    }
  }) {
    Ok(value) -> Ok(value)
    Error(_) -> Error(Nil)
  }
}

/// Get argument at index
fn list_at(lst: List(a), index: Int) -> Result(a, Nil) {
  case list.drop(lst, index) {
    [first, ..] -> Ok(first)
    [] -> Error(Nil)
  }
}

/// Print usage instructions
fn print_usage() {
  io.println("")
  io.println("Usage:")
  io.println("  gleam run -- --query \"your question\" [--stream true|false]")
  io.println("")
  io.println("Examples:")
  io.println("  gleam run -- --query \"How does binary search work?\"")
  io.println("  gleam run -- --query \"Write a haiku about clouds\" --stream true")
  io.println("")
}

/// Get command line arguments (returns charlists from Erlang)
@external(erlang, "init", "get_plain_arguments")
fn get_args_raw() -> List(List(Int))

/// Convert charlists to Gleam strings
fn get_args() -> List(String) {
  get_args_raw()
  |> list.map(charlist_to_string)
}

/// Convert Erlang charlist to Gleam string
fn charlist_to_string(charlist: List(Int)) -> String {
  charlist
  |> list.map(fn(code) {
    case code >= 0 && code <= 1_114_111 {
      True -> string.utf_codepoint(code)
      False -> panic as "Invalid codepoint"
    }
  })
  |> list.fold("", fn(acc, codepoint) {
    case codepoint {
      Ok(cp) -> acc <> string.from_utf_codepoints([cp])
      Error(_) -> acc
    }
  })
}

/// Exit with code
@external(erlang, "erlang", "halt")
fn halt(code: Int) -> Nil
