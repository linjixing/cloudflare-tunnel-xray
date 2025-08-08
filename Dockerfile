FROM ubuntu:22.04

LABEL org.opencontainers.image.source https://github.com/linjixing/cloudflare-tunnel-xray

COPY entrypoint.sh /

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y vim tzdata ca-certificates curl wget git unzip sudo net-tools iputils-ping iproute2 supervisor --no-install-recommends; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo "alias ll='ls -la'" >> /etc/bash.bashrc; \
    echo "alias reboot='sudo kill -SIGTERM 1'" >> /etc/bash.bashrc; \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    echo "set fileencodings=utf-8,gbk,utf-16le,cp1252,iso-8859-15,ucs-bom" >> /etc/vim/vimrc; \
    echo "set termencoding=utf-8" >> /etc/vim/vimrc; \
    echo "set encoding=utf-8" >> /etc/vim/vimrc; \
    wget -O /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64; \
    chmod +x /usr/local/bin/ttyd; \
    wget https://github.com/XTLS/Xray-core/releases/download/v25.7.26/Xray-linux-64.zip; \
    unzip -o Xray-linux-64.zip -d /usr/local/bin; \
    rm -rf Xray-linux-64.zip; \
    curl -Lo /usr/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/download/2025.7.0/cloudflared-linux-amd64; \
    chmod +x /usr/bin/cloudflared; \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord","-c","/etc/supervisord.conf"]
