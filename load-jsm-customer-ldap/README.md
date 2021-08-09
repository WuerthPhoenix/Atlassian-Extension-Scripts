## load-jsm-customer-ldap
<br>
Simple script that allows to upload Customers in Organizations structure into ATLASSIAN Jira Service Management (Cloud tested) from a local common LDAP service (i.e. Active Directory). The script supports multi-projects configuration. Strongly based on jq https://stedolan.github.io/jq/

## LICENSE

LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            
Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          
This program comes with ABSOLUTELY NO WARRANTY.                                        
This is free software, and you are welcome to redistribute it under certain conditions;


### jira.conf
- Script Configuration. This file needs to be filled with LDAP environment information
- By default jira.conf looks for Bind password in path /opt/jira/.pwd_jira_ldap <br>
   (password is the only alphanumeric string that should be in the file and of course you can change the path!)
- in activedirectorydepartments you can specify all or specific entity. For example in case of "departments" you can specify them as
```
 "activedirectorydepartments" : [
    { "department" : "department 1"  }, 
    { "department" : "department 2"  } 
  ]
```
or for all

```
 "activedirectorydepartments" : [
    { "department" : "*"  } 
  ]
```

### ./load-jsm-customer-ldap.sh 
- -h HELP<br>
- -f SYNC FORCE (use everytime) <br>

Execution example<br>
```
 ./load-jsm-customer-ldap.sh -f
```
### jira_variables.sh
Variable configuration - no changes required

### External libraries
tools/ldif-to-csv.sh provided by https://gist.github.com/dansimau?direction=asc&sort=created

