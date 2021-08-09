#!/bin/bash


#"-------------------------------------------------------------------------------------------"
#">> LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            |"
#" | Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          |"
#" | This program comes with ABSOLUTELY NO WARRANTY.                                        |"
#" | This is free software, and you are welcome to redistribute it under certain conditions;|"
#"-------------------------------------------------------------------------------------------"
loc=$(dirname "$0")
me=`basename "$0"`
source $loc/jira_variables.sh $me $loc
usage()
{
cat << EOF

-d    | --delete                                   (DANGER)   If not specified customers will not be deleted
-h    | --help                                     Brings up this menu
-c    | --customer-limit                           Expected customer amount limit (default 1000)
-o    | --org-limit                                Expected organization amount limit (default 200)
-f    | --fetch-maxresult                          Fetch size param (default 100)

EOF
}
delete="false"

customerlimit=1000
orglimit=200
fetchmax=100


while [ "$1" != "" ]; do
    case $1 in
        -d | --delete )
            shift
            delete="true"
        ;;
        -c | --customer-limit )
            shift
            customerlimit=$1
        ;;
        -o | --org-limit )
            shift
            orglimit=$1
        ;;
        -f | --fetch-maxresult )
            shift
            fetchmax=$1
        ;;
        -h | --help )    usage
            exit
        ;;

    esac
    shift
done

if [[ "$delete" == "true" ]]; then
    read -p "Are you sure? (Y/y to contine) " -n 1 -r
    echo   
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo   
        echo "START DELETION.. TO LATE!!!"
    echo   
    else
    echo   
        echo "DELETION HAS BEEN CANCELLED... ON TIME!! "
    echo   
        exit
    fi
fi

i=0

until [ $i -gt $customerlimit ]
do
  echo "----------------------------------------------------------------"
  echo "[delete=$delete] $fetchmax customers will be deleted starting from postion: $i[/$customerlimit]"
  echo "----------------------------------------------------------------"
     
     getallCustomerUrl="rest/api/3/users/search?maxResults=$fetchmax&startAt=$i"
     echo $getallCustomerUrl
     
     getUser=$(curl -s --user $jirauser:$jiraapitoken -X GET $jirahost/$getallCustomerUrl    \
							-H 'Content-type: application/json'  \
						        -H 'X-ExperimentalApi: opt-in'       \
						        -H 'Accept: application/json'        \
						        -H 'X-Atlassian-Token: no-check'     \
						        -H 'User-Agent: user-Agent-Name-Here' ) 
     
     
     jq ' .[] | select(.accountType=="customer") | .accountId  ' <<< $getUser  | while read user; do
       if [[ "$delete" == "true" ]]; then
         url="/rest/api/3/user?accountId=$(echo $user |  sed 's/\"//g') "
         deleteuser=$(curl -s  --user $jirauser:$jiraapitoken -X DELETE $jirahost/$url       \
                                                        -H 'Content-type: application/json'  \
						        -H 'X-ExperimentalApi: opt-in'       \
						        -H 'Accept: application/json'        \
						        -H 'X-Atlassian-Token: no-check'  -H 'User-Agent: user-Agent-Name-Here' ) 
         echo DELETED CUSTOMER: $user  -- $deleteuser
       else
         echo  "Found customer [$user] that could be deleted"
       fi
     done 
     
    ((i=i+$fetchmax))
done

j=0
until [ $j -gt $orglimit ]
do
  echo "----------------------------------------------------------------"
  echo "[delete=$delete] $fetchmax organizations will be deleted starting from postion: $j[/$orglimit]"
  echo "----------------------------------------------------------------"
    getallOrgUrl="rest/servicedeskapi/organization?maxResults=maxResults=$fetchmax&startAt=$j"
    getOrg=$(curl -s --user $jirauser:$jiraapitoken -X GET $jirahost/$getallOrgUrl           \ 
							-H 'Content-type: application/json'  \
						        -H 'X-ExperimentalApi: opt-in'       \
						        -H 'Accept: application/json'        \
						        -H 'X-Atlassian-Token: no-check'     \
						        -H 'User-Agent: user-Agent-Name-Here') 
    
    
    jq ' .values[] | .id  ' <<< $getOrg  | while read org; do
      if [[ "$delete" == "true" ]]; then
        url="rest/servicedeskapi/organization/$(echo $org |  sed 's/\"//g') "
        deleteorg=$(curl -s  --user $jirauser:$jiraapitoken -X DELETE $jirahost/$url         \
							-H 'Content-type: application/json'  \
						        -H 'X-ExperimentalApi: opt-in'       \
						        -H 'Accept: application/json'        \
						        -H 'X-Atlassian-Token: no-check'     \
						        -H 'User-Agent: user-Agent-Name-Here') 
        echo DELETED ORGANIZATION: $org -- $deleteorg
      else
        echo  "Found organization [$org] that could be deleted"
      fi
    done 
    ((j=j+$fetchmax))
done
