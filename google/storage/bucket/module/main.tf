# Cloud Storage Bucket Module

resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.location
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = try(lifecycle_rule.value.action.storage_class, null)
      }
      condition {
        age                   = try(lifecycle_rule.value.condition.age, null)
        num_newer_versions    = try(lifecycle_rule.value.condition.num_newer_versions, null)
        with_state            = try(lifecycle_rule.value.condition.with_state, null)
      }
    }
  }

  labels = var.labels
}
