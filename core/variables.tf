variable "location" {
  type     = string
  default  = "West Europe"
  nullable = false
}

variable "github_token" {
  type      = string
  nullable  = false
  sensitive = true
}