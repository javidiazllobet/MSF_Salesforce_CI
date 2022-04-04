/**
* @author 		Omega
* @date 		03/09/2021
* @group 		Opportunity
* @description	Job to check and update the field msf_IsFromLastMonthsBool__c ZenIT#25762
*/
public class MSF_CheckUtimosMeses_BATCH implements
Database.Batchable<sObject>, Database.Stateful{
    public Integer recordsProcessed = 0;
    public Integer numberErros = 0;
    
    private Integer lim;
    private Integer query;

    public MSF_CheckUtimosMeses_BATCH(Integer lim, Integer query){
        this.lim = lim;
        this.query = query;
    }
    
    public Database.QueryLocator  start(Database.BatchableContext bc) {
        date lastTwoYears = date.today()-365*2;      
        date lastFiveYears = date.today()-365*5; 
        Id donationId =
  Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
    .get('Donation').getRecordTypeId();
        Id matching_GiftId =
  Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
    .get('Matching Gift').getRecordTypeId();
        
    //List<Opportunity> result = new Database.QueryLocator();
    if(query == 1){
        //Query con formula desglosada
        return Database.getQueryLocator([SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Opportunity where msf_IsFromLastMonthsBool__c = false and((((RecordTypeId =:donationId AND Type IN('SMS Donor', 'One off Donation', 'SMS Operator',
        'Employee or client Donation', 'Solidarity initiative', 'Solidarity Wedding', 'Solidarity Gift')) 
        or (RecordTypeId =:matching_GiftId and Type = 'Matching Gift')) AND CloseDate >=:lastFiveYears)) limit :lim]);
    }else if(query == 2){
        //Query 2da parte
        return Database.getQueryLocator([SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Opportunity 
        where msf_IsFromLastMonthsBool__c = false and (CloseDate >=:lastFiveYears AND CloseDate <= :lastTwoYears AND Type != 'Recurrent Donation' AND Type != 'Historical' AND Type != 'Membership') limit :lim]);
    }else{
        //Query original
        return Database.getQueryLocator([SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Opportunity where msf_IsFromLastMonthsBool__c = false and (
            (msf_TypeFundraisingContribution__c = 'D' AND CloseDate >=:lastFiveYears) OR
            (CloseDate >=:lastFiveYears AND CloseDate <= :lastTwoYears AND Type != 'Recurrent Donation' AND Type != 'Historical' AND Type != 'Membership')) limit :lim]);
    }
		
    }


    public void execute(Database.BatchableContext bc, List<Opportunity> records){
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        for(Opportunity iOpp: records){
            if(iOpp.msf_IsFromLastMonths__c == true && iOpp.msf_IsFromLastMonthsBool__c == false ){
                iOpp.msf_IsFromLastMonthsBool__c = true;            
            	listOppToUpdate.add(iOpp);    
                recordsProcessed = recordsProcessed + 1;             
            }
        }
        //if (!listOppToUpdate.isEmpty())Database.update(listOppToUpdate, false);
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
            MSF_CheckUtimosMeses_BATCH myBatchObject = new MSF_CheckUtimosMeses_BATCH(lim, query);
			Id batchId = Database.executeBatch(myBatchObject,10);
        }
    }
}