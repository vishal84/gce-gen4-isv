# ==============================================================================
# Google Cloud Colab Enterprise / Vertex AI Notebook Runtime Configuration
# ==============================================================================

resource "google_notebooks_runtime" "mongodb_data_gen" {
  count    = var.enable_colab_runtime ? 1 : 0
  name     = "mongodb-data-gen-runtime"
  location = local.region
  project  = local.project_id

  access_config {
    access_type   = "SINGLE_USER"
    runtime_owner = var.colab_runtime_user != "" ? var.colab_runtime_user : "admin@example.com"
  }

  software_config {
    idle_shutdown         = true
    idle_shutdown_timeout = 60
  }

  virtual_machine {
    virtual_machine_config {
      machine_type = "e2-standard-4"

      data_disk {
        initialize_params {
          disk_size_gb = 100
          disk_type    = "PD_STANDARD"
        }
      }

      network = google_compute_network.mongodb.id
      subnet  = google_compute_subnetwork.mongodb.id
    }
  }

  depends_on = [google_project_service.required_apis]
}
