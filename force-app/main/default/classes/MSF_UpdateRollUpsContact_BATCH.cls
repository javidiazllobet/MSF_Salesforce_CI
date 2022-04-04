global without sharing class MSF_UpdateRollUpsContact_BATCH implements Database.Batchable<sObject>{

    global final String query; 
    
    global MSF_UpdateRollUpsContact_BATCH (){
         
        String queryStep = '';
        queryStep  = 'SELECT Id ';
        queryStep += 'FROM Contact ';
        queryStep += 'WHERE RecordType.DeveloperName in(\'Individual_Contact\',\'Organization\',\'Anonymous\')';

        query = queryStep;         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
	
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
		
        
        List<Contact> lUpdateContacts = new List<Contact>();
        Set<ID> sContIds = new Map<ID,Contact>(scope).keyset();
        
        List<Id> idsRT = new List<Id>(); 
        List<String> rNames = new List<String>{'Donation','Grant','Historical','In_Kind_Gift','Legacy','Matching_Gift'};
        for (String n : rNames) {
             idsRT.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(n).getRecordTypeId());
        }
        
        for(AggregateResult ar : [SELECT npsp__Primary_Contact__c contact, COUNT(Id) NumberOfClosedOpps 
                                  FROM Opportunity 
                                  WHERE npsp__Primary_Contact__c IN: sContIds
                                  AND RecordTypeId IN :idsRT 
                                  AND IsWon = TRUE 
                                  AND Amount > 0 
                                  GROUP BY npsp__Primary_Contact__c])
        {
        	Contact tempCon = new Contact(
                Id = (Id)ar.get('contact'),
                npo02__NumberOfClosedOpps__c = (Double)ar.get('NumberOfClosedOpps')
            );	
            lUpdateContacts.add(tempCon);  
        }
        
        // DML statement
        Database.SaveResult[] srList = Database.update(lUpdateContacts, false);
        
        
        //*
        List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
        
        for (Database.SaveResult sr : srList) { // Iterate through each returned result
            if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                for(Database.Error err : sr.getErrors()) {
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_UpdateRollUpsContact_BATCH', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                    lAPE.add(tempAPE);
                }
            }            
        }  
        
        if(!lAPE.isEmpty()){
            insert lAPE;
        }//*/
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_UpdateRollUpsContact_BATCH');
    }  
}