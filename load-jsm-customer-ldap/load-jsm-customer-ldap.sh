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

-f    | --force-sync                                (Optional)            Force resync of all created customers in their organization. U
-h    | --help                                      Brings up this menu

EOF
}
forcesync="false"




while [ "$1" != "" ]; do
    case $1 in
        -f | --project-sync )
            shift
            forcesync="true"
        ;;
        -h | --help )    usage
            exit
        ;;

    esac
    shift
done

echo "Executing slow query!!! Be patient"
echo ""
printf '%s %s\n' "$(date)" 
echo "" 


ldapsearch -h $ldaphost -b $ldapbase -D $ldapbind -w $ldappwd $ldapfilter | $loc/tools/ldif-to-csv.sh $ldapfields> $tmpdirldpap

prepareCustomerProperties(){
    createdAccount=$(echo $2 |   sed 's/\"//g')
    orgID=$(echo $3 | sed 's/\"//g')  
    GetCustomerUsers=$4
    jq -c  '.[] |.EMAIL,.ACCOUNTNUMBER, .CUSTOMER' <<< "$GetCustomerUsers" | while read myorgvalue; do
      m=$((m+1))
       case "$m" in
        "1" )
            shift
            property="email"
            
            if [[ "$(echo $myorgvalue| sed 's/\"//g')" == "" ]]; then
                return
            fi
            json="{\"key\" : \"$property\", \"value\"  : $myorgvalue }"
        ;;
        "2" )
            shift
            property="department"
            json="{\"key\" : \"$property\", \"value\"  : $myorgvalue }"
        ;;
        "3" )
            shift
            property="displayname"
            json="{\"key\" : \"$property\", \"value\"  : $myorgvalue }"
        ;;
        * )
    esac
    shift
    
     resturlCusProperties="/rest/api/3/user/properties/contact_$property?accountId="$createdAccount
     createCustomerProperty=$(curl -s --user $jirauser:$jiraapitoken -X PUT $jirahost/$resturlCusProperties \
								    -H 'Content-type: application/json'    \
								    -H 'Accept: application/json' 	   \
								    -H 'X-Atlassian-Token: no-check' 	   \
								    -H 'User-Agent: user-Agent-Name-Here'  -d "$json") 
    if [[ "$m" == 3 ]]; then # increase if you want to add additional informations
     # Before exit add a property with JSM ORG id - used to set Organization via automation
     JSOnorg="{\"key\" : \"jsmorgid\", \"value\"  : $orgID }"
     RESturlOrgProperties="/rest/api/3/user/properties/contact_jsmorgid?accountId="$createdAccount
     CreateCustomerOrgIDProperty=$(curl -s --user $jirauser:$jiraapitoken -X PUT $jirahost/$resturlOrgProperties \
     								    -H 'Content-type: application/json'    \
     								    -H 'Accept: application/json' 	   \
     								    -H 'X-Atlassian-Token: no-check' 	   \
     								    -H 'User-Agent: user-Agent-Name-Here'  -d "$jsonorg") 
     return
    fi
   done  
}



while IFS=, read -r department user givename lastname sAMAccountName
do
              data="{\"name\" : \"$(echo $department |  sed 's/\"//g' )\" }"
              resturl="rest/servicedeskapi/organization"
              getid=$(curl -s --user $jirauser:$jiraapitoken   -X POST $jirahost/$resturl           \
								-H 'Content-type: application/json' \
								-H 'Accept: application/json'       \
								-H 'X-Atlassian-Token: no-check'    \
								-H 'User-Agent: user-Agent-Name-Here' -d "$data") 
              createdId=$(jq '.id' <<< $getid)     
              echo "Organization: $data ($createdId) created! .. or already existing!"

##########################     
##   Create Customers   ##  
##########################       
              customer="{ \"email\" :$user, \"displayName\" : \"$(echo $givename $lastname  |  sed 's/\"//g')\"}"
              resturlCustomer="rest/servicedeskapi/customer"
              getuserResult=$( curl -s  --user $jirauser:$jiraapitoken   -X POST $jirahost/$resturlCustomer         \
										-H 'Content-type: application/json' \
										-H 'Accept: application/json'       \
									        -H 'X-Atlassian-Token: no-check '   \
										-H 'User-Agent: user-Agent-Name-Here' -d "$customer")
              echo "CUSTOMER: $customer created! .. or already existing"
            


#######################################     
##   Add customer to Organizations   ##  
#######################################       
              getMail=$(echo $user|   sed 's/\"//g')
                       getallCustomerUrl="rest/api/3/user/search?query="$getMail
                       getUserEmail=$(curl -s --user $jirauser:$jiraapitoken -X GET $jirahost/$getallCustomerUrl    \
								                -H 'Content-type: application/json' \
										-H  'X-ExperimentalApi: opt-in'     \
										-H 'Accept: application/json'       \
										-H 'X-Atlassian-Token: no-check'    \
										-H 'User-Agent: user-Agent-Name-Here') 
                 createdAccount=$( jq --arg mail $getMail '[.[] | select(.emailAddress=$mail) | .accountId][0]' <<< "$getUserEmail")


                 echo "Force Sync active for: "$createdAccount"  , "$getMail 

                   #################################### 
                   #   Add Customers properties       #
                   ####################################
         
                  echo "Adding properties to user using email: "$getMail
                  jsonproperty="[{\"EMAIL\" :  \"$getMail\"  ,                                       \
				  \"ACCOUNTNUMBER\" :  \"$(echo $department |  sed 's/\"//g' )\"  ,  \
				  \"CUSTOMER\" : \"$(echo $givename $lastname  |  sed 's/\"//g')\" } \
				]" 

                  createProperties=$(prepareCustomerProperties "$getMail" "$createdAccount" "$createdId" "$jsonproperty")
                  echo $createProperties




                  accounts="{\"accountIds\" : [$createdAccount],\"usernames\" : []}"

                  orgID=$(echo $createdId |  sed 's/\"//g')
   
                  resturlCustomer2org="rest/servicedeskapi/organization/$orgID/user"
                  getuser2orgResult=$(curl -s  --user $jirauser:$jiraapitoken   -X POST $jirahost/$resturlCustomer2org \
										-H 'Content-type: application/json'    \
										-H 'Accept: application/json'          \
										-H 'X-Atlassian-Token: no-check'       \
										-H 'User-Agent: user-Agent-Name-Here' -d "$accounts")
                   
        
################################################################## 
#   Add Organization to Project if configured in jira.conf       #
##################################################################
                 jq  '.projects[] as $p | $p | .args[] | select(.activedirectorycustomers=="yes") | $p.name' "$config_file" | while read prj; do
                        ## check if department is valid for this project
                        prjclean=$(echo $prj |  sed 's/\"//g')
                        jq -c  --arg proj "$prjclean" '.projects[] | select(.name==$proj)|  .args[] |  .activedirectorydepartments[] | .department' "$config_file" | while read dep; do                   
                           dep=$(echo $dep |  sed 's/\"//g')
                           department=$(echo $department |  sed 's/\"//g')
                           toBeAdded="false"
                           case $dep in
                              "*" | $department )
                                   shift
                                   toBeAdded="true"
                                   ;;
                               * )        continue                             
                           esac

                           if [[ "$toBeAdded" == "true" ]] ;  then  
                             echo "   Department $dep expected for project $prj"
                             prj=$(echo $prj |  sed 's/\"//g')
                             echo "      Organization : "$createdId" added in Project: "$prj
                             resturlPrj="rest/servicedeskapi/servicedesk/$prj/organization"
                             dataPrj="{\"organizationId\" : $createdId}"
                             getiPrjResult=$(curl -s  --user $jirauser:$jiraapitoken   -X POST $jirahost/$resturlPrj        \
										       -H 'Content-type: application/json'  \
										       -H 'Accept: application/json'        \
										       -H 'X-Atlassian-Token: no-check'     \
										       -H 'User-Agent: user-Agent-Name-Here' -d "$dataPrj")
                           fi
                        done
        
                   done
                

done < $tmpdirldpap
