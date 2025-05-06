#!/bin/bash
yum update -y
yum install -y git python3

cd /home/ec2-user
mkdir app && cd app
git clone https://github.com/andresmarinabad/telegram_bot.git
cd telegram_bot
rm -rf infra
cd src

pip3 install -r requirements.txt || true

export TELEGRAM_BOT_TOKEN="${telegram_bot_token}"
python3 bot.py