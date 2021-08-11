# Atlassian-Extension-Scripts
Atlassian Extension Scripts by Würth Phoenx

#### LICENSE

LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            
Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          
This program comes with ABSOLUTELY NO WARRANTY.                                        
This is free software, and you are welcome to redistribute it under certain conditions;

***

# load-jsm-customer-ldap 
Simple script that allows to upload Customers in Organizations structure from a local common LDAP service (i.e. Active Directory). The script supports multi-projects configuration. <br>
<br>
LINK:  [load-jsm-customer-ldap](https://github.com/WuerthPhoenix/Atlassian-Extension-Scripts/tree/main/load-jsm-customer-ldap "load-jsm-customer-ldap")

- Jira Service Management

***

# jira-worklog-report-csv
Script that creates a CSV report with all  Worklog registration entries based on a JQL call  (Cloud tested). If necessary the script attaches the output report to a new Jira Issue for easier access.
<br>
LINK:  [jira-worklog-report-csv](https://github.com/WuerthPhoenix/Atlassian-Extension-Scripts/blob/main/jira-worklog-report-csv "jira-worklog-report-csv")

- Jira
- Jira Service Management

***

# load-jsm-cmdb
Sript that loads data into Jira Service Management CMDB (new 2021 CLOUD Insight) and show how to create dependencies/relationships between two separate Object Types
<br>
LINK:  [load-jsm-cmdb](https://github.com/WuerthPhoenix/Atlassian-Extension-Scripts/blob/main/load-jsm-cmdb "load-jsm-cmdb")

- Jira Service Management

***

# icinga2-opsgenie-services
Script that performs the syncronization between [Icinga2 Business Process Module](https://icinga.com/docs/icinga-business-process-modelling/latest/doc/03-Getting-Started/ "")  and OpsGenie Services.  
<br>
LINK:  [icinga2-opsgenie-services](https://github.com/WuerthPhoenix/Atlassian-Extension-Scripts/blob/main/icinga2-opsgenie-services "icinga2-opsgenie-services")

- Jira Service Management (cloud) 
- OpsGenie
- Icinga2
- NetEye4

***

# delete-jsm-customers
Simple script that simulates deletion and really (!) deletes Customers and Organizations from ATLASSIAN Jira Service Management (Cloud tested) 
<br>
LINK:  [delete-jsm-customers](https://github.com/WuerthPhoenix/Atlassian-Extension-Scripts/blob/main/delete-jsm-customers "delete-jsm-customer")

- Jira Service Management

***




#### jira.conf
jira.conf of different projects can be merged into one single file!
```
 {
  "jirahost": "https://<Jira Service Management Cloud instance>.atlassian.net",
  "jirauser": "<API USER>",
  "jiraapitoken": "<API TOKEN>",
  "logredirect" : "false",
  "logdir": "/tmp/",
  "ldap" : { 
     "howto" : "This is the ldap configuration section for load-jsm-customer-ldap",
     "tmpdirldpap" : "/tmp/ad.csv",
     "ldaphost"    : "<LDAP SERVER IP/FQDN>" ,
     "ldapbase"    : "cn=admin,dc=example,dc=com",
     "ldapbind"    : "<>",
     "ldappwd"     : "/opt/jira/.pwd_jira_ldap",
     "ldapfilter"  : "(&(objectClass=user)(mail=*)(department=*))",
     "ldapfields"  : " department mail givenName sn sAMAccountName"
  },
  "projects": [
    {
      "howto" : "This is the jira project configuration section",
      "type": "<FREE DESCRIPTION>",
      "name": "<JIRA PROJECT KEY>",
      "fields": [
      ],
      "args": [
        {
          "activedirectorycustomers" : "yes",
          "activedirectorydepartments" : [
               { "department" : "*"  }
          ]
        }
      ]
    },
    {
      "howto" : "This is another jira project configuration section.. You can create a new one for each jira project",
      "type": "<FREE DESCRIPTION>",
      "name": "<JIRA PROJECT KEYS..n>",
      "fields": [
      ],
      "args": [
        {
          "activedirectorycustomers" : "yes",
          "activedirectorydepartments" : [
               { "department" : "<Specify the name of a department to add it to this project>"  }
          ]
        }
      ]
    }
  ],
  "export" : {
     "worklogfilter" : "jira-worklog-report-csv.jq",
     "worklogoutputfile" : "/tmp/jira-worklog-report-csv.csv",
     "worklogproject" : "<JIRA PROJECT FOR ISSUE CREATION>"
  },
  "fields": [
    {
      "name": "customfield_XXXXX",
      "contextid": "10XXX",
      "displayName": "CustomField01",
      "notes": "Sample custom field to be included in the report."
    }
   ],
   "userproperties" : [
      {
         "key" : "ResourceID",
         "value1" : "<JIRA USER ACCOUNT ID>",
         "value2" : "<JIRA USER LABEL>"
      },
      {
         "key" : "ResourceID",
         "value1" : "<JIRA USER 2 ACCOUNT ID>",
         "value2" : "<JIRA USER 2 LABEL>"
      }
  ]
  "insightRestAPI" : [
             {
                "identifier"     : "products",
                "objectSchemaId" : "9",
                "objectSchema"   : "Products",
                "objectTypeId"   : "15",
                "sampledatadir"  : "sample-data.json",
                "objectTypeAttributes" : [
                 { 
                    "attributename" : "Name",
                    "attributeid"   : "157" 
                 },
                 { 
                    "attributename" : "Description",
                    "attributeid"   : "160" 
                 }
                ]
             }
  ]
}

```

#### jira_variables.sh
jira_variabiles.sh of different projects can be merged into one single file! 
