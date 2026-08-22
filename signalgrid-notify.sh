#!/bin/bash

CLIENT_KEY="[your-client-key]"
CHANNEL_TOKEN="[your-channel-token]"

TITLE="$1"
BODY="$2"
NAGIOS_STATE="$3"

if [ "$4" = "true" ]; then
    IS_CRITICAL="true"
else
    IS_CRITICAL="false"
fi

case "$NAGIOS_STATE" in
    OK|UP)         TYPE="SUCCESS" ;;
    WARNING)       TYPE="WARN"    ;;
    CRITICAL|DOWN) TYPE="CRIT"    ;;
    *)             TYPE="INFO"    ;;
esac

curl -s \
  --form-string "client_key=$CLIENT_KEY" \
  --form-string "channel=$CHANNEL_TOKEN" \
  --form-string "type=$TYPE" \
  --form-string "title=$TITLE" \
  --form-string "body=$BODY" \
  --form-string "critical=$IS_CRITICAL" \
https://api.signalgrid.co/v1/push
