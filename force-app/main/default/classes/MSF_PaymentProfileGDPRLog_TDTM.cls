/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Payment Profile
* @description	Trigger Handler that create GDPR logs
*/

global without sharing class MSF_PaymentProfileGDPRLog_TDTM extends npsp.TDTM_Runnable{

    /*******************************************************************************************************
    * @description	Trigger Handler on Payment profile that manage the changes that must be registered by the GDPR rules.
    * @param 		listNew the list of Payment Profiles from trigger new.  
    * @param 		listOld the list of Payment Profiles from trigger old. 
    * @param 		triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param 		objResult the describe for Payment Profiles.
    * @return 		dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
    	
        //Current User
        Boolean bEcoUser = [SELECT Id, msf_EconomicProcessUser__c FROM User WHERE Id =: UserInfo.getUserId()].msf_EconomicProcessUser__c;
        
        //Attributes
        List<cpm__Payment_Profile__c> lNewPP = (List<cpm__Payment_Profile__c>) newlist;      
		List<cpm__Payment_Profile__c> lOldPP = (List<cpm__Payment_Profile__c>) oldlist;
        Map<Id, cpm__Payment_Profile__c> mOldPP = new Map<Id, cpm__Payment_Profile__c>();
        if(lOldPP != null){            
            mOldPP.putAll(lOldPP);
        }    
        
        MSF_SharedMethods_UTIL sm = new MSF_SharedMethods_UTIL();
   		
        List<msf_GDPRLog__c> lLogsToInsert = new List<msf_GDPRLog__c>();
        
        Map<String,Schema.sObjectField> mObjectFields = cpm__Payment_Profile__c.sObjectType.getDescribe().fields.getMap();
        
        Set<String> sfields = new Set<String>{'cpm__Holder_Name__c','cpm__IBAN__c','cpm__Token__c'};

            
        //Actions
                        
        /*** BEFORE INSERT & BEFORE UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {	
            for(cpm__Payment_Profile__c pp : lNewPP){       
                if(pp.msf_ModificationChannel__c != null){
                    if(bEcoUser){
                        pp.msf_ModificationChannel__c = 'Fichero Bancario';
                    }
                    pp.msf_LastModificationChannel__c = pp.msf_ModificationChannel__c;
                    pp.msf_ModificationChannel__c = null;    
                }				
            }   
        }    
        
        /*** AFTER INSERT ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {	
            for(cpm__Payment_Profile__c pp : lNewPP){            	 
            	msf_GDPRLog__c l = sm.createLog(pp, null, UserInfo.getUserId(), pp.cpm__Contact__c, pp.Id, true, false, sfields, mObjectFields);  
                if (l != null){
                	lLogsToInsert.add(l);     
                }
            }   
        }
        /*** AFTER UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {	
        	for(cpm__Payment_Profile__c pp : lNewPP){
            	msf_GDPRLog__c l = sm.createLog(pp, mOldPP.get(pp.Id), UserInfo.getUserId(), pp.cpm__Contact__c, pp.Id, false, false, sfields, mObjectFields);  
                if (l != null){
                	lLogsToInsert.add(l);     
                }
            } 	   
        } 
        /*** AFTER DELETE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete) {	
        	for(cpm__Payment_Profile__c pp : lOldPP){
            	msf_GDPRLog__c l = sm.createLog(pp, null, UserInfo.getUserId(), pp.cpm__Contact__c, pp.Id, false, true, null, null);  
                if (l != null){
                	lLogsToInsert.add(l);     
                }
            } 
        }
        
        /*** DML OPERATIONS ***/
        if(lLogsToInsert.isEmpty()){
            return null;
        }
        
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToInsert.addAll((List<msf_GDPRLog__c>) lLogsToInsert);        
        
        return dmlWrapper; 
    } 

}