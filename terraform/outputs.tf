output "mongodb_seed_ip" {
  description = "Internal IP address of the MongoDB replica-set seed node."
  value       = google_compute_address.mongodb[0].address
}

output "mongodb_node_ips" {
  description = "Internal IP addresses for all MongoDB replica-set members."
  value       = google_compute_address.mongodb[*].address
}

output "mongodb_instance_names" {
  description = "Names of the deployed MongoDB instances."
  value       = google_compute_instance_from_template.mongodb[*].name
}

output "wif_provider_name" {
  description = "Workload Identity Provider resource name for GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "codemender_service_account_email" {
  description = "Service Account email for CodeMender / GitHub Actions"
  value       = google_service_account.codemender.email
}

output "colab_runtime_id" {
  description = "Resource ID of the deployed Colab Enterprise / Vertex AI Notebook runtime instance (if enabled)"
  value       = var.enable_colab_runtime ? google_notebooks_runtime.mongodb_data_gen[0].id : null
}


