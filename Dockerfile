# Pin to your running version if you want: n8nio/n8n:1.106.3
FROM n8nio/n8n:latest

USER root
# Create /docker-entrypoint.sh inside the image
RUN cat >/docker-entrypoint.sh <<'SH'
#!/bin/sh
set -e
# Map Railway's dynamic port
if [ -n "$PORT" ]; then export N8N_PORT="$PORT"; fi
# Derive WEBHOOK_URL if not provided
if [ -z "$WEBHOOK_URL" ] && [ -n "$RAILWAY_STATIC_URL" ]; then
  export WEBHOOK_URL="https://$RAILWAY_STATIC_URL"
fi
exec n8n
SH
RUN chmod +x /docker-entrypoint.sh && chown node:node /docker-entrypoint.sh

USER node
ENV N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_PROTOCOL=http \
    TZ=America/Argentina/Buenos_Aires

EXPOSE 5678
ENTRYPOINT ["/docker-entrypoint.sh"]
