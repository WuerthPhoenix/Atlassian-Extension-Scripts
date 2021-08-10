
caller=$1
path=$2

config_file=$2/jira.conf


echo "Config file [$config_file] loaded"

caller=$1
tmpdir="$( jq -r ' .logdir ' "$config_file" )"
LOGFILE="$tmpdir/$caller.log"



echo "Global source file loaded by $caller in path $path"

jirahost="$( jq -r ' .jirahost ' "$config_file" )"
jirauser="$( jq -r ' .jirauser ' "$config_file" )"
jiraapitoken="$( jq -r ' .jiraapitoken ' "$config_file" )"

logredirect="$( jq -r ' .logredirect ' "$config_file" )"  # true || false
if [ $logredirect == "true" ]; then 
echo $logredirect
 exec &>> $LOGFILE 2>&1
fi


echo "-----------------------"
echo "   GLOBAL VARIABLES    " 
echo "-----------------------"
echo "jira_host:    $jirahost"
echo "jira_user:    $jirauser"
echo "-----------------------"

#
# Insight variables 
#
insightUser="$( jq -r ' .insight.insightuser ' "$config_file" )"
insightHost="$( jq -r ' .insight.insighthost ' "$config_file" )"
insightApiToken="$( jq -r ' .insight.insightapitoken ' "$config_file" )"

productdatajsonfile="$2/$( jq -r  --arg idn "products"    ' .insightRestAPI[]|select(.identifier==$idn) | .sampledatadir ' "$config_file" )"
componentdatajsonfile="$2/$( jq -r --arg idn "components" ' .insightRestAPI[]|select(.identifier==$idn) | .sampledatadir ' "$config_file" )"
echo "JIRA VARIABLES LOADED"
