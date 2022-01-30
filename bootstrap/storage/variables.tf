variable "location" {
  type     = string
  nullable = false
}

variable "resource_group_name" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[0-9a-zA-z-_]{1,64}$", var.resource_group_name))
    error_message = "Resouce group names must be between 1 and 64 characters in length and may contain numbers, letters, underscore, and hyphen only."
  }

}

variable "storage_account_name" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[0-9a-z]{3,24}$", var.storage_account_name))
    error_message = "Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only."
  }
}