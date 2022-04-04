/**
* @author 		Deloitte
* @date 		02-2020
* @group 		Recurring Donations
* @description	Close Recurring Donations in batch mode
*/
global without sharing class MSF_CloseRecurringDonations_02_BATCH implements Database.Batchable<sObject>{

    global final String query;
    global Set<ID> lIdsRecurringDonations;
    
    global MSF_CloseRecurringDonations_02_BATCH (){
            String queryStep = 'SELECT Id ';
            queryStep += 'FROM npe03__Recurring_Donation__c ';
        	queryStep += 'WHERE msf_PendingCloseRecurring__c = TRUE';
            query = queryStep;

    }    

	global MSF_CloseRecurringDonations_02_BATCH (Set<ID> lIds){
         
        lIdsRecurringDonations = lIds;         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Database.QueryLocator dbQuery;
        
        if(lIdsRecurringDonations!=null && lIdsRecurringDonations.isEmpty()==FALSE)
        {
        	//Batch called from trigger MSF_OpportunitiesFieldsLogic_TDTM
            dbQuery = Database.getQueryLocator([SELECT Id, msf_PendingCloseRecurring__c 
                                               FROM npe03__Recurring_Donation__c WHERE Id IN :lIdsRecurringDonations]);
        }
        else
        {
            //Batch called from Scheduled
            dbQuery = Database.getQueryLocator(query);
        }
        return dbQuery;
        
    }
	

    global void execute(Database.BatchableContext BC, List<npe03__Recurring_Donation__c> scope){
		
        
        List<npe03__Recurring_Donation__c> lRecurringDonationsToUpdate = new List<npe03__Recurring_Donation__c>();
        for (npe03__Recurring_Donation__c rC : scope) {
            rC.npe03__Open_Ended_Status__c = 'Closed'; 
            rC.msf_CancelationReason__c = 'Unpaid'; 
            rC.msf_PendingCloseRecurring__c= FALSE; 
            lRecurringDonationsToUpdate.add(rC);
        }
       
        
        // DML statement
        Database.SaveResult[] srList = Database.update(lRecurringDonationsToUpdate, false);
        
        
        //*
        List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
        
        for (Database.SaveResult sr : srList) { // Iterate through each returned result
            if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                for(Database.Error err : sr.getErrors()) {
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_CloseRecurringDonations_02_BATCH', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                    lAPE.add(tempAPE);
                }
            }            
        }  
        
        if(!lAPE.isEmpty()){
            insert lAPE;
        }//*/
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_CloseRecurringDonations_02_BATCH');
    }  
}