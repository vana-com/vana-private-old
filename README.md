# Joining the Vana PoS Network as a Validator

This guide will help you set up a validator node to join our Vana Proof-of-Stake (PoS) mainnet. By following the steps below, you can configure your environment and use Docker to deploy a validator that connects to the network.

## Prerequisites

Before getting started, ensure you have the following installed:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)
- **Google Cloud SDK (gcloud)**: [Install gcloud](https://cloud.google.com/sdk/docs/install) if using Google Cloud resources.
- **OpenSSL**: To handle key and token generation. Install via your package manager:
  ```bash
  sudo apt-get install openssl  # Debian-based systems
  brew install openssl          # macOS
  ```

## Setting Up the Validator Node

### 1. Clone the Repository

Clone the repository that contains the configuration files and scripts for setting up your validator node.

```bash
git clone https://github.com/vana-com/vana.git
cd vana
```

### 2. Configure the `.env` File

The `.env` file contains the necessary environment variables to set up your validator. Here's what needs to be configured:

```bash
# GCP configuration (if using Google Cloud)
PROJECT=<your-gcloud-project-id>
ZONE=<your-gcloud-zone>

# VM configuration
VM_NAME_PREFIX=<validator-vm-prefix>
VM_MACHINE_TYPE=<machine-type>
VM_BOOT_DISK_SIZE=<disk-size-in-gb>
VM_IMAGE_FAMILY=<ubuntu-image-family>
VM_IMAGE_PROJECT=<ubuntu-image-project>

# Network configuration
NETWORK=<testnet/mainnet>
CHAIN_ID=<chain-id>
NUM_NODES=<number-of-nodes>
NUM_VALIDATORS_PER_NODE=<validators-per-node>
VALIDATOR_BALANCE=<validator-balance-in-wei>

# Seed for deterministic key generation
SEED=<your-random-seed>
```

Make sure the following fields are set according to your private mainnet’s configuration:

- **NETWORK**: Set to the network name (e.g., `mainnet` or `testnet`).
- **CHAIN_ID**: This is the unique identifier for your private Ethereum chain.
- **SEED**: This seed will be used to deterministically generate the validator keys.

### 3. Generate Validator Keys

You will need to generate your own validator keys to join the PoS network. We recommend using either the Ethereum Foundation’s validator key tools, OpenSSL, or another secure key generation process to create the following:

- **Keystore:** This contains the private key for your validator, securely encrypted with a password.
- **Password File:** The password used to encrypt your keystore.
- **JWT Token:** A token for secure communication between the execution and consensus layers.

Once your keys are generated, ensure they are stored securely and backed up.

Place the generated key files in the appropriate directories within your configuration folder:

- Keystore files: Place these in `./config/execution/keystore`.
- Password file: Place in `.`/config/execution/password.txt`.
- JWT Token: Place the token in `./config/jwt.hex`.
Ensure these files have the correct permissions and are accessible by your Docker containers.

#### Importing a Private Key Using Docker
If you have already generated a private key and need to import it into the Ethereum client (Geth) inside a Docker container, you can use the following command:

```bash
docker run --rm -v "./config/validator_<validator_number>/execution:/data" ethereum/client-go:latest \
    account import --datadir /data --password /data/password.txt /data/temp_private_key
```

### 4. Verify Your Configuration and Files

Before starting your validator node, ensure that all the necessary files and configurations are in place:

1. **Genesis Files**:
   - **Execution Layer Genesis (`genesis.json`)**: This file contains the initial state and configuration for Vana's execution layer.
   - **Consensus Layer Genesis (`genesis.ssz`)**: This file contains the initial state for the Beacon chain, which is necessary for the consensus layer.

   Both of these files are provided in the repository. Ensure they are correctly placed in your configuration directory:
   - `./config/execution/genesis.json`
   - `./config/consensus/genesis.ssz`

2. **Consensus Layer Configuration (`config.yml`)**:
   - This file contains network-specific settings for the Beacon chain (e.g., fork configurations). The `config.yml` is also provided in the repository.
   
   Ensure it is located in:
   - `./config/consensus/config.yml`

3. **Validator Key Files**:
   - **Keystore**: Ensure your generated keystore is placed in the directory `./config/execution/keystore`.
   - **Password File**: Make sure your password file is located at `./config/execution/password.txt`.
   - **JWT Token**: The JWT token for secure communication between the execution and consensus layers should be in `./config/jwt.hex`.

### 5. Deploy the Validator

Once you have the necessary configuration files and keys in place, you can deploy your validator node using Docker.

#### 1. **Run the Validator Locally Using Docker Compose**

We have provided a Docker Compose template that you can use to set up your validator, execution (Geth), and beacon nodes. The template includes all the necessary configurations for running your validator node in a local Docker environment.

1. Customize the Docker Compose template with your network-specific values such as:
   - `__EXTERNAL_IP__`
   - `__CHAIN_ID__`
   - `<your_http_port>`, `<your_authrpc_port>`, and other ports.

2. Ensure that the required files (like `genesis.json`, `genesis.ssz`, JWT token, and keystore) are in the correct directories as specified in the Docker Compose template.

3. Once your Docker Compose file is ready, run the following command to start the validator:

   ```bash
   docker-compose up -d
   ```

   This will start your validator node, along with the execution and beacon nodes, connecting you to the PoS network.

#### 2. **Deploy on Google Cloud (Optional)**

If you want to deploy your validator node on Google Cloud, follow the official [Google Cloud documentation](https://cloud.google.com/docs) for setting up a virtual machine, installing Docker, and configuring your environment.

This approach allows you to run your validator in a cloud environment, providing scalability and reliability for long-term operation.

Ensure that your Docker Compose configuration and required files are correctly transferred to the cloud environment before running the validator.

### 6. Verify the Validator is Running

Once the validator node is running, you can verify its status by checking the logs.

```bash
docker logs -f <container_name>
```

## Troubleshooting

- **Connection Issues**: Ensure your validator has access to the necessary bootnodes and peers by verifying the peer connections.
- **Insufficient Balance**: Make sure your validator account has enough balance to participate in staking.
- **Syncing Issues**: Check if the execution and consensus layers are syncing properly by reviewing the logs.

