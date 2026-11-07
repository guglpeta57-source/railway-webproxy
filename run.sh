#!/bin/bash
if [ -z "$WEB_SECRET" ]; then
  echo "Ошибка: Добавь WEB_SECRET в Railway Variables!"
  exit 1
fi

# 1. Запуск внутреннего MTProxy (бэкенд) на локальном порту 2398
BACKEND_SECRET=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)
python3 /mtproxy/mtprotoproxy.py -p 2398 -s "$BACKEND_SECRET" &

# 2. Генерация ключей для Go-релея
head -c 32 /dev/urandom > /token.key
cat <<EOF > /profiles.json
{
  "profiles": [
    {
      "secret": "$WEB_SECRET",
      "mtproxy": "127.0.0.1:2398"
    }
  ]
}
EOF

# 3. Конфиг tproxy-server (RAILWAY_PUBLIC_DOMAIN подтянется сам)
cat <<EOF > /config.json
{
  "public_hostname": "${RAILWAY_PUBLIC_DOMAIN:-localhost}",
  "base_path": "",
  "listen": "0.0.0.0:$PORT",
  "admin_listen": "127.0.0.1:8081",
  "token_key_file": "/token.key",
  "profiles_file": "/profiles.json"
}
EOF

# 4. Запуск прокси
exec tproxy-server -config /config.json
