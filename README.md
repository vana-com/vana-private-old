# Joining the Vana PoS Network as a Validator

This guide will help you set up a validator node to join our Vana Proof-of-Stake (PoS) mainnet. By following the steps below, you can configure your environment and use Docker to deploy a validator that connects to the network.

## Prerequisites

Before getting started, ensure you have the following installed:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)
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
# Network configuration
NETWORK=mainnet
CHAIN_ID=1337
NUM_NODES=3
NUM_VALIDATORS_PER_NODE=1
VALIDATOR_BALANCE=32000000000000000000  # 32 ETH in Wei

# Seed for deterministic key generation
SEED=my-secure-random-seed

# Geth node configuration
EXTERNAL_IP=192.168.1.100
HTTP_PORT=8545
AUTHRPC_PORT=8551
P2P_PORT=30303

# Beacon chain configuration
RPC_PORT=4000
P2P_TCP_PORT=13000
P2P_UDP_PORT=12000

# Validator configuration
VALIDATOR_PORT=7500
VALIDATOR_ADDRESS=0xYourValidatorEthereumAddress
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

In the provided config directory, there are dummy files placed to show where your actual files need to go. These placeholders are structured to guide you, and they should be replaced with the real files you generate:

- Keystore files: Place these in `./config/execution/keystore`.
- Password file: Place in `./config/execution/password.txt`.
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

1. Customize the Docker Compose template with your network-specific values.

2. Ensure that the required files (like `genesis.json`, `genesis.ssz`, JWT token, and keystore) are in the correct directories as specified in the Docker Compose template.

3. Once your Docker Compose file is ready, run the following command to start the validator:

   ```bash
   docker-compose up -d
   ```

   This will start your validator node, along with the execution and beacon nodes, connecting you to the PoS network.

### 6. Verify the Validator is Running

Once the validator node and other components are running, you can verify their status by checking the logs for specific messages that indicate successful operation.

- **Execution Layer (Geth)**: Check if Geth is syncing and connected to peers.

  ```bash
  docker logs -f <geth_container_name> | grep -i "Looking for peers"
  ```

  This confirms that the execution layer is looking for and connecting to peers. You may also see syncing progress.

- **Beacon Chain**: Ensure the beacon chain is connected and functioning properly.

  ```bash
  docker logs -f <beacon_container_name> | grep -i "gRPC client connected to beacon node"
  ```

  This confirms the beacon chain is connected to the network.

- **Validator**: Verify the validator is performing its duties.

  ```bash
  docker logs -f <validator_container_name> | grep -i "Submitted new sync contribution and proof"
  ```

  This confirms that the validator is participating in block validation.

## Troubleshooting

- **Connection Issues**: Ensure your validator has access to the necessary bootnodes and peers by verifying the peer connections.
- **Insufficient Balance**: Make sure your validator account has enough balance to participate in staking.
- **Syncing Issues**: Check if the execution and consensus layers are syncing properly by reviewing the logs.

