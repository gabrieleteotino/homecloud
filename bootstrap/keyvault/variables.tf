variable "resource_group_name" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[0-9a-zA-z-_]{1,64}$", var.resource_group_name))
    error_message = "Resouce group names must be between 1 and 64 characters in length and may contain numbers, letters, underscore, and hyphen only."
  }
}
