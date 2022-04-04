global without sharing class MSF_UpdateRollUpsAccount_BATCH implements Database.Batchable<sObject>{

    global final String query; 
    
    global MSF_UpdateRollUpsAccount_BATCH (){
         
        String queryStep = '';
        queryStep  = 'SELECT Id ';
        queryStep += 'FROM Account ';
        query = queryStep;         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
	
    global void execute(Database.BatchableContext BC, List<Account> scope){
		
        
        List<Account> lUpdateAccounts = new List<Account>();
        Set<ID> sAccIds = new Map<ID,Account>(scope).keyset();
        
        for(AggregateResult ar : [SELECT AccountId account, COUNT(Id) NumberOfClosedOpps 
                                  FROM Opportunity 
                                  WHERE AccountId IN: sAccIds
                                  AND RecordType.DeveloperName IN ('Donation','Grant','Historical','In_Kind_Gift','Legacy','Matching_Gift') 
                                  AND IsWon = TRUE 
                                  AND Amount > 0 
                                  GROUP BY AccountId])
        {
        	Account tempAcc = new Account(
                Id = (Id)ar.get('account'),
                npo02__NumberOfClosedOpps__c = (Double)ar.get('NumberOfClosedOpps')
            );	
            lUpdateAccounts.add(tempAcc);  
        }
        
        // DML statement
        Database.SaveResult[] srList = Database.update(lUpdateAccounts, false);
        
        
        //*
        List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
        
        for (Database.SaveResult sr : srList) { // Iterate through each returned result
            if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                for(Database.Error err : sr.getErrors()) {
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_UpdateRollUpsAccount_BATCH', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                    lAPE.add(tempAPE);
                }
            }            
        }  
        
        if(!lAPE.isEmpty()){
            insert lAPE;
        }//*/
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_UpdateRollUpsAccount_BATCH');
    }
}