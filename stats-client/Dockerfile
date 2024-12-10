# Dockerfile for vana-stats-client (build from git)

# Base image
FROM ubuntu:latest

# Install curl, git, Docker CLI, and build tools
RUN apt-get update && apt-get install -y curl git build-essential docker.io

# Add the Node.js 18.x repository and install Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install TypeScript globally
RUN npm install -g typescript

# Set the working directory
WORKDIR /home/vananetintel/vana-stats-client

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install && \
    npm install -g pm2 && \
    npm install web3@latest && \
    npm install web3-providers-http && \
    npm install web3-providers-ws

# Copy the source code into the Docker container
COPY . /home/vananetintel/vana-stats-client

# Compile TypeScript to JavaScript
RUN tsc

# Expose necessary port
EXPOSE 3000

# Start the app with PM2 (run as root user)
CMD ["pm2-runtime", "start", "app.json"]
