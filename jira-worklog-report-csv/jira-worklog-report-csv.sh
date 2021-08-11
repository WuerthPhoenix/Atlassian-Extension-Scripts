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

echo "Send output to "$worklogoutputfile


usage()
{
cat << EOF


-q    | --jql-query               (option)              default: "updated > startOfMonth() and updated < endOfMonth() and worklogAuthor != empty"
-t    | --create-ticket           (option)              create a ticket in jira.conf specified project by attaching the report
-h    | --help                                          Brings up this menu

EOF
}



jqlquery="updated > startOfMonth() and updated < endOfMonth() and worklogAuthor != empty"
createticket="false"

while [ "$1" != "" ]; do
    case $1 in
        -q| --jql-query )
            shift
            jqlquery=$1
        ;;
        -t| --create-ticket )
            shift
            createticket="true"
        ;;
        -h | --help )    usage
            exit
        ;;
        * )              usage
            exit 1
    esac
    shift
done


# wipe out file
> $worklogoutputfile
# Send standard output to file
exec &>> $worklogoutputfile 2>&1


urlencode() {
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%s' "$c" | xxd -p -c1 |
                   while read c; do printf '%%%s' "$c"; done ;;
        esac
    done
}

query=$( urlencode "$jqlquery") 

getIssueSearch="rest/api/3/search?jql="$query
getSearchPayLoad=$(curl -s --user $jirauser:$jiraapitoken -X GET $jirahost/$getIssueSearch    \
							   -H 'Content-type: application/json'\
							   -H 'Accept: application/json'      \
							   -H 'X-Atlassian-Token: no-check'   \
							   -H 'User-Agent: user-Agent-Name-Here' ) 

echo "WorkLog Author Display Name",       \
     "WorkLog Author Email Address",      \
     "WorkLog Author AccountId",          \
     "IssueId",                           \
     "WorkLog Time Spent",                \
     "WorkLog Started", "WorkLog Updated",\
     "WorkLog Created","CustomField01",   \
     "Assegnee Display Name",             \
     "Assegnee Email",                    \
     "Assegnee Account Id",               \
     "Project key",                       \
     "Aggregate Time Spent",              \
     "Summary",                           \
     "resourceShortName"     ,            \
     "WorkLog Time Spent Decimal"

        jq -c '.issues[] | .key ' <<< "$getSearchPayLoad" | while read issue ; do
        
          # GET ISSUE PAYLOAD 
           getIssueUrl="rest/api/3/issue/$(echo $issue |  sed 's/\"//g')"
           getIssuePayLoad=$( curl  -s --user $jirauser:$jiraapitoken -X GET $jirahost/$getIssueUrl        \
								      -H 'Content-type: application/json'  \
								      -H 'Accept: application/json'        \
								      -H 'X-Atlassian-Token: no-check'     \
								      -H 'User-Agent: user-Agent-Name-Here' )
        
           CustomField01="$( jq -r --arg field CustomField01 '.fields[] 
								| select(.displayName==$field) 
								| .name ' "$config_file" )"
           Aggregatetimespent="aggregatetimespent"
           Summary="summary"
           
        
           total=$(jq '.total' <<< "$getIssuePayLoad")
           if [ "$total" != 0 ]; then
              getResourceIdProperty=$(echo $getIssuePayLoad| jq '.fields.worklog.worklogs[].author.accountId' )



                IFS=$' '       # make newlines the only separator
                echo $(echo $getResourceIdProperty|  sed 's/\"//g') |  while read author ; do  ## loop on authors 
                   #if [ "$getResourceIdProperty" != "" ] ; then
                   if [ "$author" != "" ] ; then            
                      param=$(echo $author |  sed 's/\"//g')                 
                      resourceShortName=$(jq --arg account "$param" '.userproperties[] 
									| select(.key=="ResourceID")
									|  select(.value1==$account)
									| .value2' "$config_file" )
                   fi


                   if [ "$resourceShortName" == ""  ]; then
                      resourceShortName="NULL"
                   fi 

                   echo $getIssuePayLoad | jq  \
                                         --arg customfield01 $CustomField01              \
                                         --arg aggregateTimeSpent $Aggregatetimespent    \
                                         --arg summary $Summary                          \
                                         --arg resourceShortName "$(echo $resourceShortName| sed 's/\"//g')"    \
                                         --arg decimal "$(echo $resourceShortName| sed 's/\"//g')"    \
                                               -f $loc/$worklogfilter |  sed 's/\\"/"/g;s/""/"/g' 
               done
           fi
        
        done


if [ "$createticket" == "true" ]; then
    desc=" \"description\" :  {  \"type\": \"doc\",\"version\": 1,\"content\":[{\"type\":\"paragraph\",\"content\": \
			      [ {\"text\": \"Here the issue for the Worklog report\n\n **JQL QUERY**: \nCLEAR TEXT: \
			      $jqlquery   \n\nENCODED: $query \",\"type\": \"text\"}]}]}"
    
    # CREATE ISSUE AND ATTACH OUTPUT CSV
    jsonCreate="{  \"fields\": {  \"project\":   { \"key\": \"$worklogproject\"}, \"summary\": \"WORKLOG REPORT\", $desc , \"issuetype\": {\"name\": \"Task\" }  }}"
    createUrl="rest/api/3/issue/"
    createIssue=$( curl -s --user $jirauser:$jiraapitoken -X POST $jirahost/$createUrl          \
    							-H 'Content-type: application/json' \
    						        -H 'Accept: application/json'       \
    							-H 'X-Atlassian-Token: no-check'    \
    							-H 'User-Agent: user-Agent-Name-Here' -d  "$jsonCreate" ) 

    
    id=$(echo $createIssue | jq '.id'|  sed 's/\"//g' )
    addAttachmentUrl="rest/api/3/issue/$id/attachments"
    addAttachment=$(  curl -s --user $jirauser:$jiraapitoken -X POST $jirahost/$addAttachmentUrl  \
							     -H 'X-Atlassian-Token: no-check'     \
							     -F "file=@$worklogoutputfile" ) 
fi











