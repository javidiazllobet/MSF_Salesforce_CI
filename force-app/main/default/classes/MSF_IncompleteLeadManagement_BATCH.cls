/**
* @author 		Deloitte
* @date 		11-2018
* @group 		Contact
* @description	Lead management. Delete leads that have been created 30 days before
* 				and there isn't from assosiative 
*/
global without sharing class MSF_IncompleteLeadManagement_BATCH implements Database.Batchable<sObject>, Schedulable{

    global final String query; 
    
    global MSF_IncompleteLeadManagement_BATCH (){
         
        String queryStep = '';
        queryStep  = 'SELECT Id ';												
        queryStep += 'FROM Lead ';
        queryStep += 'WHERE RecordType.DeveloperName = \'Individual\' ';
        queryStep += 'AND LeadSource != \'SMS\' ';
        if(Test.IsRunningTest()){
            queryStep += 'AND CreatedDate <= TODAY';    
        }else{
            queryStep += 'AND CreatedDate < LAST_N_DAYS:30 ';
        }      
        
        query = queryStep;         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext SC){ 
    	MSF_IncompleteLeadManagement_BATCH myBatch = new MSF_IncompleteLeadManagement_BATCH();
        Id batchJobId = Database.executeBatch(myBatch, 500);
    }
	
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        
        // DML statements        
        if(!scope.isEmpty()){        	
            Database.DeleteResult[] drList = Database.delete(scope, false);
            
            //*
            List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
            
            for (Database.DeleteResult dr : drList) { // Iterate through each returned result
                if (!dr.isSuccess()) {  // Operation failed, so get all errors                                   
                    for(Database.Error err : dr.getErrors()) {
                        msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_IncompleteLeadManagement', msf_RecordId__c = scope.get(drList.indexOf(dr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = err.getMessage());
                        lAPE.add(tempAPE);
                    }
                }            
            }  
            
            if(!lAPE.isEmpty()){
                insert lAPE;
            }//*/   
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_IncompleteLeadManagement_BATCH');
    }  
}