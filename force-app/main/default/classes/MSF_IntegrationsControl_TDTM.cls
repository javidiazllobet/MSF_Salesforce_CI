/**
* @author 		Deloitte
* @date 		11-2018
* @group 		msf_IntegrationsControl__c donation.
* @description	msf_IntegrationsControl__c
*/
global without sharing class MSF_IntegrationsControl_TDTM extends npsp.TDTM_Runnable{

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
     	
        //Attributes
        List<msf_IntegrationsControl__c> lNewIC = (List<msf_IntegrationsControl__c>) newlist;        
        List<msf_IntegrationsControl__c> lOldIC = (List<msf_IntegrationsControl__c>) oldlist;
        Map<Id, msf_IntegrationsControl__c> mOldIC = new Map<Id, msf_IntegrationsControl__c>();
        if(lOldIC != null){            
            mOldIC.putAll(lOldIC);
        }
        /*
        Id recordTypeIdSingleEntryFile = Schema.SObjectType.msf_IntegrationsControl__c.getRecordTypeInfosByDeveloperName().get('SingleEntryFile').getRecordTypeId();
        
        //Before Insert || Before Update
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate){
            
            //PaymentSchedules;
            List<String> paymentSchedulesStatus = new List<String>{'Done', 'Scheduled'}; 
			List<cpm__Payment_Schedule__c> paymentSchedulesList = [SELECT Id, cpm__Status__c FROM cpm__Payment_Schedule__c 
                                                                   WHERE cpm__Status__c NOT IN :paymentSchedulesStatus]; 
        	
            if (paymentSchedulesList.isEmpty() == false) {
                
                for (msf_IntegrationsControl__c ic: lNewIC) {
                    if (ic.RecordTypeId == recordTypeIdSingleEntryFile) {
                        if ((ic.msf_Status__c == 'Nuevo' || ic.msf_Status__c == 'En progreso') && Test.isRunningTest() == false) {
                            ic.addError(System.Label.MSF_INTEGRATIONS_CONTROL_BLOCKED);
                        }
                    }
                }
                
            }
        }     
    	*/
         
        Id recordTypeIdTalones = Schema.SObjectType.msf_IntegrationsControl__c.getRecordTypeInfosByName().get('Talones').getRecordTypeId();
        Id recordTypeIdSAPFinance = Schema.SObjectType.msf_IntegrationsControl__c.getRecordTypeInfosByName().get('SAP Finanzas').getRecordTypeId();
        List<msf_IntegrationsControl__c> icToInsert = new List<sObject>(); 

        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){
            
            for (msf_IntegrationsControl__c ic : lNewIC) {
                if (ic.RecordTypeId == recordTypeIdTalones) {
                    msf_IntegrationsControl__c newIC = new msf_IntegrationsControl__c(); 
                    newIC.msf_ProcessType__c = 'SAP Finance'; 
                    newIC.msf_StartDatePeriod__c = ic.msf_StartDatePeriod__c;
                    newIC.msf_EndDatePeriod__c = ic.msf_EndDatePeriod__c; 
                    newIC.msf_TypologyPaymentMethod__c = '02'; 
                    newIC.msf_Status__c = 'Nuevo'; 
                    newIC.RecordTypeId = recordTypeIdSAPFinance;
                    
                    icToInsert.add(newIC);
                }
            }
        }
     
        if (icToInsert.isEmpty()) {
         	return null;    
        }
        
        //DML Operations
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToInsert.addAll((List<msf_IntegrationsControl__c>) icToInsert);
        
        return dmlWrapper; 
    }
}