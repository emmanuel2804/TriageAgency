# 🤖 TriageAgency

A CLI-based AI agent system built in **Gleam** that intelligently routes user queries to specialized agents using OpenRouter API.

## Overview

TriageAgency implements a sequential "agency" pattern where:
1. A **triage agent** classifies user queries as either "tech" or "creative"
2. The query is routed to the appropriate specialized agent:
   - **Tech Agent**: Handles technical questions (programming, debugging, architecture, etc.)
   - **Creative Agent**: Handles creative tasks (writing, brainstorming, storytelling, etc.)
3. The final agent generates and returns the response

## Stack

- **Language**: Gleam
- **HTTP Client**: gleam_httpc
- **JSON**: gleam_json
- **API**: OpenRouter (https://openrouter.ai)
- **Model**: `meta-llama/llama-3.1-8b-instruct:free`

## Prerequisites

- Erlang/OTP
- Gleam 1.14.0+
- OpenRouter API key

## Setup

1. **Install dependencies**:
```bash
gleam deps download
```

2. **Configure environment variables**:

Create a `.env` file in the project root:
```bash
# .env
OPENROUTER_API_KEY=your-api-key-here
```

Get your free API key at: https://openrouter.ai

Then, load the environment variables:
```bash
# Load variables from .env into your current shell
source <(cat .env | sed 's/^/export /')

# Or manually export them
export OPENROUTER_API_KEY="your-api-key-here"
```

**Note**: Don't commit the `.env` file to git (it's already in `.gitignore`).

3. **Build the project**:
```bash
gleam build
```

## Usage

### Basic usage:
```bash
gleam run -- --query "How does binary search work?"
```

### With streaming (coming soon):
```bash
gleam run -- --query "Write a short story" --stream true
```

## Examples

**Technical query:**
```bash
gleam run -- --query "Explain how async/await works in JavaScript"
```

**Creative query:**
```bash
gleam run -- --query "Write a haiku about clouds"
```

## Architecture

```
User Query
    ↓
Triage Agent (classifies intent)
    ↓
├─→ Tech Agent (if tech)
└─→ Creative Agent (if creative)
    ↓
Response to stdout
```

### Modules

- `types.gleam`: Shared types (Intent, AgencyError)
- `config.gleam`: Environment variable configuration
- `prompts.gleam`: System prompts for all agents
- `http_client.gleam`: HTTP POST to OpenRouter + JSON parsing
- `triage.gleam`: Query classification logic
- `agents.gleam`: Tech and Creative final agents
- `agency.gleam`: Orchestration logic
- `triage_agency.gleam`: CLI entry point

## Error Handling

The system handles:
- Missing API key
- HTTP errors (non-200 status codes)
- Malformed JSON responses
- Invalid intent classification
- Missing CLI arguments

All errors are reported with clear, user-friendly messages.

## Development Status

✅ **Completed:**
- Project setup and dependencies
- Type system and error handling
- Environment variable configuration
- System prompts design
- HTTP client (non-streaming)
- JSON response parser
- Triage agent implementation
- Tech and Creative agents
- CLI argument parsing
- Agency orchestration

🚧 **In Progress:**
- Streaming responses
- Chainlit UI integration

## License

MIT
