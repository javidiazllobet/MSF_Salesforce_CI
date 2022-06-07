/**
* @author       Deloitte
* @date         03-2019
* @group        Contact, Opportunity, npe03__Recurring_Donation__c, Campaign , npsp__General_Accounting_Unit__c, cpm__Payment_Profile__c
* @description  test class for the MSF_FormDataEntry_CTRL class.
*/
@isTest
private class MSF_FormDataEntry_TEST {

    @testSetup static void setup(){
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Service Center'];
        RecordType rtOrg = [SELECT id FROM RecordType Where developername= 'Organization' AND SobjectType = 'Contact' LIMIT 1];
        RecordType rtContact = [SELECT id FROM RecordType Where developername= 'Individual_Contact' AND SobjectType = 'Contact' LIMIT 1];
        RecordType rtContactRep = [SELECT id FROM RecordType Where developername= 'Organization_Contact' AND SobjectType = 'Contact' LIMIT 1];
        Map<String,Schema.RecordTypeInfo> mRtPaymentProfileInfo = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName();
        List<cpm__Payment_Profile__c> lPP = new List<cpm__Payment_Profile__c>();
        
        List<Campaign> lCamp = new List<Campaign>();
        lCamp.add(new Campaign(Name='MSFFormF2FTESTtestGetExistingCampaingId',msf_FinalCampaign__c = false));
       	lCamp.add(new Campaign(Name='MSFFormF2FTESTName1',msf_FinalCampaign__c = false));
        insert lCamp;
        
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
        
        //Individual
        Contact c1 = new Contact();
        c1.FirstName='Manuel';
        c1.LastName= 'Medina';
		c1.npe01__HomeEmail__c = 'm@m.com';
        c1.msf_NIF__c='18956402D';
        c1.Gender__c='H';
        insert c1;
        
        //Organization
        
        Contact c0 = new Contact();
        c0.LastName = 'Data';
        c0.npe01__HomeEmail__c = 'dahorg@dah.com';
        c0.msf_NIF__c = '22723449R';
        c0.RecordTypeId = rtOrg.Id;
        c0.msf_MainEmail__c = 'a@a.com';
        c0.MailingStreet = 'Fake Street, 123';
        c0.MailingPostalCode = '08123';
        c0.MailingCity = 'Barcelona';
        c0.MailingState = 'Catalonia';
        c0.MailingCountry = 'Spain';
        c0.HomePhone = '931456767';
        c0.msf_LanguagePreferer__c = 'ESP';
        C0.msf_IsAssosiative__c = true;
		insert c0;
        
		//Organization Contact
        Contact c0contact = new Contact();
        c0contact.FirstName = 'Dummy';
        c0contact.LastName = 'Data';
        c0contact.npe01__HomeEmail__c = 'dah@dah.com';
        c0contact.msf_NIF__c = '54884017Z';
        c0contact.RecordTypeId = rtContactRep.Id;
        c0contact.msf_IsPrimary__c = true;
        c0contact.msf_Organization__c = c0.Id;
		insert c0contact;

        c0.msf_PrimaryContact__c = c0contact.Id;
        update c0;
        
        //GAU
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(
        	Name = 'Terremoto',
            npsp__Active__c =true
        );
        Insert gau;
        
        npsp4hub.NPSPSetup base = new npsp4hub.NPSPSetup();
        cpm.SetupService.install(base);
        cpm.TestService.activateSourceExtension(base);
        cpm.TestService.createIbanRegex();
        cpm.TestService.initTestPSPExtension();
        cpm.TestService.initTestSourceExtension();

        cpm__IbanValidation__c ibanValidation = new cpm__IbanValidation__c(
            Name = 'ES',
            cpm__RegEx__c = '^(?=[0-9A-Z]{24}$)ES\\d{22}$' 
        );
        insert ibanValidation;
        
       cpm__PaymentHub_Settings__c ps = new cpm__PaymentHub_Settings__c (
            cpm__Auto_Create_Mandate_Recurring_Payment_DD__c = false,	
            cpm__Re_use_existing_mandate__c	= false,
            cpm__Store_Informal_Logs__c	= true,
            Name = 'main'        
        );
        insert ps;
        
        //Payment profile from individual 
        cpm__Payment_Profile__c p1 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES8920631786117012691524',
            cpm__Holder_Name__c = 'jose lopez',
            msf_NIF__c = '12707968P',
            cpm__Active__c = true,
            cpm__Contact__c = c1.Id,
            RecordTypeId = mRtPaymentProfileInfo.get('IBAN').getRecordTypeId(),
            OwnerId = u.Id         
        );
        lPP.add(p1);
        
        //Payment profile from organization
        cpm__Payment_Profile__c p2 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES5520248587044315196515',
            cpm__Holder_Name__c = 'org 1',
            msf_NIF__c = '22723449R',
            cpm__Active__c = true,
            cpm__Contact__c = c0.Id,
            RecordTypeId = mRtPaymentProfileInfo.get('IBAN').getRecordTypeId(),
            OwnerId = u.Id         
        );
        lPP.add(p2);
        insert lPP;
        
        //Opportunity
        Opportunity o = new Opportunity (
                    name = 'Donacion puntual',
            		npsp__Primary_Contact__c = c1.Id,
                    type = 'Solidarity Wedding',
                    StageName = 'Propuesta',
            		LeadSource = 'Cupón',
            		CampaignId = lCamp[0].Id,
           			npsp4hub__Payment_Profile__c= p1.Id,
                    CloseDate = date.newInstance(2019, 10, 15)
                );
        insert o;

        Profile pMid = [SELECT Id FROM Profile WHERE Name='Fundraising MID'];
        User u1 = new User(Alias = 'usmid', Email='usmid@test.org.com',
           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
           LocaleSidKey='en_US', ProfileId = pMid.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='usmid@test.org.com');
        insert u1;
    }
        
    @isTest static void testWithRecordIdIndividualContact1(){
        
        Contact c1 = [SELECT Id, msf_LanguagePreferer__c FROM Contact WHERE msf_NIF__c = '18956402D' LIMIT 1];
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'MSFFormF2FTESTName1' LIMIT 1];
        cpm__Payment_Profile__c p1 = [SELECT Id FROM cpm__Payment_Profile__c WHERE msf_NIF__c = '12707968P' LIMIT 1];
        npsp__General_Accounting_Unit__c gau = [SELECT Id FROM npsp__General_Accounting_Unit__c WHERE Name = 'Terremoto' LIMIT 1];
		
        Contact tc1 = new Contact();
        tc1.FirstName='Rosa';
        tc1.LastName= 'Medina';
		tc1.npe01__HomeEmail__c = 'mmmmm@m.com';
        tc1.msf_NIF__c='87726451N';
        tc1.Gender__c='H';

        
        cpm__Payment_Profile__c tp1 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES8920631786117012691524',
            msf_NIF__c = '87726451N'
        );
        
        test.startTest();
            MSF_FormDataEntry_CTRL.getMemberInfo(c1.Id);
            
            MSF_FormDataEntry_CTRL.initializeSobjects(); 
            MSF_FormDataEntry_CTRL.getLanguage(); 
            MSF_FormDataEntry_CTRL.getGender(); 
            MSF_FormDataEntry_CTRL.getOrganizationType(); 
            MSF_FormDataEntry_CTRL.getFundationType(); 
            MSF_FormDataEntry_CTRL.getPayMethod(); 
            MSF_FormDataEntry_CTRL.getLeadSource(); 
            MSF_FormDataEntry_CTRL.getFrequencies(); 
        	MSF_FormDataEntry_CTRL.getModificationChannels();
            
            MSF_FormDataEntry_CTRL.getPayProf('Direct Debit', c1.Id); 
            MSF_FormDataEntry_CTRL.getPayProf('CreditCard',c1.Id);
            MSF_FormDataEntry_CTRL.getPayProf('GRANT',c1.Id);        
            
            MSF_FormDataEntry_CTRL.getPaymentProfileInfo('new');
       		MSF_FormDataEntry_CTRL.getPaymentProfileInfo(p1.Id);
            
        //NEW INDIVIDUAL CONTACT, DIRECT DEBIT, ONE OFF DONATION, NEW PAYMENT PROFILE OTHER .
            MSF_FormDataEntry_CTRL.saveProcess(true, true, false, false, tc1, null, tp1, 'other', 15.00, '', '', '', '', 'One off Donation', '', 
                                               date.Today(), '', gau, 'Direct Debit', 'LA CAIXA CCC OPERATIVA', 'Cupón', camp1, 'Teléfonos At. Socio',null);
        	
        //NEW INDIVIDUAL CONTACT, DUPLICATE NIF, NEW PAYMENT PROFILE OTHER / UAT
        	MSF_FormDataEntry_CTRL.saveProcess(true, true, false, false, tc1, null, tp1, 'member', 15.00, '', '', '', '', 'One off Donation', '', 
                                               date.Today(), '', null, 'Direct Debit', 'LA CAIXA CCC OPERATIVA', 'Cupón', camp1, 'Teléfonos At. Socio',null);
			
/*         //EXIST CONTACT, EN ESPECIE-SERVICIOS, IN-KIND,SERVICIOS, EXIST PAYMENTE PROFILE MEMBER.
			MSF_FormDataEntry_CTRL.saveProcess(false, true, false, false, tc1, null, tp1, 'member', 15.00, '', '', '', '', 'In-Kind Gift', 'Servicios', 
                                               date.Today(), '', null, 'EN ESPECIE-SERVICIOS', 'LA CAIXA CCC OPERATIVA', 'Cupón', camp1, 'Teléfonos At. Socio',null);
        
        //EXIST CONTACT, TALÓN BANCARIO ESTÁNDAR, Matching Gift, EXIST PAYMENTE PROFILE OTHER.
        	MSF_FormDataEntry_CTRL.saveProcess(false, true, false, false, c1, null, p1, 'member', 15.00, '1111111', '1111', '', '', 'Matching Gift', '', 
                                               date.Today(), '', null, 'TALÓN BANCARIO ESTÁNDAR', 'LA CAIXA CCC OPERATIVA', 'Cupón', camp1, 'Teléfonos At. Socio',null); */

        //************* ASSERTS ************************
            List<Contact> assCont = new List<Contact>();
        	List<Opportunity> assOpp = new List<Opportunity>();
        
            assCont = [SELECT id FROM Contact WHERE msf_NIF__c =: tc1.msf_NIF__c];
            system.assertEquals(1, assCont.size(),'No contact inserted');
        
        	assOpp = [SELECT id FROM Opportunity WHERE npsp__Primary_Contact__c =:assCont[0].Id];
        	system.assertEquals(2, assOpp.size(),'No opportunity inserted'); 
        //*********************************************
        
        test.stopTest();
    }

    @isTest static void testWithRecordIdIndividualContact1_2(){
        
        Contact c1 = [SELECT Id, msf_LanguagePreferer__c FROM Contact WHERE msf_NIF__c = '18956402D' LIMIT 1];
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'MSFFormF2FTESTName1' LIMIT 1];
        cpm__Payment_Profile__c p1 = [SELECT Id FROM cpm__Payment_Profile__c WHERE msf_NIF__c = '12707968P' LIMIT 1];
        npsp__General_Accounting_Unit__c gau = [SELECT Id FROM npsp__General_Accounting_Unit__c WHERE Name = 'Terremoto' LIMIT 1];
		
        Contact tc1 = new Contact();
        tc1.FirstName='Rosa';
        tc1.LastName= 'Medina';
		tc1.npe01__HomeEmail__c = 'mmmmm@m.com';
        tc1.msf_NIF__c='87726451N';
        tc1.Gender__c='H';

        
        cpm__Payment_Profile__c tp1 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES8920631786117012691524',
            msf_NIF__c = '87726451N'
        );
        
        test.startTest();

			
        //EXIST CONTACT, EN ESPECIE-SERVICIOS, IN-KIND,SERVICIOS, EXIST PAYMENTE PROFILE MEMBER.
			MSF_FormDataEntry_CTRL.saveProcess(false, true, false, false, tc1, null, tp1, 'member', 15.00, '', '', '', '', 'In-Kind Gift', 'Servicios', 
                                               date.Today(), '', null, 'EN ESPECIE-SERVICIOS', 'LA CAIXA CCC OPERATIVA', 'Cupón', camp1, 'Teléfonos At. Socio',null);
        
        //EXIST CONTACT, TALÓN BANCARIO ESTÁNDAR, Matching Gift, EXIST PAYMENTE PROFILE OTHER.
        	MSF_FormDataEntry_CTRL.saveProcess(false, true, false, false, c1, null, p1, 'member', 15.00, '1111111', '1111', '', '', 'Matching Gift', '', 
                                               date.Today(), '', null, 'TALÓN BANCARIO ESTÁNDAR', 'LA CAIXA CCC OPERATIVA', 'Cupón', camp1, 'Teléfonos At. Socio',null);
        
        test.stopTest();
    }
   
    @isTest static void testWithRecordIdIndividualContact2(){
        
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'MSFFormF2FTESTName1' LIMIT 1];
		
        Contact tc1 = new Contact();
        tc1.FirstName='Rosa';
        tc1.LastName= 'Medina';
		tc1.npe01__HomeEmail__c = 'mmmmm@m.com';
        tc1.msf_NIF__c='87726451N';
        tc1.Gender__c='H';

        
        cpm__Payment_Profile__c tp1 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES8920631786117012691524',
            msf_NIF__c = '87726451N'
        );
        
        test.startTest();
   
        //NEW INDIVIDUAL CONTACT, DIRECT DEBIT, ONE OFF DONATION, NEW PAYMENT PROFILE MEMBER .
        	MSF_FormDataEntry_CTRL.saveProcess(true, true, false, false, tc1, null, tp1, 'member', 15.00, '', '', '', '', 'One off Donation', '', date.Today(), '', null, 'Direct Debit', 'LA CAIXA CCC OPERATIVA', 'Cupón', camp1, 'Teléfonos At. Socio',null);

        //************* ASSERTS ************************
            List<Contact> assCont = new List<Contact>();
        	List<Opportunity> assOpp = new List<Opportunity>();
        
            assCont = [SELECT id FROM Contact WHERE msf_NIF__c =: tc1.msf_NIF__c];
           	system.assertEquals(1, assCont.size(),'No contact inserted');
        
        	assOpp = [SELECT id FROM Opportunity WHERE npsp__Primary_Contact__c =:assCont[0].Id];
        	system.assertEquals(1, assOpp.size(),'No opportunity inserted');
        //*********************************************
        
        test.stopTest();
    }
    
    @isTest static void testWithRecordIdOrganizationContact1(){
        RecordType rtOrg = [SELECT id FROM RecordType Where developername= 'Organization' AND SobjectType = 'Contact' LIMIT 1];
        RecordType rtContactRep = [SELECT id FROM RecordType Where developername= 'Organization_Contact' AND SobjectType = 'Contact' LIMIT 1];
        
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'MSFFormF2FTESTName1' LIMIT 1];
        
        //org test
        Contact tc0 = new Contact();
        tc0.LastName = 'Data';
        tc0.RecordTypeId = rtOrg.Id;
        tc0.msf_MainEmail__c = 'a@a.com';
        tc0.HomePhone = '931456767';
        tc0.msf_NIF__c = 'A85773216';
        tc0.msf_IsAssosiative__c = true;
        
        //org contact test
        Contact tc2 = new Contact();
        tc2.LastName = 'person 1';
        tc2.RecordTypeId = rtContactRep.Id;
        tc2.msf_MainEmail__c = 'a@a.com';
        tc2.msf_fiscalNif__c='01698172J';
        tc2.HomePhone = '999555666';
        
        //payment profile
        cpm__Payment_Profile__c tp1 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES8920631786117012691524',
            msf_NIF__c = '87726451N'
        );
        
        test.startTest();
        
        //NEW ORGANIZATION, WITH ORGANIZATION CONTACT, Direct Debit, Grant, NEW PAYMENT PROFILE OTHER
        	MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, tp1, 'member', 15.00, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, 'Direct Debit', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio',null);
        
        //EXIST ORGANIZATION, WITH ORGANIZATION CONTACT, Direct Debit, One off Donation, EXIST PAYMENT PROFILE MEMBER
            MSF_FormDataEntry_CTRL.saveProcess(false, false, true, true, tc0, tc2, tp1, 'member', 15.00, '', '', '', '', 'One off Donation', '', date.Today(), '', null, 'Direct Debit', 'LA CAIXA CCC OPERATIVA', 'Cupón', camp1, 'Teléfonos At. Socio',null);
        
        //EXIST ORGANIZATION, WITH ORGANIZATION CONTACT, PAYPAL, Matching gift, EXIST PAYMENT PROFILE OTHER
        	//MSF_FormDataEntry_CTRL.saveProcess(false, false, true, true, tc0, tc2, tp1, 'other', 15, '', '', '12345', '67890', 'Matching Gift', '', date.Today().addMonths(1), '', null, 'PAYPAL', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio');

        //KPG - NEW ORGANIZATION, WITH ORGANIZATION CONTACT, TRANSFERENCIA BANCARIA, MAtching Gift, NEW PAYMENT PROFILE OTHER
        	//MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, tp1, 'member', 15, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, 'TRANSFERENCIA BANCARIA', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio');
        
        //KPG - NEW ORGANIZATION, WITH ORGANIZATION CONTACT, sin payment method, Grant, NEW PAYMENT PROFILE OTHER
        	//MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, tp1, 'member', 15, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, null, 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio');

        //KPG - NEW ORGANIZATION, WITH ORGANIZATION CONTACT, sin payment method, Grant, NEW PAYMENT PROFILE OTHER
        	//MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, null, 'member', 15, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, 'GRANT', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio');
 		
        //KPG - NEW ORGANIZATION, WITH ORGANIZATION CONTACT, sin payment method, Grant, NEW PAYMENT PROFILE OTHER
        	//MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, null, 'member', 15, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, 'Direct Debit', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio');

         //************* ASSERTS ************************
            List<Contact> assOrg = new List<Contact>();
        	List<Contact> assContOrg = new List<Contact>();
        	List<Opportunity> assOpp = new List<Opportunity>();
        
            assOrg = [SELECT id FROM Contact WHERE msf_NIF__c =: tc0.msf_NIF__c];
            system.assertEquals(1, assOrg.size(),'No contact inserted');
        
        	assContOrg = [SELECT id FROM Contact WHERE msf_Organization__c=: assOrg[0].Id AND msf_fiscalNif__c =: tc2.msf_fiscalNif__c];
            system.assertEquals(1, assContOrg.size(),'No organization contact inserted');
        
        	assOpp = [SELECT id FROM Opportunity WHERE npsp__Primary_Contact__c =:assOrg[0].Id];
        	system.assertEquals(2, assOpp.size(),'No opportunity inserted');
        //*********************************************
        
        test.stopTest();
        
    }
    
    @isTest static void testWithRecordIdOrganizationContact2(){
        Contact c0 = [SELECT Id, msf_LanguagePreferer__c FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        Contact c0contact = [SELECT Id, msf_LanguagePreferer__c FROM Contact WHERE msf_NIF__c = '54884017Z' LIMIT 1];
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'MSFFormF2FTESTName1' LIMIT 1];
		cpm__Payment_Profile__c p1 = [SELECT Id FROM cpm__Payment_Profile__c WHERE msf_NIF__c = '22723449R' LIMIT 1];
        
        /*npsp4hub.NPSPSetup base = new npsp4hub.NPSPSetup();
        CPM.SetupService.install(base);
        CPM.TestService.activateSourceExtension(base);*/
        
        test.startTest();
            MSF_FormDataEntry_CTRL.getMemberInfo(c0.Id);

        //EXIST ORGANIZATION, WITH ORGANIZATION CONTACT, ACMA, MEMBERSHIP, EXIST PAYMENT PROFILE OTHER
        	MSF_FormDataEntry_CTRL.saveProcess(false, false, true, true, c0, c0contact, p1, 'member', 15.00, '', '', '', '', 'Membership', '', date.Today().addMonths(1), '', null, 'ACMA', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio',null);
        
        //EXIST ORGANIZATION, WITH ORGANIZATION CONTACT, HERENCIAS Y LEGADOS , Herencia, EXIST PAYMENT PROFILE OTHER
        	MSF_FormDataEntry_CTRL.saveProcess(false, false, true, true, c0, c0contact, p1, 'member', 15.00, '', '', '', '', 'Herencia', '', date.Today().addMonths(1), '', null, 'HERENCIAS Y LEGADOS', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio',null);
        
        
        
        //************* ASSERTS ************************
        	List<Opportunity> assOpp = new List<Opportunity>();
        
        	assOpp = [SELECT id FROM Opportunity WHERE npsp__Primary_Contact__c =:c0.Id];
        	system.assertEquals(2, assOpp.size(),'No opportunity inserted');
        //*********************************************
        
        test.stopTest();
        
    }

    @isTest static void testWithRecordIdOrganizationContact2_v2(){
        Contact c0 = [SELECT Id, msf_LanguagePreferer__c FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        Contact c0contact = [SELECT Id, msf_LanguagePreferer__c FROM Contact WHERE msf_NIF__c = '54884017Z' LIMIT 1];
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'MSFFormF2FTESTName1' LIMIT 1];
		cpm__Payment_Profile__c p1 = [SELECT Id FROM cpm__Payment_Profile__c WHERE msf_NIF__c = '22723449R' LIMIT 1];

        test.startTest();
        //RECURRING NUEVA ORG.
        MSF_FormDataEntry_CTRL.saveProcess(false, false, true, true, c0, c0contact, p1, 'member', 15.00, '', '', '', '', 'Recurrent Donation', '', date.Today().addMonths(1), 'Semestral', null, 'Direct Debit', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1 ,'Teléfonos At. Socio',null);//ORG new 

        test.stopTest();
        
    }
    
    
    //KPG
    @isTest static void testWithRecordIdOrganizationContact3(){
        RecordType rtOrg = [SELECT id FROM RecordType Where developername= 'Organization' AND SobjectType = 'Contact' LIMIT 1];
        RecordType rtContactRep = [SELECT id FROM RecordType Where developername= 'Organization_Contact' AND SobjectType = 'Contact' LIMIT 1];
        
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'MSFFormF2FTESTName1' LIMIT 1];
        
        //org test
        Contact tc0 = new Contact();
        tc0.LastName = 'Data';
        tc0.RecordTypeId = rtOrg.Id;
        tc0.msf_MainEmail__c = 'a@a.com';
        tc0.HomePhone = '931456767';
        tc0.msf_NIF__c = 'A85773216';
        tc0.msf_IsAssosiative__c = true;
        
        //org contact test
        Contact tc2 = new Contact();
        tc2.LastName = 'person 1';
        tc2.RecordTypeId = rtContactRep.Id;
        tc2.msf_MainEmail__c = 'a@a.com';
        tc2.msf_fiscalNif__c='01698172J';
        tc2.HomePhone = '999555666';
        
        //payment profile
        cpm__Payment_Profile__c tp1 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES8920631786117012691524',
            msf_NIF__c = '87726451N'
        );
        
        test.startTest();
        
        //KPG - NEW ORGANIZATION, WITH ORGANIZATION CONTACT, TRANSFERENCIA BANCARIA, MAtching Gift, NEW PAYMENT PROFILE OTHER
        	MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, tp1, 'member', 15.00, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, 'TRANSFERENCIA BANCARIA', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio',null);
        
        //KPG - NEW ORGANIZATION, WITH ORGANIZATION CONTACT, sin payment method, Grant, NEW PAYMENT PROFILE OTHER
        	MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, tp1, 'member', 15.00, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, null, 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio',null);

        
         //************* ASSERTS ************************
            List<Contact> assOrg = new List<Contact>();
        	List<Contact> assContOrg = new List<Contact>();
        	List<Opportunity> assOpp = new List<Opportunity>();
        
            assOrg = [SELECT id FROM Contact WHERE msf_NIF__c =: tc0.msf_NIF__c];
            system.assertEquals(1, assOrg.size(),'No contact inserted');
        
        	assContOrg = [SELECT id FROM Contact WHERE msf_Organization__c=: assOrg[0].Id AND msf_fiscalNif__c =: tc2.msf_fiscalNif__c];
            system.assertEquals(1, assContOrg.size(),'No organization contact inserted');
        
        	assOpp = [SELECT id FROM Opportunity WHERE npsp__Primary_Contact__c =:assOrg[0].Id];
        	system.assertEquals(1, assOpp.size(),'No opportunity inserted');
        //*********************************************
        
        test.stopTest();
        
    }

    //KPG
    @isTest static void testWithRecordIdOrganizationContact3_v2(){
        RecordType rtOrg = [SELECT id FROM RecordType Where developername= 'Organization' AND SobjectType = 'Contact' LIMIT 1];
        RecordType rtContactRep = [SELECT id FROM RecordType Where developername= 'Organization_Contact' AND SobjectType = 'Contact' LIMIT 1];
        
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'MSFFormF2FTESTName1' LIMIT 1];
        
        //org test
        Contact tc0 = new Contact();
        tc0.LastName = 'Data';
        tc0.RecordTypeId = rtOrg.Id;
        tc0.msf_MainEmail__c = 'a@a.com';
        tc0.HomePhone = '931456767';
        tc0.msf_NIF__c = 'A85773216';
        tc0.msf_IsAssosiative__c = true;
        
        //org contact test
        Contact tc2 = new Contact();
        tc2.LastName = 'person 1';
        tc2.RecordTypeId = rtContactRep.Id;
        tc2.msf_MainEmail__c = 'a@a.com';
        tc2.msf_fiscalNif__c='01698172J';
        tc2.HomePhone = '999555666';
        
        //payment profile
        cpm__Payment_Profile__c tp1 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES8920631786117012691524',
            msf_NIF__c = '87726451N'
        );
        
        test.startTest();
        //KPG - NEW ORGANIZATION, WITH ORGANIZATION CONTACT, sin payment method, Grant, NEW PAYMENT PROFILE OTHER (falla)
            MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, null, 'member', 15.00, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, 'GRANT', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio',null);
 		
        //KPG - NEW ORGANIZATION, WITH ORGANIZATION CONTACT, sin payment profile, Grant, NEW PAYMENT PROFILE OTHER (falla)
        	MSF_FormDataEntry_CTRL.saveProcess(true, false, true, true, tc0, tc2, null, 'member', 15.00, '', '', '', '', 'Grant', '', date.Today().addMonths(1), '', null, 'Direct Debit', 'LA CAIXA CCC OPERATIVA', 'SMS', camp1, 'Teléfonos At. Socio',null);

         //************* ASSERTS ************************
            List<Contact> assOrg = new List<Contact>();
        	List<Contact> assContOrg = new List<Contact>();
        	List<Opportunity> assOpp = new List<Opportunity>();
        
            assOrg = [SELECT id FROM Contact WHERE msf_NIF__c =: tc0.msf_NIF__c];
            system.assertEquals(1, assOrg.size(),'No contact inserted');
        
        	assContOrg = [SELECT id FROM Contact WHERE msf_Organization__c=: assOrg[0].Id AND msf_fiscalNif__c =: tc2.msf_fiscalNif__c];
            system.assertEquals(1, assContOrg.size(),'No organization contact inserted');
        
        	assOpp = [SELECT id FROM Opportunity WHERE npsp__Primary_Contact__c =:assOrg[0].Id];
        	system.assertEquals(1, assOpp.size(),'No opportunity inserted');
        //*********************************************
        
        test.stopTest();
        
    }
    
    @isTest static void testWithoutRecordId(){
        test.startTest();        
            MSF_FormDataEntry_CTRL.getOppType('Direct Debit');
            MSF_FormDataEntry_CTRL.getOppType('TRANSFERENCIA BANCARIA');
            MSF_FormDataEntry_CTRL.getOppType('INICIATIVA SOLIDARIA ONLINE');
            MSF_FormDataEntry_CTRL.getOppType('EFECTIVO ASOCIATIVO');
            MSF_FormDataEntry_CTRL.getOppType('GIRO POSTAL');
            MSF_FormDataEntry_CTRL.getOppType('CUENTA ABOGADO/CUENTA PUENTE');
            MSF_FormDataEntry_CTRL.getOppType('GRANT');
            MSF_FormDataEntry_CTRL.getOppType('EN ESPECIE-SERVICIOS');
            MSF_FormDataEntry_CTRL.getOppType('HERENCIAS Y LEGADOS');        
            
            MSF_FormDataEntry_CTRL.getInKindTypes(true);
            MSF_FormDataEntry_CTRL.getInKindTypes(false);
            
            MSF_FormDataEntry_CTRL.getTarget(true);
            MSF_FormDataEntry_CTRL.getTarget(false);
            
            MSF_FormDataEntry_CTRL.nextRecurringDate(); 
        
        //************* ASSERTS ************************
        String result = (String)MSF_FormDataEntry_CTRL.getOppType('GRANT');
		system.assertEquals(false, String.isEmpty(result),'No assert');

		result = (String)MSF_FormDataEntry_CTRL.getInKindTypes(true);
		system.assertEquals(false, String.isEmpty(result),'No assert');
        
        result = (String)MSF_FormDataEntry_CTRL.getTarget(true);
		system.assertEquals(false, String.isEmpty(result),'No assert');
        
        //*********************************************
        
        test.stopTest();
    }

    @isTest static void getPayMethodProfileMid() {

        String check;

        User u1 = [SELECT Id FROM User WHERE UserName='usmid@test.org.com'];
        test.startTest(); 
        System.runAs(u1) {
            check = (String) MSF_FormDataEntry_CTRL.getPayMethod();
        }
        test.stopTest();
        system.assertEquals(true, String.isNotBlank(check) && check.contains('Direct Debit'),'No assert');
     }
        
}