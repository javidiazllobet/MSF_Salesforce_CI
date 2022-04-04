/**
* @author 		Deloitte
* @date 		10-2018
* @group 		QuotaModification
* @description	QuotaModification fields management and name.
*/
global without sharing class MSF_QuotaModificationFieldsLogic_TDTM extends npsp.TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description	Trigger Handler on Quota Modifications that handles the logic of some fields and the 
    * 				change of quota. 
    * @param 		listNew the list of Recurring Donations from trigger new. 
    * @param 		listOld the list of Recurring Donations from trigger old. 
    * @param 		triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param 		objResult the describe for Recurring Donations 
    * @return 		dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
    	
        //Attributes
        List<msf_QuotaModification__c> lNewMQ = (List<msf_QuotaModification__c>) newlist;
        List<msf_QuotaModification__c> lOldMQ = (List<msf_QuotaModification__c>) oldlist;
        Map<Id, msf_QuotaModification__c> mOldMQ = new Map<Id, msf_QuotaModification__c>();
        if(lOldMQ != null){            
            mOldMQ.putAll(lOldMQ);
        }

        List<npe03__Recurring_Donation__c> lRDToUpdate = new List<npe03__Recurring_Donation__c>();
        
        //Actions             
        
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert){	  
       		
            MSF_SharedMethods_UTIL smUtil = new MSF_SharedMethods_UTIL();            
            Map<String, msf_LeadSourceMasterData__c> mLeadSourceValues = smUtil.getLeadSourceDependencies();
            
            for(msf_QuotaModification__c mq : lNewMQ){    
            	setLeadSourceDependencies(mq, mLeadSourceValues);                
            }         
        }
        
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){	  
       		lRDToUpdate.addAll(updateRD(lNewMQ));          
        }
                        
        //DML Operations
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToUpdate.addAll((List<npe03__Recurring_Donation__c>)lRDToUpdate);
        
        if(lRDToUpdate.isEmpty()){
            return null;
        }
        
        return dmlWrapper;
    }
    
    // PRIVATE METHODS
    
	/*******************************************************************************************************
    * @description	Establishes the new quota modification in the related recurring donation.
    * @param 		lMQ is a new quota modification.				
    ********************************************************************************************************/
    private List<npe03__Recurring_Donation__c> updateRD(List<msf_QuotaModification__c> lMQ){
        
        List<npe03__Recurring_Donation__c> lRD = new List<npe03__Recurring_Donation__c>();
        
        for(msf_QuotaModification__c mq : lMQ){
        	lRD.add(
                new npe03__Recurring_Donation__c(
                    Id = mq.msf_RecurringDonation__c, 
                    msf_CurrentQuotaModification__c = mq.Id
                )
            );    
        }
        
        return lRD;
    }   
    
    /*******************************************************************************************************
    * @description	Establishes the values in the 'LeadSource2; LeadSource3' fields in lead depending of the 
    * 				value of the 'LeadSource1' field.
    * @param 		rd is the Recurrent Donation to update its fields. 
    * @param 		mLsValues is a map that contains values for fields 'LeadSource2; LeadSource3'
    ********************************************************************************************************/
    private void setLeadSourceDependencies(msf_QuotaModification__c mq, Map<String, msf_LeadSourceMasterData__c> mLsValues){
        if(mLsValues.containsKey(mq.msf_LeadSource1__c)){
            mq.msf_LeadSource2__c = mLsValues.get(mq.msf_LeadSource1__c).msf_LeadSource2__c;
            mq.msf_LeadSource3__c = mLsValues.get(mq.msf_LeadSource1__c).msf_LeadSource3__c;
        }
    }
}