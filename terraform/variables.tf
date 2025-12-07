variable "postgres_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "password123"
  sensitive   = true
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "tpfinal"
}

variable "backend_port" {
  description = "Backend application port"
  type        = number
  default     = 8081
}

variable "frontend_port" {
  description = "Frontend exposed port"
  type        = number
  default     = 3000
}

variable "postgres_external_port" {
  description = "PostgreSQL external port"
  type        = number
  default     = 5433
}

variable "backend_external_port" {
  description = "Backend external port"
  type        = number
  default     = 8081
}
