#!/bin/bash
set -euxo pipefail

# 1. Asignar variables de Terraform a variables de Bash al inicio
APP="${app_name}"
USER="${service_user}"

echo "=== STARTUP SCRIPT BEGIN FOR $APP ==="

# 2. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 3. Crear usuario (usando la variable de Bash $USER, no la de TF)
if ! id "$USER" >/dev/null 2>&1; then
  useradd -r -m -d /home/"$USER" -s /bin/bash "$USER"
  usermod -aG docker "$USER"
fi

# 4. Limpieza
systemctl stop "$APP" || true
systemctl disable "$APP" || true

echo "=== STARTUP SCRIPT READY FOR $APP DEPLOYS ==="