import os
import json
import random
from telegram.ext import Updater, MessageHandler, Filters


with open("respuestas.json", "r", encoding="utf-8") as f:
    RESPUESTAS = json.load(f)

def responder(update, context):
    if not update.message or not update.message.text:
        return

    mensaje = update.message.text.lower()
    for palabra, posibles_respuestas in RESPUESTAS.items():
        if palabra in mensaje:
            respuesta = random.choice(posibles_respuestas)
            update.message.reply_text(
                respuesta,
                reply_to_message_id=update.message.message_id
            )
            break

def main():
    TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
    updater = Updater(TOKEN, use_context=True)
    dp = updater.dispatcher
    dp.add_handler(MessageHandler(Filters.text & ~Filters.command, responder))
    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()
