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

resource "fly_machine" "bot_instance" {
  app   = fly_app.bot.name
  image = "registry.fly.io/${fly_app.bot.name}:latest"
  name  = "${fly_app.bot.name}-machine"

  env = {
    TELEGRAM_BOT_TOKEN = var.telegram_bot_token
    PORT               = "8080"
  }

  region = "mad"

}

