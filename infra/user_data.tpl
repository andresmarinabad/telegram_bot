#!/bin/bash
# Actualizar el sistema
apt-get update -y
apt-get upgrade -y

# Instalar git y python3
apt-get install -y git python3 python3-pip

# Crear el directorio para la aplicación
cd /home/ubuntu

# Clonar el repositorio de GitHub
git clone https://github.com/andresmarinabad/telegram_bot.git

# Cambiar al directorio de la aplicación y eliminar el directorio 'infra'
cd telegram_bot
rm -rf infra

# Instalar dependencias de Python desde requirements.txt
cd src
pip3 install -r requirements.txt || true

# Configurar la variable de entorno TELEGRAM_BOT_TOKEN
export TELEGRAM_BOT_TOKEN="${telegram_bot_token}"

# Ejecutar el bot
python3 bot.py
