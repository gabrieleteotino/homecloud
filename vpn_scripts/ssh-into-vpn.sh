#!/bin/bash

echo "Reading outputs"
(cd ../vpn; terraform output -json | jq -r '@sh "export DROPLET_KEYVAULT_SECRET_ID=\(.vpn_host_private_key_secret_name.value)\nexport DROPLET_IP=\(.vpn_host_ip.value)"' > ../vpn_scripts/outputs.sh)

. ./outputs.sh

echo "Reading secret from keyvault"
echo $DROPLET_KEYVAULT_SECRET_ID
az keyvault secret show \
    --id $DROPLET_KEYVAULT_SECRET_ID \
    --query value \
    --output tsv > id_digitalocean
chmod 600 id_digitalocean

echo "Connecting to "$DROPLET_IP
ssh root@$DROPLET_IP -i id_digitalocean -o "StrictHostKeyChecking no"