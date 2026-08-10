# ==============================================================================
# Google Cloud Storage Bucket for Terraform Remote State
# ==============================================================================

resource "google_storage_bucket" "terraform_state" {
  project       = var.gcp_project_id
  name          = var.tfstate_bucket_name
  location      = "US-CENTRAL1"
  force_destroy = false

  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
      with_state         = "ARCHIVED"
    }
  }

  depends_on = [google_project_service.required_apis]

  lifecycle {
    prevent_destroy = true
  }
}
