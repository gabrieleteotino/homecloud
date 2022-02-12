#!/bin/bash

echo "Retrieving configuration from Azure"
resource_group_name="rg-bootstrap"
storage_account_name=$(az storage account list --resource-group=$resource_group_name --query="[?starts_with(name,'stbootstrap')].name | [0]" --output tsv)
connection_string=$(az storage account show-connection-string --resource-group $resource_group_name --name $storage_account_name --output tsv)
echo "Configuration downlad complete"
echo

folder_name="tfstate_backup"
echo "Creating folder $folder_name"
mkdir -p $folder_name

echo "Creating a SAS token"
end=$(date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ')
sas=$(az storage container generate-sas --account-name $storage_account_name --name tfstate --https-only --permissions rl --expiry $end -o tsv)

echo "Downloading tfstate blobs from $storage_account_name"
az storage blob directory download --account-name $storage_account_name --sas-token $sas --container tfstate --source "*" --destination "$folder_name" --recursive
