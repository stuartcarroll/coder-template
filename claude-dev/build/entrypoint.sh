#!/bin/bash
set -e

# Execute the Coder agent init script (this is critical!)
# The init script is provided by Coder and starts the agent
exec bash -c "$CODER_AGENT_SCRIPT"
