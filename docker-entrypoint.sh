#!/bin/sh
set -e
CONFDIR=/etc/exim4

# By default, send email directly to the recipient.
DC_EXIMCONFIG_CONFIGTYPE="internet"

# By default, only hosts on the private network can use the smart host (ie,
# only other containers, not the whole internet); a thin layer of protection
# in case port 25 is accidentally exposed to the public internet.
DC_RELAY_NETS="10.0.0.0/8;172.16.0.0/12;192.168.0.0/16"

# If RELAY_HOST has been set then switch to smart host configuration.
if [ -n "$RELAY_HOST" ]; then
    DC_EXIMCONFIG_CONFIGTYPE="satellite"
    DC_SMARTHOST="$RELAY_HOST::${RELAY_PORT:-25}"
    if [ -n "$RELAY_USERNAME" ] && [ -n "$RELAY_PASSWORD" ]; then
        printf '%s\n' "*:$RELAY_USERNAME:$RELAY_PASSWORD" > "$CONFDIR/passwd.client"
    fi
fi

# Set which hosts can use the smart host.
if [ -n "$RELAY_NETS" ]; then
    DC_RELAY_NETS="$RELAY_NETS"
fi

# Set local interfaces (IP addresses to listen on).
DC_LOCAL_INTERFACES="${LOCAL_INTERFACES:-}"

# Set other hostnames (additional domains to accept mail for).
DC_OTHER_HOSTNAMES="${OTHER_HOSTNAMES:-}"

# Set relay domains (domains to relay mail for).
DC_RELAY_DOMAINS="${RELAY_DOMAINS:-}"

# Set whether to hide the local mailname in outgoing mail (default: true).
DC_HIDE_MAILNAME="${HIDE_MAILNAME:-true}"

# Set local delivery method (mail_spool, maildir_home, maildir_directory).
DC_LOCALDELIVERY="${LOCAL_DELIVERY:-mail_spool}"

# Write exim configuration.
cat << EOF > "$CONFDIR/update-exim4.conf.conf"
dc_eximconfig_configtype='$DC_EXIMCONFIG_CONFIGTYPE'
dc_other_hostnames='$DC_OTHER_HOSTNAMES'
dc_local_interfaces='$DC_LOCAL_INTERFACES'
dc_readhost=''
dc_relay_domains='$DC_RELAY_DOMAINS'
dc_minimaldns='false'
dc_relay_nets='$DC_RELAY_NETS'
dc_smarthost='${DC_SMARTHOST:-}'
CFILEMODE='644'
dc_use_split_config='false'
dc_hide_mailname='$DC_HIDE_MAILNAME'
dc_mailname_in_oh='true'
dc_localdelivery='$DC_LOCALDELIVERY'
EOF

# Set primary_hostname.
if [ -n "$MAILNAME" ]; then
    printf '%s\n' "$MAILNAME" > /etc/mailname
    printf '%s\n' "MAIN_HARDCODE_PRIMARY_HOSTNAME=$MAILNAME" >> "$CONFDIR/update-exim4.conf.conf"
fi

# Apply exim configuration.
update-exim4.conf

exec "$@"
