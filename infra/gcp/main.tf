module "telegram_bot_infra" {
  source = "../../modules/gcp-github-bot"

  project_id   = var.project_id
  region       = var.region
  
  github_owner = var.github_owner
  github_repo  = "telegram_bot"
  
  telegram_bot_token = var.telegram_bot_token

  template_vars = {
    app_name = "telegram-bot"
    service_user = "telegram"
  }
}