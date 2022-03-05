#!/bin/bash

echo "Finding Bootstrap Key Vault"
resource_group_name="rg-bootstrap"
keyvault_name=$(az keyvault list --resource-group=$resource_group_name --query="[?starts_with(name,'kv-secret')].name | [0]" --output tsv)
echo "Search complete"
echo

echo "Downloading secrets"
secret_list=$(az keyvault secret list --vault-name "$keyvault_name" --query="[].name" --output json)

for secret_name in $(echo $secret_list | jq -c '.[]' | jq -r $sh)
do
    # TODO check if file exist, move it, download, delete after
    echo "Downloading secret $secret_name"
    az keyvault secret download --file "$secret_name.secret" --vault-name "$keyvault_name" -n "$secret_name"
done
