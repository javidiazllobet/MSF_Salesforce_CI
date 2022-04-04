/**
* @author 		Deloitte
* @date 		12-2018
* @group 		Associative
* @description	Trigger Handler that controls the associative logic
*/

global without sharing class MSF_AssociativeLogic_TDTM extends npsp.TDTM_Runnable {

	/*******************************************************************************************************
    * @description	Trigger Handler on Associative that controls the communication permissions, the associative 
    * 				check of the related contact and the cancellation of the recurring donations 
    * @param 		listNew the list of Associative from trigger new. 
    * @param 		listOld the list of Associative from trigger old. 
    * @param 		triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param 		objResult the describe for Associative.
    * @return 		dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
    	
        //Attributes
        List<msf_Associative__c> lNewAs = (List<msf_Associative__c>) newlist;      
		List<msf_Associative__c> lOldAs = (List<msf_Associative__c>) oldlist;
        Map<Id, msf_Associative__c> mOldAs = new Map<Id, msf_Associative__c>();
        if(lOldAs != null){            
            mOldAs.putAll(lOldAs);
        }    
        
        List<Contact> lConToUpdate = new List<Contact>();
        List<npe03__Recurring_Donation__c> lRDToUpdate = new List<npe03__Recurring_Donation__c>();
        Set<ID> sCon = new Set<ID>();
        
        Set<ID> lDisableContactRD = new Set<ID>();
   

        //Actions
        
        /*** BEFORE INSERT & BEFORE UPDATE ***/        
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {	
            
            for(msf_Associative__c asso : lNewAs){
                if(asso.msf_Status__c == 'Baja'){
                    asso.msf_receiveEmailCommunications__c = false;
                }else if(asso.msf_Status__c == 'Activo'){
                	asso.msf_receiveEmailCommunications__c = true;    
                }  
                
                sCon.add(asso.msf_ContactId__c);
            } 

            allowNewAsso(lNewAs, sCon);    
                       
        } 
        
        /*** AFTER INSERT & AFTER UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {	
            
            for(msf_Associative__c asso : lNewAs){  
                
                if(lOldAs == null || 
                   asso.msf_Status__c != mOldAs.get(asso.Id).msf_Status__c || 
                   asso.msf_CancellationReason__c != mOldAs.get(asso.Id).msf_CancellationReason__c)
                {
                    Contact tempCon = new Contact();
                    tempCon.Id = asso.msf_ContactId__c;
                    
                    if(asso.msf_Status__c == 'Baja'){
                        tempCon.msf_IsAssosiative__c = false;
                        if(asso.msf_CancellationReason__c == 'Fallecido'){
                            tempCon.npsp__Deceased__c = true;
                            tempCon.msf_ContactDeleteReason__c = 'Deceased';
                        }                        
                        lDisableContactRD.add(asso.msf_ContactId__c);
                    }else if(asso.msf_Status__c == 'Activo'){
                        tempCon.msf_IsAssosiative__c = true;   
                    }
   
                    lConToUpdate.add(tempCon);
                }
            } 
            
            if(!lDisableContactRD.isEmpty()){                
                List<npe03__Recurring_Donation__c> tempRD = closeMembershipQuota(lDisableContactRD);
                if(!tempRD.isEmpty()){
                	lRDToUpdate.addAll(tempRD);    
                }    
            }             
        }  
        
        /*** DML OPERATIONS ***/
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToUpdate.addAll((List<Contact>) lConToUpdate);
        dmlWrapper.objectsToUpdate.addAll((List<npe03__Recurring_Donation__c>) lRDToUpdate);

        if(lConToUpdate.isEmpty() && lRDToUpdate.isEmpty()){
            return null;
        }
        
        return dmlWrapper; 
    } 
    
    
    /*******************************************************************************************************
    * @description	Close recurring donations of the membership type for related contacts.
    * @param 		sConIDs is a set with contacts ids of the related associative records.
    * @return		List<npe03__Recurring_Donation__c> Recurring donatios to close.
    ********************************************************************************************************/
    private List<npe03__Recurring_Donation__c> closeMembershipQuota (Set<ID> sConIds){
        List<npe03__Recurring_Donation__c> lRDToUpdate = new List<npe03__Recurring_Donation__c>();
        
        for(npe03__Recurring_Donation__c rd : [SELECT Id FROM npe03__Recurring_Donation__c 
                                               WHERE npe03__Contact__c IN: sConIds 
                                               AND npe03__Open_Ended_Status__c = 'Open' 
                                               AND RecordType.DeveloperName = 'Associate'])
        {
            rd.npe03__Open_Ended_Status__c = 'Closed';
            /* Set a cancellation reason ? */
            lRDToUpdate.add(rd);
        }
        
        return lRDToUpdate;
    }
    
    /*******************************************************************************************************
    * @description	Avoid creating an associative record for a contact that already has one.
    * @param		lNewAs is the list of the new or updated associative records.			
    * @param		sConIDs is a set with contacts ids of the related associative records.
    ********************************************************************************************************/
    private void allowNewAsso (List<msf_Associative__c> lNewAs, Set<ID> sConIDs){
        Set<ID> sConWithAsso = new Set<ID>(); 
        Set<ID> sAssoId = new Set<ID>();
        
        for(msf_Associative__c asso : lNewAs){
        	sAssoId.add(asso.Id);  
        }
        
        for(msf_Associative__c asso : [SELECT id, msf_ContactId__c 
                                       FROM msf_Associative__c 
                                       WHERE msf_ContactId__c IN: sConIDs
                                       AND ID NOT IN : sAssoId
                                       AND msf_Status__c = 'Activo'] )
        {
            sConWithAsso.add(asso.msf_ContactId__c);
        }
        
        for(msf_Associative__c asso : lNewAs){
            if(sConWithAsso.contains(asso.msf_ContactId__c) && asso.msf_Status__c == 'Activo' ){
            	asso.addError(System.Label.MSF_TWO_ASSOCIATED_RECORD_ERROR);    
            }
        }
    }
    
}