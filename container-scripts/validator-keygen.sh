#!/usr/bin/env sh

set -e

# Check NETWORK
if [ "$NETWORK" != "moksha" ] && [ "$NETWORK" != "maya" ] && [ "$NETWORK" != "mainnet" ]; then
  echo "Error: Invalid NETWORK '$NETWORK', must be either 'moksha' or 'maya' or 'mainnet'"
  exit 1
fi

echo "NETWORK check passed: $NETWORK"

# Check if WITHDRAWAL_ADDRESS is set and not the default value
if [ -z "$WITHDRAWAL_ADDRESS" ] || [ "$WITHDRAWAL_ADDRESS" = "0x0000000000000000000000000000000000000000" ]; then
    echo "Error: WITHDRAWAL_ADDRESS is not set or is still the default value."
    echo "Please set a valid withdrawal address in your .env file."
    exit 1
fi

python3 -m staking_deposit.deposit --language=${LANGUAGE:-English} new-mnemonic \
  --mnemonic_language=${LANGUAGE:-English} \
  --num_validators=${NUM_VALIDATORS:-1} \
  --chain=vana_${NETWORK:-mainnet} \
  --eth1_withdrawal_address=${WITHDRAWAL_ADDRESS}

echo 'Please enter the account password you just entered to secure your validator keys:'
read -s PASSWORD
echo $PASSWORD > /app/validator_keys/account_password.txt
chmod 600 /app/validator_keys/account_password.txt
echo 'Account password saved to secrets/account_password.txt'

echo 'Please enter a wallet password that will be used to secure your validator wallet:'
read -s PASSWORD
echo $PASSWORD > /app/validator_keys/wallet_password.txt
chmod 600 /app/validator_keys/wallet_password.txt
echo 'Wallet password saved to secrets/wallet_password.txt'