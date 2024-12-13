#!/bin/bash

set -e

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if .env file exists
if [ -f "$PROJECT_ROOT/config/.env" ]; then
  export $(grep -v '^#' "$PROJECT_ROOT/config/.env" | xargs)
else
  echo ".env file not found at $PROJECT_ROOT/config/.env"
  exit 1
fi

TEMPLATE_DIR="$PROJECT_ROOT/config/container-templates"
OUTPUT_DIR="$PROJECT_ROOT/containers"

mkdir -p "$OUTPUT_DIR"

# Replace placeholders {{ DB_USER }} and {{ DB_NAME }} in all relevant files and save with .container extension
for file in immich-database.txt immich-machine_learning.txt immich-server.txt; do
  base_name=$(basename "$file" .txt)
  sed -e "s|{{ DB_USER }}|$DB_USER|g" \
      -e "s|{{ DB_NAME }}|$DB_NAME|g" \
      "$TEMPLATE_DIR/$file" > "$OUTPUT_DIR/$base_name.container"
done

# Escaping path for sed
ESCAPED_EXTERNAL_MEDIA_PATH=$(printf '%s\n' "$EXTERNAL_MEDIA_PATH" | sed -e 's|[\/]|\\&|g')

# Replace placeholders in immich-server.container for {{ EXTERNAL_MEDIA_PATH }}
sed -i "s|{{ EXTERNAL_MEDIA_PATH }}|$ESCAPED_EXTERNAL_MEDIA_PATH|g" "$OUTPUT_DIR/immich-server.container"

# Copy additional container files
cp "$TEMPLATE_DIR/immich-adminer.txt" "$OUTPUT_DIR/immich-adminer.container"
cp "$TEMPLATE_DIR/immich-redis.txt" "$OUTPUT_DIR/immich-redis.container"

echo "Environment variables replaced successfully and files saved to $OUTPUT_DIR."