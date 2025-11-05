variable "name" {
  description = "The name of the GitHub repository"
  type        = string
}

variable "description" {
  description = "A description of the repository"
  type        = string
  default     = ""
}

variable "visibility" {
  description = "The visibility of the repository (public, private, or internal)"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "Visibility must be one of: public, private, internal"
  }
}

variable "repoType" {
  description = "The type of repository (for categorization)"
  type        = string
  default     = "other"
}

variable "topics" {
  description = "List of topics for the repository"
  type        = list(string)
  default     = []
}

variable "admins" {
  description = "List of GitHub teams or users with admin access (format: team:teamname or user:username)"
  type        = list(string)
  default     = []
}

variable "writers" {
  description = "List of GitHub teams or users with write access (format: team:teamname or user:username)"
  type        = list(string)
  default     = []
}

variable "enable_branch_protection" {
  description = "Whether to enable branch protection on the main branch"
  type        = bool
  default     = true
}

# Processed variables
locals {
  # Split admins into teams and users
  admin_teams = [
    for item in var.admins :
    trimprefix(item, "team:") if startswith(item, "team:")
  ]
  admin_users = [
    for item in var.admins :
    trimprefix(item, "user:") if startswith(item, "user:")
  ]

  # Split writers into teams and users
  writer_teams = [
    for item in var.writers :
    trimprefix(item, "team:") if startswith(item, "team:")
  ]
  writer_users = [
    for item in var.writers :
    trimprefix(item, "user:") if startswith(item, "user:")
  ]
}

variable "admin_teams" {
  description = "Processed list of admin team IDs"
  type        = list(string)
  default     = []
}

variable "admin_users" {
  description = "Processed list of admin usernames"
  type        = list(string)
  default     = []
}

variable "writer_teams" {
  description = "Processed list of writer team IDs"
  type        = list(string)
  default     = []
}

variable "writer_users" {
  description = "Processed list of writer usernames"
  type        = list(string)
  default     = []
}
