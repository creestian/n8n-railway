# n8n on Railway (no external files)
FROM n8nio/n8n:latest

USER root
RUN printf '#!/bin/sh\nset -e\n' \
    'if [ -n "$PORT" ]; then export N8N_PORT="$PORT"; fi\n' \
    'if [ -z "$WEBHOOK_URL" ] && [ -n "$RAILWAY_STATIC_URL" ]; then export WEBHOOK_URL="https://$RAILWAY_STATIC_URL"; fi\n' \
    'exec n8n\n' > /usr/local/bin/railway-entrypoint.sh \
 && chmod +x /usr/local/bin/railway-entrypoint.sh \
 && chown node:node /usr/local/bin/railway-entrypoint.sh

USER node
ENV N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_PROTOCOL=http \
    N8N_PORT=5678 \
    TZ=America/Argentina/Buenos_Aires

EXPOSE 5678
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "require('http').get({host:'127.0.0.1',port:process.env.N8N_PORT||5678,path:'/healthz'},res=>process.exit(res.statusCode===200?0:1)).on('error',()=>process.exit(1))"

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
