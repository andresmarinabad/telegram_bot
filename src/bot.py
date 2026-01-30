import os
import json
import random
import logging
from telegram.ext import Updater, MessageHandler, Filters

# Config logger para archivo local
logger = logging.getLogger("telegram_bot")
logger.setLevel(logging.INFO)

# Log a archivo persistente
log_file_path = "/var/log/telegram-bot.log"
fh = logging.FileHandler(log_file_path)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
fh.setFormatter(formatter)
logger.addHandler(fh)

logger.info("Iniciando bot...")

# Cargar respuestas del bot
try:
    with open("/opt/telegram_bot/src/respuestas.json", "r", encoding="utf-8") as f:
        RESPUESTAS = json.load(f)
except Exception as e:
    logger.error(f"No se pudo cargar respuestas.json: {e}")
    RESPUESTAS = {}

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
