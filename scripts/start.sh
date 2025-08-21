#!/bin/bash

# Скрипт для быстрого запуска Drill

echo "Starting Apache Drill 1.20.4 with Unicode fix..."

# Остановим существующий контейнер если есть
docker stop drill-unicode-fix 2>/dev/null || true
docker rm drill-unicode-fix 2>/dev/null || true

# Запустим новый контейнер
docker-compose up -d

echo "Waiting for Drill to start..."
sleep 30

# Проверим статус
if curl -s http://37.252.23.30:8047/ > /dev/null; then
    echo "✅ Drill started successfully!"
    echo "🌐 Web UI: http://37.252.23.30:8047"
    echo "📋 Logs: docker logs drill-unicode-fix"
else
    echo "❌ Failed to start Drill"
    echo "Check logs: docker logs drill-unicode-fix"
fi
