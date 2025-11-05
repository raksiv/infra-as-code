variable "project_id" {
  description = "The GCP project ID where Cloud Shell will be enabled"
  type        = string
}

variable "region" {
  description = "The GCP region for Cloud Shell configuration"
  type        = string
  default     = "us-central1"
}
