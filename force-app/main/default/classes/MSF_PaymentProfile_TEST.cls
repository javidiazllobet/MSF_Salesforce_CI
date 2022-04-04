/**
 * @description       : 
 * @author            : arubio@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 18-03-2022
 * @last modified by  : arubio@omegacrmconsulting.com
**/
@isTest
public with sharing class MSF_PaymentProfile_TEST {
   @isTest 
   static void paymentProfileTest(){

    Profile p = [SELECT Id FROM Profile WHERE Name='Fundraising'];    
    User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='testPaymentProfile@test.org',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testPaymentProfile@test.org');
    insert u1;
    
    npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestOpportunitiesFieldsLogic',
            npsp__Class__c = 'MSF_PaymentProfile_TDTM',
            npsp__Object__c = 'cpm__Payment_Profile__c',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon;         
        
        Contact c = new Contact(
            FirstName='FirstName1',
            LastName= 'LastName1',
            msf_MainEmail__c = 'm@m.com',
            msf_NIF__c='43578879C',
            msf_IsAssosiative__c = true
        );
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testopp';
        opp.StageName = 'Propuesta'; 
        opp.CloseDate = Date.today().addDays(1);
       	opp.Amount = 100;
        opp.npsp__Primary_Contact__c = c.Id;
        insert opp; 
                       
        cpm__IbanValidation__c ibanValidation = new cpm__IbanValidation__c(
            Name = 'ES',
            cpm__RegEx__c = '^(?=[0-9A-Z]{24}$)ES\\d{22}$' ,
            SetupOwnerId = UserInfo.getOrganizationId()
        );
        insert ibanValidation;
    
        
        cpm__PaymentHub_Settings__c ps = new cpm__PaymentHub_Settings__c (
            cpm__Auto_Create_Mandate_Recurring_Payment_DD__c = false,	
            cpm__Re_use_existing_mandate__c	= false,
            cpm__Store_Informal_Logs__c	= true,
            Name = 'main',
            SetupOwnerId = UserInfo.getOrganizationId()
        );
        insert ps;
        
        cpm__Payment_Method__c pm = new cpm__Payment_Method__c(
            cpm__IsActive__c = true,
            cpm__IsDefault__c = false,
            cpm__Method_Default__c = true,
            cpm__Payment_Method__c = 'Direct Debit',
            cpm__Payment_Service_Provider__c = null,
            cpm__Provided_By__c = 'PaymentHub-SEPA',
            cpm__Requires_Payment_Profile__c = true,
            cpm__Support_Bulk__c = true,
            cpm__Support_Online__c = true,
            cpm__Support_Recurring__c = false,
            Name = 'PaymentHub-SEPA-Direct Debit',
            SetupOwnerId = UserInfo.getOrganizationId()
        );
        insert pm;    
        
        cpm__Payment_Schedule__c psche = new cpm__Payment_Schedule__c(); 
        psche.cpm__PaymentMethod__c = 'Direct Debit'; 
        psche.cpm__Payment_Processor__c = 'PaymentHub-SEPA'; 
        psche.cpm__Source__c = 'PaymentHub'; 
        psche.cpm__Target__c = 'None';
        psche.cpm__Run_Date__c = Date.today();
        psche.cpm__Selection_Date__c = Date.today();
        psche.cpm__Collection_Date__c = Date.today().addMonths(3);
        insert psche; 

        Lead lead3 = new Lead(RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId(),
                              Company='Company3',
                              FirstName='FirstName3',
                              LastName='LastName3',
                              Suffix = 'Suffix3',
                              msf_NIF__c = '53617806E',
                              Email='a@a3.com',   
                              msf_AssociativePhone__c = '911111113',
                              Phone = '911111113',
                              MobilePhone='611111113',
                              LeadSource='SMS',
                              msf_ExemptOfPayment__c=false,
                              msf_IBANCode__c = 'ES28',
                              msf_IBANEntity__c = '2022',
                              msf_IBANOffice__c = '1321',
                              msf_IBANDC__c = '87',
                              msf_IBANAccountNumber__c = '8568946703',     
                              msf_noCriminalRecord__c = true,
                              msf_AcceptStatutes__c = true,
                              msf_acceptDataProtectionPolicy__c = true,                             
                              msf_EndorsedByOne__c = c.Id
                              );      
        insert lead3;

        cpm__Installment__c inst = new cpm__Installment__c();
            inst.npsp4hub__Opportunity__c = opp.Id; 
            inst.cpm__of_times_rejected__c = 0; 
            inst.cpm__Contact__c = c.Id;
            //inst.cpm__Payment_Profile__c = payment.Id;
            insert inst; 
        
        String sIBAN = lead3.msf_IBANCode__c + lead3.msf_IBANEntity__c + lead3.msf_IBANOffice__c + lead3.msf_IBANDC__c + lead3.msf_IBANAccountNumber__c;
        cpm__Payment_Profile__c payment = new cpm__Payment_Profile__c(cpm__Contact__c=c.Id, 
                                                                      cpm__IBAN__c=sIBAN, 
                                                                      msf_NIF__c=lead3.msf_NIF__c, 
                                                                      cpm__Active__c=true,
                                                                      RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName().get('IBAN').getRecordTypeId()
                                                                     );


        System.runAs(u1){
            test.startTest();
            insert payment;

            cpm__Installment__c installment = [SELECT id, cpm__Payment_Profile__c FROM cpm__Installment__c Limit 1];
            installment.cpm__Payment_Profile__c = payment.Id;
            update installment;

            payment.cpm__Bank_Name__c = 'TestBank';
            update payment;
            test.stopTest();
            system.assertEquals('TestBank', payment.cpm__Bank_Name__c);
        }                                                             
   }
}