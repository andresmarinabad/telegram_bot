#!/bin/bash
set -euxo pipefail

echo "=== STARTUP SCRIPT BEGIN ==="

# ----------------------------
# Crear usuario del servicio
# ----------------------------

# Crear usuario telegram con HOME real
if ! id telegram >/dev/null 2>&1; then
  useradd -r -m -d /home/telegram -s /usr/sbin/nologin telegram
else
  mkdir -p /home/telegram
  chown telegram:telegram /home/telegram
fi


# ----------------------------
# Paquetes base
# ----------------------------
apt-get update -y
apt-get install -y \
  software-properties-common \
  curl \
  git \
  build-essential

# ----------------------------
# Instalar uv GLOBAL (clave)
# ----------------------------
curl -LsSf https://astral.sh/uv/install.sh | sh

# Mover binario a PATH global
install -m 0755 /root/.local/bin/uv /usr/local/bin/uv

# ----------------------------
# Clonar repo en /opt
# ----------------------------
if [ ! -d "${APP_DIR}" ]; then
  git clone https://github.com/andresmarinabad/telegram_bot.git "${APP_DIR}"
fi

chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}"

# ----------------------------
# Crear venv y deps como el usuario
# ----------------------------
sudo -u "${APP_USER}" bash <<EOF
set -euxo pipefail
cd "${APP_DIR}"
uv sync
EOF

# ----------------------------
# Variables de entorno
# ----------------------------
cat <<EOF > "${ENV_FILE}"
TELEGRAM_BOT_TOKEN=${telegram_bot_token}
EOF

chmod 600 "${ENV_FILE}"

# ----------------------------
# systemd service
# ----------------------------
cat <<EOF > /etc/systemd/system/telegram-bot.service
[Unit]
Description=Telegram Bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${APP_USER}
WorkingDirectory=${APP_DIR}
EnvironmentFile=${ENV_FILE}
ExecStart=${APP_DIR}/.venv/bin/python src/bot.py
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# ----------------------------
# Activar servicio
# ----------------------------
systemctl daemon-reload
systemctl enable telegram-bot
systemctl start telegram-bot

echo "=== STARTUP SCRIPT END ==="