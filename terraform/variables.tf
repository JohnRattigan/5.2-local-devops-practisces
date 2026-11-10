variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Choose dev or prod."
  }
}

variable "docker_host" {
  type        = string
  default     = "unix:///var/run/docker.sock"
  description = "Docker Desktop: set TF_VAR_docker_host from docker context inspect if needed."
}

# Teaching example only; intentionally never passed to a resource or output.
variable "dummy_secret" {
  type        = string
  sensitive   = true
  default     = null
  description = "Sensitive masks display; it does NOT encrypt state. Do not use real secrets here."
}
