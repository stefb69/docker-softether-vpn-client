FROM debian:bullseye

### SET ENVIRONNEMENT
ENV LANG="ja_JP.UTF-8"

### SETUP
RUN apt -y update && apt -y install cmake gcc g++ make libncurses5-dev libssl-dev libsodium-dev pkg-config libreadline-dev zlib1g-dev supervisor git && \
    git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git && \
    cd SoftEtherVPN && \
    git submodule init && git submodule update && \
    ./configure && \
    make -C build && \
    make -C build install && \
    cd .. && rm -rf SoftEtherVPN

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

