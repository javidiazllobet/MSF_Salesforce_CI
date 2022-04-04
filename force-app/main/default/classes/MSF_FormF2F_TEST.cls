/**
* @author 		Deloitte
* @date 		01-2019
* @group 		Account, Contact, Opportunity, npe03__Recurring_Donation__c, Lead, Task, npe5__Affiliation__c
* @description	test class for the  FormF2F clases. Continues with the class MSF_FormF2F_TEST2 due to overload of SOQL queries.
*/
@isTest
private class MSF_FormF2F_TEST {
    
    @testSetup static void setup(){   
         npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestOpportunitiesFieldsLogic',
            npsp__Class__c = 'MSF_OpportunitiesFieldsLogic_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        ); 
        upsert thCon; 
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Canvasser'];
        RecordType rtOrg = [SELECT id FROM RecordType Where developername= 'Organization' AND SobjectType = 'Contact' LIMIT 1];
        RecordType rtContact = [SELECT id FROM RecordType Where developername= 'Individual_Contact' AND SobjectType = 'Contact' LIMIT 1];
        RecordType rtContactRep = [SELECT id FROM RecordType Where developername= 'Organization_Contact' AND SobjectType = 'Contact' LIMIT 1];
        
        List<Campaign> lCamp = new List<Campaign>();
        lCamp.add(new Campaign(Name='MSFFormF2FTESTtestGetExistingCampaingId',msf_FinalCampaign__c = false, msf_BetterNowExternalId__c = 'TEST01F2FEXIST', msf_CustomExternalId__c = 'TEST02F2FEXIST'));
        lCamp.add(new Campaign(Name='MSFFormF2FTESTName1',msf_FinalCampaign__c = false, msf_BetterNowExternalId__c = 'TEST01F2F', msf_CustomExternalId__c = 'TEST02F2F'));
        insert lCamp;
        
        User u = new User();
        //u.msf_Campaign__c= 'Alta F2F';
        u.msf_City__c = 'Barcelona';
        u.Email = 'user@ab.testcom';
        u.Username = 'user@ab.testcom';
        u.LastName = 'user1';
        u.Alias = 'cc';
        u.CommunityNickname = '';
        u.TimeZoneSidKey = 'Europe/Paris';
        u.LocaleSidKey = 'es_ES';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId=prof.Id;
        u.LanguageLocaleKey='es';
        insert u;
        
        List<Contact> contList = new List<Contact>();
        
        Contact cOrg = new Contact();
        cOrg.LastName= 'Silver&Gold';
        cOrg.msf_NIF__c ='A89359160';
        cOrg.msf_MainEmail__c = 'aaa@a.com';
        cOrg.RecordTypeId=rtOrg.Id;
        cOrg.Gender__c='N';
        cOrg.msf_BeginDateMSF__c=date.today();
        contList.add(cOrg);
        
        Contact c1 = new Contact();
        c1.FirstName='Manuel';
        c1.LastName= 'Medina';
        c1.npe01__HomeEmail__c = 'm@m.com';
        c1.msf_NIF__c='18956402D';
        c1.Gender__c='H';
        c1.msf_BeginDateMSF__c=date.today();
        contList.add(c1);
        insert contList;
        
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
        c0.Gender__c='H';
        c0.msf_BeginDateMSF__c=date.today();
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
        c0contact.msf_BeginDateMSF__c=date.today();
        insert c0contact;
        
        c0.msf_PrimaryContact__c = c0contact.Id;
        update c0;

         npe03__Recurring_Donation__c recDonation = new npe03__Recurring_Donation__c (
                Name = 'DR',
                recordTypeId = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Recurring_donation').getRecordTypeId(),
                npe03__Open_Ended_Status__c = 'Open',
                npe03__Installment_Period__c = 'Yearly',
                npe03__Contact__c = c0.Id,
                npe03__Date_Established__c = date.today(),
                npe03__Amount__c = 50,
                npe03__Installments__c = 0,
                npsp4hub__Payment_Method__c = 'Direct Debit',
                npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
            );
        insert recDonation;
        
        Lead lc = new Lead();
        lc.FirstName ='patricia';
        lc.LastName='pereira';
        lc.msf_NIF__c='74035964E';
        lc.msf_esOrganizacion__c =false;
        lc.Company='N/A';
        lc.Description='vv';
        lc.msf_FirmaDonante__c=true;
        insert lc;
        
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Header_Picture1'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        content.origin = 'H';
        insert content;
        
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE id =:content.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = lc.id;
        contentlink.ContentDocumentId = cv.ContentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink;	
        
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
    }
    
    //**************** Test Methods-Contacts ****************
    @isTest()
    static void myTest(){
        Contact c0 = [SELECT Id,FirstName, LastName, npe01__HomeEmail__c, msf_NIF__c, msf_PrimaryContact__c, msf_MainEmail__c,
                      MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingCountry, HomePhone,msf_LanguagePreferer__c
                      FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        User u = [SELECT Id, msf_Campaign__c, msf_City__c, Email, Username, LastName, Alias, CommunityNickname,
                  TimeZoneSidKey, LocaleSidKey, EmailEncodingKey,ProfileId,LanguageLocaleKey
                  FROM User WHERE UserName = 'user@ab.testcom' LIMIT 1];
        
        Lead lc = [SELECT Id, FirstName, LastName, msf_NIF__c, msf_esOrganizacion__c, Company, Description, msf_FirmaDonante__c,createdDate
                   FROM Lead WHERE msf_NIF__c = '74035964E' LIMIT 1];
        ContentVersion content = [SELECT Id, Title, VersionData, origin FROM ContentVersion Where Title = 'Header_Picture1' LIMIT 1];
        ContentDocumentLink contentlink= [SELECT Id, ContentDocumentId, ShareType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :lc.id];
        
        //********************* Objects whitout Insert *************************
        List<Opportunity> listOpportunityTest1 = new List<Opportunity>(); 
        List<npe03__Recurring_Donation__c> listRecurringTest1 = new List<npe03__Recurring_Donation__c>(); 
        Contact c2 = new Contact();
        c2.FirstName='patricia';
        c2.LastName= 'pereira';
        c2.msf_NIF__c='74035964E';
        c2.Gender__c = 'M';
        
        //con pp. p2
        Contact c3 = new Contact();
        c3.FirstName='Manuel';
        c3.LastName= 'Medina';
        c3.Suffix='dd';
        c3.msf_MainEmail__c = 'example@dddd.com';
        c3.msf_NIF__c='18956402D';
        c3.Birthdate =date.newInstance(2002, 10, 15);
        c3.MailingCity= 'bcn';
        c3.MailingCountry= 'españa';
        c3.MailingPostalCode='12345';
        c3.MailingState ='bcn';
        c3.MailingStreet='valencia';
        c3.HomePhone='956123123';
        c3.MobilePhone='654654654';
        c3.msf_LanguagePreferer__c='CAT';
        c3.Gender__c='H';
        c3.msf_FiscalFirstName__c='xx';
        c3.msf_FiscalLastName1__c='xx';
        c3.msf_FiscalLastName2__c='xx';
        c3.msf_fiscalNif__c ='78019601J';
        
        Contact c4 = new Contact();
        c4.LastName= 'gonzales S.L.';
        c4.msf_NIF__c='68538610J'; 
        
        cpm__Payment_Profile__c p1 = new cpm__Payment_Profile__c();
        p1.cpm__IBAN__c ='ES5600578616567582427325';
        p1.msf_HolderFirstName__c = 'jose';
        p1.msf_HolderLastName1__c = 'lopez';
        p1.msf_HolderLastName2__c = '';
        p1.msf_NIF__c = '15426414S';
        p1.cpm__Holder_Name__c = 'jose lopez';
        p1.cpm__Active__c = true;
        p1.OwnerId = u.Id;
        
        cpm__Payment_Profile__c p2 = new cpm__Payment_Profile__c();
        p2.cpm__IBAN__c ='ES2201043116021519780525';
        p2.msf_HolderFirstName__c = 'ff';
        p2.msf_HolderLastName1__c = 'aa';
        p2.msf_HolderLastName2__c = '';
        p2.msf_NIF__c = c4.msf_NIF__c;
        p2.cpm__Holder_Name__c = 'jose lopez';
        p2.cpm__Active__c = true;
        p2.OwnerId = u.Id;
        
        cpm__Payment_Profile__c p3 = new cpm__Payment_Profile__c();
        p3.cpm__IBAN__c ='ES5630087251839239584129';
        p3.msf_HolderFirstName__c = 'ff';
        p3.msf_HolderLastName1__c = 'aa';
        p3.msf_HolderLastName2__c = '';
        p3.msf_NIF__c = '28008400N';
        p3.cpm__Holder_Name__c = 'ff aa';
        p3.cpm__Active__c = true;
        p3.OwnerId = u.Id;
        
        for (Integer x=0;x<2;x++){
            Opportunity o = new Opportunity (
                name = 'DonacionPuntual',
                type = 'Solidarity Wedding',
                StageName = 'Propuesta',
                CloseDate = date.newInstance(2019, 10, 15)
            );
            listOpportunityTest1.add(o);
        }
        
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        npe03__Recurring_Donation__c r = new npe03__Recurring_Donation__c (
            Name='RDContact',
            npe03__Amount__c=15,
            npe03__Open_Ended_Status__c ='Open',
            npe03__Date_Established__c =date.today(),
            npe03__Installment_Period__c = (pickListValues[0]).getLabel(),
            npe03__Installments__c = 0,
            OwnerId = u.Id,
            npsp4hub__Payment_Method__c = 'Direct Debit',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
        );
        listRecurringTest1.add(r);
        
        //****************************************************************
        
        test.startTest();
        MSF_FormF2F_CTRL.setContact(c2, u, null, listOpportunityTest1[0], p1, null, false,false, 25, 'Name1', lc); //existent lead,c2 without insert, is not a member. covers 50%
        MSF_FormF2F_CTRL.setContact(c3, u, null, listOpportunityTest1[1], p2, null, true, false, 30, 'Name2', null);//c3 without insert, with merge, unique operation, is a member. Increases code coverage at 68%
        MSF_FormF2F_CTRL.setContact(c3, u, null, listOpportunityTest1[1], p2, c2, true, false, 30, 'Name2', null);
        MSF_FormF2F_CTRL.setContact(c4, u, listRecurringTest1[0], null, p3, new Contact(LastName='DummyContactFORMF2F'), false, true, 35, 'Name3', null); 
        
        //asserts
        List<Contact> assCont = new List<Contact>();
        List<String> nifs = new List<String>();
        nifs.add(c2.msf_NIF__c);
        nifs.add(c3.msf_NIF__c);
        nifs.add(c4.msf_NIF__c);
        assCont = [SELECT id FROM Contact WHERE msf_NIF__c IN:nifs];
        system.assertEquals(3, assCont.size(),'No insertó contacto');
        test.stopTest();
    }
    
    @isTest()
    static void myTestpart2(){
        Contact c0 = [SELECT Id,FirstName, LastName, npe01__HomeEmail__c, msf_NIF__c, msf_PrimaryContact__c, msf_MainEmail__c,
                      MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingCountry, HomePhone,msf_LanguagePreferer__c
                      FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        User u = [SELECT Id, msf_Campaign__c, msf_City__c, Email, Username, LastName, Alias, CommunityNickname,
                  TimeZoneSidKey, LocaleSidKey, EmailEncodingKey,ProfileId,LanguageLocaleKey
                  FROM User WHERE UserName = 'user@ab.testcom' LIMIT 1];
        
        Lead lc = [SELECT Id, FirstName, LastName, msf_NIF__c, msf_esOrganizacion__c, Company, Description, msf_FirmaDonante__c FROM Lead WHERE msf_NIF__c = '74035964E' LIMIT 1];
        ContentVersion content = [SELECT Id, Title, VersionData, origin FROM ContentVersion Where Title = 'Header_Picture1' LIMIT 1];
        ContentDocumentLink contentlink= [SELECT Id, ContentDocumentId, ShareType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :lc.id];
        
        //********************* Objects whitout Insert *************************
        List<Opportunity> listOpportunityTest1 = new List<Opportunity>(); 
        List<npe03__Recurring_Donation__c> listRecurringTest1 = new List<npe03__Recurring_Donation__c>(); 
        Contact c2 = new Contact();
        c2.FirstName='patricia';
        c2.LastName= 'pereira';
        c2.msf_NIF__c='74035964E';
        c2.Gender__c = 'M';
        
        //con pp. p2
        Contact c3 = new Contact();
        c3.FirstName='Manuel';
        c3.LastName= 'Medina';
        c3.Suffix='dd';
        c3.msf_MainEmail__c = 'example@dddd.com';
        c3.msf_NIF__c='18956402D';
        c3.Birthdate =date.newInstance(2002, 10, 15);
        c3.MailingCity= 'bcn';
        c3.MailingCountry= 'españa';
        c3.MailingPostalCode='12345';
        c3.MailingState ='bcn';
        c3.MailingStreet='valencia';
        c3.HomePhone='956123123';
        c3.MobilePhone='654654654';
        c3.msf_LanguagePreferer__c='CAT';
        c3.Gender__c='H';
        c3.msf_FiscalFirstName__c='xx';
        c3.msf_FiscalLastName1__c='xx';
        c3.msf_FiscalLastName2__c='xx';
        c3.msf_fiscalNif__c ='78019601J';
        
        Contact c4 = new Contact();
        c4.FirstName='jose';
        c4.LastName= 'gonzales';
        c4.msf_NIF__c='32871203V'; 
        c4.Title='DAH';
        
        cpm__Payment_Profile__c p1 = new cpm__Payment_Profile__c();
        p1.cpm__IBAN__c ='ES5600578616567582427325';
        p1.msf_HolderFirstName__c = 'jose';
        p1.msf_HolderLastName1__c = 'lopez';
        p1.msf_HolderLastName2__c = '';
        p1.msf_NIF__c = '15426414S';
        p1.cpm__Holder_Name__c = 'jose lopez';
        p1.cpm__Active__c = true;
        p1.OwnerId = u.Id;
        
        cpm__Payment_Profile__c p2 = new cpm__Payment_Profile__c();
        p2.cpm__IBAN__c ='ES2201043116021519780525';
        p2.msf_HolderFirstName__c = 'ff';
        p2.msf_HolderLastName1__c = 'aa';
        p2.msf_HolderLastName2__c = '';
        p2.msf_NIF__c = c4.msf_NIF__c;
        p2.cpm__Holder_Name__c = 'jose lopez';
        p2.cpm__Active__c = true;
        p2.OwnerId = u.Id;
        
        cpm__Payment_Profile__c p3 = new cpm__Payment_Profile__c();
        p3.cpm__IBAN__c ='ES5630087251839239584129';
        p3.msf_HolderFirstName__c = 'ff';
        p3.msf_HolderLastName1__c = 'aa';
        p3.msf_HolderLastName2__c = '';
        p3.msf_NIF__c = '28008400N';
        p3.cpm__Holder_Name__c = 'ff aa';
        p3.cpm__Active__c = true;
        p3.OwnerId = u.Id;
        
        for (Integer x=0;x<2;x++){
            Opportunity o = new Opportunity (
                name = 'Donacion puntual',
                type = 'Solidarity Wedding',
                StageName = 'Propuesta',
                CloseDate = date.newInstance(2019, 10, 15)
            );
            listOpportunityTest1.add(o);
        }
        
        npe03__Recurring_Donation__c recDonation = new npe03__Recurring_Donation__c(Name='npe03Recurring_DonationcTEST2Name1');
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        recDonation.npe03__Installment_Period__c = (pickListValues[0]).getLabel();
        recDonation.npsp4hub__Payment_Method__c = 'Direct Debit';
		recDonation.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
		recDonation.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        
        //****************************************************************  
        test.startTest();
            MSF_FormF2F_CTRL.setContact(c3, u, recDonation, null, p2, null,  true, true, 40,'Name1', null);//c3 without insert, with merge, unique operation, is a member.
            MSF_FormF2F_CTRL.setContact(c0, u, recDonation, null, p2, null,  true, true, 45,'Name2', null);//c0 without insert, with merge, unique operation, is a member. 
            
            //asserts
            List<Contact> assCont = new List<Contact>();
            List<String> nifs = new List<String>();
            nifs.add(c2.msf_NIF__c);
            nifs.add(c3.msf_NIF__c);
            nifs.add(c4.msf_NIF__c);
            assCont = [SELECT id FROM Contact WHERE msf_NIF__c IN:nifs];
            system.assertEquals(1, assCont.size(),'No insertó contacto');
        test.stopTest();
    }
    
    @isTest static void testGetPeriods(){
        MSF_FormF2F_CTRL.getDate();
        MSF_FormF2F_CTRL.getLanguage(); 
        MSF_FormF2F_CTRL.getGender();
        
        List<String> options = new List<String>();
        options.add(System.Label.MSF_FORM_F2F_UNIQUE_DONATION);
        System.assertEquals(options, MSF_FormF2F_CTRL.getPeriod(false, true));
        
        MSF_FormF2F_CTRL.getPeriod(true, false);
    }
    
    @isTest static void testGetCanvasser(){
        User userCan = [SELECT Id, name, msf_Place__c, msf_Campaign__c, msf_City__c FROM User WHERE id =: UserInfo.getUserId() LIMIT 1];
        System.assertEquals(userCan,(User)MSF_FormF2F_CTRL.getCanvasser());
    }
    
    @isTest static void testGetSocio(){
        Contact c1 = [SELECT Id,FirstName, LastName, npe01__HomeEmail__c, msf_NIF__c FROM Contact WHERE npe01__HomeEmail__c = 'm@m.com' LIMIT 1];
        Map<String, Object> mapData = (Map<String, Object>) MSF_FormF2F_CTRL.getSocio(c1.msf_NIF__c, false);
        System.assertNotEquals(null,mapData.get('socio'));
    }
    
    @isTest static void testGetEmptySocio(){
        Map<String, Object> mapData = (Map<String, Object>) MSF_FormF2F_CTRL.getSocio('123456789Z', false);
        System.assertEquals(null,mapData);
    }
    
    @isTest static void testGetMemberInfoHasMember(){
        Contact c0 = [SELECT Id,FirstName FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        Map<String, Object> mapData = (Map<String, Object>) MSF_FormF2F_CTRL.getMemberInfo(c0.Id);
        System.assertNotEquals(null, mapData.get('member'));
    }
    
    @isTest static void testGetMemberInfoHasQuota(){
        Contact c0 = [SELECT Id,FirstName FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        Map<String, Object> mapData = (Map<String, Object>) MSF_FormF2F_CTRL.getMemberInfo(c0.Id);
        System.assertNotEquals(null, mapData.get('quota'));
    }
    
    @isTest static void testGetMemberInfoHasLabelPeriod(){
        Contact c0 = [SELECT Id,FirstName FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        Map<String, Object> mapData = (Map<String, Object>) MSF_FormF2F_CTRL.getMemberInfo(c0.Id);
        System.assertNotEquals(null, mapData.get('member'));
    }
    
    @isTest static void testGeneratePDF(){
        Contact c0 = [SELECT Id,FirstName FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        Boolean b = MSF_FormF2F_CTRL.GeneratePDF(c0.Id,true);
        System.assertEquals(b, true);
    }
    
    //**************** Test methods-Organization ****************
    @isTest ()
    static void myTest2(){
        
        List<npe03__Recurring_Donation__c> listRecurringTest2 = new List<npe03__Recurring_Donation__c>(); 
        List<Opportunity> listOpportunityTest2 = new List<Opportunity>(); 
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Canvasser'];
        RecordType rtOrg = [SELECT id FROM RecordType Where developername= 'Organization' AND SobjectType = 'Contact' LIMIT 1];
        RecordType rtContact = [SELECT id FROM RecordType Where developername= 'Individual_Contact' AND SobjectType = 'Contact' LIMIT 1];
        
        User u = [SELECT Id, msf_Campaign__c, msf_City__c, Email, Username, LastName, Alias, CommunityNickname,
                  TimeZoneSidKey, LocaleSidKey, EmailEncodingKey,ProfileId,LanguageLocaleKey
                  FROM User WHERE UserName = 'user@ab.testcom' LIMIT 1];
        
        Contact cOrg = [SELECT Id, FirstName, LastName, msf_NIF__c, msf_MainEmail__c, Title, Suffix,
                        Birthdate, MailingStreet, MailingPostalCode, MailingCity,
                        MailingState, MailingCountry, HomePhone, MobilePhone, msf_LanguagePreferer__c, Gender__c,
                        msf_FiscalFirstName__c, msf_FiscalLastName1__c, msf_FiscalLastName2__c, msf_fiscalNif__c
                        FROM Contact WHERE msf_NIF__c='A89359160' LIMIT 1];                 
        
        //********************* Objects whitout Insert *************************
        Account a = new Account();
        a.name='Silver&Gold';
        
        Account a2 = new Account();
        a2.name='Silver&cc';
        
        Contact cOrg2 = new Contact();
        cOrg2.LastName= 'Silver&Black';
        cOrg2.msf_NIF__c ='G06921167';
        cOrg2.RecordTypeId = [SELECT id FROM RecordType Where developername= 'Organization' AND SobjectType = 'Contact' LIMIT 1].Id;
        
        Contact cr1 = new Contact();
        cr1.FirstName='jose';
        cr1.LastName= 'gonzales';
        cr1.msf_BeginDateMSF__c=date.today();
        
        Contact cr2 = new Contact();
        cr2.FirstName='jose';
        cr2.LastName= 'gonzales';
        cr2.title='vendedor'; 
        cr2.msf_BeginDateMSF__c=date.today();
        
        for (Integer x=0;x<3;x++){
            npe03__Recurring_Donation__c r = new npe03__Recurring_Donation__c (
                Name='RDContactt'+x,
                npe03__Amount__c=15,
                npe03__Open_Ended_Status__c ='Open',
                npe03__Date_Established__c =date.today(),
                npe03__Installment_Period__c = 'Monthly',
                npe03__Installments__c = 0,
                OwnerId = u.Id,
                npsp4hub__Payment_Method__c = 'Direct Debit',
                npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
            );
            listRecurringTest2.add(r);
        }
        
        for (Integer x=0;x<=3;x++){
            Opportunity o = new Opportunity (
                name = 'Donacion puntual',
                type = 'Solidarity Wedding',
                StageName = 'Propuesta',
                CloseDate = date.newInstance(2019, 10, 15)
            );
            listOpportunityTest2.add(o);
        }
        
        cpm__Payment_Profile__c p1 = new cpm__Payment_Profile__c();
        p1.cpm__IBAN__c ='ES0502206574586451211273';
        p1.msf_HolderFirstName__c = 'jose';
        p1.msf_HolderLastName1__c = 'lopez';
        p1.msf_HolderLastName2__c = '';
        p1.msf_NIF__c = '28629660L';
        p1.cpm__Holder_Name__c = 'jose lopez';
        p1.cpm__Active__c = true;
        
        Lead l1 = new Lead();
        l1.FirstName ='N/A';
        l1.LastName='N/A';
        l1.msf_NIF__c='D11255403';
        l1.msf_esOrganizacion__c =true;
        l1.Company='xx';
        l1.Description='vv';
        l1.msf_FirmaDonante__c=true;
        
        Lead l2 = new Lead();
        l2.FirstName ='N/A';
        l2.LastName='N/A';
        l2.msf_NIF__c='D11255403';
        l2.Title='AAAAG';
        l2.msf_esOrganizacion__c =true;
        l2.Company='xx';
        
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        
        l2.msf_RecDon_npe03_Installment_Period__c = 'Monthly';
        l2.Description='vvrrrrr';
        l2.msf_FirmaDonante__c=true;
        
        Task t1 = new Task(
            ActivityDate = date.today(),
            Subject = 'Call',
            Type = 'Call',
            Priority = 'High',
            Status = 'Not Started'  
        ); 
        //*************************************************************
        
        test.startTest();
        MSF_FormF2F_CTRL.getSocio(cOrg.msf_NIF__c, true);
        
        MSF_FormF2F_CTRL.setContact(cOrg, u, null, listOpportunityTest2[0], p1, cr1, true, true,5, 'Name', null); //Organization member and old 'crep' 
        MSF_FormF2F_CTRL.setContact(cOrg, u, null, listOpportunityTest2[1], p1, cr2, true, true,10, 'Name', null); //Organization member and old 'crep' changing title.
        MSF_FormF2F_CTRL.setContact(cOrg2, u, null, listOpportunityTest2[2], p1, cr2, false, true,15, 'Name', null); //Organization member and old 'crep' but new for this org.
        
        //asserts
        List<Contact> assCont = [SELECT id, title FROM Contact WHERE RecordType.DeveloperName = 'Organization_Contact' AND Name =: cr2.FirstName+' '+cr2.LastName];
        system.assertEquals('vendedor', assCont[0].title,'No insertó organización');
        test.stopTest();
    }
    
    @isTest static void testSetLead(){
        Lead l = new Lead();
        l.FirstName ='N/A';
        l.LastName='N/A';
        l.msf_NIF__c='D11255403';
        l.msf_esOrganizacion__c =true;
        l.Company='xx';
        l.Description='vv';
        l.msf_FirmaDonante__c=true;
        Task t = new Task(
            ActivityDate = date.today(),
            Subject = 'Call',
            Type = 'Call',
            Priority = 'High',
            Status = 'Not Started'  
        );    
        Map<String, Object> data = (Map<String, Object>)MSF_FormF2F_CTRL.setLead(l,t,l.msf_Opp_npe03_Amount__c,null );        
        String returnType = (String)data.get('type');
        System.assertEquals('success', returnType);
    }
    
    @isTest static void testSetLeadWithIncompleteLead(){
        Lead l1 = new Lead();
        l1.FirstName ='N/A';
        l1.LastName='N/A';
        l1.msf_NIF__c='D11255403';
        l1.msf_esOrganizacion__c =true;
        l1.Company='xx';
        l1.Description='vv';
        l1.msf_FirmaDonante__c=true;
        Task t = new Task(
            ActivityDate = date.today(),
            Subject = 'Call',
            Type = 'Call',
            Priority = 'High',
            Status = 'Not Started'  
        );    
        MSF_FormF2F_CTRL.setLead(l1,t,l1.msf_Opp_npe03_Amount__c,null);  
        Lead l2 = new Lead();
        l2.FirstName ='N/A';
        l2.LastName='N/A';
        l2.msf_NIF__c='D11255403';
        l2.Title='AAAAG';
        l2.msf_esOrganizacion__c =true;
        l2.Company='xx';
        l2.msf_RecDon_npe03_Installment_Period__c = 'Monthly';
        l2.Description='vvrrrrr';
        l2.msf_FirmaDonante__c=true;
        Map<String, Object> data = (Map<String, Object>)MSF_FormF2F_CTRL.setLead(l2,t,l2.msf_Opp_npe03_Amount__c,l1);        
        Id returnId = (Id)data.get('idLead');
        System.assertNotEquals(null, returnId);
    }
    
    @isTest static void testSetLeadError(){
        Lead l = new Lead(Id = (Id)getFakeId(Lead.SObjectType));
        Task t = new Task(
            ActivityDate = date.today(),
            Subject = 'Call',
            Type = 'Call',
            Priority = 'High',
            Status = 'Not Started'  
        );    
        Map<String, Object> data = (Map<String, Object>)MSF_FormF2F_CTRL.setLead(l,t,0.1,null);        
        String returnType = (String)data.get('type');
        System.assertEquals('error', returnType);
    }
    
    //**************** Test Methods-NewQuota ****************
    @isTest static void myTest3(){
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Canvasser'];
        
        User u = [SELECT Id, msf_Campaign__c, msf_City__c, Email, Username, LastName, Alias, CommunityNickname,
                  TimeZoneSidKey, LocaleSidKey, EmailEncodingKey,ProfileId,LanguageLocaleKey
                  FROM User WHERE UserName = 'user@ab.testcom' LIMIT 1];
        
        Contact c0 = [SELECT Id,FirstName, LastName, npe01__HomeEmail__c, msf_NIF__c, msf_PrimaryContact__c, msf_MainEmail__c,
                      MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingCountry, HomePhone,msf_LanguagePreferer__c
                      FROM Contact WHERE msf_NIF__c = '22723449R' LIMIT 1];
        Contact c1 = [SELECT Id,FirstName, LastName, npe01__HomeEmail__c, msf_NIF__c FROM Contact WHERE npe01__HomeEmail__c = 'm@m.com' LIMIT 1];
        
        npe03__Recurring_Donation__c recDonation = new npe03__Recurring_Donation__c(Name='RDTest');
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        recDonation.npe03__Installment_Period__c = (pickListValues[0]).getLabel();
        recDonation.npsp4hub__Payment_Method__c = 'Direct Debit';
		recDonation.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        recDonation.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        //********************* Objects whitout Insert *************************
        cpm__Payment_Profile__c p3 = new cpm__Payment_Profile__c();
        p3.cpm__IBAN__c ='ES0502206574586451211273';
        p3.msf_HolderFirstName__c = 'ff';
        p3.msf_HolderLastName1__c = 'aa';
        p3.msf_HolderLastName2__c = '';
        p3.msf_NIF__c = c1.msf_NIF__c;
        p3.cpm__Holder_Name__c = 'jose lopez';
        p3.cpm__Active__c = true; 
        
        npe03__Recurring_Donation__c r = new npe03__Recurring_Donation__c (
            Name='RD-Contactt',
            npe03__Amount__c=15,
            npe03__Open_Ended_Status__c ='Open',
            npe03__Date_Established__c =date.newInstance(2019, 10, 15),
            npe03__Installment_Period__c = 'Monthly',
            npe03__Installments__c = 0,
            npsp4hub__Payment_Method__c = 'Direct Debit',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA',
            OwnerId = u.Id
        );
        //**********************************************************************
        
        test.startTest();
        MSF_FormF2F_CTRL.setContact(c1, u, r, null, p3, null, false, false,410,'Name', null); 
        test.stopTest();        
    }
    
    @isTest static void testCreateNewQuota(){
        User u = [SELECT Id, msf_Campaign__c, msf_City__c, Email, Username, LastName, Alias, CommunityNickname,
                  TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey, Name, msf_Place__c
                  FROM User WHERE UserName = 'user@ab.testcom' LIMIT 1];
        
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='18956402D' LIMIT 1];
        
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe() ;
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        pickListValues[0].getLabel();
        
        npe03__Recurring_Donation__c r = [SELECT Id, npe03__Date_Established__c, npe03__Installment_Period__c, npe03__Amount__c
                                          FROM npe03__Recurring_Donation__c LIMIT 1];
        
        Map<String, Object> data = (Map<String, Object>)MSF_FormF2F_CTRL.createNewQuota('MSF_FormF2F_TEST_Name1', r, r.npe03__Date_Established__c, r.npe03__Installment_Period__c, r.npe03__Amount__c, u, c.Id);        
        String returnType = (String)data.get('type');
        System.assertEquals('success', returnType);        
    }
    
    @isTest static void testCreateNewQuotaError(){
        User u = [SELECT Id, msf_Campaign__c, msf_City__c, Email, Username, LastName, Alias, CommunityNickname,
                  TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey, Name, msf_Place__c
                  FROM User WHERE UserName = 'user@ab.testcom' LIMIT 1];
        
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='18956402D' LIMIT 1];
        
        npe03__Recurring_Donation__c r = new npe03__Recurring_Donation__c (
            Name='RD-Contactt',
            npe03__Amount__c=15,
            npe03__Open_Ended_Status__c ='Open',
            npe03__Date_Established__c =date.today(),
            npe03__Installment_Period__c = 'Monthly',
            npe03__Installments__c = 0,
            OwnerId = u.Id,
            npsp4hub__Payment_Method__c = 'Direct Debit',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
        );
                																
        Map<String, Object> data = (Map<String, Object>)MSF_FormF2F_CTRL.createNewQuota('NO EXIST CAMPAIGN', r, r.npe03__Date_Established__c, r.npe03__Installment_Period__c, r.npe03__Amount__c, u, c.Id);        
        String returnType = (String)data.get('type');
        System.assertEquals('error', returnType);        
    }
    
    @isTest static void testGetNumConvertation_Insert(){
        Integer numConv = MSF_FormF2F_CTRL.getNumConvertation(null,true);   
        Decimal numQuery = [SELECT msf_NumConversation__c FROM msf_Conversation__c WHERE msf_IdCanvasser__c =: UserInfo.getUserId() AND msf_DayWorked__c = TODAY LIMIT 1].msf_NumConversation__c;
        System.assertEquals(numConv,numQuery);
    }
    
    @isTest static void testGetNumConvertation_Update(){
        msf_Conversation__c nwInfoCanvasser = new msf_Conversation__c();
        nwInfoCanvasser.msf_IdCanvasser__c = UserInfo.getUserId();
        nwInfoCanvasser.msf_NumConversation__c = 10; 
        nwInfoCanvasser.msf_DayWorked__c = Date.today();
        Insert nwInfoCanvasser;
        
        Integer numConv = MSF_FormF2F_CTRL.getNumConvertation(-1,true);   
        Decimal numQuery = [SELECT msf_NumConversation__c FROM msf_Conversation__c WHERE 	msf_IdCanvasser__c =: UserInfo.getUserId() AND msf_DayWorked__c = TODAY LIMIT 1].msf_NumConversation__c;
        System.assertEquals(11,numQuery);
    }
    
    @isTest static void testGetExistingCampaingId(){
        Campaign camp = [SELECT Id, Name FROM Campaign Where Name='MSFFormF2FTESTtestGetExistingCampaingId' LIMIT 1];
        
        Contact c2 = new Contact();
        c2.FirstName='patricia';
        c2.LastName= 'pereira';
        c2.msf_NIF__c='74035964E';
        
        User u = [SELECT Id, msf_Campaign__c FROM User WHERE Id =: UserInfo.getUserId()];
        u.msf_Campaign__c = camp.Name;
        update u;
        Lead lc = [SELECT Id, FirstName,createdDate, LastName, msf_NIF__c, msf_esOrganizacion__c, Company, Description, msf_FirmaDonante__c FROM Lead WHERE msf_NIF__c = '74035964E' LIMIT 1];
        Opportunity o = new Opportunity (
            name = 'Donacion puntual',
            type = 'Solidarity Wedding',
            StageName = 'Propuesta',
            CloseDate = date.newInstance(2019, 10, 15)
        );
        
        cpm__Payment_Profile__c p1 = new cpm__Payment_Profile__c();
        p1.cpm__IBAN__c ='ES5600578616567582427325';
        p1.msf_HolderFirstName__c = 'jose';
        p1.msf_HolderLastName1__c = 'lopez';
        p1.msf_HolderLastName2__c = '';
        p1.msf_NIF__c = '15426414S';
        p1.cpm__Holder_Name__c = 'jose lopez';
        p1.cpm__Active__c = true;
        p1.OwnerId = u.Id;
        
        Map<String, Object> data = (Map<String, Object>)MSF_FormF2F_CTRL.setContact(c2, u, null, o, p1, null, false,false, 40, camp.Name, lc); //lead existente,c2 sin insert,no es socio. solo cubre 50%
        
        System.assertEquals('success', (String)data.get('type'), 'Error:'+(String)data.get('msg'));
    }

    static Integer s_num = 1;
    
    private static String getFakeId(Schema.SObjectType sot){
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + 
            '0'.repeat(12-result.length()) + result;
    }
}