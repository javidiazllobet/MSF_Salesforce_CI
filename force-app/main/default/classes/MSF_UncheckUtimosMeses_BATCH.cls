public with sharing class MSF_UncheckUtimosMeses_BATCH implements
Database.Batchable<sObject>, Database.Stateful{
    public Integer recordsProcessed = 0;
    public Integer numberErros = 0;
    
    private Integer lim;

    public MSF_UncheckUtimosMeses_BATCH(Integer lim){
        this.lim = lim;
    }

    public Database.QueryLocator  start(Database.BatchableContext bc) {
        /*
        SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Opportunity 
        where msf_IsFromLastMonthsBool__c = true and msf_IsFromLastMonths__c = false Limit
        */
        date lastTwoYears = date.today()-365*2;      
        date lastFiveYears = date.today()-365*5; 
        /*Id donationId =
  Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
    .get('Donation').getRecordTypeId();
        Id matching_GiftId =
  Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
    .get('Matching Gift').getRecordTypeId();*/
		return Database.getQueryLocator([SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Opportunity where msf_IsFromLastMonthsBool__c = true and (
            (msf_TypeFundraisingContribution__c = 'D' AND CloseDate <:lastFiveYears) OR
            (CloseDate <:lastFiveYears AND CloseDate > :lastTwoYears AND Type != 'Recurrent Donation' AND Type != 'Historical' AND Type != 'Membership')) Limit :lim]);
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
            System.debug('No llamar al batch: ');
        }else {
            System.debug('llamarlo otra vez');
            MSF_UncheckUtimosMeses_BATCH myBatchObject = new MSF_UncheckUtimosMeses_BATCH(lim);
			Id batchId = Database.executeBatch(myBatchObject,10);
        }
    }
}