variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "tfstate_bucket_name" {
  description = "Name of the GCS bucket used to store Terraform remote state"
  type        = string
  default     = "mongo-experiments-tfstate"
}

variable "github_repository" {
  description = "GitHub repository in 'owner/repo' format for Workload Identity Federation"
  type        = string
}
