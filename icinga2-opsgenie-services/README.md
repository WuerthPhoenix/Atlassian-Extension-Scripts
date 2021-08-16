## icinga2-opsgenie-services
Script that performs the syncronization between [Icinga2 Business Process Module](https://icinga.com/docs/icinga-business-process-modelling/latest/doc/03-Getting-Started/ "")  and OpsGenie Services.  


#### LICENSE

LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            
Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          
This program comes with ABSOLUTELY NO WARRANTY.                                        
This is free software, and you are welcome to redistribute it under certain conditions;


### icinga2-opsgenie-services.sh
- -t    | --team                                     OpsGenie Team Id (REQUIRED)
- -a    | --api-token                                OpsGenie Api Token  (REQUIRED)
- -u    | --opsgenie-url                             OpsGenie instance URL  (REQUIRED)


Execution example<br>
```
 ./icinga2-opsgenie-services.sh -t "<OpsGenie Team ID>" -a "<OpsGenie API Token>" -u "<https://api.eu.opsgenie.com/v1/services||https://api.opsgenie.com/v1/services>"

```


