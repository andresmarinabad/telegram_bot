
# Telegram Bot on Fly.io with Terraform

This project deploys a Telegram bot that responds to messages containing specific keywords. It runs on Fly.io using Docker, and the infrastructure is managed with Terraform. It also includes a GitHub Actions workflow for automatic deployment (CI/CD).

## Requirements

- Python
- Docker
- Terraform
- Fly.io CLI (`fly auth token`)
- Telegram Bot Token (via [@BotFather](https://t.me/BotFather))
- GitHub Actions (for CI/CD)

## How to Use

1. Clone this repository.

2. Fill in your secrets in `terraform.tfvars`:

```hcl
fly_token           = "YOUR_FLY_API_TOKEN"
telegram_bot_token  = "YOUR_TELEGRAM_BOT_TOKEN"
```

3. Deploy using Terraform:

```bash
terraform init
terraform apply
```

4. A first manual deploy is mandatory in order to publish the image so the machine can be created with terraform and pull that image

```bash
flyctl deploy --remote-only --image-label latest
```

## Environment Variables

The bot reads the Telegram token from an environment variable:

- `TELEGRAM_BOT_TOKEN` → your bot’s token from @BotFather

This variable needs to be declared in Fly.io in order to be injected while deploy.

## JSON-based Keyword Responses

The bot responds to messages containing specific words. These keywords and their possible replies are stored in `respuestas.json` like this:

```json
{
  "hello": ["Hi!", "Hello there!", "How can I help?"],
  "thanks": ["You're welcome!", "No problem!", "Anytime!"]
}
```

If the bot detects a word from the list, it replies with a random message from the associated options.


## Folder Structure

```
telegram-bot/
├── bot.py
├── respuestas.json
├── Dockerfile
├── fly.toml
├── main.tf
├── variables.tf
├── terraform.tfvars     # Do not commit this file
├── .gitignore
├── .github/workflows/deploy.yml
└── README.md
```

## Security Tips

- Never commit your `telegram_bot_token` or `fly_token` to the repository.
- Use `terraform.tfvars` locally.
- Use GitHub Actions secrets for CI/CD.

## License

MIT – Free to use, fork, modify. Contributions welcome!

