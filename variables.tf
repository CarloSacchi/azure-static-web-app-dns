variable "project_name" {
  type        = string
  description = "Project name - will be used in resource naming"
  default     = "hugostaticwa"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "westeurope"
}

variable "domain_name" {
  type        = string
  description = "Custom domain name"
  default     = "domain.ext"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    "ManagedBy" = "Terraform"
    "Owner"     = "Project Owner Name"
  }
}