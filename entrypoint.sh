#!/bin/bash

# set
PARAM_SS_PORT=""
if [ "${SS_PORT}" ]
then
    PARAM_SS_PORT=${SS_PORT}
else
    PARAM_SS_PORT=36000
fi
PARAM_SS_PASSWORD=""
if [ "${SS_PASSWORD}" ]
then
    PARAM_SS_PASSWORD="${SS_PASSWORD}"
else
    PARAM_SS_PASSWORD="`head -n 4096 /dev/urandom | tr -cd '[:alnum:]!@#$%^&*_' | head -c 16`"
fi
PARAM_SS_METHOD=""
if [ "${SS_METHOD}" ]
then
    PARAM_SS_METHOD="${SS_METHOD}"
else
    PARAM_SS_METHOD="aes-256-gcm"
fi
PARAM_NS_DEVICE=""
ETH=$(eval "ifconfig | grep 'eth0'| wc -l")
if [ "$ETH"  ==  '1' ]
then
    PARAM_NS_DEVICE="eth0"
else
    PARAM_NS_DEVICE="venet0"
fi

# output
echo "----- ----- ----- ----- -----"
echo "----- ----- ----- ----- -----"
echo "----- ----- ----- ----- -----"
if [ "${SS_PORT}" ]
then
    echo "ss port: ${PARAM_SS_PORT} (created by env)"
else
    echo "ss port: ${PARAM_SS_PORT}"
fi
if [ "${SS_PASSWORD}" ]
then
    echo "ss password: ${PARAM_SS_PASSWORD} (created by env)"
else
    echo "ss password: ${PARAM_SS_PASSWORD}"
fi
if [ "${SS_METHOD}" ]
then
    echo "ss method: ${PARAM_SS_METHOD} (created by env)"
else
    echo "ss method: ${PARAM_SS_METHOD}"
fi
echo "----- ----- ----- ----- -----"
echo "----- ----- ----- ----- -----"
echo "----- ----- ----- ----- -----"

# run
if [ "${NS_OFF}" != "true" ]
then
    echo "net-speeder ${PARAM_NS_DEVICE} [enabled]"
    echo "----- ----- ----- ----- -----"
    nohup /usr/local/bin/net_speeder ${PARAM_NS_DEVICE} "ip" >/dev/null 2>&1 &
    ip a
    ping yahoo.com -c 5
    echo "----- ----- ----- ----- -----"
    echo "----- ----- ----- ----- -----"
    echo "----- ----- ----- ----- -----"
fi

if [ "${NGROK_LINK}" ]
then
    if [ "${NGROK_PORT}" ]
    then
        wget -O ngrok "${NGROK_LINK}"
        chmod +x ngrok
        touch ngrok.cfg
        cat >./ngrok.cfg<<EOF
        server_addr: "${NGROK_SERVER}"
        trust_host_root_certs: false
        tunnels:
            test:
                remote_port: ${NGROK_PORT}
                proto:
                  tcp: ${PARAM_SS_PORT}
        EOF
        nohup ./ngrok -config=ngrok.cfg start test >/dev/null 2>&1 &
    else
        wget -O ngrok "${NGROK_LINK}"
        chmod +x ngrok
        nohup ./ngrok ${NGROK_RUN} >/dev/null 2>&1 &
    fi
fi

/usr/local/bin/ssserver -p ${PARAM_SS_PORT} -k ${PARAM_SS_PASSWORD} -m ${PARAM_SS_METHOD}
