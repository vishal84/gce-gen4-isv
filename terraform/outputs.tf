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

