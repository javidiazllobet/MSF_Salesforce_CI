/**
* @author       Deloitte
* @date         01-2019
* @group        Contacts
* @description  Calculation of member level.
*/
global without sharing class MSF_LevelCalculation_01_BATCH implements Database.Batchable<sObject>, Schedulable{
    
    global final String query; 
    global static final Integer BATCH_SIZE = 1000;
    global static final String defaultQuery ='SELECT Id '
                                            + 'FROM Contact '
                                            + 'WHERE RecordType.DeveloperName = \'Individual_Contact\' AND msf_RecalculateLevel__c = FALSE '
                                            + 'AND Id IN (SELECT npsp__Primary_Contact__c FROM Opportunity WHERE Recordtype.DeveloperName = \'Legacy\' AND npsp__Primary_Contact__c != null AND LastModifiedDate >= YESTERDAY) ';
 
    
    global MSF_LevelCalculation_01_BATCH (){
        String queryStep = ''+defaultQuery;
          query = queryStep; 
    }
    
     global MSF_LevelCalculation_01_BATCH (Integer option){
              
        String queryStep = '';
        if(option == 1)
        {
            //Recalculate all Contacts
            queryStep = 'SELECT Id ';
            queryStep += 'FROM Contact ';
        	queryStep += 'WHERE RecordType.DeveloperName IN (\'Individual_Contact\',\'Organization\') AND msf_RecalculateLevel__c = FALSE ';
        }
        else
        {
            //Default option
            queryStep = ''+defaultQuery;
        }
        
        query = queryStep;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext SC){ 
        MSF_LevelCalculation_01_BATCH myBatch = new MSF_LevelCalculation_01_BATCH();
        Id batchJobId = Database.executeBatch(myBatch, BATCH_SIZE);
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
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_LevelCalculation_01', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                    lAPE.add(tempAPE);
                }
            }       
        }  
        
        if(!lAPE.isEmpty()){
            insert lAPE;
        }//*/ 
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_LevelCalculation_01_BATCH');
        Id batchJobId = Database.executeBatch(new MSF_LevelCalculation_02_BATCH(), BATCH_SIZE);
    }   
}