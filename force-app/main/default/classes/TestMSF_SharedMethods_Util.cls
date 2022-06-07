/**
 * @description       : 
 * @author            : arubio@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 06-04-2022
 * @last modified by  : arubio@omegacrmconsulting.com
**/
@isTest
private class TestMSF_SharedMethods_UTIL{

	@testSetup static void setup(){

        Id recordPF = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Id IDContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();
		Id recordRD = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Recurring_donation').getRecordTypeId();
        Id recordTypeOppDonation = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        Id recordTypeLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Associative').getRecordTypeId();

		npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestOpportunitiesFieldsLogic',
            npsp__Class__c = 'MSF_OpportunitiesFieldsLogic_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 6,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon;  
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'Service Center'];
		User u = new User();
        u.msf_City__c = 'Barcelona';
        u.Email = 'user@ac.testcom';
        u.Username = 'user@ac.testcom';
        u.LastName = 'user1';
        u.Alias = 'cc';
        u.CommunityNickname = '';
        u.TimeZoneSidKey = 'Europe/Paris';
        u.LocaleSidKey = 'es_ES';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId=prof.Id;
        u.LanguageLocaleKey='es';
        insert u;
		cpm__IbanValidation__c ibanValidation = new cpm__IbanValidation__c(
            Name = 'ES',
            cpm__RegEx__c = '^(?=[0-9A-Z]{24}$)ES\\d{22}$' 
        );
        insert ibanValidation;
		npsp4hub.NPSPSetup base = new npsp4hub.NPSPSetup();
        cpm.SetupService.install(base);
        cpm.TestService.activateSourceExtension(base);
        cpm.TestService.createIbanRegex();
        cpm.TestService.initTestPSPExtension();
        cpm.TestService.initTestSourceExtension();
		cpm__PaymentHub_Settings__c ps = new cpm__PaymentHub_Settings__c (
            cpm__Auto_Create_Mandate_Recurring_Payment_DD__c = false,	
            cpm__Re_use_existing_mandate__c	= false,
            cpm__Store_Informal_Logs__c	= true,
            Name = 'main'        
        );
        insert ps;
		
		
		Campaign camp = new Campaign(Name='MSFConvertAssociativeLeadTESTcamp1',msf_FinalCampaign__c = false);
        insert camp;


		Lead lead2 = new Lead(RecordTypeId=recordTypeLead,
                              Company='Company2',
                              FirstName='FirstName2',
                              LastName='LastName2',
                              Suffix = 'Suffix2',
                              msf_NIF__c = '59115913W',
                              Email='a@a2.com',   
                              msf_AssociativePhone__c = '911111112',
                              Phone = '911111112',
                              MobilePhone='611111112',
                              LeadSource='SMS',
                              msf_ExemptOfPayment__c=false,
                              msf_IBANCode__c = 'ES76',
                              msf_IBANEntity__c = '3183',
                              msf_IBANOffice__c = '5763',
                              msf_IBANDC__c = '08',
                              msf_IBANAccountNumber__c = '4530503821',     
                              msf_noCriminalRecord__c = true,
                              msf_AcceptStatutes__c = true,
                              msf_acceptDataProtectionPolicy__c = true                             
                              );  
        insert lead2;
		CampaignMember campMem = new CampaignMember(CampaignId=camp.Id, LeadId = lead2.Id);
        insert campMem;
		/**************************************************************************************************************** */
        Contact cont2 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName12',RecordTypeId=IDContactRT);
        insert cont2;

        
        
        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_Name');
        
        insert acc;        
        Contact contactPrueba  = new Contact(
                FirstName='NombrePrueba',
                LastName= 'ApellidoPrueba',
                msf_MainEmail__c = 'm@m.com',
                msf_NIF__c='43578812C',
                msf_IsAssosiative__c = true,
                RecordTypeId=IDContactRT,
                AccountId = acc.Id,
                msf_FirstEntryDateRecurringDonor__c = Date.newInstance(2020, 3, 7)
            );
        
        
        insert contactPrueba;
        
        cpm__Payment_Profile__c p1 = new cpm__Payment_Profile__c(
                cpm__Contact__c = contactPrueba.Id,
                recordtypeId = recordPF,
                cpm__IBAN__c = 'ES7900830842484269389890',
                msf_NIF__c =  contactPrueba.msf_NIF__c,
                cpm__Holder_Name__c =  contactPrueba.FirstName + ' ' +  contactPrueba.LastName + ' ' +  contactPrueba.Suffix,
                cpm__Active__c = true
            ); 
        
        
        insert p1;

        
        npe03__Recurring_Donation__c don = new npe03__Recurring_Donation__c();
        don.npe03__Contact__c =  contactPrueba.Id;
        don.Name = 'test2';
        don.npe03__Open_Ended_Status__c = 'Open';
        don.npsp4hub__Payment_Method__c = 'CreditCard';
        don.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        don.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        don.RecordTypeId = recordRD;
        don.npe03__Paid_Amount__c = 0;
        don.npe03__Total_Paid_Installments__c = 0;
        don.npe03__Amount__c = 1234;
        don.npe03__Installment_Period__c ='Monthly';
        don.msf_CurrentLeadSource1__c ='Correo postal sin cupón';
        don.msf_CurrentCampaign__c = camp.ID;
        don.npsp4hub__Payment_Profile__c = p1.Id;
        don.npe03__Date_Established__c = Date.newInstance(2022, 3, 11);

        insert don;
    
        Opportunity newOpp = new Opportunity(
			Name = 'Opportunity Test', 
            RecordTypeId = recordTypeOppDonation,
			Type = 'Recovered Quota',
            CloseDate = Date.newInstance(2022, 3, 9),
            npsp__Primary_Contact__c = contactPrueba.Id,
            StageName='Cobrada',
			Amount = 1000,
            npsp4hub__Payment_Method__c = 'CreditCard',
            npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA',
            npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA',
			CampaignId = camp.Id,
			npsp4hub__Payment_Profile__c=  p1.Id,
			npe03__Recurring_Donation__c = don.Id
            );
		insert newOpp;

        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole.OpportunityId = newOpp.Id;
        opportunityContactRole.ContactId = contactPrueba.Id;
        opportunityContactRole.IsPrimary = true;
        insert opportunityContactRole;

	}

	@isTest static void SocioConExtraActiva() {

        Contact contactPrueba = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT ID,npe03__Open_Ended_Status__c,npe03__Paid_Amount__c,npe03__Total_Paid_Installments__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        opp.type ='Solidarity Wedding';
        update opp;
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Socio con extra activa', contactPrueba1.msf_MemberType__c);

        Test.stopTest();
    }
    @isTest static void SocioConExtraInactiva() {

        Contact contactPrueba = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT ID,npe03__Open_Ended_Status__c,npe03__Date_Established__c,npe03__Paid_Amount__c,npe03__Total_Paid_Installments__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        testRd.npe03__Date_Established__c = Date.newInstance(2020, 3, 8);
        update testRd;
        opp.type ='Solidarity Wedding';
        opp.CloseDate = Date.newInstance(2020, 3, 9);
        update opp;
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Socio con extra inactiva', contactPrueba1.msf_MemberType__c);

        Test.stopTest();
    }
    @isTest static void Socio() {

        Contact contactPrueba = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT ID,npe03__Open_Ended_Status__c,npe03__Date_Established__c,npe03__Paid_Amount__c,npe03__Total_Paid_Installments__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        System.assertEquals('Socio', contactPrueba.msf_MemberType__c);

        Test.stopTest();
    }

    @isTest static void DonanteConBajaPrevia() {

        Contact contactPrueba = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT ID,npe03__Open_Ended_Status__c,npe03__Paid_Amount__c,npe03__Total_Paid_Installments__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        testRd.npe03__Open_Ended_Status__c = 'Closed';
        testRd.npe03__Paid_Amount__c = 1;
        testRd.msf_CancelationReason__c = '2 TCS devueltas';

        update testRd;
        opp.type ='Solidarity Wedding';
        update opp;
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Donante con Baja previa', contactPrueba1.msf_MemberType__c);

        Test.stopTest();
    }
    @isTest static void ExdonanteConBajaPrevia() {

        Contact contactPrueba = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT ID,npe03__Date_Established__c,npe03__Open_Ended_Status__c,npe03__Paid_Amount__c,npe03__Total_Paid_Installments__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName,type,CloseDate FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        testRd.npe03__Open_Ended_Status__c = 'Closed';
        testRd.npe03__Paid_Amount__c = 1;
        testRd.msf_CancelationReason__c = '2 TCS devueltas';
        testRd.npe03__Date_Established__c =  Date.newInstance(2020, 3, 5);

        update testRd;
        opp.type ='Solidarity Wedding';
        opp.CloseDate = Date.newInstance(2020, 3, 9);
        update opp;
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Exdonante con baja previa', contactPrueba1.msf_MemberType__c);

        Test.stopTest();
    }
    @isTest static void BajaConExtra() {

        Contact contactPrueba = [SELECT msf_MemberType__c,msf_FirstEntryDateRecurringDonor__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT ID,npe03__Open_Ended_Status__c,npe03__Date_Established__c,npe03__Paid_Amount__c,npe03__Total_Paid_Installments__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName,type,CloseDate FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        contactPrueba.msf_FirstEntryDateRecurringDonor__c =  Date.newInstance(2020, 3, 8);
        update contactPrueba;
        testRd.npe03__Open_Ended_Status__c = 'Closed';
        testRd.msf_CancelationReason__c = '2 TCS devueltas';
        testRd.npe03__Date_Established__c =  Date.newInstance(2020, 3, 5);
        update testRd;
        update opp;
        opp.type ='Solidarity Wedding';
        opp.CloseDate = Date.newInstance(2020, 3, 9);
        update opp;

        Test.stopTest();
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Baja con extra', contactPrueba1.msf_MemberType__c);
    }
    @isTest static void Baja() {

        Contact contactPrueba = [SELECT msf_MemberType__c,msf_FirstEntryDateRecurringDonor__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT ID,npe03__Open_Ended_Status__c,npe03__Paid_Amount__c,npe03__Total_Paid_Installments__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        testRd.npe03__Open_Ended_Status__c = 'Closed';
        testRd.msf_CancelationReason__c = '2 TCS devueltas';
        update testRd;
        update opp;
        Test.stopTest();
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Baja', contactPrueba1.msf_MemberType__c);
        }

    @isTest static void Donante() {

        Contact contactPrueba = [SELECT msf_MemberType__c,msf_FirstEntryDateRecurringDonor__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT  npe03__Contact__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        testRd.npe03__Contact__c = null;
        
        update testRd;

        opp.type ='Solidarity Wedding';
        update opp;
        Test.stopTest();
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Donante', contactPrueba1.msf_MemberType__c);
    }
    @isTest static void Exdonante() {

        Contact contactPrueba = [SELECT msf_MemberType__c,msf_FirstEntryDateRecurringDonor__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT  npe03__Contact__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        testRd.npe03__Contact__c = null;
        
        update testRd;
        opp.type ='Solidarity Wedding';
        opp.CloseDate = Date.newInstance(2020, 3, 9);
        update opp;
        Test.stopTest();
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Exdonante', contactPrueba1.msf_MemberType__c);
    }
    @isTest static void NadaDonanteSMS() {

        Contact contactPrueba = [SELECT msf_MemberType__c,msf_FirstEntryDateRecurringDonor__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT  npe03__Contact__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        testRd.npe03__Contact__c = null;
        
        update testRd;
        opp.type ='SMS Operator';
        update opp;
        Test.stopTest();
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Nada (Donante SMS)', contactPrueba1.msf_MemberType__c);
    }
    @isTest static void Nada() {

        Contact contactPrueba = [SELECT msf_MemberType__c,msf_FirstEntryDateRecurringDonor__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        npe03__Recurring_Donation__c testRd = [SELECT  npe03__Contact__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: contactPrueba.Id];
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE npsp__Primary_Contact__c=:contactPrueba.Id LIMIT 1];
        Test.startTest();
        testRd.npe03__Contact__c = null;
        update testRd;
        update opp;
        Test.stopTest();
        Contact contactPrueba1 = [SELECT msf_MemberType__c FROM CONTACT WHERE LASTNAME = 'ApellidoPrueba' LIMIT 1];
        System.assertEquals('Nada', contactPrueba1.msf_MemberType__c);
    }
}