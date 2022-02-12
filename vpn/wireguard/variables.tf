variable "do_token" {
  type     = string
  nullable = false
}

variable "keyvault_id" {
  type     = string
  nullable = false
}

variable "users" {
  type     = list(string)
  nullable = false
}

variable "storage_account_name" {
  type     = string
  nullable = false
}
