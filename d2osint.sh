#!/bin/bash

dom_list=$1
out_csvfile=$2
echo -e "Host, IP, Reverse DNS, ASN, NetBlock Owner"> "$out_csvfile"
while read e; do
    ip=$(dig +short $e | tail -n1)
    if [ -z "$ip" ]
    then
        echo "[!] Could not find an IP for $e"
        echo -e "$e, , , ">> "$out_csvfile"
    else
        ptr=$(dig +noall +answer -x $ip | cut -f 4 | sed -e 's/\.$//')
        whois=$(whois -r --sources RIPE $ip)
        asn=$(echo "$whois" | grep "origin" | tr -d ' ' |cut -d ":" -f 2 )
        asnprov=$(echo "$whois" | grep "descr" | tail -1 | tr -d ' ' |cut -d ":" -f 2 )
        echo -e "[+] Adding $e -> $ip, $ptr, $asn, $asnprov"
        echo -e "$e, $ip, $ptr, $asn, $asnprov">> "$out_csvfile"
    fi
done <$1%
