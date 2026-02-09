variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "project" {
  description = "Project title"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
  default     = "us-central1"
}

variable "telegram_bot_token" {
  description = "Telegram Bot Token"
  type        = string
}

variable "github_owner" {
  type = string
  description = "GitHub repo owner"
}

variable "repo" {
  type = string
  description = "Repository name"
}

variable "github_token" {
  type = string
  description = "Token de GitHub"
}

variable "template_vars" {
  type        = map(any)
  description = "Mapa libre de variables para el script de inicio"
  default     = {}
}
