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
