#!/bin/bash

echo Retrieving configuration from Azure
resource_group_name="rg-bootstrap"

storage_account_name=$(az storage account list --resource-group=$resource_group_name --query="[?starts_with(name,'stboot')].name | [0]" --output tsv)

folder_name=${PWD##*/}

echo Writing config

touch backend_configuration.tfvars

echo "resource_group_name  = \"$resource_group_name\"
storage_account_name = \"$storage_account_name\"
container_name       = \"tfstate\"
key                  = \"$folder_name.tfstate\"" > ./backend_configuration.tfvars

echo Configuration ready
echo You can now initialize Terrfarom with the following command:
echo
echo terraform init --backend-config=backend_configuration.tfvars
echo