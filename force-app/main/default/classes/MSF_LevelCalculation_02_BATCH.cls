/**
* @author       Deloitte
* @date         01-2019
* @group        Contacts
* @description  Calculation of member level.
*/
global without sharing class MSF_LevelCalculation_02_BATCH implements Database.Batchable<sObject>{
    
    global final String query; 
    global static final Integer BATCH_SIZE = 1000;
    
    global MSF_LevelCalculation_02_BATCH (){
        String queryStep = '';
        queryStep = 'SELECT Id ';
        queryStep += 'FROM Contact ';
        queryStep += 'WHERE RecordType.DeveloperName = \'Individual_Contact\' AND msf_RecalculateLevel__c = FALSE '; 
        queryStep += 'AND Id IN (SELECT msf_PromoterIndividual__c FROM Campaign WHERE Recordtype.DeveloperName = \'Default\' AND msf_PromoterIndividual__c != null) ';
        query = queryStep; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){

        for(Contact s : scope){   
            s.msf_RecalculateLevel__c = true;     
        }       
    
        // DML statements
        Database.SaveResult[] srList = Database.update(scope, false);            
        
        //*
        List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
        
        for (Database.SaveResult sr : srList) { // Iterate through each returned result
            if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                for(Database.Error err : sr.getErrors()) {
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_LevelCalculation_02', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                    lAPE.add(tempAPE);
                }
            }            
        }  
        
        if(!lAPE.isEmpty()){
            insert lAPE;
        }//*/    
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_LevelCalculation_02_BATCH');
        Id batchJobId03 = Database.executeBatch(new MSF_LevelCalculation_03_BATCH(), BATCH_SIZE);
    }   
}