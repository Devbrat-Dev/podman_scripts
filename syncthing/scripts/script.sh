#!/usr/bin/env bash

set -euo pipefail

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if .env file exists
if [ -f "$PROJECT_ROOT/config/.env" ]; then
  export $(grep -v '^#' "$PROJECT_ROOT/config/.env" | xargs)
else
  echo ".env file not found at $PROJECT_ROOT/config/.env" >&2
  exit 1
fi

TEMPLATE_DIR="$PROJECT_ROOT/config/container-templates"
OUTPUT_DIR="$PROJECT_ROOT/containers"

mkdir -p "$OUTPUT_DIR"

# Replace placeholders {{ TIMEZONE }}, {{ HOSTNAME }} and {{ EXTERNAL_FOLDER_PATH }} in all relevant files and save with .container extension
for file in syncthing-server.txt; do
  base_name=$(basename "$file" .txt)
  sed -e "s|{{ TIMEZONE }}|$TIMEZONE|g" \
      -e "s|{{ HOSTNAME }}|$HOSTNAME|g" \
      -e "s|{{ EXTERNAL_FOLDER_PATH }}|$EXTERNAL_FOLDER_PATH|g" \
      "$TEMPLATE_DIR/$file" > "$OUTPUT_DIR/$base_name.container"
done

echo "Environment variables replaced successfully and files saved to $OUTPUT_DIR."