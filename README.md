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

- **Language**: Gleam 1.14.0+
- **Runtime**: Erlang/OTP 27+
- **HTTP Client**: gleam_httpc
- **JSON**: gleam_json v3
- **API**: OpenRouter (https://openrouter.ai)
- **Model**: `openrouter/free` (auto-selects available free models)

## Prerequisites

- **Erlang/OTP 27+** (required for gleam_json v3)
- **Gleam 1.14.0+**
- **OpenRouter API key** (free tier available)

## Setup

1. **Install dependencies**:
```bash
gleam deps download
```

2. **Configure environment variables**:

Create a `.env` file in the project root:
```bash
cp .env.example .env
# Edit .env and add your OpenRouter API key
```

Get your free API key at: https://openrouter.ai/keys

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

### ✅ Sprint 1 - Completed (14/14 tasks)
- ✅ Project initialization with Gleam
- ✅ Dependencies setup (httpc, json, http, envoy)
- ✅ Shared types module (Intent, AgencyError)
- ✅ Environment configuration (API key reading)
- ✅ System prompts for all agents
- ✅ HTTP client for OpenRouter API
- ✅ JSON response parser (string-based, robust)
- ✅ Triage agent (query classification)
- ✅ Tech and Creative final agents
- ✅ Agency orchestration function
- ✅ CLI argument parsing (--query, --stream)
- ✅ Main function integration
- ✅ Error handling and user-friendly messages
- ✅ Working end-to-end system

### 🚧 Sprint 2 - In Progress
- ⏳ Streaming response implementation
- ⏳ HTTP POST streaming to OpenRouter
- ⏳ Stream chunk parser

### 📋 Sprint 3 - Planned
- ⏳ Chainlit UI integration
- ⏳ Integration testing
- ⏳ Documentation updates

### 🎉 Current Status
**The system is fully operational** for non-streaming queries. You can classify and respond to both technical and creative queries using OpenRouter's free tier.

## License

MIT
