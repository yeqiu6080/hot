#!/bin/sh

set -e

echo "正在下载 Cloudflared..."

# 下载 cloudflared
curl -LO https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
mv cloudflared-linux-amd64 /usr/local/bin/cloudflared

echo "正在生成 Supervisor 配置..."

# 生成 supervisor.conf
cat > /etc/supervisor/supervisord.conf << 'EOF'
[supervisord]
logfile=/var/log/supervisor/supervisord.log
logfile_maxbytes=10MB
logfile_backups=10
loglevel=info
pidfile=/var/run/supervisor/supervisord.pid
nodaemon=true
childlogdir=/var/log/supervisor

[inet_http_server]
port=127.0.0.1:9005

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=http://127.0.0.1:9005

[program:cloudflared]
command=/usr/local/bin/cloudflared tunnel --no-autoupdate run --token %(ENV_CF_ZERO_TRUST_TOKEN)s
directory=/
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
autostart=true
autorestart=true
startsecs=5
stopwaitsecs=5
killasgroup=true
EOF

echo "初始化完成！"
