terraform {
  backend "remote" {
    organization = "andres-marin-abad"

    workspaces {
      name = "telegram-bot"
    }
  }

  required_providers {
    fly = {
      source  = "andrewbaxter/fly"
      version = "0.1.18"
    }
  }
}

provider "fly" {
  fly_api_token = var.fly_token
}

resource "fly_app" "bot" {
  name = var.fly_app
  org  = "personal"
}

