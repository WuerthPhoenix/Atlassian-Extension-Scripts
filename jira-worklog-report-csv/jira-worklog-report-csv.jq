. as $root
   |  .fields as $jfield  
   |  $jfield.worklog.worklogs[] 
   | [ 
         .author.displayName, 
         .author.emailAddress, 
         .author.accountId,
         .issueId, 
         .timeSpent, 
         .started, 
         .updated, 
         .created ,  
         $jfield[$customfield01],
         $jfield.assignee.displayName,
         $jfield.assignee.emailAddress ,
         $jfield.assignee.accountId ,
         $root.key,
         $jfield[$aggregateTimeSpent] ,
         $jfield[$summary], 
         $resourceShortName,
         $decimal
       ] 
    | @csv
