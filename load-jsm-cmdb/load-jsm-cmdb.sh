#!/bin/bash

loc=$(dirname "$0")
me=`basename "$0"`
source $loc/jira_variables.sh $me $loc


usage()
{
cat << EOF

-h    | --help                                      Brings up this menu
-v    | --verbose                                   Echo Update/Create call


EOF
}

verbose="false"
while [ "$1" != "" ]; do
    case $1 in
        -h | --help )    usage
            echo "See README.md for more information"
            echo 
            exit
        ;;
        -v | --verbose )
            verbose="true"
        ;;

    esac
    shift
done


# https://developer.atlassian.com/cloud/insight/rest/api-group-object/#api-object-create-post
getWorkSpaceIdURL="/rest/servicedeskapi/insight/workspace"
getWorkSpace="$(curl -s --user $jirauser:$jiraapitoken -X GET $jirahost/$getWorkSpaceIdURL -H 'Content-type: application/json' -H 'Accept: application/json' -H 'X-ExperimentalApi: opt-in')"
workspace=$(echo $getWorkSpace | jq -r '.values[] | .workspaceId ' ) 
version="1"



createJson4products(){
     start=0
     numberOfAttr="$( jq -r --arg  objectType $2 '   .insightRestAPI[]
                                                      | select(.identifier==$objectType)
                                                      | .objectTypeAttributes|length ' "$config_file" )"

     IFS=";"
     objectTypeId="$( jq -r --arg  objectType $2 '   .insightRestAPI[]
                                                      | select(.identifier==$objectType)
                                                      |.objectTypeId ' "$config_file" )"

     echo $1 | while read -r i;
       do
             placeholder=$(echo $i   |  sed 's/\"//g' |  sed 's/ $//g')
             case "$placeholder" in
                 Name*)
                     start=$(($start+1))
                     attr="Name"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;
                 Description*)
                     start=$(($start+1))
                     attr="Description"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;
                 SearchKey*)
                     start=$(($start+1))
                     attr="SearchKey"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;
                 Organization*)
                     start=$(($start+1))
                     attr="Organization"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;
                 Price*)
                     start=$(($start+1))
                     attr="Price"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;                 
		 ItemNumber*)
                     start=$(($start+1))
                     attr="ItemNumber"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;                 
             esac


              if [ "$attr" == "" ];  # TODO this is a workaround!!
               then
                 continue
               else
                  objectTypeAttributeId="$(jq -r --arg attribute $attr --arg objectType $2     ' .insightRestAPI[]
                                                                                               | select(.identifier==$objectType)
                                                                                               | .objectTypeAttributes[]
                                                                                               | select(.attributename==$attribute)|.attributeid' "$config_file" )"

                  str=$str"{\"objectTypeAttributeId\" : \"$objectTypeAttributeId\" ,  \"objectAttributeValues\": [{\"value\": \"$(echo $value |sed 's/ $//' )\" }]},"
              fi
              donestr=" { \"objectTypeId\": \"$objectTypeId\", \"attributes\" : [$str] }"
              if [ $start -eq $numberOfAttr ]; then 
                      echo $donestr  |sed 's/,]}$/]}/' | sed 's/,]/]/g'
              fi

     done
}



createJson4components(){
     start=0
     numberOfAttr="$( jq -r --arg  objectType $2 '   .insightRestAPI[]
                                                      | select(.identifier==$objectType)
                                                      | .objectTypeAttributes|length ' "$config_file" )"

     IFS=";"
     objectTypeId="$( jq -r  --arg objectType $2 '   .insightRestAPI[]
                                                           | select(.identifier==$objectType)
                                                           |.objectTypeId ' "$config_file" )"

     echo $1 | while read -r i;
       do
             placeholder=$(echo $i   |  sed 's/\"//g' |  sed 's/ $//g')
             case "$placeholder" in
                 Name*)
                     start=$(($start+1))
                     attr="Name"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;
                 ComponentDescription*)
                     start=$(($start+1))
                     attr="ComponentDescription"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;
                 ComponentModel*)
                     start=$(($start+1))
                     attr="ComponentModel"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;
                 ProductItemNumber*)
                     start=$(($start+1))
                     attr="ProductItemNumber"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;                 
                 SearchKey*)
                     start=$(($start+1))
                     attr="SearchKey"
                     value=$( cut -d ":" -f2- <<< $placeholder)
                 ;;
             esac


              if [ "$attr" == "" ];  # TODO this could be a bug!!
               then
                 continue
               else
                  objectTypeAttributeId="$(jq -r --arg attribute $attr --arg objectType $2 '.insightRestAPI[]
                                                                                             | select(.identifier==$objectType)
                                                                                             | .objectTypeAttributes[]
                                                                                             | select(.attributename==$attribute)|.attributeid' "$config_file" )"
                  str=$str"{\"objectTypeAttributeId\" : \"$objectTypeAttributeId\" ,  \"objectAttributeValues\": [{\"value\": \"$(echo $value |sed 's/ $//' )\" }]},"
              fi

               donestr=" { \"objectTypeId\": \"$objectTypeId\", \"attributes\" : [$str] }"

               if [ $start -eq $numberOfAttr ]; then  # if you add new attribute do not forget to increase this number!!  :-)
                      echo $donestr  |sed 's/,]}$/]}/' | sed 's/,]/]/g'
               fi

     done
}



createInsightObject(){
    payload=$1
    name="SearchKey"

    attributesToDisplay="$( jq -r  --arg attribute $name --arg objectType $2 ' .insightRestAPI[]
                                                                                             | select(.identifier==$objectType)
                                                                                             |.objectTypeAttributes[]
                                                                                             | select(.attributename==$attribute)|.attributeid' "$config_file" )"
    attributesToDisplay=$(echo $attributesToDisplay |   sed 's/\"//g' )

    objectTypeId="$( jq -r  --arg objectType $2 '.insightRestAPI[]
                                                                | select(.identifier==$objectType)
                                                                | .objectTypeId ' "$config_file" )"


    objectSchemaId="$( jq -r  --arg objectType $2 '.insightRestAPI[]
                                                                | select(.identifier==$objectType)
                                                                | .objectSchemaId ' "$config_file" )"
    objectSchemaId=$(echo $objectSchemaId |   sed 's/\"//g' )


 
    jq -r --arg objid $attributesToDisplay ' .attributes[]| select(.objectTypeAttributeId==$objid) | .objectAttributeValues[].value ' <<< "$payload" |  while read line; do
        line="$line"


        checkpayload="{ \"objectTypeId\": \"$objectTypeId\", \
                         \"attributesToDisplay\": { \"attributesToDisplayIds\": [ $attributesToDisplay ] },  \
                         \"page\": 1,\"asc\": 1,\"resultsPerPage\": 25,\"includeAttributes\": false, \
                         \"objectSchemaId\": \"$objectSchemaId\", \
                         \"iql\": \"$name=$line\"  }"
  
  
        checkIfExistsUrl="https://api.atlassian.com/jsm/insight/workspace/$workspace/v$version/object/navlist/iql"
        checkIfExtistResult=$(curl -s --user $jirauser:$jiraapitoken -X POST $checkIfExistsUrl -H 'Content-type: application/json' -H 'Accept: application/json' -H 'X-ExperimentalApi: opt-in' -d "$checkpayload" )
        totalFilterCount=$(jq '.totalFilterCount '<<< "$checkIfExtistResult"  ) 
        ########## START LINK CREATION #############
        if [[ "$2" == "components" ]];then
                  linkfield="ProductLink"
                  targetobjectTypeAttributeId="$( jq --arg mytype $2 --arg link $linkfield '.| .insightRestAPI[]  
        								| select(.identifier==$mytype) 
        								| .objectTypeAttributes[] 
        								| select(.attributename==$link)
        								| .targetobjectTypeAttributeId'  "$config_file" )"

                  linkAttributeId="$( jq --arg link $linkfield --arg mytype $2  '.| .insightRestAPI[]  
        						    | select(.identifier==$mytype) 
        						    | .objectTypeAttributes[] 
        						    | select(.attributename==$link)
        						    | .attributeid'  "$config_file" )"

                  sourceobjectTypeAttributeId="$( jq --arg link $linkfield --arg mytype $2 '.| .insightRestAPI[]  
        								| select(.identifier=$mytype) 
        								| .objectTypeAttributes[] 
        								| select(.attributename==$link)
        								| .sourceobjectTypeAttributeId'  "$config_file" )"
                 ProductNumber=$(echo $payload | jq --arg sourceobjectTypeAttributeId $(echo $sourceobjectTypeAttributeId |sed 's/\"//g') ' .attributes[]| 
				  				  			 			                             select(.objectTypeAttributeId==$sourceobjectTypeAttributeId)	
		   														             | .objectAttributeValues | .[].value' )

                 if [[ "$ProductNumber" != "" ]];then

                           targetobjectTypeId="$( jq --arg link $linkfield  --arg mytype $2  '.| .insightRestAPI[]  
                 						     | select(.identifier==$mytype) 
                						     | .objectTypeAttributes[] 
                 						     | select(.attributename==$link)
                						     | .targetobjectTypeId'  "$config_file" )"


                           targetSchemaId="$( jq --arg link $linkfield --arg mytype $2  '.| .insightRestAPI[]  
                						 | select(.identifier==$mytype) 
                						 | .objectTypeAttributes[] 
                						 | select(.attributename==$link)
                						 | .targetSchemaId'  "$config_file" )"

                           iql="ItemNumber=$ProductNumber"
                           searchProjectsPayload="{ \"objectTypeId\": \"$(echo $targetobjectTypeId |   sed 's/\"//g'  )\", \
                                            \"attributesToDisplay\": { \"attributesToDisplayIds\": [ $(echo $targetobjectTypeAttributeId |   sed 's/\"//g'  )] },  \
                                            \"page\": 1,\"asc\": 1,\"resultsPerPage\": 25,\"includeAttributes\": false, \
                                            \"objectSchemaId\": \"$(echo $targetSchemaId |   sed 's/\"//g'  )\", \
                                           \"iql\": \"$(echo $iql  |   sed 's/\"//g'  )\"  }"


                            searchProjectsPayloadUrl="https://api.atlassian.com/jsm/insight/workspace/$workspace/v$version/object/navlist/iql"

                            searchProjectsPayloadResult=$(curl -s --user $jirauser:$jiraapitoken -X POST $searchProjectsPayloadUrl   \
                									-H 'Content-type: application/json' \
                									-H'Accept: application/json'  -d "$searchProjectsPayload" )

                            targetProjectId=$(echo $searchProjectsPayloadResult| jq '.objectEntries[] | .id' )

                            if [[ "$targetProjectId" != "" ]];then
                               payload=$(echo $payload | jq --arg src $(echo $linkAttributeId|sed 's/\"//g') --arg val $(echo $targetProjectId |sed 's/\"//g') '.attributes += [{ "objectTypeAttributeId": $src, "objectAttributeValues": [{ "value": $val } ]  }]')
                            fi 
                 fi
        fi
       #  ############# END LINK CREATION ###############

             if [[ "$totalFilterCount" -gt "0" ]]; then
               echo "(<>)  [$2] An existing object with SearchKey [$line] has been found. It will be updated"
                 id=$(jq '.objectEntries[].id '<<< "$checkIfExtistResult"  ) 
                 putInsightUrl="https://api.atlassian.com/jsm/insight/workspace/$workspace/v$version/object/$(echo $id |  sed 's/\"//g')"
                 ##########################
                 #         UPDATE         #
                 ##########################
                 update=$(curl -s --user $jirauser:$jiraapitoken -X PUT $putInsightUrl               \
								 -H 'Content-type: application/json' \
								 -H 'Accept: application/json' -d "$payload" )
                 if [ "$verbose"  == "true" ]; then
                   echo "--------------------------- UPDATE CALL -------------------------------"
                   echo
                   echo $update
                fi
             else
               echo "  (++)  [$2] A new object with SearchKey [$line] will be created"
                 ##########################
                 #         CREATE         #
                 ##########################
                 postInsightUrl="https://api.atlassian.com/jsm/insight/workspace/$workspace/v$version/object/create"
                 create=$(curl -s --user $jirauser:$jiraapitoken -X POST $postInsightUrl             \
								 -H 'Content-type: application/json' \
								 -H 'Accept: application/json' -d "$payload" )
                 if [ "$verbose"  == "true" ]; then
                   echo "--------------------------- CREATE CALL -------------------------------"
                   echo
                   echo $create
                fi
             fi
 
           done 
    
}



###################################
## LOOP ON PRODUCTS
###################################

 echo "Product Data Json file: $productdatajsonfile"
 echo "Component Data Json file: $componentdatajsonfile"


 jq ' .[]  |  "Name:"+.PRODUCTNAME+";"                            ,
       "Description:"+.PRODUCTDESCRIPTION+";"                     , 
       "Organization:"+.PRODUCT_ORGANIZATION+";"                  , 
       "Price:"+.PRICE+";"                                        , 
       "SearchKey:"+.SEARCHKEY+";"                                , 
       "ItemNumber:"+.PRODUCT_ITEMNUMBER+"|"  ' "$productdatajsonfile" |  while read -r -d "|" productline; do


                Productresult=$(createJson4products "$productline" "products" )  # TODO - Improvement - The Type can be retrieved from jira.conf

                echo $(createInsightObject "$Productresult" "products" )

                ###################################
                ## LOOP ON COMPONENTS
                ###################################
                echo "$productline" | while read prod; do

                    if [[ "$prod" =~ ^\"ItemNumber.* ]]; then
                         ProductNumberAttr=$( cut -d ":" -f2- <<< $prod)
                         ProductNumberAttr=$(echo $ProductNumberAttr |   sed 's/\"//g' |   sed 's/\;//g')                                 

                    
                         jq --arg product $ProductNumberAttr ' .[] | .COMPONENTS[] | select(.PRODUCT_ITEMNUMBER==$product)      | 
                                     "Name:"+.Name+";"                                                              ,
                                     "ComponentDescription:"+.COMPONENTDESCRIPTION+";"                              ,
                                     "ComponentModel:"+.COMPONENT_MODEL+";"                                         ,
                                     "ProductItemNumber:"+.PRODUCT_ITEMNUMBER+";"                                   ,
       				     "SearchKey:"+.SEARCHKEY+"|"  ' "$componentdatajsonfile" |  while read -r -d "|" componentline; do

                                             Componentresult=$(createJson4components "$componentline"  "components" )
                                             echo $(createInsightObject "$Componentresult" "components"  )
                                     done
                    fi
                 done
 done




