
caller=$1
path=$2

config_file=$2/jira.conf
echo "Config file [$config_file] loaded"

caller=$1
tmpdir="$( jq -r ' .logdir ' "$config_file" )"
LOGFILE="$tmpdir/$caller.log"




# WORKLOG EXPORT
worklogfilter="$( jq -r ' .export.worklogfilter ' "$config_file" )"
worklogoutputfile="$( jq -r ' .export.worklogoutputfile ' "$config_file" )"
worklogproject="$( jq -r ' .export.worklogproject ' "$config_file" )"



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


# Jira Single line text field used to TAG worklog information 
CustomField01="$( jq -r --arg field CustomField01 '.fields[] | select(.displayName==$field) | .name ' "$config_file" )"     



