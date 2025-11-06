output "service_account_email" {
  description = "Email address of the service account"
  value       = google_service_account.service_account.email
}

output "service_account_id" {
  description = "ID of the service account"
  value       = google_service_account.service_account.id
}

output "service_account_name" {
  description = "Name of the service account"
  value       = google_service_account.service_account.name
}

output "service_account_unique_id" {
  description = "Unique ID of the service account"
  value       = google_service_account.service_account.unique_id
}

output "service_account_member" {
  description = "IAM member string for the service account"
  value       = "serviceAccount:${google_service_account.service_account.email}"
}
