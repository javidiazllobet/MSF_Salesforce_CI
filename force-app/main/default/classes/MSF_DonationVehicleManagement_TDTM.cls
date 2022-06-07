/**
* @author 		Deloitte
* @date 		11-2018
* @group 		Opportunity
* @description	Donation vehicle management.
*/
global without sharing class MSF_DonationVehicleManagement_TDTM extends npsp.TDTM_Runnable{
	
    /*******************************************************************************************************
    * @description	Trigger Handler on Opportunities that handles the donation vehicle. 
    * @param 		listNew the list of Opportunities from trigger new. 
    * @param 		listOld the list of Opportunities from trigger old. 
    * @param 		triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param 		objResult the describe for Opportunities.
    * @return 		dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
    	
        //Attributes
        List<Opportunity> lNewOpp = (List<Opportunity>) newlist;      
		List<Opportunity> lOldOpp = (List<Opportunity>) oldlist;
        Map<Id, Opportunity> mOldOpp = new Map<Id, Opportunity>();
        if(lOldOpp != null){            
            mOldOpp.putAll(lOldOpp);
        }    
        
        List<OpportunityContactRole> lOCRToInsert = new List<OpportunityContactRole>();
        List<OpportunityContactRole> lOCRToDelete = new List<OpportunityContactRole>();       
        
        Set<ID> sOppIdsCon = new Set<ID>();
        Set<ID> sConIds = new Set<ID>();      
        Set<String> sOCRToDelete = new Set<String>();

        Map<String,OpportunityContactRole> oldOCRMap = new Map<String,OpportunityContactRole>();
        List<Id> opportunityIds = new List<Id>();
        for (Opportunity o : lNewOpp){
            opportunityIds.add(o.Id);
        }
        for(OpportunityContactRole oCR : [SELECT id, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId IN :opportunityIds]){
            oldOCRMap.put((String)oCR.OpportunityId+(String)oCR.ContactId, oCR);
        }

        //Actions
        /*** BEFORE INSERT & BEFORE UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {	            
            for(Opportunity o : lNewOpp){
                if(o.msf_DonationVehicleContact__c == null && o.npsp__Primary_Contact__c != null){
                    o.msf_DonationVehicleContact__c = o.npsp__Primary_Contact__c;
                }                
            }
        } 
        
        /*** AFTER INSERT ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {	
            for(Opportunity o : lNewOpp){
                if(o.msf_DonationVehicleContact__c != null && o.msf_DonationVehicleContact__c != o.npsp__Primary_Contact__c){
                    OpportunityContactRole oCR = createOCR(o.Id,o.msf_DonationVehicleContact__c);
                    if(!oldOCRMap.containsKey((String)oCR.OpportunityId+(String)oCR.ContactId)){
                        lOCRToInsert.add(oCR);
                    }                    
                } 
            }
        }  
        
        /*** AFTER UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {	
            for(Opportunity o : lNewOpp){
                if(o.msf_DonationVehicleContact__c != mOldOpp.get(o.Id).msf_DonationVehicleContact__c){
                    if(o.msf_DonationVehicleContact__c != o.npsp__Primary_Contact__c && o.msf_DonationVehicleContact__c != null){
                        OpportunityContactRole oCR = createOCR(o.Id,o.msf_DonationVehicleContact__c);
                        if(!oldOCRMap.containsKey((String)oCR.OpportunityId+(String)oCR.ContactId)){
                            lOCRToInsert.add(oCR);
                        }
                    } 
                
                	if(mOldOpp.get(o.Id).msf_DonationVehicleContact__c != null && mOldOpp.get(o.Id).msf_DonationVehicleContact__c != o.msf_DonationVehicleContact__c){
                        sOCRToDelete.add((String)o.Id+(String)mOldOpp.get(o.Id).msf_DonationVehicleContact__c);
                        sOppIdsCon.add(o.Id);
                        sConIds.add(mOldOpp.get(o.Id).msf_DonationVehicleContact__c);
                    }
                } 
            }
            
            if(!sOCRToDelete.isEmpty()) lOCRToDelete.addAll(deleteOCR(sOppIdsCon,sConIds,sOCRToDelete));       
        }  
        System.debug('lOCRToInsert '+lOCRToInsert);
        /*** DML OPERATIONS ***/
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToInsert.addAll((List<OpportunityContactRole>) lOCRToInsert);
        dmlWrapper.objectsToDelete.addAll((List<OpportunityContactRole>) lOCRToDelete);

        if(lOCRToInsert.isEmpty() && lOCRToDelete.isEmpty()){
            return null;
        }  
        
        return dmlWrapper; 
    } 
    
    
    //*** PRIVATE METHODS ***//
    
    /*******************************************************************************************************
    * @description	The helper method for Trigger Handler. Define a new opportunity contact role.
    * @param 		idOpp is the id of the opportunity to which a new opportunity contact role will be created.
    * @param 		idCon is the id of the contact to which a new opportunity contact role will be created.
    * @return 		OpportunityContactRole. 
    ********************************************************************************************************/ 
    private OpportunityContactRole createOCR (ID idOpp, ID idCon){        
        OpportunityContactRole crTemp = new OpportunityContactRole();
            crTemp.ContactId = idCon;
            crTemp.OpportunityId = idOpp;
            crTemp.Role = 'Donor by donation vehicle'; 
        
        return crTemp;
    }
    
    /*******************************************************************************************************
    * @description	The helper method for Trigger Handler. Identify opportunity contact roles records to be deleted.
    * @param 		sOppIdsCon are the ids of opportunities in which information related to the donation vehicle 
    * 				has been updated and it is necessary to delete a opportunity contact role record.
    * @param 		sConIdsare the ids of opportunities in which information related to the donation vehicle in
    * 				ContactVD field has been updated and it is necessary to delete a opportunity contact role record.
    * @param 		sOCRToDelete is a list of strings that contains the exact relationship between the opportunity 
    * 				and the old contact value to remove.
    * @return 		List<OpportunityContactRole>. 
    ********************************************************************************************************/ 
    private List<OpportunityContactRole> deleteOCR (Set<ID> sOppIdsCon, Set<ID> sConIds, Set<String> sOCRToDelete){        
        List<OpportunityContactRole> lTempOCR = new List<OpportunityContactRole>();        
        for(OpportunityContactRole ocr : [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole 
                                          WHERE OpportunityId IN: sOppIdsCon 
                                          AND Role = 'Donor by donation vehicle'
                                          AND ContactId IN: sConIds])
        {
            if(sOCRToDelete.contains((String)ocr.OpportunityId+(String)ocr.ContactId)){
                lTempOCR.add(ocr);
            }
        }
        
        return lTempOCR;
    }
}