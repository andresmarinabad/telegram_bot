FROM python:3.11-slim

WORKDIR /app

COPY bot.py .
COPY respuestas.json .
COPY requirements.txt .

RUN pip install -r requirements.txt

CMD ["python", "bot.py"]