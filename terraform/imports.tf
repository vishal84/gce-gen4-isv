# ==============================================================================
# Declarative Imports for Pre-existing GCP Resources
# ==============================================================================

import {
  to = google_storage_bucket.terraform_state
  id = var.tfstate_bucket_name
}

import {
  to = google_iam_workload_identity_pool.github_pool
  id = "projects/${var.gcp_project_id}/locations/global/workloadIdentityPools/github-pool"
}
