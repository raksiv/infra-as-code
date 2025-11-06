output "project_id" {
  description = "The GCP project ID where Cloud Shell is enabled"
  value       = var.project_id
}

output "region" {
  description = "The region configured for Cloud Shell"
  value       = var.region
}

output "cloudshell_api_enabled" {
  description = "Whether the Cloud Shell API is enabled"
  value       = google_project_service.cloudshell.service
}
