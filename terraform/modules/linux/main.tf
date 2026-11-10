terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}
variable "environment" {
  type = string
}
resource "docker_network" "lab" {
  name = "devops-mini-lab-${var.environment}"
}
data "docker_registry_image" "ubuntu" {
  name = "ubuntu:24.04"
}
resource "docker_image" "ubuntu" {
  name          = data.docker_registry_image.ubuntu.name
  pull_triggers = [data.docker_registry_image.ubuntu.sha256_digest]
  keep_locally  = true
}
resource "docker_container" "linux" {
  name    = "devops-mini-lab-${var.environment}-linux"
  image   = docker_image.ubuntu.image_id
  command = ["sleep", "infinity"]
  labels {
    label = "devops-mini-lab"
    value = var.environment
  }
  networks_advanced {
    name = docker_network.lab.name
  }
}
output "container_name" {
  value = docker_container.linux.name
}
output "network_name" {
  value = docker_network.lab.name
}
