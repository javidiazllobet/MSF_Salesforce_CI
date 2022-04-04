global without sharing class MSF_IntegrationsControl_SCHED_02 implements Schedulable{
	
    global void execute(SchedulableContext SC) {
        
        List<msf_IntegrationsControl__c> icToInsert = new List<msf_IntegrationsControl__c>();
        
        List<String> codes = new List<String>{'09', '10'};
            
        //Date; 
		Date startDate = Date.today().addYears(-1);
        Integer numberOfDays = Date.daysInMonth(startDate.year(), 12);
        
        Id recordTypeIdSAPFinance = Schema.SObjectType.msf_IntegrationsControl__c.getRecordTypeInfosByDeveloperName().get('SAPFinance').getRecordTypeId();
        
        for (String code : codes) {
            msf_IntegrationsControl__c ic = new msf_IntegrationsControl__c();
            ic.msf_ProcessType__c = 'SAP Finance'; 
            ic.msf_StartDatePeriod__c = Date.newInstance(startDate.year(), 1, 1);
            ic.msf_EndDatePeriod__c   = Date.newInstance(startDate.year(), 12, numberOfDays);
            ic.msf_TypologyPaymentMethod__c = code; 
            ic.msf_Status__c = 'Nuevo'; 
            ic.RecordTypeId = recordTypeIdSAPFinance;
                   
            icToInsert.add(ic);
        }
        
        insert icToInsert; 
        
    }

}