variable "gcp_project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "gcp_region" {
  description = "Région de déploiement"
  type        = string
  default     = "europe-west9"
}

variable "machine_type" {
  description = "Type d'instance Compute Engine"
  type        = string
  default     = "e2-micro"
}
