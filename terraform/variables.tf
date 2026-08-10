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

variable "enable_colab_runtime" {
  description = "Whether to deploy Google Cloud Colab Enterprise runtime template and instance for data generation"
  type        = bool
  default     = false
}

variable "colab_runtime_user" {
  description = "User email for the Colab Enterprise runtime instance. If provided and enable_colab_runtime is true, an active runtime instance will be provisioned."
  type        = string
  default     = ""
}

