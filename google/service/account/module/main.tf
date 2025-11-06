# Enable required APIs
resource "google_project_service" "required_services" {
  for_each = toset([
    "iam.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Create service account
resource "google_service_account" "service_account" {
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
  project      = var.project_id

  depends_on = [google_project_service.required_services]
}

# Create custom role if trusted actions are provided
resource "google_project_iam_custom_role" "custom_role" {
  count = length(var.trusted_actions) > 0 ? 1 : 0

  role_id     = replace("${var.account_id}_role", "-", "_")
  title       = "${var.display_name} Custom Role"
  description = "Custom role for ${var.display_name}"
  project     = var.project_id
  permissions = var.trusted_actions

  depends_on = [google_project_service.required_services]
}

# Bind custom role to service account
resource "google_project_iam_member" "service_account_role" {
  count = length(var.trusted_actions) > 0 ? 1 : 0

  project = var.project_id
  role    = google_project_iam_custom_role.custom_role[0].id
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

# Bind predefined roles to service account
resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
