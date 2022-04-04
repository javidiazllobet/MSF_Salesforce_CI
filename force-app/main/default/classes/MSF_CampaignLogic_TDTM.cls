/**
* @author       Deloitte
* @date         01-2019
* @group        Campaign.
* @description  Logic of some fields and processes.
*/
global without sharing class MSF_CampaignLogic_TDTM extends npsp.TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description  Trigger Handler on Campaign that handles the logic of some fields and deletions. 
    * @param        listNew the list of Campaigns from trigger new. 
    * @param        listOld the list of Campaigns from trigger old. 
    * @param        triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param        objResult the describe for Campaigns
    * @return       dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
        
        //Attributes
        List<Campaign> lNewCam = (List<Campaign>) newlist;
        List<Campaign> lOldCam = (List<Campaign>) oldlist;
        Map<Id, Campaign> mOldCam = new Map<Id, Campaign>();
        if(lOldCam != null){            
            mOldCam.putAll(lOldCam);
        }

        List<Contact> lContactsToUpdate = new List<Contact>();
        List<CampaignMemberStatus> cms2Delete = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>();
        
        //After Insert
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){
                       
            List<CampaignMemberStatus> cms = new List<CampaignMemberStatus>();
			List<Campaign> defaultCampaigns = new List<Campaign>();
            
            Id recordTypeIdDefaultCampaign = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId(); 
            for (Campaign c : lNewCam) {
                if (c.RecordTypeId == recordTypeIdDefaultCampaign) {
                    CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId = c.Id, HasResponded=false, 
                                                                      Label='Impactado', SortOrder = 3, isDefault = true);
                    cms2Insert.add(cms1);
                    
                    CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId = c.Id, HasResponded=true, 
                                                                         Label='Respondida (op abierta)', SortOrder = 5, isDefault = false);
                    cms2Insert.add(cms2);   
                    
                    CampaignMemberStatus cms3 = new CampaignMemberStatus(CampaignId = c.Id, HasResponded=true, 
                                                                         Label='Respondida (cerrada)', SortOrder = 4, isDefault = false);
                    cms2Insert.add(cms3);
                    
                    defaultCampaigns.add(c);
                }
            }
           
            for (CampaignMemberStatus cm : [SELECT ID, Label, CampaignId FROM CampaignMemberStatus WHERE CampaignId IN :defaultCampaigns]) {
				cms2Delete.add(cm);
            }
            //insert cms2Insert;
    		//delete cms2Delete;
            
        }
        

        //Actions
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete){
            for(Campaign cam : lOldCam){ 
                // If the campaign to be deleted was from a promoter, the level for this promoter is checked again.
                if(cam.msf_PromoterIndividual__c != null){
                    lContactsToUpdate.add(new Contact(Id=cam.msf_PromoterIndividual__c,msf_RecalculateMemberType__c=TRUE));
                }
            }    
        }
        
        //DML Operations
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToUpdate.addAll((List<Contact>)lContactsToUpdate);

        dmlWrapper.objectsToInsert.addAll((List<CampaignMemberStatus>) cms2Insert);
        dmlWrapper.objectsToDelete.addAll((List<CampaignMemberStatus>) cms2Delete);
                
        return dmlWrapper;
    }
}