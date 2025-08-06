FROM ubuntu:22.04

LABEL org.opencontainers.image.source https://github.com/linjixing/cloudflare-tunnel-xray

COPY entrypoint.sh /

RUN export DEBIAN_FRONTEND=noninteractive; \
    chmod +x /entrypoint.sh; \
    echo "alias ll='ls -la'" >> /etc/bash.bashrc; \
    echo "alias reboot='sudo kill -SIGTERM 1'" >> /etc/bash.bashrc; \
    apt update; \
    apt install -y software-properties-common openssh-server sudo cron tzdata curl wget unzip vim \
    telnet net-tools iputils-ping iproute2 supervisor --no-install-recommends; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*; \
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
    curl -Lo /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/download/2025.7.0/cloudflared-linux-amd64; \
    chmod +x /usr/local/bin/cloudflared; \
    mkdir /var/run/sshd

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord","-c","/etc/supervisord.conf"]
