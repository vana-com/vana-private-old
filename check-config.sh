#!/bin/sh

# Check if NETWORK is empty
if [ -z "$NETWORK" ]; then
  echo "Error: NETWORK is not set. Please set the NETWORK environment variable to either 'moksha' or 'mainnet'"
  exit 1
fi

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

# Check if validator keys exist and have been imported
if [ ! -d /vana/secrets ] || [ -z "$(ls -A /vana/secrets)" ]; then
  echo "Error: Validator keys not found in /vana/secrets. See README.md for instructions on how to import validator keys."
  exit 1
fi
if [ ! -d /vana/data/validator/wallet ] || [ -z "$(ls -A /vana/data/validator/wallet)" ]; then
  echo "Error: Validator keys not imported. Wallet directory is empty. See README.md for instructions on how to import validator keys."
  exit 1
fi

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

# Check if JWT secret exists
if [ ! -f /vana/data/jwt.hex ]; then
  echo "Error: JWT secret not found at /vana/data/jwt.hex. See README.md for instructions on how to generate a JWT secret."
  exit 1
fi

echo "JWT secret check passed"

echo "All configuration checks passed"