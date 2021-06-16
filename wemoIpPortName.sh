#!/bin/sh
#
# Gets IP Address, Port and Friendly Name of WeMo devices.
#

# run using:
#   bash wemoIpPortname.sh

for i in {64..253}
do 
    ip="192.168.1.${i}"

    # prior to running a curl command make sure the IP Address is responding to pings
    # this check significantly cuts down run time
    # running without this check doesn't yield any more WeMo devices
    p=$(ping -c1 -t2 ${ip} | grep ' 0.0%')
    if [[ ! -z "$p" ]]
    then
        for port in {49151..49156}
        do
            # m2 returns 19 of 31. Increasing to m4 had no change
            r=$(curl -0 -m2 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetFriendlyName\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetFriendlyName xmlns:u="urn:Belkin:service:basicevent:1"><FriendlyName></FriendlyName></u:GetFriendlyName></s:Body></s:Envelope>' -s http://$ip:$port/upnp/control/basicevent1 | grep "<FriendlyName")
            r=${r%</FriendlyName>*} 
            r=${r##*<FriendlyName>} 
            if [[ ! -z "$r" ]]
            then
                echo "${ip} ${port} ${r}"
                # found one, so to decrease run-time skip remaining ports
                break
            fi
        done
    fi
done
