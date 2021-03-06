# Homecloud

Infrastructure for my personal cloud.

Includes the following components
 
1. Bootstrap: initial tfstate Storage Account and  Key Vault
2. Core
  1. Funz Function App + Funz Storage Account
  2. Core Storage Account
3. VPN - a digital ocean droplet with wireguard, all secrets are stored in keyvault

## Prerequisites

- Azure subscription
- Terraform
- az

### Vpn module

A DigitalOcean account.

A PAT (personal access token) [guide](https://docs.digitalocean.com/reference/api/create-personal-access-token/)

Save the DigitalOcean PAT in the core keyvault with the name **DigitalOceanPersonalAccessToken**.

Optional but useful [doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/)

```
sudo snap install doctl
doctl auth init
```

### Github CI/CD

Create a GitHub [Personal Access Token](https://github.com/settings/tokens).

Give it a name, choose an appropriate expiration and set the permission **public_repo**.

Save the token in keyvault with the name **GitHubPersonalAccessToken**.

## Installation

### Terraform on linux with tfenv

Install **brew**.
Remember to execute the commands in the __Next steps__ section at the end of the script output.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Wait for it
## Execute the next steps
```

Install **tfenv**

```
brew install tfenv
```

Install terraform

```
# Latest version
tfenv install

# Specific version
tfenv install 1.1.3
```

Create a file __.terraform-version__ so that tfenv automatically detects the version of terraform. [Documentation](https://github.com/tfutils/tfenv#terraform-version).


### Azure CLI

Follow the instructions on [Microsoft docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt).

The fastest way is:

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Authenticate and verify your subscription.

```
az login
az account list
```

Eventually set your default subscription if you have more than one linked to your account.

To keep az up-to-date

```
az upgrade
```

## Terraform commands

### Initialize terraform

#### First run

On the first run change __bootstrap/providers.tf__ and uncomment the local provider

```
  backend "local" {}
  # backend "azurerm" {}
```

Initialize and deploy

```
terraform init
terraform apply
```

Change again __bootstrap/providers.tf__ and uncomment azurerm

```
  # backend "local" {}
  backend "azurerm" {}
```

Generate a __backend_configuration.tfvars__ and reinit terraform to migrate the state

```
terraform init --migrate-state --backend-config=backend_configuration.tfvars
```

#### Script to generate tfvars

Set the script as executable and then launch the script

```
cd reponame/modulename/
chmod +x ./generate-config.sh
./generate-config.sh
```

#### Manual steps

Create a file *service-bus/backend_configuration.tfvars* (do NOT commit) with the following content

```
resource_group_name  = "rg-bootstrap"
storage_account_name = "name-of-the-storage-account"
container_name       = "tfstate"
key                  = "name-of-the-key-goes-here.tfstate"
```

Initialize the backend

```
terraform init --backend-config=backend_configuration.tfvars
```

### Using external variables

If there is a need to specify variables there are two options:

1. Include parameters in the command

```
terraform plan --var="variable_name=value"
terraform apply --var="variable_name=value"
```

2. Create a tfvars file, put the values inside the file

```
terraform plan --var-file="my.tfvars"
terraform apply --var-file="my.tfvars"
```


### Backend variables

```
terraform plan --var-file="backend_configuration.tfvars"
terraform apply --var-file="backend_configuration.tfvars"
```

Note: do not include tfvars files in source countrol.

### Automatic formatting

```
terraform fmt -recursive
```

## Digital Ocean commands

### Digital Ocean parameters

To obtain the possible values for the droplet the documentation is not useful.

```
# Image
doctl compute image list --public | grep ubuntu-

# Region
doctl compute region list
```
