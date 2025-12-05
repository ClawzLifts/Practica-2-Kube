variable "mariadb_user" {
  description = "MariaDB user for Matomo"
  type        = string
  default     = "matomo_user"
}

variable "mariadb_password" {
  description = "MariaDB password"
  type        = string
  default     = "matomo_password"
}

variable "mariadb_database" {
  description = "MariaDB database name"
  type        = string
  default     = "matomo_db"
}

variable "dockerhub_username" {
  description = "Docker Hub username for custom Matomo image"
  type        = string
  default     = "clawzlifts"  # Cambiar por tu usuario de Docker Hub
}
