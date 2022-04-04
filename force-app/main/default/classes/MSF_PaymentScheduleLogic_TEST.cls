/**
* @author       Deloitte
* @date         01-2019
* @group        Campaign
* @description  test class for the MSF_PaymentScheduleLogic_TDTM class.
*/
@isTest
private class MSF_PaymentScheduleLogic_TEST {
	
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'test',
            npsp__Class__c = 'MSF_PaymentScheduleLogic_TDTM',
            npsp__Object__c = 'cpm__Payment_Schedule__c',
            npsp__Trigger_Action__c = 'AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 1,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        insert thCon; 
    }
    
    @isTest static void test() {
        cpm__Payment_Schedule__c ps = new cpm__Payment_Schedule__c(); 
        ps.cpm__PaymentMethod__c = 'Direct Debit'; 
        ps.cpm__Payment_Processor__c = 'PaymentHub-SEPA'; 
        ps.cpm__Source__c = 'PaymentHub'; 
        ps.cpm__Target__c = 'None';
        ps.cpm__Run_Date__c = Date.today();
        ps.cpm__Selection_Date__c = Date.today();
        ps.cpm__Collection_Date__c = Date.today().addMonths(3);
        insert ps; 
        
        test.startTest();
        
        ps.cpm__Status__c = 'Done'; 
        ps.cpm__PaymentMethod__c = 'Direct Debit'; 
        update ps; 
        
        ps.cpm__Status__c = 'Done'; 
        ps.cpm__PaymentMethod__c = 'CreditCard'; 
        update ps; 
        
        test.stopTest();
        
    }
    
}