/**
* @author       Deloitte
* @date         10-2019
* @group        PaymentSchedule.
* @description  Logic of some fields and processes.
*/
global without sharing class MSF_PaymentScheduleLogic_TDTM extends npsp.TDTM_Runnable {

    /*******************************************************************************************************
    * @description  Trigger Handler on PaymentSchedule that handles the logic of some fields and deletions. 
    * @param        listNew the list of PaymentSchedule from trigger new. 
    * @param        listOld the list of PaymentSchedule from trigger old. 
    * @param        triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param        objResult the describe for PaymentSchedule
    * @return       dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
        
        List<cpm__Payment_Schedule__c> lNewPS = (List<cpm__Payment_Schedule__c>) newlist;
        List<cpm__Payment_Schedule__c> lOldPS = (List<cpm__Payment_Schedule__c>) oldlist;
        
        List<msf_IntegrationsControl__c> icToInsert = new List<sObject>(); 
        
        //After Update
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate){
            Id recordTypeIdSAPFinance = Schema.SObjectType.msf_IntegrationsControl__c.getRecordTypeInfosByDeveloperName().get('SAPFinance').getRecordTypeId();
            
            for (cpm__Payment_Schedule__c ps : lNewPS) {
                if (ps.cpm__Status__c == 'Done') {
               		if (ps.cpm__PaymentMethod__c == 'Direct Debit') {
                    	msf_IntegrationsControl__c ic = new msf_IntegrationsControl__c(); 
                        ic.msf_ProcessType__c = 'SAP Finance'; 
                        ic.msf_StartDatePeriod__c = ps.cpm__Collection_Date__c;
                        ic.msf_EndDatePeriod__c = ps.cpm__Collection_Date__c; 
                        ic.msf_TypologyPaymentMethod__c = '00'; 
                        ic.msf_Status__c = 'Nuevo'; 
                        ic.RecordTypeId = recordTypeIdSAPFinance;
                        
                        icToInsert.add(ic);

                    }
                    else if (ps.cpm__PaymentMethod__c == 'CreditCard') {
                        msf_IntegrationsControl__c ic = new msf_IntegrationsControl__c(); 
                        ic.msf_ProcessType__c = 'SAP Finance'; 
                        ic.msf_StartDatePeriod__c = ps.cpm__Run_Date__c;
                        ic.msf_EndDatePeriod__c = ps.cpm__Run_Date__c; 
                        ic.msf_TypologyPaymentMethod__c = '01'; 
                        ic.msf_Status__c = 'Nuevo'; 
                        ic.RecordTypeId = recordTypeIdSAPFinance;
                        
                        icToInsert.add(ic); 
                    }     
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