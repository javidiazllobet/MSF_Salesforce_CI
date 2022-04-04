/**
* @author       Deloitte
* @date         01-2019
* @group        Campaign
* @description  test class for the MSF_IntegrationsControl_SCHED, MSF_IntegrationsControl_SCHED_02 class.
*/
@isTest
private class MSF_IntegrationsControl_TEST {
    
    @testSetup static void setup(){
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerT',
            npsp__Class__c = 'MSF_IntegrationsControl_TDTM',
            npsp__Object__c = 'msf_IntegrationsControl__c',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 1,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );       
        upsert thCon; 
    }
    
    public static String CRON_EXP = '0 0 0 L * ? *';
    
   @isTest public static void test() {
        Test.startTest();        	
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP, new MSF_IntegrationsControl_SCHED());  
        
        String jobId2 = System.schedule('ScheduledApexTest-2',CRON_EXP, new MSF_IntegrationsControl_SCHED_02());        
        Test.stopTest();
    }
    
    @isTest public static void test_2() {        
        cpm__Payment_Schedule__c ps = new cpm__Payment_Schedule__c(); 
        ps.cpm__Status__c = 'Verified';
        ps.cpm__PaymentMethod__c = 'CreditCard'; 
        ps.cpm__Run_Date__c = Date.today(); 
        ps.cpm__Selection_Date__c = Date.today(); 
        ps.cpm__Target__c = 'none'; 
        ps.cpm__Collection_Date__c = Date.today();
        ps.cpm__Payment_Processor__c = 'PaymentHub-MT940'; 
        ps.cpm__Source__c = 'PaymentHub'; 
        insert ps; 
        
        msf_IntegrationsControl__c ic = new msf_IntegrationsControl__c(); 
        ic.RecordTypeId = Schema.SObjectType.msf_IntegrationsControl__c.getRecordTypeInfosByDeveloperName().get('SingleEntryFile').getRecordTypeId();
        ic.msf_Status__c = 'Nuevo';
        ic.msf_StartDatePeriod__c = Date.today();
        ic.msf_EndDatePeriod__c = Date.today().addDays(1);
        ic.msf_ProcessType__c = 'Fichero entrada único'; 
        insert ic; 
    }
    
    @isTest public static void test_3() {        
        
        msf_IntegrationsControl__c ic = new msf_IntegrationsControl__c(); 
        ic.RecordTypeId = Schema.SObjectType.msf_IntegrationsControl__c.getRecordTypeInfosByName().get('Talones').getRecordTypeId();
        ic.msf_Status__c = 'Nuevo';
        ic.msf_StartDatePeriod__c = Date.today();
        ic.msf_EndDatePeriod__c = Date.today().addDays(1);
        ic.msf_ProcessType__c = 'Talones'; 
        insert ic; 
        
        List<msf_IntegrationsControl__c> icList = [SELECT Id FROM msf_IntegrationsControl__c WHERE msf_ProcessType__c = 'SAP Finance'];
        
        System.assertEquals(1, icList.size());
    }
}