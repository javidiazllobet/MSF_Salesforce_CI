/**
 * @description       : 
 * @author            : arubio@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 11-04-2022
 * @last modified by  : arubio@omegacrmconsulting.com
**/
public with sharing class MSF_UncheckUtimosMeses_BATCH implements
Database.Batchable<sObject>, Database.Stateful{
    public Integer recordsProcessed = 0;
    public Integer numberErros = 0;
    
    public Database.QueryLocator  start(Database.BatchableContext bc) {
        
        date lastFiveYears = date.today().addyears(-5);  
		return Database.getQueryLocator([SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Opportunity where msf_UncheckUtimosMeses__c = 'true' AND CloseDate <:lastFiveYears]);
    }


    public void execute(Database.BatchableContext bc, List<Opportunity> records){
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        
        for(Opportunity iOpp: records){
        if(iOpp.msf_IsFromLastMonths__c == false && iOpp.msf_IsFromLastMonthsBool__c == true ){
            iOpp.msf_IsFromLastMonthsBool__c = false;            
            listOppToUpdate.add(iOpp);   
            recordsProcessed = recordsProcessed + 1;                
            }
        }
        if (!listOppToUpdate.isEmpty()){
            Database.SaveResult[] results = Database.update(listOppToUpdate, false);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        numberErros = numberErros + 1;
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Opportunity fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }


    public void finish(Database.BatchableContext bc){

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        System.debug('Job: '+ job.TotalJobItems);
        System.debug('Errores: '+numberErros);
        System.debug(numberErros == recordsProcessed);
        if(job.TotalJobItems==0 || numberErros == recordsProcessed){
            System.debug('Llamamos al segundo batch: ');
            MSF_UncheckUtimosMeses_02_BATCH myBatchObject = new MSF_UncheckUtimosMeses_02_BATCH();
		    Id batchId = Database.executeBatch(myBatchObject, 10);
        }else {
            System.debug('llamarlo otra vez');
            MSF_UncheckUtimosMeses_BATCH myBatchObject = new MSF_UncheckUtimosMeses_BATCH();
			Id batchId = Database.executeBatch(myBatchObject);
        }
    }
}