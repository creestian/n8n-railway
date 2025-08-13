#!/bin/sh
set -e

# Use Railway's dynamic port
if [ -n "$PORT" ]; then
  export N8N_PORT="$PORT"
fi

# Auto-set WEBHOOK_URL from Railway static URL if not provided
if [ -z "$WEBHOOK_URL" ] && [ -n "$RAILWAY_STATIC_URL" ]; then
  export WEBHOOK_URL="https://$RAILWAY_STATIC_URL"
fi

exec n8n
