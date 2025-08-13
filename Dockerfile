# n8n 1.106.3 on Alpine, simple + Railway-friendly
FROM node:20-alpine

ARG N8N_VERSION=1.106.3

# System deps n8n commonly needs
RUN apk add --no-cache graphicsmagick tzdata python3 make g++ git

# Install n8n
RUN npm_config_user=root npm install -g n8n@${N8N_VERSION}

# App data location
WORKDIR /data
ENV N8N_USER_FOLDER=/data \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_PROTOCOL=http \
    TZ=America/Argentina/Buenos_Aires

# Map Railway/compose $PORT -> N8N_PORT at runtime, then start
ENTRYPOINT ["/bin/sh","-lc","export N8N_PORT=${PORT:-5678}; exec n8n start"]

# EXPOSE is informational; Railway ignores it (still fine for local)
EXPOSE 5678
