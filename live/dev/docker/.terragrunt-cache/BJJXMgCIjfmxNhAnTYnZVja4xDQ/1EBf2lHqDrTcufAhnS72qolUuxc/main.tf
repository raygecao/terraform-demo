terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "guestbook" {
  name         = "ibmcom/guestbook:${var.guestbook_image_tag}"
  keep_locally = true
}

resource "docker_container" "guestbook" {
  image = docker_image.guestbook.image_id
  name  = "tutorial"
  ports {
    internal = 3000
    external = var.external_port
  }
  env = ["REDIS_MASTER_SERVICE_PORT=6379", "REDIS_MASTER_SERVICE_HOST=${docker_container.redis.network_data[0].ip_address}", "REDIS_MASTER_SERVICE_PASSWORD=dea1452fe9133ea28e60b25f70fa93c43bcfeca9648d0cb470a473f563c91af6"]
}

resource "docker_image" "redis" {
  name         = "redis:5.0.5-alpine"
  keep_locally = true
}

resource "docker_container" "redis" {
  name = "storage"
  image = docker_image.redis.image_id
  command = ["--requirepass", "dea1452fe9133ea28e60b25f70fa93c43bcfeca9648d0cb470a473f563c91af6"]
}
