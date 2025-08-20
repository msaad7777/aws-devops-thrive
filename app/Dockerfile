# Use Node.js LTS base image
FROM node:18

# Add curl for container healthchecks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/src/app

# Copy package files first for better caching
COPY package*.json ./
RUN npm ci --omit=dev

# Copy source
COPY . .

# Expose container port (ALB -> instance:80 -> container:3000)
EXPOSE 3000

# Start app
CMD ["npm", "start"]
