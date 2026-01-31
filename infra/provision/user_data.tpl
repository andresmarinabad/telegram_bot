#!/bin/bash
set -e

echo "=== STARTUP SCRIPT BEGIN ==="

sudo apt-get update -y
sudo apt-get upgrade -y

# Instalar dependencias necesarias
sudo apt-get install -y software-properties-common curl git build-essential \
libssl-dev zlib1g-dev libncurses5-dev libncursesw5-dev libreadline-dev \
libsqlite3-dev libffi-dev libbz2-dev wget git curl

# Agregar PPA de deadsnakes para Python 3.13
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update -y

# Instalar Python 3.13 y herramientas relacionadas
sudo apt-get install -y python3.13 python3.13-venv python3.13-dev


# Instalar uv
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

source $HOME/.local/bin/env


if [ ! -d telegram_bot ]; then
  git clone https://github.com/andresmarinabad/telegram_bot.git
fi

cd telegram_bot

# Instalar dependencias con uv
uv sync


# Crear servicio systemd
cat <<EOF | sudo tee /etc/systemd/system/telegram-bot.service
[Unit]
Description=Telegram Bot
After=network.target

[Service]
Environment=TELEGRAM_BOT_TOKEN=${telegram_bot_token}
ExecStart=/home/andres_marin_abad/telegram_bot/.venv/bin/python3.13 /home/andres_marin_abad/telegram_bot/src/bot.py
Restart=always
User=root
WorkingDirectory=/home/andres_marin_abad/telegram_bot/src
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable telegram-bot
sudo systemctl start telegram-bot

