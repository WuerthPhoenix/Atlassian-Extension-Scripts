## load-jsm-cmdb
This script loads data into Jira Service Management CMDB (new Insight) and show how to create dependencies/relationships between two separate Object Types <br>

#### LICENSE

LICENSED UNDER GNU General Public License, v3  (see LICENSE.md for details)            
Atlassian-Extension-Scripts Copyright (C) 2021  Würth Phoenix                          
This program comes with ABSOLUTELY NO WARRANTY.                                        
This is free software, and you are welcome to redistribute it under certain conditions;

# Environment preparation
The loading example is based on a pool of data contained in sample-data-load.json file. <br>
Let's assume there are the two following CMDB Object schemas:<br> 
- Products
- Components
and the target is to make a Composite aggregation among a pool of Component and a Product..  
```
[COMPONENTS]n<>------1[PRODUCTS]
```

## jira.conf
- copy jira.conf_orig to jira.conf


## Products (Key: PROD)
Object Schema: Products
Object Type: Sample Product
Object Attributes: see jira.conf for details and adjust the attributeIds based on their creation sequence
- Key (Type: Text - Default)
- Name (Type: Text - Default)
- Created (Type: DateTime - Default)
- Updated (Type: DateTime - Default)
- Description  (Type: Text Multiline)
- Organization (Type: Text - Default) - This field can be used to match Configuration Item with Ticket Organization
- Price (Type: Text - Default)
- ItemNumber (Type: Text - Default)  - Will be used to establish the link
- Searchkey (Type: Text - Default) - Will be used to search for the Products by script - No Spaces!!

**Be sure you set the Object Schema "Allow others to select objects from this schema" flag in Object Schema configuration**

## Components (Key: COMP) 
Object Schema: Components
Object Type: Sample Component
Oblect Attributes: see jira.conf for details and adjust the attributeIds based on their creation sequence
- Key (Type: Text - Default)
- Name (Type: Text - Default)
- Created (Type: DateTime - Default)
- Updated (Type: DateTime - Default)
- Description  (Type: Text Multiline)
- Model (Type: Text) 
- ProductItemNumber (Type: Text)   - Will be used to establish the link with Product-ItemNumber
- ProductLink (Type: Object, Type Value: Sample Component) 
- Searchkey (Type: Text - Default) - No Spaces.. currently not used but just filled 


## Execution example
- in order to be compliant with future release it's stringly suggested to make a copy of load-jsm-cmdb.sh to load-jsm-cmdb-<your instance name>.sh
- If new classes are configured also the script requires some adjustments!
```
 ./load-jsm-cmdb-<your instance name>.sh 
```

### jira_variables.sh
Variable configuration
If new classes are configured also these two variable instances should be updated with correct idn argument specified in identifier in jira.conf:
```
productdatajsonfile="$2/$( jq -r  --arg idn "product"    ' .insightRestAPI[]|select(.identifier==$idn) | .sampledatadir ' "$config_file" )"
componentdatajsonfile="$2/$( jq -r --arg idn "components" ' .insightRestAPI[]|select(.identifier==$idn) | .sampledatadir ' "$config_file" )"

```


