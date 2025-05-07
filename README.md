
# Telegram Bot

This project consists of a Telegram bot that responds to messages in a group chat based on specific keywords. The bot is built using Python and is hosted on an AWS EC2 instance. The infrastructure is managed using Terraform, and automated actions are set up to handle changes in the source code.

## Project Structure

The project has the following folder structure:

```
/telegram-bot-project
├── infra/               # Contains Terraform configuration files for AWS EC2 instance setup
├── src/                 # Contains the Python source code for the Telegram bot
└── README.md            # Project description and instructions
```

### `infra/`
This folder contains the Terraform files to manage the infrastructure on AWS, including the creation of EC2 instances. When changes are made to the source code, an action is triggered to stop the EC2 instance.

### `src/`
This folder contains the Python code for the Telegram bot. The bot listens for messages in a Telegram group and checks if the message contains any word from a predefined list. For each keyword, the bot has several associated responses and randomly selects one to reply with.

## Features

- **Keyword Detection**: The bot listens for specific keywords in messages. If a message contains any of these keywords, the bot responds with one of several predefined responses.
- **Random Response**: For each keyword, the bot has multiple possible responses, and it randomly selects one of them.
- **AWS EC2 Automation**: An action is triggered whenever there are changes in the source code, automatically stopping the EC2 instance on AWS.
- **Infrastructure as Code**: The infrastructure (EC2 instance) is set up and managed using Terraform, allowing easy provisioning and maintenance.

## Architecture

[architecture.drawio](architecture.drawio)


## Prerequisites

Before you can run the project, make sure you have the following installed:

- Python 3.x
- Terraform
- AWS CLI (with proper IAM permissions)
- Telegram Bot Token (to interact with the Telegram API)

## Setup

### 1. Clone the repository
Clone the repository to your local machine:

```bash
git clone https://github.com/andresmarinabad/telegram_bot.git
cd telegram-bot-project
```

### 2. Set up the infrastructure (AWS EC2)
Navigate to the `infra` directory and initialize Terraform:

```bash
cd infra
terraform init
```

Next, apply the Terraform configuration to provision the AWS resources:

```bash
terraform apply
```

Terraform will create the necessary resources, including an EC2 instance. Ensure your AWS credentials are properly configured in your environment.

### 3. Set up the bot
Navigate to the `src` directory, and install the required Python dependencies:

```bash
cd ../src
pip install -r requirements.txt
```

### 4. Add your Telegram Bot Token
The token is defined in terraform.tfvars and injected to the autoscaling group template when rendered


### 5. Run the bot
To start the bot, run the following command:

```bash
python bot.py
```

The bot will start listening for messages in the Telegram group and respond based on the configured keywords.

## AWS EC2 Auto-Stop Action

Whenever there is a change in the source code, the EC2 instance will be automatically stopped using an action. This ensures that the EC2 instance is not running unnecessarily when changes are being made, saving costs on AWS.

## Contributing

Feel free to fork the repository, create issues, and submit pull requests. If you encounter any bugs or have feature requests, don't hesitate to contribute!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
