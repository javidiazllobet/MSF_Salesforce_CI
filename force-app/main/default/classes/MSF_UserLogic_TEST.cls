/**
* @author       Deloitte
* @date         01-2019
* @group        Campaign
* @description  test class for the MSF_PaymentScheduleLogic_TDTM class.
*/
@isTest
private class MSF_UserLogic_TEST {
	 @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'test',
            npsp__Class__c = 'MSF_UserLogic_TDTM',
            npsp__Object__c = 'User',
            npsp__Trigger_Action__c = 'BeforeUpdate;BeforeInsert',
            npsp__Active__c = true,
            npsp__Load_Order__c = 1,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        insert thCon; 
     }
    
    @isTest
    private static void test() {
        User u = new User(); 
        u.Email = 'mail@mail.com';
        u.Username = 'Userlogic@mail.com';
        u.FirstName = 'Test';
        u.LastName = 'Last';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Canvasser' LIMIT 1].Id;
        u.Alias = 'TEST';
    	u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey ='en_US';
        u.EmailEncodingKey ='UTF-8';
        u.LanguageLocaleKey ='en_US';
        insert u;
        
        User u2 = new User(); 
        u2.Email = 'mail@mail.com';
        u2.Username = 'Userlogic2@mail.com';
        u2.FirstName = 'Test';
        u2.LastName = 'Last';
        u2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'F2F Assistant' LIMIT 1].Id;
        u2.Alias = 'TEST';
    	u2.TimeZoneSidKey = 'Australia/Sydney';
        u2.LocaleSidKey ='en_US';
        u2.EmailEncodingKey ='UTF-8';
        u2.LanguageLocaleKey ='en_US';
        insert u2;
        
        
    }
}