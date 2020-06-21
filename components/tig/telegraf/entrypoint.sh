#!/bin/bash

set -m
CONFIG_TEMPLATE="/telegraf.template.conf"
CONFIG_FILE="/etc/telegraf/telegraf.conf"

ESCAPED_NFS_ROOT=$(printf '%s\n' "$NFS_ROOT" | sed -e 's/[\/&]/\\&/g')
ESCAPED_SNMP_AGENT=$(printf '%s\n' "$SNMP_AGENT" | sed -e 's/[\/&]/\\&/g')

# Replace environment variables with actual values in configuration file
sed -e "s/\${TELEGRAF_HOST}/$TELEGRAF_HOST/" \
    -e "s/\${INFLUXDB_HOST}/$INFLUXDB_HOST/" \
    -e "s/\${INFLUXDB_PORT}/$INFLUXDB_PORT/" \
    -e "s/\${INFLUXDB_DB}/$INFLUXDB_DB/" \
    -e "s/\${NFS_ROOT}/$ESCAPED_NFS_ROOT/" \
    -e "s/\${SNMP_COMMUNITY}/$SNMP_COMMUNITY/" \
    -e "s/\${SNMP_AGENT}/$ESCAPED_SNMP_AGENT/" \
    $CONFIG_TEMPLATE > $CONFIG_FILEFIG_TEMPLATE > $CONFIG_FILE

hddtemp -d --listen localhost --port 7634 /dev/sd*

mount --bind /hostfs/proc/ /proc/

echo "=> Starting Telegraf ..."
exec telegraf -config /etc/telegraf/telegraf.conf
