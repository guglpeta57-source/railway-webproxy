# 3. Конфиг tproxy-server (теперь слушает только локально)
cat <<EOF > /config.json
{
  "public_hostname": "${RAILWAY_PUBLIC_DOMAIN:-localhost}",
  "base_path": "",
  "listen": "127.0.0.1:8080",
  "admin_listen": "127.0.0.1:8081",
  "token_key_file": "/token.key",
  "profiles_file": "/profiles.json"
}
EOF

# 4. Проброс внешнего порта Railway ($PORT) на локальный порт (8080)
socat TCP-LISTEN:$PORT,fork,bind=0.0.0.0 TCP:127.0.0.1:8080 &

# 5. Запуск прокси
exec tproxy-server -config /config.json
