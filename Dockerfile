# Use official n8n image
FROM n8nio/n8n:latest

# --- Copy entrypoint that adapts to Railway ($PORT / $RAILWAY_STATIC_URL)
USER root
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && chown node:node /docker-entrypoint.sh

# --- Ensure the persistent data dir exists and is owned by node
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Drop privileges
USER node

# --- Sensible defaults; override via Railway env vars
ENV N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_PROTOCOL=http \
    N8N_PORT=5678 \
    TZ=America/Argentina/Buenos_Aires

# Hint to orchestrators that this path should be persisted
VOLUME ["/home/node/.n8n"]

EXPOSE 5678

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "require('http').get({host:'127.0.0.1',port:process.env.N8N_PORT||process.env.PORT||5678,path:'/healthz'},res=>process.exit(res.statusCode===200?0:1)).on('error',()=>process.exit(1))"

ENTRYPOINT ["/docker-entrypoint.sh"]
