/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Opportunity
* @description	test class for the MSF_PaymentProfileGDPRLog_TDTM class.
*/
@isTest
public class MSF_PaymentProfileGDPRLog_TEST {
	@testSetup static void setup(){
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestPaymentProfileGDPRLog',
            npsp__Class__c = 'MSF_PaymentProfileGDPRLog_TDTM',
            npsp__Object__c = 'cpm__Payment_Profile__c',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon;
        
        cpm__IbanValidation__c ibanValidation = new cpm__IbanValidation__c(
            Name = 'ES',
            cpm__RegEx__c = '^(?=[0-9A-Z]{24}$)ES\\d{22}$' ,
            SetupOwnerId = UserInfo.getOrganizationId()
        );
        insert ibanValidation;
        
        npsp4hub.NPSPSetup base = new npsp4hub.NPSPSetup();
        cpm.SetupService.install(base);
        cpm.TestService.activateSourceExtension(base);
        cpm.TestService.createIbanRegex();
        cpm.TestService.initTestPSPExtension();
        cpm.TestService.initTestSourceExtension();
        
        Contact c = new Contact(LastName='cTest', msf_BeginDateMSF__c=date.today());
        c.msf_ModificationChannel__c = 'SMS'; 
        insert c; 
    }
    
    
    @isTest private static void test() {
        cpm__Payment_Profile__c pp = new cpm__Payment_Profile__c();
        pp.cpm__IBAN__c = 'ES9301981287913291375873';
        pp.msf_ModificationChannel__c = 'SMS';
        pp.cpm__Contact__c = [SELECT Id FROM Contact WHERE LastName = 'cTest' LIMIT 1].Id;
        
        insert pp; 
        
        pp.msf_ModificationChannel__c = 'New'; 
        update pp; 
        
        delete pp; 
    }
}