/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Opportunity
* @description	test class for the MSF_ContactGDPRLog_TDTM class.
*/
@isTest
private class MSF_ContactGDPRLog_TEST {
    @testSetup static void setup(){
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestContactGDPRLog',
            npsp__Class__c = 'MSF_ContactGDPRLog_TDTM',
            npsp__Object__c = 'Contact',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon;
    }
    
    @isTest private static void test() {
        Contact c = new Contact(LastName='MSF_AddCampaignMember_TEST_LastName1', msf_BeginDateMSF__c=date.today());
        c.msf_ModificationChannel__c = 'SMS'; 
        insert c; 
        
        c.LastName = 'Testins';
        update c; 
        
        delete c; 
    }

}