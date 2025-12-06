# Network
resource "docker_network" "clicker_network" {
  name   = "clicker-network"
  driver = "bridge"
}

# Volume for PostgreSQL data
resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

# PostgreSQL Container
resource "docker_image" "postgres" {
  name = "postgres:15-alpine"
  keep_locally = false
}

resource "docker_container" "postgres" {
  name  = "tp-final-db"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}"
  ]

  ports {
    internal = 5432
    external = var.postgres_external_port
  }

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  volumes {
    host_path      = abspath("${path.root}/../database/00-init.sql")
    container_path = "/docker-entrypoint-initdb.d/00-init.sql"
  }

  volumes {
    host_path      = abspath("${path.root}/../database/01-populate.sql")
    container_path = "/docker-entrypoint-initdb.d/01-populate.sql"
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U postgres"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }

  networks_advanced {
    name    = docker_network.clicker_network.name
    aliases = ["postgres"]
  }

  restart = "unless-stopped"
}

# Backend Image and Container
resource "docker_image" "backend" {
  name = "tp-final-backend:latest"
  build {
    context    = abspath("${path.root}/../backend")
    dockerfile = "Dockerfile"
  }
  keep_locally = false
}

resource "docker_container" "backend" {
  name  = "tp-final-backend"
  image = docker_image.backend.image_id

  env = [
    "DB_HOST=postgres",
    "DB_PORT=5432",
    "DB_USER=${var.postgres_user}",
    "DB_PASSWORD=${var.postgres_password}",
    "DB_NAME=${var.postgres_db}",
    "PORT=${var.backend_port}"
  ]

  ports {
    internal = var.backend_port
    external = var.backend_external_port
  }

  networks_advanced {
    name = docker_network.clicker_network.name
  }

  restart = "unless-stopped"

  depends_on = [docker_container.postgres]
}

# Frontend Image and Container
resource "docker_image" "frontend" {
  name = "tp-final-frontend:latest"
  build {
    context    = abspath("${path.root}/../frontend")
    dockerfile = "Dockerfile"
  }
  keep_locally = false
}

resource "docker_container" "frontend" {
  name  = "tp-final-frontend"
  image = docker_image.frontend.image_id

  ports {
    internal = 80
    external = var.frontend_port
  }

  networks_advanced {
    name = docker_network.clicker_network.name
  }

  restart = "unless-stopped"

  depends_on = [docker_container.backend]
}
