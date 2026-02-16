"""
Chainlit UI integration for TriageAgency

This app provides a web UI for interacting with the Gleam-based TriageAgency CLI.
It spawns the CLI as a subprocess and streams the response progressively to the user.
"""

import chainlit as cl
import subprocess
import os
from pathlib import Path


# Path to the Gleam CLI binary
GLEAM_BIN = os.path.expanduser("~/.local/bin/gleam")
PROJECT_ROOT = Path(__file__).parent


@cl.on_chat_start
async def start():
    """
    Called when a new chat session starts.
    Displays a welcome message to the user.
    """
    await cl.Message(
        content="👋 **Welcome to TriageAgency!**\n\n"
        "I'm an AI assistant that routes your questions to specialized agents:\n"
        "- 🔧 **Tech Agent**: Programming, debugging, architecture, DevOps\n"
        "- ✨ **Creative Agent**: Writing, brainstorming, storytelling, content creation\n\n"
        "Ask me anything, and I'll automatically route it to the right agent!"
    ).send()


@cl.on_message
async def main(message: cl.Message):
    """
    Called when the user sends a message.
    Spawns the Gleam CLI as a subprocess with streaming enabled.
    """
    query = message.content.strip()

    if not query:
        await cl.Message(content="❌ Please provide a query.").send()
        return

    # Create a message that will be updated with streaming content
    msg = cl.Message(content="")
    await msg.send()

    try:
        # Load environment variables from .env file
        env = os.environ.copy()
        env_file = PROJECT_ROOT / ".env"
        if env_file.exists():
            with open(env_file, "r") as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#"):
                        key, value = line.split("=", 1)
                        env[key.strip()] = value.strip()

        # Check if API key is available
        if "OPENROUTER_API_KEY" not in env:
            await msg.update(
                content="❌ **Error**: OPENROUTER_API_KEY not found in environment.\n\n"
                "Please set it in the `.env` file."
            )
            return

        # Spawn the Gleam CLI as a subprocess with streaming enabled
        process = subprocess.Popen(
            [
                GLEAM_BIN,
                "run",
                "--",
                "--query",
                query,
                "--stream",
                "true",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,  # Line buffered
            cwd=PROJECT_ROOT,
            env=env,
        )

        # Stream the output line by line
        accumulated_output = ""
        triage_decision = None

        for line in iter(process.stdout.readline, ""):
            if not line:
                break

            accumulated_output += line

            # Check if this is the triage decision line
            if "🤖 Triage decision:" in line:
                triage_decision = line.strip()
                await msg.update(content=triage_decision + "\n\n")
            else:
                # Update the message with accumulated streaming content
                if triage_decision:
                    await msg.update(content=triage_decision + "\n\n" + accumulated_output)
                else:
                    await msg.update(content=accumulated_output)

        # Wait for the process to complete
        return_code = process.wait()

        if return_code != 0:
            error_msg = f"\n\n❌ **Error**: CLI exited with code {return_code}"
            await msg.update(content=accumulated_output + error_msg)

    except FileNotFoundError:
        await msg.update(
            content=f"❌ **Error**: Gleam binary not found at `{GLEAM_BIN}`.\n\n"
            "Please ensure Gleam is installed and the path is correct."
        )
    except Exception as e:
        await msg.update(content=f"❌ **Error**: {str(e)}")


if __name__ == "__main__":
    # Run the Chainlit app
    # Use: chainlit run app.py -w
    pass
