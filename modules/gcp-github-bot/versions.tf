terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Permite actualizaciones menores (5.1, 5.2) pero no cambios de versión mayor
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}