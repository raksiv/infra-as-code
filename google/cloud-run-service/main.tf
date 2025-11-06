# Cloud Run Service Module

locals {
  required_services = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ]
}

# Enable required services
resource "google_project_service" "required_services" {
  for_each = toset(local.required_services)

  service                    = each.key
  project                    = var.project_id
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Cloud Run service
resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  deletion_protection = var.deletion_protection
  ingress             = var.ingress

  template {
    max_instance_request_concurrency = var.container_concurrency

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.image

      resources {
        cpu_idle = var.cpu_idle
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      ports {
        container_port = var.container_port
      }

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }
    }

    service_account = var.service_account_email
    timeout         = "${var.timeout_seconds}s"
  }

  depends_on = [google_project_service.required_services]
}

# IAM binding for public access (optional)
resource "google_cloud_run_service_iam_member" "public_invoker" {
  count = var.allow_public_access ? 1 : 0

  project  = var.project_id
  service  = google_cloud_run_v2_service.service.name
  location = google_cloud_run_v2_service.service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
