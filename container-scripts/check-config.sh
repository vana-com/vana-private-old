#!/bin/sh

# Check NETWORK
if [ "$NETWORK" != "moksha" ] && [ "$NETWORK" != "mainnet" ]; then
  echo "Error: Invalid NETWORK '$NETWORK', must be either 'moksha' or 'mainnet'"
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
# Check if we need to perform validator-related checks
if [ "$USE_VALIDATOR" = "true" ]; then
  echo "Performing validator-specific checks..."

  # Check if WITHDRAWAL_ADDRESS is set and not the default value
  if [ -z "$WITHDRAWAL_ADDRESS" ] || [ "$WITHDRAWAL_ADDRESS" = "0x0000000000000000000000000000000000000000" ]; then
      echo "Error: WITHDRAWAL_ADDRESS is not set or is still the default value."
      echo "Please set a valid withdrawal address in your .env file."
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

  echo "Validator keys and wallet check passed"

  # Check if account password file exists
  if [ ! -f /vana/secrets/account_password.txt ]; then
    echo "Error: Account password file not found at /vana/secrets/account_password.txt. See README.md for instructions on how to set up validator keys and password."
    exit 1
  fi

  echo "Account password file check passed"

  # Check if wallet password file exists
  if [ ! -f /vana/secrets/wallet_password.txt ]; then
    echo "Error: Wallet password file not found at /vana/secrets/wallet_password.txt. See README.md for instructions on how to set up validator keys and password."
    exit 1
  fi

  echo "Wallet password file check passed"

  # Check DEPOSIT_PRIVATE_KEY
  if [ -z "$DEPOSIT_PRIVATE_KEY" ] || [ "$DEPOSIT_PRIVATE_KEY" = "0000000000000000000000000000000000000000000000000000000000000000" ]; then
    echo "Error: DEPOSIT_PRIVATE_KEY is not set or is still the default value."
    echo "Please set a valid private key for deposits in your .env file."
    exit 1
  fi

  echo "DEPOSIT_PRIVATE_KEY check passed"

  # Check if account password file exists
  if [ ! -f /vana/secrets/account_password.txt ]; then
    echo "Error: Account password file not found at /vana/secrets/account_password.txt. See README.md for instructions on how to set up validator keys and password."
    exit 1
  fi

  echo "Account password file check passed"

  # Check if wallet password file exists
  if [ ! -f /vana/secrets/wallet_password.txt ]; then
    echo "Error: Wallet password file not found at /vana/secrets/wallet_password.txt. See README.md for instructions on how to set up validator keys and password."
    exit 1
  fi

  echo "Wallet password file check passed"

  # Check DEPOSIT_PRIVATE_KEY
  if [ -z "$DEPOSIT_PRIVATE_KEY" ] || [ "$DEPOSIT_PRIVATE_KEY" = "0000000000000000000000000000000000000000000000000000000000000000" ]; then
      echo "Error: DEPOSIT_PRIVATE_KEY is not set or is still the default value."
      echo "Please set a valid private key for deposits in your .env file."
      exit 1
  fi

  echo "DEPOSIT_PRIVATE_KEY check passed"

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
else
  echo "Skipping validator-specific checks..."
fi

echo "All configuration checks passed"