#!/bin/sh
set -e

if [ "$1" = 'supervisord' ]; then
  if [ -z ${SE_SERVER+x} ]; then
    echo "Please provide SE_SERVER environment variable" 2>&1
    exit
  fi
  
  if [ -z ${SE_HUB+x} ]; then
    echo "Please provide SE_HUB environment variable" 2>&1
    exit
  fi
  
  if [ -z ${SE_USERNAME+x} ]; then
    echo "Please provide SE_USERNAME environment variable" 2>&1
    exit
  fi
  
  if [ -z ${SE_PASSWORD+x} ]; then
    echo "Please provide SE_PASSWORD environment variable" 2>&1
    exit
  fi

  # rebuild profile from scratch
  rm -f /usr/vpnclient/vpn_client.config

  # start it once on background for configuration
  vpnclient start

  # skip adapter creation if exists
  if grep -q vpn_${SE_NICNAME} /proc/net/dev; then 
    printf "NIC ${SE_NICNAME} already exists, skipping creation" 1>&2
  else
    vpncmd localhost \
      /CLIENT \
      /CMD NicCreate ${SE_NICNAME} > /dev/null 2>&1
    vpncmd localhost \
      /CLIENT \
      /CMD NicSetSetting ${SE_NICNAME} /MAC:${SE_NICMAC} > /dev/null 2>&1
  fi

  # create account
  vpncmd localhost \
    /CLIENT \
    /CMD AccountCreate ${SE_ACCOUNT_NAME} \
    /SERVER:${SE_SERVER} \
    /HUB:${SE_HUB} \
    /USERNAME:${SE_USERNAME} \
    /NICNAME:${SE_NICNAME} > /dev/null 2>&1

  # set account password
  vpncmd localhost \
    /CLIENT \
    /CMD AccountPasswordSet ${SE_ACCOUNT_NAME} \
    /PASSWORD:${SE_PASSWORD} \
    /TYPE:${SE_TYPE} > /dev/null 2>&1

  # set account to auto-connect
  vpncmd localhost \
    /CLIENT \
    /CMD AccountStartupSet ${SE_ACCOUNT_NAME} > /dev/null 2>&1

  vpnclient stop
fi

exec "$@"
