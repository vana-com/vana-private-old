#!/bin/sh

# Check NETWORK
if [ "$NETWORK" != "moksha" ] && [ "$NETWORK" != "maya" ] && [ "$NETWORK" != "mainnet" ]; then
  echo "Error: Invalid NETWORK '$NETWORK', must be either 'moksha' or 'maya' or 'mainnet'"
  exit 1
fi

echo "NETWORK check passed: $NETWORK"

# Check if network configuration files exist
if [ ! -f "/vana/networks/$NETWORK/genesis.json" ] || [ ! -f "/vana/networks/$NETWORK/genesis.ssz" ] || [ ! -f "/vana/networks/$NETWORK/config.yml" ]; then
  echo "Error: Network configuration files missing for $NETWORK"
  exit 1
fi

echo "Network configuration files check passed"

# Check if JWT secret exists
if [ ! -f /vana/data/jwt.hex ]; then
  echo "Error: JWT secret not found at /vana/data/jwt.hex. See README.md for instructions on how to generate a JWT secret."
  exit 1
fi

echo "JWT secret check passed"

# Check stats-related configuration
if [ -z "$STATS_SERVICE_URL" ]; then
  echo "Error: STATS_SERVICE_URL is not set."
  echo "Please set the stats service URL in your .env file."
  exit 1
fi

echo "STATS_SERVICE_URL check passed"

# Check NODE_NAME
if [ -z "$NODE_NAME" ] || [ "$NODE_NAME" = "Example Node" ]; then
  echo "Error: NODE_NAME is not set or is still the default value."
  echo "Please set a unique node name in your .env file."
  exit 1
fi

echo "NODE_NAME check passed"

# Check STATS_API_KEY if provided
if [ -n "$STATS_API_KEY" ]; then
  echo "STATS_API_KEY check passed"
else
  echo "Note: STATS_API_KEY is not set. Stats will be reported anonymously."
fi

# Check STATS_LOG_LEVEL
if [ -n "$STATS_LOG_LEVEL" ]; then
  case "$STATS_LOG_LEVEL" in
    info|debug|error|warn) ;;
    *)
      echo "Error: Invalid STATS_LOG_LEVEL '$STATS_LOG_LEVEL'. Must be one of: info, debug, error, warn"
      exit 1
      ;;
  esac
  echo "STATS_LOG_LEVEL check passed"
else
  echo "Note: STATS_LOG_LEVEL not set, defaulting to 'info'"
fi

# Check if we need to perform validator-related checks
if [ "$USE_VALIDATOR" = "true" ]; then
  echo "Performing validator-specific checks..."

  # Check if secrets exist and are accessible
  for secret in "account_password" "wallet_password" "deposit_private_key"; do
    if [ ! -f "/run/secrets/$secret" ]; then
      echo "Error: Required secret 'secrets/$secret.txt' not found. Required for validator operations."
      exit 1
    fi
  done

  # Check if WITHDRAWAL_ADDRESS is set and not the default value
  if [ -z "$WITHDRAWAL_ADDRESS" ] || [ "$WITHDRAWAL_ADDRESS" = "0x0000000000000000000000000000000000000000" ]; then
      echo "Error: WITHDRAWAL_ADDRESS is not set or is still the default value."
      echo "Please set a valid withdrawal address in your .env file."
      exit 1
  fi

  # Check if FEE_RECIPIENT_ADDRESS is set and not the default value
  if [ -z "$FEE_RECIPIENT_ADDRESS" ] || [ "$FEE_RECIPIENT_ADDRESS" = "0x0000000000000000000000000000000000000000" ]; then
      echo "Error: FEE_RECIPIENT_ADDRESS is not set or is still the default value."
      echo "Please set a valid fee recipient address in your .env file."
      exit 1
  fi

  # Check if validator keys exist and have been imported
  if [ ! -d /vana/secrets ] || [ -z "$(ls -A /vana/secrets)" ]; then
    echo "Error: Validator keys not found in /vana/secrets. See README.md for instructions on how to import validator keys."
    exit 1
  fi

  # TODO: Only re-enable this if it can be bypassed in submit-deposits
  # if [ ! -d /vana/data/validator/wallet ] || [ -z "$(ls -A /vana/data/validator/wallet)" ]; then
  #   echo "Error: Validator keys not imported. Wallet directory is empty. See README.md for instructions on how to import validator keys."
  #   exit 1
  # fi
  echo "Validator keys and secret file checks passed"

  # Check DEPOSIT_RPC_URL
  if [ -z "$DEPOSIT_RPC_URL" ]; then
      echo "Error: DEPOSIT_RPC_URL is not set."
      echo "Please set a valid RPC URL for deposits in your .env file."
      exit 1
  fi

  echo "DEPOSIT_RPC_URL check passed"

  # Check DEPOSIT_CONTRACT_ADDRESS
  if [ -z "$DEPOSIT_CONTRACT_ADDRESS" ]; then
      echo "Error: DEPOSIT_CONTRACT_ADDRESS is not set."
      echo "Please set a valid deposit contract address in your .env file."
      exit 1
  fi

  echo "DEPOSIT_CONTRACT_ADDRESS check passed"

  # Check VALIDATOR_PUBLIC_KEYS
  if [ -z "$VALIDATOR_PUBLIC_KEYS" ] || [ "$VALIDATOR_PUBLIC_KEYS" = "0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" ]; then
    echo "Error: VALIDATOR_PUBLIC_KEYS is not set or is still the default value."
    echo "Please set valid validator public keys in your .env file."
    exit 1
  fi

  echo "VALIDATOR_PUBLIC_KEYS check passed"
else
  echo "Skipping validator-specific checks..."
fi

echo "All configuration checks passed"
