global without sharing class MSF_IntegrationsControl_SCHED implements Schedulable{
	
    global void execute(SchedulableContext SC) {
        
        List<msf_IntegrationsControl__c> icToInsert = new List<msf_IntegrationsControl__c>();
        
        List<String> codes = new List<String>{'02', '03', '04', '05', '06', '07', '12', '13', '16'};
            
        //Date; 
		Date startDate = Date.today().addMonths(-1); 
        Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
        
        Id recordTypeIdSAPFinance = Schema.SObjectType.msf_IntegrationsControl__c.getRecordTypeInfosByDeveloperName().get('SAPFinance').getRecordTypeId();
        
        for (String code : codes) {
            msf_IntegrationsControl__c ic = new msf_IntegrationsControl__c();
            ic.msf_ProcessType__c = 'SAP Finance'; 
            ic.msf_StartDatePeriod__c = Date.newInstance(startDate.year(), startDate.month(), 1);
            ic.msf_EndDatePeriod__c   = Date.newInstance(startDate.year(), startDate.month(), numberOfDays);
            ic.msf_TypologyPaymentMethod__c = code; 
            ic.msf_Status__c = 'Nuevo'; 
            ic.RecordTypeId = recordTypeIdSAPFinance;
                   
            icToInsert.add(ic);
        }
        
        insert icToInsert; 
        
    }
}