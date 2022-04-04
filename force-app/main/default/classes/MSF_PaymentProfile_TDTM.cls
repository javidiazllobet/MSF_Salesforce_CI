/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Payment Profile
* @description	Trigger Handler that create GDPR logs
*/
global without sharing class MSF_PaymentProfile_TDTM extends npsp.TDTM_Runnable{

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

        //Comprobar si se pueden modificar los PP;  
        Boolean canUpdate = true;
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            canUpdate = checkCanUpdate(lNewPP, mOldPP, bEcoUser);
        }
        if (canUpdate == false) {
            return null;
        }
            
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
    
    
    private static Boolean checkCanUpdate(List<cpm__Payment_Profile__c> lNewPP, Map<Id, cpm__Payment_Profile__c> mOldPP, Boolean isEconomic) {
        Boolean canUpdate = true; 
        
        Id profileId = UserInfo.getProfileId();
        
        Boolean isAdmin = [SELECT PermissionsModifyAllData FROM Profile WHERE Id =: profileId].PermissionsModifyAllData;
        
        if (isAdmin == false && isEconomic == false) {
            
            List<String> paymentSchedulesStatus = new List<String>{'Done'}; 
            List<cpm__Payment_Schedule__c> paymentSchedulesList = [SELECT Id, cpm__Status__c, cpm__PaymentMethod__c, cpm__Selection_Date__c FROM cpm__Payment_Schedule__c WHERE cpm__Status__c NOT IN :paymentSchedulesStatus]; 

            if (!paymentSchedulesList.isEmpty()){               
                Map<Id, List<cpm__Installment__c>> mInstallmentsByPP = new Map<id, List<cpm__Installment__c>>(); 
                for (cpm__Installment__c inst : [SELECT ID, cpm__Payment_Profile__c, cpm__Due_Date__c, cpm__Payment_Method__c, cpm__Status__c FROM cpm__Installment__c WHERE cpm__Payment_Profile__c IN :mOldPP.keyset()]) {
                    List<cpm__Installment__c> l = mInstallmentsByPP.get(inst.cpm__Payment_Profile__c);
                    if (l == null) {
                        l = new List<cpm__Installment__c>(); 
                    }
                    l.add(inst);
                    mInstallmentsByPP.put(inst.cpm__Payment_Profile__c, l);
                }
                
                for (cpm__Payment_Profile__c pp : lNewPP) {
                    cpm__Payment_Profile__c oldPP = mOldPP.get(pp.Id);
                    if (oldPP == null) { oldPP = pp; }
                    List<cpm__Installment__c> installments = mInstallmentsByPP.get(pp.Id);
                    
                    for (cpm__Installment__c inst : installments) {
                        if (inst != null) {
                            if (inst.cpm__Status__c.equals('New') || inst.cpm__Status__c.equals('Pending recollection')) {  
                                for (cpm__Payment_Schedule__c ps : paymentSchedulesList) {
                                    if (inst.cpm__Due_Date__c <= ps.cpm__Selection_Date__c && inst.cpm__Payment_Method__c == ps.cpm__PaymentMethod__c) {
                                        canUpdate = false; 
                                        pp.addError(System.Label.MSF_PAYMENTPROFILE_BLOCKED);    
                                    }
                                }
                            }
                        }   
                    }
                } 
            }
        }
        
        return canUpdate; 
    }

}