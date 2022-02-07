variable "key_vault_id" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("\\/subscriptions\\/([0-9A-Fa-f]{8}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{12})\\/resourceGroups\\/(.+)\\/providers\\/Microsoft\\.KeyVault\\/vaults\\/.+", var.key_vault_id))
    error_message = "Key Vault Id is not in the right format."
  }
}

variable "location" {
  type    = string
  default = "West Europe"
}