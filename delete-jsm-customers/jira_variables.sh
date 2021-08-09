
echo ""
echo ""
echo ""
echo "-------------------------------------------------------------------------------------------"
echo ">> LICENSED UNDER GNU General Public License, v3 (see LICENSE.md for details)             |"
echo " | Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          |"
echo " | This program comes with ABSOLUTELY NO WARRANTY.                                        |"
echo " | This is free software, and you are welcome to redistribute it under certain conditions;|"
echo "-------------------------------------------------------------------------------------------"
echo ""
echo ""
echo ""
echo ""

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


echo "------------------------------------------------------"
echo "   GLOBAL VARIABLES    " 
echo "-----------------------------------------------------"
echo "jira_host:    $jirahost"
echo "jira_user:    $jirauser"
echo "-----------------------------------------------------"


echo "JIRA VARIABLES LOADED"
