#!/bin/bash
for d in $(lsblk -lnpo NAME,TYPE | awk '$2=="part"{print $1}'); do
    if ! blkid "$d" | grep -q 'TYPE="crypto_LUKS"'; then
        echo "$d is NOT encrypted"
    fi
done