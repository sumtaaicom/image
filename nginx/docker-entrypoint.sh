#!/bin/sh
# Docker 엔트리포인트 스크립트
# 환경변수를 Nginx 설정에 주입

set -e

# 기본값 설정
N8N_WEBHOOK_URL=${N8N_WEBHOOK_URL:-"http://localhost:5678/webhook/"}

# Nginx 설정 파일에서 환경변수 치환
envsubst '${N8N_WEBHOOK_URL}' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf

echo "Starting Nginx with N8N_WEBHOOK_URL: $N8N_WEBHOOK_URL"

# Nginx 실행
exec "$@"
