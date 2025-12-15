#!/bin/bash
# Helper script to get secrets from file-based system or environment variables
# Usage: get-secret.sh SECRET_NAME
#
# This script implements a fallback hierarchy for retrieving secrets:
# 1. File-based secrets system (/opt/secrets/manage-secrets.sh)
# 2. Environment variables (TF_VAR_*)
# 3. Exit with error if neither source provides the secret

SECRET_NAME="$1"
SECRETS_SCRIPT="/opt/secrets/manage-secrets.sh"

if [ -z "$SECRET_NAME" ]; then
    echo "Error: Secret name required" >&2
    echo "Usage: get-secret.sh SECRET_NAME" >&2
    exit 1
fi

# Try file-based secrets first
if [ -x "$SECRETS_SCRIPT" ]; then
    echo "Checking file-based secrets for: $SECRET_NAME" >&2
    SECRET_VALUE=$($SECRETS_SCRIPT get-secret "$SECRET_NAME" 2>/dev/null || echo "")
    if [ -n "$SECRET_VALUE" ]; then
        echo "Found $SECRET_NAME in file-based secrets" >&2
        echo "$SECRET_VALUE"
        exit 0
    else
        echo "Secret $SECRET_NAME not found in file-based system" >&2
    fi
else
    echo "File-based secrets not available (no $SECRETS_SCRIPT)" >&2
fi

# Fall back to environment variable
TF_VAR_NAME="TF_VAR_$(echo $SECRET_NAME | tr '[:upper:]' '[:lower:]')"
SECRET_VALUE=$(eval "echo \$$TF_VAR_NAME")

if [ -n "$SECRET_VALUE" ]; then
    echo "Found $SECRET_NAME in environment variable $TF_VAR_NAME" >&2
    echo "$SECRET_VALUE"
    exit 0
fi

# Secret not found in either location
echo "Error: Secret $SECRET_NAME not found in file-based system or environment variables" >&2
echo "Checked:" >&2
echo "  - File-based: $SECRETS_SCRIPT get-secret $SECRET_NAME" >&2
echo "  - Environment: $TF_VAR_NAME" >&2
exit 1