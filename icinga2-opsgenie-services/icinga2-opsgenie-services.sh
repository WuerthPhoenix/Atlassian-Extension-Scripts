#!/bin/bash


#"-------------------------------------------------------------------------------------------"
#">> LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            |"
#" | Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          |"
#" | This program comes with ABSOLUTELY NO WARRANTY.                                        |"
#" | This is free software, and you are welcome to redistribute it under certain conditions;|"
#"-------------------------------------------------------------------------------------------"

usage()
{
cat << EOF

-t    | --team                                     OpsGenie Team Id
-a    | --api-token                                OpsGenie Api Token
-u    | --opsgenie-url                             OpsGenie instance URL

EOF
}


while [ "$1" != "" ]; do
    case $1 in
        -t | --team )
            shift
            TeamId=$1
        ;;
        -a | --api-token )
            shift
            opsgenieapitoken=$1
        ;;
        -u | --opsgenie-url )
            shift
            opsgenieAPIURL=$1
        ;;
        -h | --help )    usage
            exit
        ;;

    esac
    shift
done

if [ -z $TeamId ] || [ -z $opsgenieapitoken ] || [ -z $opsgenieAPIURL ] ; then
    echo ""
    echo " Missing parameters"
    echo " runnung -h to let you know more"
    usage
    echo ""
    exit
else

    echo ""
    echo "...executing script for (OpsGenie Team:$project | OpsGenie API:$opsgenieapitoken | OpsGenie URL:$opsgenieAPIURL)"
    echo ""

fi

countCreatedHosts=0


## GET Business Process using Icinga cli command
echo " "
echo " Get Business Processes from Icinga2 / NetEye"
echo " "
hosts=$(icingacli businessprocess process list )
neteyearray=()
IFS=$'\n'
for row in $hosts; do
    if [[ $row =~ ^\( ]];then
        continue
     fi
    echo "Business Process: " $row
    neteyearray+=("$row")
done


echo " "
echo " Retrieve existing services from OpsGenie"
echo " "
opsgeniehosts=$(curl -s -X GET "$opsgenieAPIURL" -H "Authorization: GenieKey $opsgenieapitoken" -H "Content-Type: application/json" | jq '.data[].name' |  sed "s/\"//g" )
opsgeniearray=()

for opsgenierow in $opsgeniehosts; do
    echo "OpsGenie Service: " $opsgenierow
    opsgeniearray+=("$opsgenierow")
done

## GET DIFFERENCES BETWEEN LOCAL AND CLOUD SERVICES
HostDiff=()
for i in "${neteyearray[@]}"; do
    skip=
    for j in "${opsgeniearray[@]}"; do
        [[ $i == $j ]] && { skip=1; break;  }
    done
    [[ -n $skip ]] || HostDiff+=("$i")
done

# CREATE MISSING SERVICE IN OPSGENIE
hostlist=""
for i in "${HostDiff[@]}"
do
           countCreatedHosts=$((countCreatedHosts+1))
           json='{"teamId": "'$TeamId'","name": "'$i'", "tags": ["neteye","business process"] }'
           curl -X POST  "$opsgenieAPIURL" -H "Authorization: GenieKey $opsgenieapitoken" -H "Content-Type: application/json" --data "$json"
           hostlist+=" ( $i ) "
done

if [ -n "$hostlist" ]
then
  echo "OK -  syncronization succesfully executed: created or updated objects: [$hostlist] | business_processes_uploaded=$countCreatedHosts "
 else
  echo "OK -  syncronization succesfully executed: no new hosts have been created or updated | created=0"
fi
exit 0


