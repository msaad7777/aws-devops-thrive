# Simple Node base image
FROM node:18

# App files
WORKDIR /usr/src/app
COPY . .

# App listens on 3000 inside the container
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# Healthcheck needs curl inside the container
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# No deps required (plain Node http server)
CMD ["node", "index.js"]
