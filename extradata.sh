#!/usr/bin/env sh

zeroes() {
    for i in $(seq $1); do
        echo -n "0"
    done
}

# Accept the address as an argument instead of reading it from a file
address=$1
if [ -z "$address" ]; then
    echo "Usage: $0 <address>"
    exit 1
fi

# Only remove "0x" if it's present
address=${address#0x}

extra_data="0x$(zeroes 64)${address}$(zeroes 130)"

echo $extra_data

