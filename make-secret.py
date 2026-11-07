import os, base64

raw_secret = os.urandom(16)
print(f"WEB_SECRET (вставить в Railway Variables): {raw_secret.hex()}")

url_secret = base64.urlsafe_b64encode(b'\x70' + raw_secret).decode().rstrip('=')
print(f"Ссылка: tg://webproxy?server=ДОМЕН_RAILWAY&secret={url_secret}")
input("Нажмите Enter, чтобы закрыть окно...")