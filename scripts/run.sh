#!/bin/bash
# Run Flutter with environment variables from .env file
# Usage: ./scripts/run.sh [additional flutter run args]

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env file if it exists
ENV_FILE="$PROJECT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment from $ENV_FILE"
    # Export variables from .env (eval handles quoted values correctly)
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        # Export the variable
        eval "export $line"
    done < "$ENV_FILE"
else
    echo "Warning: .env file not found at $ENV_FILE"
fi

# Build the dart-define arguments
DART_DEFINES=""
if [ -n "$SENTRY_DSN" ]; then
    echo "✓ SENTRY_DSN is set"
    DART_DEFINES="--dart-define=SENTRY_DSN=$SENTRY_DSN"
else
    echo "⚠ SENTRY_DSN is not set"
fi

# Run Flutter with the environment variables
cd "$PROJECT_DIR"
echo "Running: flutter run $DART_DEFINES $@"
flutter run $DART_DEFINES "$@"
