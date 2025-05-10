import os
import json
import random
import boto3
import logging
import watchtower
from telegram.ext import Updater, MessageHandler, Filters

# Config logger for CloudWatch
logger = logging.getLogger("telegram_bot")
logger.setLevel(logging.INFO)
boto3_client=boto3.client("logs", region_name="eu-west-1")
logger.addHandler(watchtower.CloudWatchLogHandler(log_group_name="TelegramBot", boto3_client=boto3_client))


# Load answers for the bot
with open("respuestas.json", "r", encoding="utf-8") as f:
    RESPUESTAS = json.load(f)

def responder(update, context):
    if not update.message or not update.message.text:
        return

    mensaje = update.message.text.lower()
    logger.info(f"Mensaje recibido: {mensaje}")

    for palabra, posibles_respuestas in RESPUESTAS.items():
        if palabra in mensaje.split(' '):
            respuesta = random.choice(posibles_respuestas)
            update.message.reply_text(
                respuesta,
                reply_to_message_id=update.message.message_id
            )
            logger.info(f"Respuesta enviada: {respuesta}")
            break

def main():
    TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")

    if not TOKEN:
        logger.error("No se ha configurado el token del bot.")
        return

    updater = Updater(TOKEN, use_context=True)
    dp = updater.dispatcher

    dp.add_handler(MessageHandler(Filters.text & ~Filters.command, responder))

    # Iniciar el bot
    logger.info("Bot iniciado y comenzando a recibir mensajes.")
    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()
