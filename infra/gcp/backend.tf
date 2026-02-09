terraform {
  backend "gcs" {
    bucket  = "my-telegram-bot-486909-tfstate"
    prefix  = "terraform/state"
  }
}