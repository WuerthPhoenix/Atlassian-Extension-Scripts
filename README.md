# Atlassian-Extension-Scripts
Atlassian Extension Scripts by Würth Phoenix 

#### LICENSE

LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            
Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          
This program comes with ABSOLUTELY NO WARRANTY.                                        
This is free software, and you are welcome to redistribute it under certain conditions;


## load-jsm-customer-ldap 
Simple script that allows to upload Customers in Organizations structure to Jira Service Management (Cloud tested) from a local common LDAP service (i.e. Active Directory). The script supports multi-projects configuration. <br>
<br>
LINK:  [load-jsm-customer-ldap](https://github.com/WuerthPhoenix/Atlassian-Extension-Scripts/tree/main/load-jsm-customer-ldap "load-jsm-customer-ldap readme")

## delete-jsm-customers
Simple script that simulates deletion and really (!) deletes Customers and Organizations from ATLASSIAN Jira Service Management (Cloud tested) 
<br>
LINK:  [delete-jsm-customers](https://github.com/WuerthPhoenix/Atlassian-Extension-Scripts/blob/main/delete-jsm-customers/README.md "delete-jsm-customer readme")

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
  ]
}

```

#### jira_variables.sh
jira_variabiles.sh of different projects can be merged into one single file! 
