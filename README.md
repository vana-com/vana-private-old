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

> **Checkpoint Sync Recommended**
>
> To avoid very long sync times, it's highly recommended to use checkpoint sync.
> In your `.env` file, set the following variables:
>
> ```
> TRUSTED_BEACON_NODE_URL=http://archive.vana.org:3500  # Use appropriate URL for your network
> WEAK_SUBJECTIVITY_CHECKPOINT=0x0000000000000000000000000000000000000000000000000000000000000000:0  # Replace with actual checkpoint
> ```
> WEAK_SUBJECTIVITY_CHECKPOINT is a block root:epoch number of the checkpoint that you want to sync to.
>
> Then, in the `docker-compose.yml` file, uncomment these lines in the `beacon` service:
>
> ```yaml
> - --weak-subjectivity-checkpoint=${WEAK_SUBJECTIVITY_CHECKPOINT}
> - --checkpoint-sync-url=${TRUSTED_BEACON_NODE_URL}  # not strictly necessary, but recommended for safety
> - --genesis-beacon-api-url=${TRUSTED_BEACON_NODE_URL}  # not strictly necessary, genesis state is provided by this repo
> ```
>
> This can significantly reduce the time it takes for your node to sync with the network.

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

You can combine profiles as needed. Whenever a service depends on another service, you must include the dependent profile.

 For example, to start the node, you must include the `init` and `node` profiles:
```bash
docker compose --profile init --profile node up -d
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

2. Create a file named `deposit_private_key.txt` in the `./secrets` directory containing the private key of the account funding the deposits:
   ```bash
   echo "your_private_key_here" > ./secrets/deposit_private_key.txt
   ```
   Replace `your_private_key_here` with the actual private key.

3. Run the deposit submission process:
   ```bash
   docker compose --profile manual run --rm submit-deposits
   ```

   This command will iterate through all generated validator keys and submit the required deposits.

4. Wait for the transactions to be confirmed on the network before proceeding to start your validator.

For more detailed information on Docker Compose commands and options, refer to the [official Docker Compose documentation](https://docs.docker.com/compose/reference/).
## Backup and Restore

The setup includes services for backing up and restoring your node data. It's important to perform these operations regularly to ensure data safety and to have a recovery option in case of issues.

### Backups

To create and restore backups of your node data:

#### Geth (Execution Client) Backup

To perform a backup of your Geth data, ensure that the geth service is stopped, then run:

```bash
docker compose --profile backup run --rm geth-backup
```

This will create a timestamped backup file in the ./backups directory.

#### Beacon Chain Backup

To perform a backup of your Beacon Chain data, ensure that the beacon service is stopped, then run:

```bash
docker compose --profile backup run --rm beacon-backup
```

This creates a timestamped copy of the Beacon Chain database in the ./backups directory.

#### Validator Backup

The validator backup can be triggered while the validator service is running:

```bash
docker compose --profile backup run --rm validator-backup
```

This sends a request to the validator service to create a backup, which will be stored in the ./backups directory.

### Restore

Before performing any restore operations, ensure that the respective services are stopped.

#### Geth (Execution Client) Restore

To restore Geth data:

```bash
docker compose --profile restore run --rm geth-restore
```

You'll be prompted to select a backup file to restore from.

#### Beacon Chain Restore

To restore Beacon Chain data:

```bash
docker compose --profile restore run --rm beacon-restore
```

You'll be prompted to select a backup file to restore from.

#### Validator Restore

To restore Validator data:

```bash
docker compose --profile restore run --rm validator-restore
```

You'll be prompted to select a backup file to restore from.

### Important Notes

- Remember your password and separately backup your keystore(s)!
- Performing backups while services are running risks corrupting the backup, with the exception of the validator backup.
- After restoring data, you may need to resync your node to catch up with the latest state of the network.
