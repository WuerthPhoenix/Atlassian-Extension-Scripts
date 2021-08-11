## jira-worklog-report-csv
<br>
Script that creates a CSV report with all the Jira/Jira Service Managenent Worklog registration entries based on a JQL call  (Cloud tested). If necessary the script attaches the output report to a new Jira Issue for easier access.

#### LICENSE

LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            
Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          
This program comes with ABSOLUTELY NO WARRANTY.                                        
This is free software, and you are welcome to redistribute it under certain conditions;


### jira.conf
- Script Configuration. This file needs to be filled with Atlassian environment access.
- worklogproject: a valid Jira project KEY should be specified if script parameter -t (create issue) will be used 
- FIELDS: Extract customfield. In the configuration file there is an example based on CustomField01. Before you run the script exsiting customfield_XXXXX must be set as name to this section.  
```
    {
      "name": "customfield_10068",
      "contextid": "10194",
      "displayName": "CustomField01",
      "notes": "Sample custom field to be included in the report."
    }
```
- RESOURCES: in this section at least one Jira User (resource) has to be specified. Value1 must contain the Atlassian User AccountId of people that register their worklog; value2 should be filled with additional user information that are expected on the report (i.e. User ShortName, Internal User account, Team name, Profit Center Name, etc) - Email and User Display Name are extracted by default  
```
    {
         "key" : "ResourceID",
         "value1" : "<JIRA USER ACCOUNT ID>",
         "value2" : "<JIRA USER LABEL>"
    }
```

### jira-worklog-report-cse.sh

-q    | --jql-query               (option)              default: "updated > startOfMonth() and updated < endOfMonth() and worklogAuthor != empty"
-t    | --create-ticket           (option)              create a ticket in jira.conf specified project by attaching the report
-h    | --help                                          Brings up this menu



Default Execution example<br>
```
 ./jira-worklog-report-cse.sh 
 ./jira-worklog-report-cse.sh -t # send report as attachment to a new issue 

```
Get last month registration report
```
 ./jira-worklog-report-cse -q "updated > startOfMonth(-1) and updated < endOfMonth(-1) and worklogAuthor != empty"
 ./jira-worklog-report-cse -t -q "updated > startOfMonth(-1) and updated < endOfMonth(-1) and worklogAuthor != empty" #send report as attachment to a new issue

```

### jira_variables.sh
Variable configuration


