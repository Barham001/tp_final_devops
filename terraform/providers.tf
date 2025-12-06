terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"  # Pour Windows
  # host = "unix:///var/run/docker.sock"   # Pour Linux/Mac
}
