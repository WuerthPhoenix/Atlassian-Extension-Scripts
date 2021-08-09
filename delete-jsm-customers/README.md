## delete-jsm-customers
<br>
Simple script that simulates deletion and really (!) deletes Customers and Organizations from ATLASSIAN Jira Service Management (Cloud tested) 

#### LICENSE

LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            
Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          
This program comes with ABSOLUTELY NO WARRANTY.                                        
This is free software, and you are welcome to redistribute it under certain conditions;


### jira.conf
- Script Configuration. This file needs to be filled with Atlassian environment access

### delete-jsm-customers.sh

- -d  | --delete           (DANGER)   If not specified customers will not be deleted
- -h  | --help             Brings up this menu
- -c  | --customer-limit   Expected customer amount limit (default 1000) 
- -o  | --org-limit        Expected organization amount limit (default 200)
- -f  | --fetch-maxresult  Fetch size param (default 100)


Demo mode execution example<br>
```
 ./delete-jsm-customers.sh -c 5000 -m 1000

```
Delete mode execution example (DANGER ZONE)<br>
```
 ./delete-jsm-customers.sh -d true

```
Delete mode execution example (DANGER ZONE): considering up to 5000 customers and up to 1000 organizations <br>
```
 ./delete-jsm-customers.sh -c 5000 -m 1000 -d true
```

or considering 10 customers in 1 organization

``` 
 ./delete-jsm-customers.sh -c 10 -o 1 -f 5 -d true

```
### jira_variables.sh
Variable configuration - no changes required


