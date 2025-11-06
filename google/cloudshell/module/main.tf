# Cloud Shell Environment Module
# This module manages Google Cloud Shell environments

resource "google_project_service" "cloudshell" {
  project = var.project_id
  service = "cloudshell.googleapis.com"

  disable_on_destroy = false
}

# Note: Cloud Shell is primarily a user-facing service with limited Terraform resources
# This module enables the API and can be extended with additional configurations
resource "null_resource" "cloudshell_config" {
  depends_on = [google_project_service.cloudshell]

  triggers = {
    project_id = var.project_id
    region     = var.region
  }

  provisioner "local-exec" {
    command = "echo 'Cloud Shell API enabled for project ${var.project_id} in region ${var.region}'"
  }
}
