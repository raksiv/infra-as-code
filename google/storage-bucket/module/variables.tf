variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The location of the bucket"
  type        = string
  default     = "US"
}

variable "force_destroy" {
  description = "When deleting a bucket, delete all objects in it first"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                = optional(number)
      num_newer_versions = optional(number)
      with_state         = optional(string)
    })
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to the bucket"
  type        = map(string)
  default     = {}
}
