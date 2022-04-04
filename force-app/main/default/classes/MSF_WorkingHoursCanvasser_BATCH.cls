/**
* @author 		Deloitte
* @date 		03-2019
* @group 		msf_WorkingHoursCanvasser__c
* @description	msf_WorkingHoursCanvasser__c management. Create a register for each canvasser from 40 hours worked.
*/
global without sharing class MSF_WorkingHoursCanvasser_BATCH implements Database.Batchable<sObject>, Schedulable{
    
    global final String query;
    global static final Integer BATCH_SIZE = 200;
    
    global MSF_WorkingHoursCanvasser_BATCH (){
        
        String queryStep = '';
        queryStep  = 'SELECT Id, msf_Campaign__c ';													
        queryStep += 'FROM User ';
        queryStep += 'WHERE Profile.Name = \'Canvasser\' ';
        queryStep += 'AND UserRole.DeveloperName LIKE \'%Captador%\' ';
        query = queryStep;         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext SC){ 
        MSF_WorkingHoursCanvasser_BATCH myBatch = new MSF_WorkingHoursCanvasser_BATCH();
        Id batchJobId = Database.executeBatch(myBatch, BATCH_SIZE);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope){
        
        list<msf_WorkingHoursCanvasser__c> lWHC = new List<msf_WorkingHoursCanvasser__c>();        
        Map<String,ID> mCampaigns = new Map<String,ID>();        
        Set<String> campaignNames = new Set<String>();
        
        for(User u : scope){
            campaignNames.add(u.msf_Campaign__c != null ? u.msf_Campaign__c : 'Alta F2F');
        }
        
        for(Campaign c : [SELECT id, Name FROM Campaign WHERE Name IN:campaignNames] ){
            mCampaigns.put(c.Name,c.Id);
        }

        String idCampaign;
        for(User u : scope){
            idCampaign = u.msf_Campaign__c != null ? u.msf_Campaign__c : 'Alta F2F';

            msf_WorkingHoursCanvasser__c wNew = new msf_WorkingHoursCanvasser__c(
            	msf_CanvasserId__c = u.Id,
                msf_StartDate__c = Date.today().addDays(1),
                msf_Hours__c = 20,
                msf_CampaignId__c = mCampaigns.get(idCampaign) != null ? mCampaigns.get(idCampaign) : null 
            );
            lWHC.add(wNew);
        }
        
        Database.SaveResult[] srListaCont = Database.insert(lWHC, false);
        //*
        List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
        
        for (Database.SaveResult sr : srListaCont) { // Iterate through each returned result
            if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                for(Database.Error err : sr.getErrors()) {
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_WorkingHoursCanvasser', msf_RecordId__c = scope.get(srListaCont.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                    lAPE.add(tempAPE);
                }
            }            
        }  
        
        if(!lAPE.isEmpty()){
            insert lAPE;
        }//*/ 
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH -');
    } 
}