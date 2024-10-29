# Vana PoS Network Validator Setup

This guide will help you set up a validator node for the Vana Proof-of-Stake (PoS) network using Docker.

## Prerequisites

- Docker: [Install Docker](https://docs.docker.com/get-docker/)
- Docker Compose: [Install Docker Compose](https://docs.docker.com/compose/install/)
- OpenSSL: Install via your package manager:
  ```bash
  sudo apt-get install openssl  # Debian-based systems
  brew install openssl          # macOS
  ```
- Hardware: Ensure your system meets the [minimum hardware requirements](https://docs.vana.org/vana/core-concepts/roles/propagators#hardware-requirements) for running a Vana Propagator (Validator)

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/vana-com/vana.git
   cd vana
   ```

2. Configure your environment:
   ```bash
   # For Moksha testnet
   cp .env.moksha.example .env
   # OR for Mainnet
   cp .env.mainnet.example .env

   # Edit .env with your preferred text editor
   ```

3. Choose your setup:

   a. For running a node without a validator:

   Edit the `.env` file to set `USE_VALIDATOR=false`. Use `GETH_SYNCMODE=snap` and update Prysm variables accordingly. Then run:
   ```bash
   docker compose --profile init --profile node up -d
   ```

   b. For running a validator node:

   Edit the `.env` file to set `USE_VALIDATOR=true` and set the `DEPOSIT_*` variables appropriately.

   If you already have validator keys:
   - Place your keystore files in the `./secrets` directory
   - Create a `wallet_password.txt` file in the `./secrets` directory with your wallet password
   - Create an `account_password.txt` file in the `./secrets` directory with your account password

   Then run:
   ```bash
   # Import existing validator keys:
   docker compose --profile init --profile manual run --rm validator-import

   # Start all services including the validator:
   docker compose --profile init --profile validator up -d
   ```

   If you need to generate new validator keys:
   ```bash
   # Generate validator keys (interactive process):
   docker compose --profile init --profile manual run --rm validator-keygen

   # Import the generated validator keys:
   docker compose --profile init --profile manual run --rm validator-import
   ```

   If you have not submitted your deposits yet:
   ```bash
   # Submit deposits for your validator:
   docker compose --profile init --profile manual run --rm submit-deposits
   ```

   When you have submitted your deposits, you can start your validator:
   ```bash
   # Start all services including the validator:
   docker compose --profile init --profile validator up -d
   ```

4. If the check-config service fails, check its logs:
   ```bash
   docker compose logs check-config
   ```

## Configuration

### Environment Variables

Edit the `.env` file to configure your node. Key variables include:

- `NETWORK`: Choose between `moksha` (testnet) or `mainnet`
- `CHAIN_ID`: Network chain ID
- `EXTERNAL_IP`: Your node's external IP address
- Various port configurations for different services

Ensure all required variables are set correctly before proceeding.

## Verifying Your Setup

After starting your services, you can check the logs to ensure everything is running correctly:

1. View logs for all services:
   ```bash
   docker compose logs
   ```

2. View logs for specific key services:
   ```bash
   docker compose --profile=init --profile=node logs -f geth
   docker compose --profile=init --profile=node logs -f beacon
   docker compose --profile=init --profile=node logs -f validator
   ```

3. To follow logs in real-time and filter for specific patterns:
   ```bash
   docker compose --profile=init --profile=node logs -f geth 2>&1 | grep 'Looking for peers'
   docker compose --profile=init --profile=node logs -f beacon 2>&1 | grep 'Synced new block'
   docker compose --profile=init --profile=node logs -f validator 2>&1 | grep 'Submitted new'
   ```

When reviewing logs, look for:

- Geth (execution layer): Messages about peer connections and syncing progress
- Beacon Chain: Indications of connection to the network and slot processing
- Validator: Messages about duties being performed and contributions submitted

If you see error messages or unexpected behavior in the logs, refer to the troubleshooting section or seek support.

## Troubleshooting

If you encounter issues:

1. Ensure all configuration files are present and correctly formatted.
2. Check individual service logs for specific error messages.
3. Verify that your `.env` file contains all necessary variables.
4. Run the configuration check:
   ```bash
   docker compose run --rm check-config
   ```
5. For connection issues, check your firewall settings and ensure the necessary ports are open.
6. If services fail to start, try restarting them individually:
   ```bash
   docker compose restart <service_name>
   ```

## Security Considerations

- Securely store your validator keys and never share them.
- Regularly update your node software to the latest version.
- Monitor your validator's performance and status regularly.

For additional help or to report issues, please open an issue in the GitHub repository or contact the Vana support team.

## Advanced Usage

The `docker-compose.yml` file provides several additional capabilities for managing your Vana PoS validator node. Here are some useful commands and their purposes:

### Profiles

Different profiles are available for various operations:

- `init`: Initialize clients, generate secrets
- `node`: Run the main node services
- `validator`: Run validator-specific services
- `manual`: For manual operations like key generation
- `delete`: Delete data, e.g. to reset the chain so you can re-sync
- `public`: Expose APIs securely via Caddy reverse proxy (ports 80/443)

You can combine profiles as needed. Whenever a service depends on another service, you must include the dependent profile.

 For example, to start the node, you must include the `init` and `node` profiles:
```bash
docker compose --profile init --profile node up -d
```

For example, to run the node with public API access:
```bash
docker compose --profile init --profile node --profile public up -d
```

Or to start/stop just the API gateway:
```bash
docker compose --profile init --profile node --profile public up -d caddy
docker compose --profile init --profile node --profile public down caddy
```

### Key Management

Generate validator keys (interactive process):
```bash
docker compose --profile init --profile manual run --rm validator-keygen
```

Import validator keys:
```bash
docker compose run --rm validator-import
```

### Deleting Data

To delete all data/ (does not remove generated secrets/):

```bash
docker compose --profile delete run --rm delete-all
```

To delete execution or consensus layer data:
```bash
docker compose --profile delete run --rm delete-geth
docker compose --profile delete run --rm delete-prysm
```

### Configuration Check

Run a configuration check:

```bash
docker compose --profile=init --profile=node run --rm check-config
```

### Individual Services

You can start, stop, or restart individual services:

```bash
docker compose --profile=init --profile=node up -d geth
docker compose --profile=init --profile=node stop beacon
docker compose --profile=init --profile=node restart validator
```

### Viewing Logs

View logs for specific services:

```bash
docker compose --profile=init --profile=node logs geth
docker compose --profile=init --profile=node logs beacon
docker compose --profile=init --profile=node logs validator
```

Add `-f` to follow the logs in real-time:

```bash
docker compose --profile=init --profile=node logs -f geth
```

Use grep to filter for specific events:

```bash
docker compose --profile=init --profile=node logs -f geth 2>&1 | grep 'Looking for peers'
docker compose --profile=init --profile=node logs -f beacon 2>&1 | grep 'Synced new block'
docker compose --profile=init --profile=node logs -f validator 2>&1 | grep 'Submitted new'
```

### Environment Variables

Remember that many settings are controlled via environment variables in the `.env` file. You can modify these to adjust your node's configuration.

For more detailed information on Docker Compose commands and options, refer to the [official Docker Compose documentation](https://docs.docker.com/compose/reference/).

## Submitting Deposits

After generating validator keys and before starting your validator, you need to submit deposits for each validator. This process stakes your ETH and registers your validator(s) with the network.

1. Ensure you have the following environment variables set in your `.env` file:
   - `DEPOSIT_RPC_URL`: The RPC URL for the network on which you're submitting deposits
   - `DEPOSIT_CONTRACT_ADDRESS`: The address of the deposit contract
   - `DEPOSIT_PRIVATE_KEY`: The private key of the account funding the deposits

2. Run the deposit submission process:
   ```bash
   docker compose --profile deposit run --rm submit-deposits
   ```

   This command will iterate through all generated validator keys and submit the required deposits.

3. Wait for the transactions to be confirmed on the network before proceeding to start your validator.

For more detailed information on Docker Compose commands and options, refer to the [official Docker Compose documentation](https://docs.docker.com/compose/reference/).

## Using the API Gateway

The validator node exposes its APIs through a Caddy reverse proxy for secure HTTPS access. By default, it uses `localhost` but you can configure a custom domain in your `.env` file.

### Domain Setup

If using a custom domain:
1. Point your domain's DNS to your server's IP address
2. Ensure ports 80 and 443 are open on your firewall
3. Set your domain in the `.env` file

### Local Testing

For local testing, you can access the APIs using curl with the `-k` flag to skip certificate verification:

```bash
# Query beacon node identity
curl -k -X 'GET' 'https://localhost:443/eth/v1/node/identity' -H 'accept: application/json'

# Query execution node info
curl -k -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' \
  https://localhost:443
```

### Installing Local CA Certificate

You can also install Caddy's root CA certificate on your host machine:

Linux:
```bash
docker compose cp \
    caddy:/data/caddy/pki/authorities/local/root.crt \
    /usr/local/share/ca-certificates/root.crt \
  && sudo update-ca-certificates
```

macOS:
```bash
docker compose cp \
    caddy:/data/caddy/pki/authorities/local/root.crt \
    /tmp/root.crt \
  && sudo security add-trusted-cert -d -r trustRoot \
    -k /Library/Keychains/System.keychain /tmp/root.crt
```

Windows:
```bash
docker compose cp \
    caddy:/data/caddy/pki/authorities/local/root.crt \
    %TEMP%/root.crt \
  && certutil -addstore -f "ROOT" %TEMP%/root.crt
```

Note: Many modern browsers maintain their own certificate trust stores. You may need to manually import the root.crt file in your browser's security settings.

### Troubleshooting SSL

If you encounter SSL-related issues:

1. Check Caddy logs:
   ```bash
   docker compose logs caddy
   ```
2. Verify your domain points to your server's IP address
3. Confirm ports 80 and 443 aren't used by other services
4. Check your firewall allows traffic on ports 80 and 443
