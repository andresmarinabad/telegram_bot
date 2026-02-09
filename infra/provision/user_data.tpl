#!/bin/bash
set -euxo pipefail

echo "=== STARTUP SCRIPT BEGIN ==="

# 1. Instalar Docker de forma oficial y rápida
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 2. Crear usuario del servicio y añadirlo al grupo docker
# Esto permite que el usuario maneje contenedores
if ! id telegram >/dev/null 2>&1; then
  useradd -r -m -d /home/telegram -s /bin/bash telegram
  usermod -aG docker telegram
fi

# 3. Guardar el Token en un archivo de entorno persistente
# Lo guardamos en /etc/profile.d para que esté disponible en sesiones SSH
cat <<EOF > /etc/profile.d/bot_env.sh
export TELEGRAM_BOT_TOKEN="${telegram_bot_token}"
EOF
chmod 644 /etc/profile.d/bot_env.sh

# 4. Limpieza preventiva (Opcional)
# Asegurarse de que no haya restos de instalaciones manuales previas
systemctl stop telegram-bot || true
systemctl disable telegram-bot || true

echo "=== STARTUP SCRIPT READY FOR DOCKER DEPLOYS ==="