# Apache Drill 1.20.4 with Unicode Fix

Этот репозиторий содержит настроенную версию Apache Drill 1.20.4 с исправлением проблем Unicode литералов при работе с MySQL.

## Быстрый старт

### Клонирование и запуск
\`\`\`bash
git clone https://github.com/your-username/drill-unicode-fix.git
cd drill-unicode-fix
docker-compose up -d
\`\`\`

### Или через готовый скрипт
\`\`\`bash
chmod +x scripts/start.sh
./scripts/start.sh
\`\`\`

## Доступ

- **Web UI**: http://localhost:8047
- **RPC Port**: 31010

## Что исправлено

- ✅ Отключены Unicode escape литералы (`u&'...'`)
- ✅ Настроена правильная кодировка UTF-8
- ✅ Добавлен MySQL JDBC драйвер
- ✅ Оптимизированы настройки для работы с текстом

## Настройка MySQL источника

В веб-интерфейсе создайте новый storage plugin:

\`\`\`json
{
  "type": "jdbc",
  "driver": "com.mysql.cj.jdbc.Driver",
  "url": "jdbc:mysql://your-host:3306/database?useUnicode=true&characterEncoding=UTF-8",
  "username": "your-username",
  "password": "your-password",
  "enabled": true
}
\`\`\`

## Управление

\`\`\`bash
# Остановить
docker-compose down

# Перезапустить
docker-compose restart

# Логи
docker logs drill-unicode-fix

# Подключиться к командной строке
docker exec -it drill-unicode-fix bin/drill-localhost
\`\`\`
\`\`\`

## .gitignore
```gitignore
# Docker
.env

# Logs
*.log
logs/

# IDE
.vscode/
.idea/
*.iml

# OS
.DS_Store
Thumbs.db

# Временные файлы
*.tmp
*.temp
