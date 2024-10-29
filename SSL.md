# SSL Provisioning Guide for Vana PoS Network Validator

This guide will walk you through the process of adding SSL to your Vana PoS Network Validator setup, specifically for securing the Geth node's RPC endpoint. We'll be using Caddy as a reverse proxy to handle SSL termination and a separate Docker Compose file for the SSL configuration.

## Prerequisites

- Existing Vana PoS Network Validator setup
- Docker and Docker Compose installed
- A domain name pointed to your server's IP address

## Steps to Add SSL

1. **Copy a Docker Compose file for SSL**

   Copy a `docker-compose.ssl.yml` in the same directory as main `docker-compose.yml`

   This sets up the Caddy service, mapping the necessary ports and volumes, and connects it to the existing Vana network.

2. **Create a Caddyfile**

   Create a file named `Caddyfile` in the same directory as your Docker Compose files with the following content:

   ```
   your-domain.com {
     reverse_proxy geth:8545
   }
   ```

   Replace `your-domain.com` with your actual domain name.

   Ensure that ports 80 and 443 are open on your server's firewall.

5. **Start the SSL proxy**

   Run the following command to start the Caddy service:

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.ssl.yml up -d caddy
   ```

   This command uses both Docker Compose files: the main one and the SSL-specific one.

6. **Verify SSL setup**

   Visit `https://your-domain.com` in a web browser. You should see a secure connection, and any API requests to this endpoint will now be encrypted.

## Troubleshooting

- If you encounter issues, check the Caddy logs:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.ssl.yml logs caddy
  ```
- Ensure your domain is correctly pointed to your server's IP address.
- Verify that ports 80 and 443 are open and not being used by other services.

## Managing the SSL setup

- To start both your main services and the SSL proxy:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.ssl.yml up -d
  ```

- To stop the SSL proxy while keeping other services running:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.ssl.yml stop caddy
  ```

- To remove the SSL proxy:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.ssl.yml rm -s caddy
  ```