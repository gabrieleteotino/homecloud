#!/bin/bash

echo "Retrieving configuration from Azure"
resource_group_name="rg-bootstrap"
keyvault_name=$(az keyvault list --resource-group=$resource_group_name --query="[?starts_with(name,'kv-secrets')].name | [0]" --output tsv)
echo "Configuration downlad complete"
echo

echo "Uploading secrets"
secret_list="./*.secret"

for secret_file_path in $secret_list
do
    secret_name=$(basename -- "$secret_file_path")
    secret_name="${secret_name%.*}"
    
    # Check if the secret needs recovery
    echo "Check if secret $secret_name is in deleted state"
    secret_recovery__id=$(az keyvault secret show-deleted --name $secret_name --vault-name $keyvault_name --query="recoveryId" --output tsv 2> /dev/null)
    if [ $? -eq 0 ]
    then
        echo "Recovering secret $secret_name"
        az keyvault secret recover --id=$secret_recovery__id
    fi

    echo "Uploading secret $secret_name"
    az keyvault secret set --name $secret_name --vault-name $keyvault_name --file $secret_file_path > /dev/null
done
