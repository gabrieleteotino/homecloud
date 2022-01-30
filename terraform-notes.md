# Terraform notes

## Refactor into submodule

I started this project with a bootstrap module that contains a storage account in main.

Now I want to move the storage account in a submodule without recreating it.

Steps:

1. Create a new submodule "storage" with an empty main.tf
2. In bootstrap/main.tf use the new module
```
... at the end of the file 

module "storage" {
  source = "./storage"
}
```
3. Do a terraform init
4. Add bootstrap/storage/variables.tf
```
variable "location" {
  type     = string
  nullable = false
}
```
5. Pass the variable from main
```
module "storage" {
  source   = "./storage"
  location = local.location
}
```
6. Cut and paste the resource in the new module
7. Add moved blocks in the original main
```
moved {
  from = azurerm_storage_account.st_bootstrap
  to   = module.storage.azurerm_storage_account.st_bootstrap
}
```
8. Fix variables and outputs as appropriate

On the next terraform plan and terraform apply the state will be moved into the module.
**Double check** terraform plan, no resource will need any change, only state.

When the state move is finished the __moved__ instructions could be removed. If there are other users that could have used that module it is better to leave them there.

## Move tfstate to remote

After the initial bootstrap we want to store the tfstate inside the storage account created.

To do this create a __backend_configuration.tfvars__ file with the following content

```
resource_group_name  = "rg-bootstrap"
storage_account_name = "storage_account_name_from_terraform_output"
container_name       = "tfstate"
key                  = "bootstrap.tfstate"
```

Change the __backend__ from local to remote in __requirements.tf__

```
  # backend "local" {}
  backend "azurerm" {}
```

Migrate the state

```
terraform init --migrate-state --backend-config=backend_configuration.tfvars
```