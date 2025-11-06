variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "account_id" {
  description = "The service account ID (must be 6-30 characters)"
  type        = string
  validation {
    condition     = can(regex("^[a-z](?:[-a-z0-9]{4,28}[a-z0-9])$", var.account_id))
    error_message = "The account_id must be 6-30 characters, start with a lowercase letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "display_name" {
  description = "Display name for the service account"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the service account"
  type        = string
  default     = null
}

variable "trusted_actions" {
  description = "List of IAM permissions for custom role"
  type        = list(string)
  default     = []
}

variable "roles" {
  description = "List of predefined IAM roles to assign"
  type        = list(string)
  default     = []
}
