#!/usr/bin/env sh

cat > /etc/supervisord.conf << EOF
[supervisord]
[supervisord]
nodaemon=true
logfile=/dev/null

[include]
files=/etc/supervisor/conf.d/*.conf

[unix_http_server]
file=/var/run/supervisor.sock

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

[program:ttyd]
command=ttyd -c root:password -W bash
autostart=true
autorestart=true

[program:xray]
command=xray -c /etc/xray.json
autostart=true
autorestart=true

[program:cloudflared]
command=cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token $TOKEN
autostart=true
autorestart=true
EOF

cat > /etc/xray.json << EOF
{
    "log": {
        "loglevel": "warning",
        "access": "/dev/null",
        "error": "/dev/null"
    },
    "dns": {
        "servers": ["https+local://1.1.1.1/dns-query", "localhost"]
    },
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [{
            "type": "field",
            "ip": ["geoip:cn", "geoip:private"],
            "outboundTag": "block"
        },
        {
            "type": "field",
            "domain": ["geosite:category-ads-all"],
            "outboundTag": "block"
        }]
    },
    "inbounds": [{
        "port": $PORT,
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "$UUID"
            }]
        },
        "streamSettings": {
            "network": "ws",
            "security": "none",
            "wsSettings": {
                "path": "/ws?ed=2048"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom",
        "tag": "direct"
    },
    {
        "protocol": "blackhole",
        "tag": "block"
    }]
}
EOF

cat > /tmp/vmess.txt << EOF
vmess://$(echo "{ \"v\": \"2\", \"ps\": \"$DOMAIN-443\", \"add\": \"104.16.0.0\", \"port\": \"443\", \"id\": \"$UUID\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$DOMAIN\", \"path\": \"/ws?ed=2048\", \"tls\": \"tls\", \"sni\": \"$DOMAIN\", \"alpn\": \"\", \"fp\": \"\"}" | base64 -w0)
vmess://$(echo "{ \"v\": \"2\", \"ps\": \"$DOMAIN-8443\", \"add\": \"104.17.0.0\", \"port\": \"8443\", \"id\": \"$UUID\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$DOMAIN\", \"path\": \"/ws?ed=2048\", \"tls\": \"tls\", \"sni\": \"$DOMAIN\", \"alpn\": \"\", \"fp\": \"\"}" | base64 -w0)
vmess://$(echo "{ \"v\": \"2\", \"ps\": \"$DOMAIN-2053\", \"add\": \"104.18.0.0\", \"port\": \"2053\", \"id\": \"$UUID\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$DOMAIN\", \"path\": \"/ws?ed=2048\", \"tls\": \"tls\", \"sni\": \"$DOMAIN\", \"alpn\": \"\", \"fp\": \"\"}" | base64 -w0)
vmess://$(echo "{ \"v\": \"2\", \"ps\": \"$DOMAIN-2083\", \"add\": \"104.19.0.0\", \"port\": \"2083\", \"id\": \"$UUID\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$DOMAIN\", \"path\": \"/ws?ed=2048\", \"tls\": \"tls\", \"sni\": \"$DOMAIN\", \"alpn\": \"\", \"fp\": \"\"}" | base64 -w0)
vmess://$(echo "{ \"v\": \"2\", \"ps\": \"$DOMAIN-2087\", \"add\": \"104.20.0.0\", \"port\": \"2087\", \"id\": \"$UUID\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$DOMAIN\", \"path\": \"/ws?ed=2048\", \"tls\": \"tls\", \"sni\": \"$DOMAIN\", \"alpn\": \"\", \"fp\": \"\"}" | base64 -w0)
EOF

exec "$@"
