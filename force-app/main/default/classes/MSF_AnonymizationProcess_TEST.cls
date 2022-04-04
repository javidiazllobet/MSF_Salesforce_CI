/**
* @author       Deloitte
* @date         05-2019
* @group        Contact
* @description  test class for the MSF_AnonymizationProcess_CTRL class.
*/
@isTest
private class MSF_AnonymizationProcess_TEST {

    @testSetup 
    static void setup(){
        
        Map<String,Schema.RecordTypeInfo> mConRtInfo = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName(); 
        Map<String,Schema.RecordTypeInfo> mPPRtInfo = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName(); 
        
        Campaign camp = new Campaign(Name='MSF Entry Campaign',msf_FinalCampaign__c = false);
        insert camp;  
        
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestContactFieldsLogic',
            npsp__Class__c = 'MSF_ContactFieldsLogic_TDTM',
            npsp__Object__c = 'Contact',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        
        
    	Contact c = new Contact(
            RecordtypeId = mConRtInfo.get('Organization').getRecordTypeId(),            
            LastName= 'LastName1',
            msf_MainEmail__c = 'm@m.com',
            msf_NIF__c='00000000T',            
            MailingCity = 'Barcelona',
            MailingCountry = 'España',
            MailingPostalCode = '08013',
            MailingState = 'Barcelona',
            MailingStreet = 'C/ Gran via',
            msf_DateReturnedMail3Backup__c = date.today(),
            msf_NoRecibirNada__c = false,
            msf_EntryCampaign__c = camp.Id
        );
        insert c;
        
        msf_GDPRLog__c log = new msf_GDPRLog__c();
        log.msf_Contact__c = c.Id; 
        insert log;
        
        msf_Associative__c ass = new msf_Associative__c();
        ass.msf_ContactId__c = c.Id; 
        insert ass; 
        
        msf_Endorsement__c endorsement = new msf_Endorsement__c();
        endorsement.msf_isEndorsing__c = c.Id;
        endorsement.msf_IsEndorsed__c = c.Id; 
        insert endorsement;
        
        /*Contact c2 = new Contact(
            RecordtypeId = mConRtInfo.get('Organization_Contact').getRecordTypeId(),
			msf_Organization__c = c.Id,            
            FirstName='FirstName1',
            LastName= 'LastName1',
            Suffix = 'LastName2',
            msf_MainEmail__c = 'm@m.com',
            msf_NIF__c='43578879C',            
            MailingCity = 'Barcelona',
            MailingCountry = 'España',
            MailingPostalCode = '08013',
            MailingState = 'Barcelona',
            MailingStreet = 'C/ Gran via',
            msf_DateReturnedMail3Backup__c = date.today(),
            msf_NoRecibirNada__c = false,
            msf_EntryCampaign__c = camp.Id
        );
        insert c2;*/
        
        Contact c3 = new Contact();
        c3.FirstName='Manuel';
        c3.LastName= 'Medina';
        c3.Suffix = 'Herrera';
        c3.msf_NIF__c='15573648A';
        c3.MobilePhone='665310426';
        c3.msf_NoEmail__c=false;
       	insert c3;
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'TESTOPP';
        opp.npe03__Recurring_Donation__c = null;
        opp.npsp__Primary_Contact__c = c3.id;
        opp.StageName = 'Propuesta';
        opp.CloseDate = Date.today();
        opp.AccountId = c3.AccountId; 
        insert opp;
        
                       
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
        
        cpm__Payment_Profile__c newPaymentProfile = new cpm__Payment_Profile__c(
            cpm__Contact__c = c.Id,
            recordtypeId = mPPRtInfo.get('IBAN').getRecordTypeId(),
            cpm__IBAN__c = 'ES4714577504091166875044',
            msf_HolderFirstName__c = c.FirstName,
            msf_HolderLastName1__c = c.LastName,
            msf_HolderLastName2__c = c.Suffix,
            msf_NIF__c = c.msf_NIF__c,
            cpm__Holder_Name__c = c.FirstName + ' ' + c.LastName + ' ' + c.Suffix,
            cpm__Active__c = true
        );        
        insert newPaymentProfile;   
    }
    
    
    @isTest 
    static void anonymizationProcess(){
    	Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c = '00000000T' LIMIT 1];
        MSF_AnonymizationProcess_CTRL.anonymizationRecord(c.Id);
        
        Contact c2 = [SELECT ID FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        MSF_AnonymizationProcess_CTRL.anonymizationRecord(c2.Id);
        
        /*Contact con = [SELECT Id, LastName, msf_MainEmail__c, msf_NoRecibirNada__c, msf_DateReturnedMail3Backup__c, AccountId FROM Contact WHERE Id =: c.Id LIMIT 1];
        //Contact orgCon = [SELECT Id, FirstName, LastName, msf_MainEmail__c, msf_NoRecibirNada__c, msf_DateReturnedMail3Backup__c FROM Contact WHERE msf_Organization__c =: con.Id LIMIT 1];
        Account ac = [SELECT Name, BillingCountry FROM Account WHERE Id =: con.AccountId ];
        cpm__Payment_Profile__c pp = [SELECT cpm__IBAN__c, cpm__Holder_Name__c, cpm__Active__c FROM cpm__Payment_Profile__c WHERE cpm__Contact__c =: con.Id LIMIT 1];
        */
        /*System.assertEquals('Miembro eliminado ' + date.today().day() + '-' + date.today().month() + '-' + date.today().year() + ' .', con.LastName);        
        System.assertEquals(null, con.msf_MainEmail__c);
        System.assertEquals(true, con.msf_NoRecibirNada__c);
        System.assertEquals(null, con.msf_DateReturnedMail3Backup__c);  
        
        System.assertEquals('Miembro eliminado ' + date.today().day() + '-' + date.today().month() + '-' + date.today().year(), orgCon.FirstName); 
        System.assertEquals('.' , orgCon.LastName);   
        System.assertEquals(null, orgCon.msf_MainEmail__c);
        System.assertEquals(true, orgCon.msf_NoRecibirNada__c);
        System.assertEquals(null, orgCon.msf_DateReturnedMail3Backup__c); 
        
        System.assertEquals('ES8200000000000000000000', pp.cpm__IBAN__c);
        System.assertEquals(null, pp.cpm__Holder_Name__c);
        System.assertEquals(false, pp.cpm__Active__c);
        
        System.assertEquals('Miembro eliminado ' + date.today().day() + '-' + date.today().month() + '-' + date.today().year(), ac.Name);
        System.assertEquals(null, ac.BillingCountry);*/
    }
    
}