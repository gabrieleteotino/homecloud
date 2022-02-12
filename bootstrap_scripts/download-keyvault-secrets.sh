#!/bin/bash

echo "Retrieving configuration from Azure"
resource_group_name="rg-bootstrap"
keyvault_name=$(az keyvault list --resource-group=$resource_group_name --query="[?starts_with(name,'kv-secrets')].name | [0]" --output tsv)
echo "Configuration downlad complete"
echo

echo "Downloading secrets"
secret_list=$(az keyvault secret list --vault-name "$keyvault_name" --query="[].name" --output json)

for secret_name in $(echo $secret_list | jq -c '.[]' | jq -r $sh)
do
    echo "Downloading secret ********"
    az keyvault secret download --file "$secret_name.secret" --vault-name "$keyvault_name" -n "$secret_name"
done
