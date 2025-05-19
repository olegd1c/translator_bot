#!/bin/bash

echo "🚀 Запускаю ngrok..."
# Вкажіть порт ngrok
PORT=5679
DOMAIN="grateful-ocelot-needed.ngrok-free.app"

NGROK_PID=""  # Змінна для PID

# Перевірка наявності процесу
NGROK_PID=$(pgrep -f "ngrok http --domain=$DOMAIN $PORT")

if [ -n "$NGROK_PID" ]; then
    echo "ngrok з доменом $DOMAIN:$PORT вже працює (PID: $NGROK_PID)."
else
    echo "Запуск ngrok..."
    ngrok http --domain="$DOMAIN" "$PORT" &  # Запуск у фоновому режимі
    NGROK_PID=$!  # Зберігаємо PID нового процесу
    sleep 2  # Чекаємо ініціалізації
    echo "ngrok запущено (PID: $NGROK_PID)."
fi

RETRIES=10
NGROK_URL=""

for i in $(seq 1 $RETRIES); do
  NGROK_URL=$(curl -s http://localhost:4040/api/tunnels \
    | grep -o 'https://[a-z0-9.-]*\.ngrok-free\.app' \
    | head -n1)

  if [ ! -z "$NGROK_URL" ]; then
    break
  fi

  echo "🔁 Очікую ngrok... ($i/$RETRIES)"
  sleep 2
done

if [ -z "$NGROK_URL" ]; then
  echo "❌ Не вдалося отримати ngrok URL. Перевір, чи ngrok встановлено та не блокується."
  kill $NGROK_PID
  exit 1
fi

echo "🌐 WEBHOOK_TUNNEL_URL = $NGROK_URL"

echo "🔄 Перезапускаю n8n з новою адресою..."

export WEBHOOK_TUNNEL_URL=$NGROK_URL

WEBHOOK_TUNNEL_URL=$NGROK_URL 
#docker compose down
docker compose --env-file .env --env-file .env.local -f docker-compose.yml -f docker-compose.dev.yml up --build 

echo "✅ n8n запущено! Відкрий http://localhost:5679"
echo "⚠️ Не закривай цей термінал — ngrok працює у фоновому режимі (PID $NGROK_PID)."
