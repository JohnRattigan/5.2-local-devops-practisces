provider "docker" {
  host = var.docker_host
}

module "linux" {
  source      = "./modules/linux"
  environment = var.environment
}
