/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Installment
* @description	test class for the MSF_Installments_TDTM class.
*/
@isTest
public class MSF_Installments_TEST {
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestInstallments',
            npsp__Class__c = 'MSF_Installments_TDTM',
            npsp__Object__c = 'cpm__Installment__c',
            npsp__Trigger_Action__c = 'BeforeInsert,AfterInsert,BeforeUpdate,AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 1,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );
        upsert thCon;
        
        Contact c = new Contact(LastName='LastName1', msf_BeginDateMSF__c=date.today());
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testopp';
        opp.StageName = 'Propuesta'; 
        opp.CloseDate = Date.today().addDays(1);
       	opp.Amount = 100;
        opp.npsp__Primary_Contact__c = c.Id;
        //opp.npe03__Recurring_Donation__c = don.Id;
        insert opp;
        
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
        
        cpm__Installment__c inst = new cpm__Installment__c();
       	inst.npsp4hub__Opportunity__c = opp.Id; 
       	inst.cpm__of_times_rejected__c = 0; 
        inst.cpm__Contact__c = c.Id;
        inst.msf_LeadSource__c = 'Telemarketing';
        inst.msf_Description__c = 'Descripcion test';
        //inst.cpm__Payment_Method__c = 'CreditCard';
        inst.cpm__Status__c = 'New';
        insert inst; 
        
    }
    
    @isTest
    private static void test() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Fundraising'];    
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='testPaymentProfile@test.org',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testPaymentProfile@test.org');
        insert u1;
        cpm__Installment__c inst = [SELECT Id, cpm__of_times_rejected__c,cpm__Last_ReasonCode_Received__c, 
                                    cpm__Last_Rejection_Date__c, cpm__Payment_Method__c
                                    FROM cpm__Installment__c  LIMIT 1];
       
        inst.cpm__of_times_rejected__c = 2; 
        inst.cpm__Last_ReasonCode_Received__c = '001'; 
        inst.cpm__Last_Rejection_Date__c = Date.today();
        inst.cpm__Payment_Method__c = 'CreditCard';

        System.runAs(u1){
            test.startTest();
            update inst; 
            test.stopTest();
        }
        system.assertEquals('CreditCard', inst.cpm__Payment_Method__c);
        
    }

    @isTest
    private static void test2() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Fundraising'];    
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='testPaymentProfile@test.org',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testPaymentProfile@test.org');
        insert u1;

        Contact contacto = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, name, npe03__Recurring_Donation__c FROM Opportunity WHERE Name = 'testopp'];

        npe03__Recurring_Donation__c don = new npe03__Recurring_Donation__c();
        don.npe03__Contact__c = contacto.Id;
        don.npe03__Open_Ended_Status__c = 'Open';
        don.npsp4hub__Payment_Method__c = 'Direct Debit';
        don.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        don.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        don.RecordTypeId = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Associate').getRecordTypeId();
        insert don;

        opp.npe03__Recurring_Donation__c = don.Id;
        update opp;

        cpm__Installment__c inst = [SELECT Id, cpm__of_times_rejected__c,cpm__Last_ReasonCode_Received__c, 
                                    cpm__Last_Rejection_Date__c, cpm__Payment_Method__c
                                    FROM cpm__Installment__c  LIMIT 1];
       
        inst.cpm__of_times_rejected__c = 2; 
        inst.cpm__Last_ReasonCode_Received__c = '001'; 
        inst.cpm__Last_Rejection_Date__c = Date.today();
        inst.cpm__Payment_Method__c = 'CreditCard';



        System.runAs(u1){
            test.startTest();
            update inst; 
            test.stopTest();
        }
        system.assertEquals('CreditCard', inst.cpm__Payment_Method__c);
    }
}