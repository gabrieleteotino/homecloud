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