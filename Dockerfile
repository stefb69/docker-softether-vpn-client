FROM debian:bullseye

### SET ENVIRONNEMENT
ENV LANG="ja_JP.UTF-8"

### SETUP
RUN apt -y update && apt -y install make gcc libcap-dev libssl-dev libncurses-dev readline-common supervisor wget && \
    wget -o sec.tar.gz https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.39-9772-beta/softether-vpnclient-v4.39-9772-beta-2022.04.26-linux-x64-64bit.tar.gz && \
    tar -xvf sec.tar.gz && \
    cd vpnclient && \
    make && \
    cd .. && \
    mv vpnclient /usr/vpnclient && cd /usr/vpnclient && \
    chmod 600 * && chmod 700 vpncmd && chmod 700 vpnclient && \
    cp /usr/vpnclient/vpnclient /usr/bin/ && \
    cp /usr/vpnclient/vpncmd /usr/bin

# Adjust at runtime
#ENV SE_SERVER
#ENV SE_HUB
#ENV SE_USERNAME
#ENV SE_PASSWORD

# Default values
ENV SE_ACCOUNT_NAME=default
ENV SE_TYPE=standard
ENV SE_NICNAME=vpn

COPY assets/entrypoint.sh /entrypoint.sh
COPY assets/supervisord.conf /etc/
COPY assets/dhclient-enter-hooks /etc/dhclient-enter-hooks

RUN chmod +x /entrypoint.sh /etc/dhclient-enter-hooks

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

