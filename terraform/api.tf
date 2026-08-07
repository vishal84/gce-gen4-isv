# ==============================================================================
# Google Cloud APIs Enablement
# ==============================================================================

locals {
  required_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

resource "google_project_service" "required_apis" {
  for_each           = toset(local.required_apis)
  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}
