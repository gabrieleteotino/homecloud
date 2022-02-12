#!/bin/bash

for folder_name in "bootstrap" "compute" "vpn"
do
	echo Preparing configuration for module $folder_name
    pushd $folder_name > /dev/null

    echo Retrieving configuration from Azure
    resource_group_name="rg-bootstrap"

    storage_account_name=$(az storage account list --resource-group=$resource_group_name --query="[?starts_with(name,'stboot')].name | [0]" --output tsv)

    # folder_name=${PWD##*/}

    echo Writing config in $PWD/backend_configuration.tfvars

    touch backend_configuration.tfvars

    echo "resource_group_name  = \"$resource_group_name\"
storage_account_name = \"$storage_account_name\"
container_name       = \"tfstate\"
key                  = \"$folder_name.tfstate\"" > ./backend_configuration.tfvars

    echo
    popd > /dev/null
done

echo Configuration ready
echo You can now initialize Terrfarom with the following command:
echo
echo terraform init --backend-config=backend_configuration.tfvars
echo