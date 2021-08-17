#!/bin/sh

loc=$(dirname "$0")

apidirector="apidirector:<Token>"

## GET HOSTS FROM NETEYE

icingaAPIToken="<Icinga API Token>"
icingaAPIUser="<user>"

hosts=$(curl -k -s -u $icingaAPIUser:$icingaAPIToken -H 'Accept: application/json'   'https://localhost:5665/v1/objects/hosts' | jq '.results[].attrs | .__name' |  sed "s/\"//g" )
neteyearray=()

echo "[" > $loc/neteye-hosts.json

for name in $hosts
do
      org="Acme"
      searchKey=$name"_"$org
      desc="Loaded from $(hostname)"
      link="https://$(hostname)/neteye/monitoring/host/show?host=$name"
      outs=$(jq --arg key0   'PRODUCTNAME' \
           --arg value0 "$name" \
           --arg key1   'PRODUCTDESCRIPTION' \
           --arg value1 "$desc" \
           --arg key2   'PRODUCT_ORGANIZATION' \
           --arg value2 "$org" \
           --arg key3   'SEARCHKEY' \
           --arg value3  "$searchKey" \
           --arg key4   'LINK' \
           --arg value4  "$link" \
           '. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2 | .[$key3]=$value3 | .[$key4]=$value4 '  \
           <<<'{}')
        #out=$outs","$out
     echo $outs"," >> $loc/neteye-hosts.json

done

echo "]" >> $loc/neteye-hosts.json

awk 'NR>2{print a;} {a=b; b=$0} END{sub(/,$/, "", a); print a;print b;}' $loc/neteye-hosts.json | jq '.' > $loc/neteye-hosts-ready.json

$loc/load-jsm-cmdb-neteye.sh


exit 0

