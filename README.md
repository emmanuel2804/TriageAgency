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
- **Triage Model**: `openrouter/aurora-alpha` (reliable classification)
- **Agent Model**: `openrouter/free` (auto-selects available free models)

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

### With streaming:
```bash
gleam run -- --query "Write a short story" --stream true
```

### Without streaming (complete response):
```bash
gleam run -- --query "Explain recursion" --stream false
# Or omit --stream (defaults to false)
gleam run -- --query "Explain recursion"
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

## Chainlit UI Integration

For a more user-friendly web interface, you can use the included Chainlit integration:

1. **Install Python dependencies**:
```bash
pip install -r requirements.txt
```

2. **Run the Chainlit app**:
```bash
chainlit run app.py -w
```

3. **Open your browser**: The app will automatically open at `http://localhost:8000`

The Chainlit UI provides:
- 💬 Interactive chat interface
- 🔄 Progressive streaming responses
- 🎯 Automatic triage decision display
- ✨ Better UX for exploring the agent system

**Testing the integration:**
1. Start the Chainlit server: `chainlit run app.py -w`
2. Open `http://localhost:8000` in your browser
3. Try a **technical query**: "Explain how binary search works"
   - Expected: Triage decision shows "tech", technical explanation appears progressively
4. Try a **creative query**: "Write a haiku about clouds"
   - Expected: Triage decision shows "creative", haiku appears progressively
5. Verify that both queries stream their responses progressively in the UI

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
