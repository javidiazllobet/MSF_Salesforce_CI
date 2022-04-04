/**
* @author 		Deloitte
* @date 		02-2020
* @group 		Recurring Donations
* @description	Close Recurring Donations in batch mode
*/
global without sharing class MSF_CloseRecurringDonations_01_BATCH implements Database.Batchable<sObject>, Schedulable{

    global Set<ID> lIdsRecurringDonations;
    //TODO add to Custom setting or label
    global static final Integer BATCH_SIZE = 10;
  
    global MSF_CloseRecurringDonations_01_BATCH (){
      
    }
    global MSF_CloseRecurringDonations_01_BATCH (Set<ID> lIds){
         
        lIdsRecurringDonations = lIds;         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){

            //Batch called from trigger MSF_OpportunitiesFieldsLogic_TDTM
            return Database.getQueryLocator([SELECT Id, msf_PendingCloseRecurring__c 
                                               FROM npe03__Recurring_Donation__c WHERE Id IN :lIdsRecurringDonations]);
            
    }
	
    global void execute(SchedulableContext SC){ 
        //Batch called from Scheduled
        MSF_CloseRecurringDonations_02_BATCH myBatch = new MSF_CloseRecurringDonations_02_BATCH();
        Id batchJobId = Database.executeBatch(myBatch, BATCH_SIZE);
    }
    
    global void execute(Database.BatchableContext BC, List<npe03__Recurring_Donation__c> scope){
		
        
        List<npe03__Recurring_Donation__c> lRecurringDonationsToUpdate = new List<npe03__Recurring_Donation__c>();
        for (npe03__Recurring_Donation__c rC : scope) {
            rC.msf_PendingCloseRecurring__c= TRUE; 
            lRecurringDonationsToUpdate.add(rC);
        }
       
        
        // DML statement
        Database.SaveResult[] srList = Database.update(lRecurringDonationsToUpdate, false);
        
        

        List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
        
        for (Database.SaveResult sr : srList) { // Iterate through each returned result
            if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                for(Database.Error err : sr.getErrors()) {
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_CloseRecurringDonations_01_BATCH', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                    lAPE.add(tempAPE);
                }
            }            
        }  
        
        if(!lAPE.isEmpty()){
            insert lAPE;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_CloseRecurringDonations_01_BATCH');
        if(lIdsRecurringDonations!=null && lIdsRecurringDonations.isEmpty() == FALSE)
        {
            Id batchJobId = Database.executeBatch(new MSF_CloseRecurringDonations_02_BATCH(lIdsRecurringDonations), BATCH_SIZE);
        }
        
    }  
}