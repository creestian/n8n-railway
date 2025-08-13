# n8n on Railway — diagnostic build (no COPY, no VOLUME)
FROM n8nio/n8n:latest

USER root
# Inline entrypoint that maps Railway's $PORT and $RAILWAY_STATIC_URL
# and prints a few things so you can see logs before n8n boots.
RUN printf '#!/bin/sh\nset -ex\n' \
  'echo "== Boot ENV =="\n' \
  'echo "PORT=$PORT"\n' \
  'echo "N8N_PORT=$N8N_PORT (before mapping)"\n' \
  'echo "WEBHOOK_URL=$WEBHOOK_URL"\n' \
  'echo "RAILWAY_STATIC_URL=$RAILWAY_STATIC_URL"\n' \
  'if [ -n "$PORT" ]; then export N8N_PORT="$PORT"; fi\n' \
  'if [ -z "$WEBHOOK_URL" ] && [ -n "$RAILWAY_STATIC_URL" ]; then export WEBHOOK_URL="https://$RAILWAY_STATIC_URL"; fi\n' \
  'echo "N8N_PORT=$N8N_PORT (after mapping to $PORT)"\n' \
  'echo "Starting n8n..."\n' \
  'exec n8n\n' > /usr/local/bin/railway-entrypoint.sh \
 && chmod +x /usr/local/bin/railway-entrypoint.sh \
 && chown node:node /usr/local/bin/railway-entrypoint.sh

USER node
ENV N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_PROTOCOL=http \
    N8N_PORT=5678 \
    TZ=America/Argentina/Buenos_Aires

EXPOSE 5678
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
