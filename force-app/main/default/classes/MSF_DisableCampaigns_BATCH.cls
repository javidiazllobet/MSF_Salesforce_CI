/**
* @author       Deloitte
* @date         04-2019
* @group        Campaign
* @description  Disable campaigns based on their end date
*/
global without sharing class MSF_DisableCampaigns_BATCH implements Database.Batchable<sObject>, Schedulable{
    
    global final String query; 
    global static final Integer BATCH_SIZE = 200;
    
    global MSF_DisableCampaigns_BATCH (){
        String queryStep = '';
        queryStep = 'SELECT Id, IsActive ';
        queryStep += 'FROM Campaign ';
        queryStep += 'WHERE (IsActive = true AND EndDate != null AND EndDate <= TODAY) OR '; 
        queryStep += '(IsActive = false AND StartDate != null AND (StartDate = TODAY OR StartDate = TOMORROW) AND EndDate != TOMORROW)';
        query = queryStep; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext SC){ 
        MSF_DisableCampaigns_BATCH myBatch = new MSF_DisableCampaigns_BATCH();
        Id batchJobId = Database.executeBatch(myBatch, BATCH_SIZE);
    }

    global void execute(Database.BatchableContext BC, List<Campaign> scope){

        for(Campaign s : scope){   
            if (s.IsActive == true) {
                s.Status = 'Completed';
            }
            else {
                s.Status = 'In Progress';
            }
            s.IsActive = !s.IsActive; 
        }       
    
        // DML statements
        Database.SaveResult[] srList = Database.update(scope, false); 
        
        //*
        List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
        
        for (Database.SaveResult sr : srList) { // Iterate through each returned result
            if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                for(Database.Error err : sr.getErrors()) {
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_DisableCampaigns_BATCH', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = err.getMessage());
                    lAPE.add(tempAPE);
                }
            } 
        }  
        
        if(!lAPE.isEmpty()){
            insert lAPE;
        }//*/ 
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_DisableCampaigns_BATCH');
    }   
    
}