#!/bin/bash

echo "Finding Bootstrap Key Vault"
resource_group_name="rg-bootstrap"
keyvault_name=$(az keyvault list --resource-group=$resource_group_name --query="[?starts_with(name,'kv-secret')].name | [0]" --output tsv)
echo "Search complete"
echo

echo "Loading PAT from secrets"

pat=$(az keyvault secret show  --vault-name "$keyvault_name" -n "GitHubPersonalAccessToken" --query "value" --output tsv)

echo "Saving PAT to file"

echo "github_token = \"$pat\"
" > terraform.tfvars

echo "PAT saved into terraform.tfvars"