#!/bin/sh

# Generates docker-compose file using service name and parameters (--ports)

SERVICE=${1}
while [[ $# -gt 0 ]]; do
    KEY="$1"
    case "$KEY" in
        -p|--ports)
        shift
        PORTS="$1"
        ;;

        *)
        ;;
    esac
    shift
done

ITERABLE_PORTS=${PORTS//,/ }
QUOTED_PORTS=""
PORT_COUNT=`echo ${ITERABLE_PORTS} | wc -w`

i=1
for PORT in ${ITERABLE_PORTS}
do
    if [ "$i" == "$PORT_COUNT" ]; then
        QUOTED_PORTS+='"'${PORT}'"'
    else
        QUOTED_PORTS+='"'${PORT}'", '
    fi

    i=$((i+1))
done

TPL=`cat <<EOF
version: '2'

services:
    ${SERVICE}:
        ports: [${QUOTED_PORTS}]
EOF
`

echo "$TPL"
