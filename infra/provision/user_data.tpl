#!/bin/bash
set -e

echo "=== STARTUP SCRIPT BEGIN ==="

apt-get update -y
apt-get upgrade -y
apt-get install -y git python3.13 python3-pip curl

# Instalar uv
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

cd /opt

if [ ! -d telegram_bot ]; then
  git clone https://github.com/andresmarinabad/telegram_bot.git
fi

cd telegram_bot

# Instalar dependencias con uv
uv sync

# Guardar el token como variable global del sistema
echo "TELEGRAM_BOT_TOKEN=${telegram_bot_token}" >> /etc/environment

# Crear servicio systemd
cat <<EOF | sudo tee /etc/systemd/system/telegram-bot.service
[Unit]
Description=Telegram Bot
After=network.target

[Service]
Environment=TELEGRAM_BOT_TOKEN=${telegram_bot_token}
ExecStart=/opt/telegram_bot/.venv/bin/python3.13 /opt/telegram_bot/src/bot.py
Restart=always
User=root
WorkingDirectory=/opt/telegram_bot/src
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable telegram-bot
sudo systemctl start telegram-bot

