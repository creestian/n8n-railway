FROM node:18-alpine

ARG N8N_VERSION=1.106.3

RUN apk add --update graphicsmagick tzdata

# Work as root to set up files/permissions
USER root

# Copy your entrypoint that adapts PORT/WEBHOOK_URL for Railway
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && chown node:node /docker-entrypoint.sh

# Ensure the data dir exists and is owned by node (Railway will mount over it)
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Drop privileges
USER node

# Defaults (can be overridden by Railway env vars)
ENV N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_PROTOCOL=http \
    N8N_PORT=5678 \
    TZ=America/Argentina/Buenos_Aires

EXPOSE $PORT

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "require('http').get({host:'127.0.0.1',port:process.env.N8N_PORT||process.env.PORT||5678,path:'/healthz'},res=>process.exit(res.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD export N8N_PORT=$PORT && n8n start
