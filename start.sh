#!/bin/sh

if [ -z "$DOMAIN" ]; then
    echo "DOMAIN environment variable is required"
    exit 1
fi

if [ -z "$SELECTOR" ]; then
    echo "DOMAIN environment variable is required"
    exit 1
fi

cat >> /etc/opendkim.conf <<EOF
UMask                   002
Syslog                  yes
SyslogSuccess           yes
LogWhy                  yes

# Sign mail with the ORIGINATING macro
MTA                     ORIGINATING

InternalHosts           127.0.0.0/8
InternalHosts           [::1]/128
# Allow other Docker containers to have their mail signed
InternalHosts           172.17.0.0/16

Canonicalization        relaxed/simple

Domain                  ${DOMAIN}
Selector                ${SELECTOR}
KeyFile                 /etc/dkim.key

Mode                    s
SignatureAlgorithm      rsa-sha256

# Always oversign From (sign using actual From and a null From to prevent
# malicious signatures header fields (From and/or others) between the signer
# and the verifier.  From is oversigned by default in the Debian pacakge
# because it is often the identity key used by reputation systems and thus
# somewhat security sensitive.
OversignHeaders     From

# Make our self available
Socket                  inet:12301
EOF
cat >> /etc/default/opendkim <<EOF
SOCKET="inet:12301"
EOF

ETCD_PORT=${ETCD_PORT:-4001}
HOST_IP=${HOST_IP:-172.17.42.1}
ETCD=$HOST_IP:$ETCD_PORT

#echo "waiting for confd to create primary configuration files"
#until /opt/confd -onetime -node $ETCD; do
#     sleep 1s
# done

# /opt/confd -watch -node $ETCD &
# echo "confd is now monitoring for changes in primary configuration files..."

echo "waiting for confd to create initial DKIM key"
until /opt/confd -onetime -node $ETCD -prefix "/services/dkim/$DOMAIN/$SELECTOR" -confdir /opt/confd-dkim; do
    sleep 1s
done

/opt/confd -watch -node $ETCD -prefix "/services/dkim/$DOMAIN/$SELECTOR" -confdir /opt/confd-dkim &
echo "confd is now monitoring DKIM key for changes..."


exec /usr/sbin/opendkim -f
