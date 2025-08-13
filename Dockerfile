# n8n on Railway
FROM n8nio/n8n:latest

# We’ll use a small entrypoint to adapt to Railway’s env
USER root
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && chown node:node /docker-entrypoint.sh

# Run as the non-root user the base image provides
USER node

# Sensible defaults; Railway will override N8N_PORT via the entrypoint using $PORT
ENV N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_PROTOCOL=http \
    N8N_PORT=5678 \
    TZ=America/Argentina/Buenos_Aires

# n8n keeps data in this path; mount a Railway Volume here for persistence
VOLUME ["/home/node/.n8n"]
EXPOSE 5678

# Simple healthcheck (n8n exposes /healthz)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "require('http').get({host:'127.0.0.1',port:process.env.N8N_PORT||5678,path:'/healthz'},res=>process.exit(res.statusCode===200?0:1)).on('error',()=>process.exit(1))"

ENTRYPOINT ["/docker-entrypoint.sh"]
