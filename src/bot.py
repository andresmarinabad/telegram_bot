import os
import json
import random
import logging
import asyncio
from telegram import Update
from telegram.ext import (
    ApplicationBuilder,
    ContextTypes,
    MessageHandler,
    filters,
)

# Logging a stdout (GCP lo recoge automáticamente)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("telegram_bot")

# Cargar respuestas
src_path = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(src_path, "respuestas.json"), encoding="utf-8") as f:
    RESPUESTAS = json.load(f)

async def responder(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message or not update.message.text:
        return

    mensaje = update.message.text.lower()
    logger.info(f"Mensaje recibido: {mensaje}")

    for palabra, posibles_respuestas in RESPUESTAS.items():
        if palabra in mensaje.split():
            respuesta = random.choice(posibles_respuestas)
            await update.message.reply_text(
                respuesta,
                reply_to_message_id=update.message.message_id
            )
            logger.info(f"Respuesta enviada: {respuesta}")
            break

def main():
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    if not token:
        raise RuntimeError("TELEGRAM_BOT_TOKEN no configurado")

    app = (
        ApplicationBuilder()
        .token(token)
        .build()
    )

    app.add_handler(
        MessageHandler(filters.TEXT & ~filters.COMMAND, responder)
    )

    logger.info("=== BOT STARTED ===")
    app.run_polling()

if __name__ == "__main__":
    main()
