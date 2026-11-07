# Собираем Go-релей (фронтенд)
#!/bin/bash
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git
RUN git clone https://github.com/telegramdesktop/tproxy-server.git /src
WORKDIR /src
RUN go build -o tproxy-server ./cmd/tproxy-server

# Собираем финальный образ с Python-бэкендом MTProxy
FROM python:3.11-slim
RUN apt-get update && apt-get install -y git socat && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/alexbers/mtprotoproxy.git /mtproxy
RUN pip install cryptography uvloop

COPY --from=builder /src/tproxy-server /usr/local/bin/tproxy-server

COPY run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh
RUN chmod +x /run.sh
CMD ["bash", "/run.sh"]
