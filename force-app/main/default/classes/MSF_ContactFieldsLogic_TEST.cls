/**
* @author 		Deloitte
* @date 		10-2018
* @group 		Contact
* @description	test class for the MSF_ContactFieldsLogic clases.
*/
@isTest
private class MSF_ContactFieldsLogic_TEST {
    @testSetup static void setup(){
        List<Contact> listContactTest1 = new List<Contact>();
        
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
        
        //create contacts
        Contact c = new Contact();
        c.FirstName='Manuel';
        c.LastName= 'Medina';
        c.msf_MainEmail__c = 'm@m.com';
        c.msf_NIF__c='43578879C';
        c.msf_NoRevistaCP__c = true;
        c.msf_NoMemoriaCP__c = true;
        c.msf_NoCaptacionFondosCP__c = true;
        c.msf_NoCertificadoFiscalCP__c = true;
        c.msf_NoAgradecimientosCP__c = true;
        c.msf_NoLlamadasBienvenidasEncuestasOtras__c = true;
        c.msf_NoMailingsTematicosCP__c = true;
        c.msf_NoCartasPlanRelacionCP__c = true;
        c.msf_NoInvitacionesEventosCP__c = true;
        c.msf_NoComunicacionesOnetoOneCP__c= true;
        c.msf_NoRevistaSms__c = true;
        c.msf_NoMensajesTematicosSms__c = true;
        c.msf_NoMensajesPlanRelacionSms__c = true;
        c.msf_NoMemoriaSms__c = true;
        c.msf_NoInvitacionesEventosSms__c = true;
        c.msf_NoEncuestaEstudioConcursoSms__c = true;
        c.msf_NoComunicaconesOnetoOneSms__c = true;
        c.msf_NoCertificadoFiscalSms__c = true;
        c.msf_NoCaptacionFondosSms__c = true;
        c.msf_NoAgradecimientosSms__c = true; 
        listContactTest1.add(c);
        
        Contact c1 = new Contact();
        c1.FirstName='Manuel';
        c1.LastName= 'Medina';
        c1.Suffix = 'Herrera';
        c1.msf_NIF__c='15573648A';
        c1.MobilePhone='665310426';
        c1.msf_NoEmail__c=false;
        listContactTest1.add(c1);
        
        Contact c2 = new Contact();
        c2.FirstName='Manuel';
        c2.LastName= 'Medina';
        c2.msf_NIF__c='18931233W';
        c2.MailingStreet ='girona';
        c2.MailingCity ='barcelona';
        c2.MailingState ='barcelona';
        c2.MailingPostalCode ='08018';
        c2.MailingCountry ='españa';
        
        c2.msf_SoloCertificadoFiscal__c = true;
        listContactTest1.add(c2);
        
        Contact c3 = new Contact();
        c3.FirstName='Manuela';
        c3.LastName= 'Medino';
        c3.msf_NIF__c='89670090J';
        c3.MailingStreet ='girona';
        c3.MailingCity ='barcelona';
        c3.MailingState ='barcelona';
        c3.MailingPostalCode ='08018';
        c3.MailingCountry ='españa';
        c3.msf_NoInformacionTestamentaria__c = c3.msf_NoCesionImagenPromocion__c = c3.msf_NoCaptacionFondos__c = c3.msf_NoTelefono__c = true;
        c3.msf_NoRevistaCP__c = c3.msf_NoMemoriaCP__c = c3.msf_NoCaptacionFondosCP__c = c3.msf_NoAgradecimientosCP__c = true;
        c3.msf_NoLlamadasBienvenidasEncuestasOtras__c = c3.msf_NoMailingsTematicosCP__c = c3.msf_NoCartasPlanRelacionCP__c = true;
        c3.msf_NoInvitacionesEventosCP__c = c3.msf_NoComunicacionesOnetoOneCP__c = c3.msf_NoRevistaSms__c = true;
        c3.msf_NoMensajesTematicosSms__c = c3.msf_NoMensajesPlanRelacionSms__c = c3.msf_NoMemoriaSms__c = c3.msf_NoInvitacionesEventosSms__c = true;
        c3.msf_NoEncuestaEstudioConcursoSms__c = c3.msf_NoComunicaconesOnetoOneSms__c = c3.msf_NoCaptacionFondosSms__c = true;
        c3.msf_NoAgradecimientosSms__c = c3.msf_NoRevistaEmail__c = c3.msf_NoMemoriaEmail__c = c3.msf_NoCaptacionFondosEmail__c = true;
        c3.msf_NoAgradecimientosEmail__c = c3.msf_NoEncuestaEstudioConcursoEmail__c = c3.msf_NoEmailingsTematicosEmail__c = c3.msf_NoPlanRelacionEmail__c = true;
        c3.msf_NoInvitacionesEventosEmail__c = c3.msf_NoNewsletterEmail__c = c3.msf_NoComunicacionesOnetoOneEmail__c = c3.msf_NoRevistaMi__c = true;
        c3.msf_NoMensajesTematicosMi__c = c3.msf_NoMensajesPlanRelacionMi__c = c3.msf_NoMemoriaMi__c = c3.msf_NoInvitacionesEventosMi__c = true;
        c3.msf_NoEncuestaEstudioConcursoMi__c = c3.msf_NoComunicaconesOnetoOneMi__c = c3.msf_NoCaptacionFondosMi__c = c3.msf_NoAgradecimientosMi__c = true;
        c3.msf_NoCorreoPostal__c = c3.msf_NoSMS__c = c3.msf_NoEmail__c = c3.msf_NoMi__c = true;
		c3.msf_NoCertificadoFiscalCP__c = c3.msf_NoCertificadoFiscalSms__c = c3.msf_NoCertificadoFiscalEmail__c = c3.msf_NoCertificadoFiscalMi__c = false;
        
        listContactTest1.add(c3);
        
        Contact cOrg = new Contact();
        cOrg.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        cOrg.msf_NIF__c = 'B52006749';
        cOrg.LastName= 'MSF_ContactFieldsLogic_DeveloperName1';
        cOrg.MailingStreet ='girona';
        cOrg.MailingCity ='barcelona';
        cOrg.MailingState ='barcelona';
        cOrg.MailingPostalCode ='08018';
        cOrg.MailingCountry ='españa';
        
        
        listContactTest1.add(cOrg);
        
        insert listContactTest1;
        npsp__Level__c l = new npsp__Level__c(Name='dummy level');
        l.npsp__Target__c = 'Contact';
        l.npsp__Level_Field__c = 'dummy';
        l.npsp__Source_Field__c = 'dummy';
        insert l;
        
        List<msf_LeadSourceMasterData__c> lLeadSourceMD = new List<msf_LeadSourceMasterData__c>();
        List<String> leadSource = leadSource1Desc();
        List<String> leadSource2 = leadSource2Desc();
        List<String> leadSource3 = leadSource3Desc();
        for(Integer x = 0; x < leadSource.size(); x ++){
            msf_LeadSourceMasterData__c data = new msf_LeadSourceMasterData__c(msf_LeadSource1__c = leadSource[x], 
                                                                               msf_LeadSource2__c = LeadSource2[math.mod(x, leadSource2.size())], 
                                                                               msf_LeadSource3__c = LeadSource3[math.mod(x, leadSource3.size())]);
            lLeadSourceMD.add(data);
        }
        insert lLeadSourceMD;
        
        //Recurring Donations; 
        npe03__Recurring_Donation__c nR = new npe03__Recurring_Donation__c();
        nR.npe03__Contact__c = listContactTest1.get(0).Id;
        nR.npe03__Amount__c = 1200; 
        nR.npsp4hub__Payment_Method__c = 'Direct Debit';
        nR.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        nR.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        insert nR;
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'TESTOPP';
        opp.npe03__Recurring_Donation__c = null;
        opp.npsp__Primary_Contact__c = listContactTest1.get(0).Id;
        opp.StageName = 'Propuesta';
        opp.CloseDate = Date.today();
        insert opp;
        
        //msf_Associative__c
        msf_Associative__c mA = new msf_Associative__c();
        mA.msf_ContactId__c = listContactTest1.get(0).Id;
        insert mA;
		
    }
    
    @isTest static void updateContactDeceased() {
        Contact c = [SELECT id, npsp__Deceased__c, msf_ContactDeleteReason__c FROM Contact WHERE msf_NIF__c = '43578879C'];
        c.msf_ContactDeleteReason__c = 'Deceased'; 
        c.npsp__Deceased__c = true; 
        update c; 
    }
    
    @isTest static void insertLeadSourceDependencies(){
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertPostalCodeCat_LastName1');
        c.LeadSource = values[0].msf_LeadSource1__c;
        insert c;
        c = [SELECT Id, msf_LeadSource2Level__c	, msf_LeadSource3Level__c 
             FROM Contact 
             WHERE Id =: c.Id LIMIT 1 ];
        System.assertNotEquals(null, c.msf_LeadSource2Level__c, 'Result is not null for msf_LeadSource2Level__c '+c);
        System.assertNotEquals(null, c.msf_LeadSource3Level__c, 'Result is not null for msf_LeadSource3Level__c'+c);
    }
    @isTest static void insertCheckPostalCodeCat(){
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertPostalCodeCat_LastName1');
        c.MailingPostalCode = '43000';
        insert c;
        c = [SELECT Id,msf_LanguagePreferer__c FROM Contact WHERE LastName='MSF_ContactFieldsLogic_TEST_insertPostalCodeCat_LastName1' LIMIT 1];
        System.assertEquals('CAT',c.msf_LanguagePreferer__c);
        
    }
    @isTest static void insertCheckPostalCodeESP(){
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertPostalCodeEsp_LastName1');
        c.MailingPostalCode = '09000';
        insert c;
        c = [SELECT Id,msf_LanguagePreferer__c FROM Contact WHERE LastName='MSF_ContactFieldsLogic_TEST_insertPostalCodeEsp_LastName1' LIMIT 1];
        System.assertEquals('ESP',c.msf_LanguagePreferer__c);
        
    }
    @isTest static void insertTypeOrgCont(){
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertTypeOrgCont_LastName1');
        c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        insert c;
        c = [SELECT Id,RecordTypeId FROM Contact WHERE LastName='MSF_ContactFieldsLogic_TEST_insertTypeOrgCont_LastName1' LIMIT 1];
        System.assertEquals(Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId(), c.RecordTypeId);
    }
    @isTest static void insertTypeNull(){
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertTypeNull_LastName1');
        c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Anonymous').getRecordTypeId();
        insert c;
        c = [SELECT Id,RecordTypeId FROM Contact WHERE LastName='MSF_ContactFieldsLogic_TEST_insertTypeNull_LastName1' LIMIT 1];
        System.assertEquals(Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Anonymous').getRecordTypeId(), c.RecordTypeId);
    }
    @isTest static void insertCheckNifNull(){
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertTypeOrgCont_LastName1');
        try{
            c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
            c.msf_NIF__c = 'hasta la vista baby';
            insert c;
            System.assert(false);
        }catch(DmlException e){
            System.assert(true);
        }
    }
    @isTest static void insertCheckFiscalNifNull(){
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertTypeOrgCont_LastName1');
        try{
            c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
            c.msf_fiscalNif__c = 'hasta la vista baby';
            c.msf_CopyTaxData__c = false;
            insert c;
            System.assert(false);
        }catch(DmlException e){
            System.assert(true);
        }
    }
    @isTest static void insertWithAutomaticBirtYear(){
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertAutomaticBirthYear_LastName1');
        c.Birthdate = Date.today();
        insert c;
        c = [SELECT Id,msf_birthyear__c FROM Contact WHERE LastName='MSF_ContactFieldsLogic_TEST_insertAutomaticBirthYear_LastName1' LIMIT 1];
        System.assertEquals(String.valueOf(Date.today().year()), c.msf_birthyear__c);
    }    
    @isTest static void insertWithNoMail(){
        Contact c = new Contact(LastName='MSF_ContactFieldsLogic_TEST_insertWithNoMail_LastName1');
        c.Birthdate = Date.today();
        c.msf_NoRevistaEmail__c = c.msf_NoMemoriaEmail__c = c.msf_NoCaptacionFondosEmail__c = c.msf_NoCertificadoFiscalEmail__c = true;
        c.msf_NoAgradecimientosEmail__c = c.msf_NoEncuestaEstudioConcursoEmail__c = c.msf_NoEmailingsTematicosEmail__c = true;
        c.msf_NoPlanRelacionEmail__c = c.msf_NoInvitacionesEventosEmail__c = c.msf_NoNewsletterEmail__c = c.msf_NoComunicacionesOnetoOneEmail__c = true;
        
        //Trigger must change this value to true
        c.msf_NoEmail__c = false;
        insert c;
        c = [SELECT Id,msf_NoEmail__c FROM Contact WHERE LastName='MSF_ContactFieldsLogic_TEST_insertWithNoMail_LastName1' LIMIT 1];
        System.assert(c.msf_NoEmail__c, 'NoEmail returned false');
    }    
    
    @isTest static void updatePhone(){
        Contact c = [SELECT Id, FirstName, LastName, msf_MainEmail__c, msf_NIF__c, msf_NoRevistaCP__c, msf_NoMemoriaCP__c,
                     msf_NoCaptacionFondosCP__c, msf_NoCertificadoFiscalCP__c, msf_NoAgradecimientosCP__c,
                     msf_NoLlamadasBienvenidasEncuestasOtras__c, msf_NoMailingsTematicosCP__c, msf_NoCartasPlanRelacionCP__c,
                     msf_NoInvitacionesEventosCP__c, msf_NoComunicacionesOnetoOneCP__c, msf_NoRevistaSms__c, msf_NoMensajesTematicosSms__c,
                     msf_NoMensajesPlanRelacionSms__c, msf_NoMemoriaSms__c, msf_NoInvitacionesEventosSms__c, msf_NoEncuestaEstudioConcursoSms__c,
                     msf_NoComunicaconesOnetoOneSms__c, msf_NoCertificadoFiscalSms__c, msf_NoCaptacionFondosSms__c, msf_NoAgradecimientosSms__c
                     FROM Contact WHERE msf_NIF__c = '43578879C' LIMIT 1];
        c.MobilePhone='685623256';
        c.msf_NoRevistaCP__c = true;
        c.msf_NoMemoriaCP__c = true;
        c.msf_NoCaptacionFondosCP__c = true;
        c.msf_NoCertificadoFiscalCP__c = true;
        c.msf_NoAgradecimientosCP__c = true;
        c.msf_NoLlamadasBienvenidasEncuestasOtras__c = true;
        c.msf_NoMailingsTematicosCP__c = true;
        c.msf_NoCartasPlanRelacionCP__c = true;
        c.msf_NoInvitacionesEventosCP__c = true;
        c.msf_NoComunicacionesOnetoOneCP__c= true;
        c.msf_NoRevistaSms__c = true;
        c.msf_NoMensajesTematicosSms__c = true;
        c.msf_NoMensajesPlanRelacionSms__c = true;
        c.msf_NoMemoriaSms__c = true;
        c.msf_NoInvitacionesEventosSms__c = true;
        c.msf_NoEncuestaEstudioConcursoSms__c = true;
        c.msf_NoComunicaconesOnetoOneSms__c = true;
        c.msf_NoCertificadoFiscalSms__c = true;
        c.msf_NoCaptacionFondosSms__c = true;
        c.msf_NoAgradecimientosSms__c = true; 
        update c;
        
        Contact cTest = [SELECT msf_ContactInformationSummary__c, msf_PercomsSummary__c FROM Contact WHERE Id =: c.Id  LIMIT 1];
        System.debug('DATA of cTest:' + cTest);
        System.assertEquals('Email+Teléfono', cTest.msf_ContactInformationSummary__c);
        System.assertEquals('Varios', cTest.msf_PercomsSummary__c);
    }
    @isTest static void updatePhoneEmail_Null(){
        Contact c = [SELECT Id, FirstName, LastName, msf_MainEmail__c, msf_NIF__c, msf_NoRevistaCP__c, msf_NoMemoriaCP__c,
                     msf_NoCaptacionFondosCP__c, msf_NoCertificadoFiscalCP__c, msf_NoAgradecimientosCP__c,
                     msf_NoLlamadasBienvenidasEncuestasOtras__c, msf_NoMailingsTematicosCP__c, msf_NoCartasPlanRelacionCP__c,
                     msf_NoInvitacionesEventosCP__c, msf_NoComunicacionesOnetoOneCP__c, msf_NoRevistaSms__c, msf_NoMensajesTematicosSms__c,
                     msf_NoMensajesPlanRelacionSms__c, msf_NoMemoriaSms__c, msf_NoInvitacionesEventosSms__c, msf_NoEncuestaEstudioConcursoSms__c,
                     msf_NoComunicaconesOnetoOneSms__c, msf_NoCertificadoFiscalSms__c, msf_NoCaptacionFondosSms__c, msf_NoAgradecimientosSms__c
                     FROM Contact WHERE msf_NIF__c = '43578879C' LIMIT 1];
        c.msf_NoRevistaCP__c = true;
        c.msf_NoMemoriaCP__c = true;
        c.msf_NoCaptacionFondosCP__c = true;
        c.msf_NoCertificadoFiscalCP__c = true;
        c.msf_NoAgradecimientosCP__c = true;
        c.msf_NoLlamadasBienvenidasEncuestasOtras__c = true;
        c.msf_NoMailingsTematicosCP__c = true;
        c.msf_NoCartasPlanRelacionCP__c = true;
        c.msf_NoInvitacionesEventosCP__c = true;
        c.msf_NoComunicacionesOnetoOneCP__c= true;
        c.msf_NoRevistaSms__c = true;
        c.msf_NoMensajesTematicosSms__c = true;
        c.msf_NoMensajesPlanRelacionSms__c = true;
        c.msf_NoMemoriaSms__c = true;
        c.msf_NoInvitacionesEventosSms__c = true;
        c.msf_NoEncuestaEstudioConcursoSms__c = true;
        c.msf_NoComunicaconesOnetoOneSms__c = true;
        c.msf_NoCertificadoFiscalSms__c = true;
        c.msf_NoCaptacionFondosSms__c = true;
        c.msf_NoAgradecimientosSms__c = true; 
        
        c.MobilePhone=null;
        c.msf_MainEmail__c=null;
        update c;
        
        Contact cTest = [SELECT msf_ContactInformationSummary__c, msf_PercomsSummary__c FROM Contact WHERE Id =: c.Id  LIMIT 1];
        System.assertEquals('No data', cTest.msf_ContactInformationSummary__c);
        System.assertEquals('Varios', cTest.msf_PercomsSummary__c);
    }
    @isTest static void updateInvalidNif(){
        try{
            Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = '43578879C' LIMIT 1];
            c.msf_NIF__c = '123';
            update c;        
            System.assert(false);
        }catch(DmlException e){
            System.assert(true);
        }
    }
    @isTest static void updateInvalidCifPattern(){
        try{
            Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = 'B52006749' LIMIT 1];
            c.msf_NIF__c = 'Z23682785';
            update c;        
            System.assert(false);
        }catch(DmlException e){
            System.assert(true, 'Error found: ' + e.getMessage());
        }
    }
    @isTest static void updateInvalidCif(){
        try{
            Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = 'B52006749' LIMIT 1];
            c.msf_NIF__c = 'V2368278I';
            update c;        
            System.assert(false);
        }catch(DmlException e){
            System.assert(true, 'Error found: ' + e.getMessage());
        }
    }
    @isTest static void updateInvalidCifIfLetraFinal(){
        try{
            Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = 'B52006749' LIMIT 1];
            c.msf_NIF__c = 'N60376373';
            update c;        
            System.assert(false);
        }catch(DmlException e){
            System.assert(true, 'Error found: ' + e.getMessage());
        }
    }
    @isTest static void updateInvalidNie(){
        try{
            Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = '43578879C' LIMIT 1];
            c.msf_NIF__c = 'Y13578879Z';
            update c;        
            System.assert(false);
        }catch(DmlException e){
            System.assert(true);
        }
    }    
    
    @isTest static void updateContactInformationSummary_WithOnlyRestrictedPhone(){
        Contact c = [SELECT Id, msf_NIF__c,msf_Phone__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c.MobilePhone = null;
        c.msf_RestrictedPhone__c = '911111111';
        c.npe01__HomeEmail__c = c.msf_MainEmail__c = c.npe01__AlternateEmail__c = null;
        c.msf_RestrictedEmail__c = null;
        c.MailingStreet = c.MailingCity = c.MailingState = c.MailingPostalCode = c.MailingCountry = null; 
        c.OtherStreet = c.OtherCity = c.OtherState = c.OtherPostalCode = c.OtherCountry = null;
        update c;
        c = [SELECT Id, msf_ContactInformationSummary__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        System.assertEquals(c.msf_ContactInformationSummary__c,'Sólo teléfono restringido');
    }
    @isTest static void updateContactInformationSummary_WithOnlyRestrictedEmail(){
        Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c.msf_RestrictedEmail__c = 'a@a.com';
        c.npe01__HomeEmail__c = c.msf_MainEmail__c = c.npe01__AlternateEmail__c = null;
        c.OtherPhone = c.HomePhone = c.msf_MobilePhone2__c = c.MobilePhone = null;
        c.MailingStreet = c.MailingCity = c.MailingState = c.MailingPostalCode = c.MailingCountry = null;
        c.OtherStreet = c.OtherCity = c.OtherState = c.OtherPostalCode = c.OtherCountry = null;
        
        update c;
        c = [SELECT Id, msf_ContactInformationSummary__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        System.assertEquals('Sólo email restringido', c.msf_ContactInformationSummary__c);
    }    
    @isTest static void updateContactInformationSummary_WithRestrictedEmailPlusMailCheckingMain(){
        Contact c = [SELECT Id, msf_NIF__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        c.msf_RestrictedEmail__c = 'a@a.com';
        c.npe01__HomeEmail__c = c.msf_MainEmail__c = c.npe01__AlternateEmail__c = null;
        c.OtherPhone = c.HomePhone = c.msf_MobilePhone2__c = c.MobilePhone = null;
        update c;
        c = [SELECT Id, msf_ContactInformationSummary__c FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        System.assertEquals('Email restringido+Correo',c.msf_ContactInformationSummary__c);
    }
    @isTest static void updateContactInformationSummary_WithRestrictedEmailPlusMailCheckingOther(){
        Contact c = [SELECT Id, msf_NIF__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        c.msf_RestrictedEmail__c = 'a@a.com';
        c.npe01__HomeEmail__c = c.msf_MainEmail__c = c.npe01__AlternateEmail__c = null;
        c.OtherPhone = c.HomePhone = c.msf_MobilePhone2__c = c.MobilePhone = null;
        
        c.OtherStreet = c.MailingStreet;
        c.OtherCity = c.MailingCity;
        c.OtherState = c.MailingState;
        c.OtherPostalCode = c.MailingPostalCode;
        c.OtherCountry = c.MailingCountry;
        
        c.MailingStreet = c.MailingCity = c.MailingState = c.MailingPostalCode = c.MailingCountry = null;
        
        update c;
        c = [SELECT Id, msf_ContactInformationSummary__c FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        System.assertEquals('Email restringido+Correo',c.msf_ContactInformationSummary__c);
    }

    @isTest static void updateContactInformationSummary_WithOnlyRestrictedEmailPlusRestrictedPhone(){
        Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c.msf_RestrictedPhone__c = '911111111';
        c.msf_RestrictedMobilePhone__c = '611111111';
        
        c.MobilePhone = c.msf_MobilePhone2__c = c.HomePhone = c.OtherPhone = null;
        c.npe01__HomeEmail__c = c.msf_MainEmail__c = c.npe01__AlternateEmail__c = null;
        c.msf_RestrictedEmail__c =  'a@a.com';
        
        update c;
        
        c = [SELECT Id, msf_ContactInformationSummary__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        System.assertEquals('Email restringido+Teléfono restringido', c.msf_ContactInformationSummary__c);
    }
    @isTest static void updateContactInformationSummary_WithOnlyRestrictedEmailPlusPhone(){
        Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        
        c.MobilePhone = c.msf_MobilePhone2__c = '611111111';
        c.msf_RestrictedPhone__c = c.HomePhone = c.OtherPhone = '911111111';
        c.npe01__HomeEmail__c = c.msf_MainEmail__c = c.npe01__AlternateEmail__c = null;
        c.msf_RestrictedEmail__c =  'a@a.com';
        
        update c;
        
        c = [SELECT Id, msf_ContactInformationSummary__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        System.assertEquals('Email restringido+Teléfono', c.msf_ContactInformationSummary__c);
    }    
    @isTest static void updateContactInformationSummary_WithOnlyEmailPlusRestrictedPhone(){
        Contact c = [SELECT Id, msf_NIF__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c.msf_RestrictedPhone__c = '911111111';
        c.MobilePhone = c.msf_MobilePhone2__c = c.HomePhone = c.OtherPhone = null;
        c.npe01__HomeEmail__c = c.msf_MainEmail__c = c.npe01__AlternateEmail__c = c.msf_RestrictedEmail__c = 'a@a.com';
        
        update c;
        
        c = [SELECT Id, msf_ContactInformationSummary__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        System.assertEquals('Email+Teléfono restringido', c.msf_ContactInformationSummary__c);
    }
    @isTest static void updateContactInformationSummary_WithOnlyMailPlusRestrictedPhone(){
        Contact c = [SELECT Id, msf_NIF__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                     MailingCountry FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        c.msf_RestrictedPhone__c = '911111111';
        c.msf_RestrictedMobilePhone__c = '611111111';
        c.MobilePhone = c.msf_MobilePhone2__c = c.HomePhone = c.OtherPhone = null; 
        c.msf_RestrictedEmail__c = c.npe01__HomeEmail__c = c.msf_MainEmail__c = c.npe01__AlternateEmail__c = null;
        c.msf_DateReturnedMail1__c = null;
        c.msf_DateReturnedMail2__c = c.msf_DateReturnedMail3__c = date.today();         
        
        update c;
        
        c = [SELECT Id, msf_ContactInformationSummary__c FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        System.assertEquals('Teléfono restringido+Correo', c.msf_ContactInformationSummary__c);
    }

    @isTest static void updateContactInformationSummary_WithOnlyPhonePlusMail(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c1.MailingStreet ='girona';
        c1.MailingCity ='barcelona';
        c1.MailingState ='barcelona';
        c1.MailingPostalCode ='17018';
        c1.MailingCountry ='españa';
        c1.msf_NoEmail__c=false;
        
        update c1;
        
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Teléfono+Correo', cTest1.msf_ContactInformationSummary__c);
    }
    @isTest static void updateContactInformationSummary_WithOnlyPhonePlusMailOther(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c1.OtherStreet ='girona';
        c1.OtherCity ='barcelona';
        c1.OtherState ='barcelona';
        c1.OtherPostalCode ='17018';
        c1.OtherCountry ='españa';
        c1.msf_NoEmail__c=false;
        
        update c1;
        
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Teléfono+Correo', cTest1.msf_ContactInformationSummary__c);
    }
    @isTest static void updateContactInformationSummary_WithAll(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c1.MailingStreet ='girona';
        c1.MailingCity ='barcelona';
        c1.MailingState ='barcelona';
        c1.MailingPostalCode ='17018';
        c1.MailingCountry ='españa';
        c1.msf_NoEmail__c=false;
		c1.npe01__AlternateEmail__c = 'a@a.com';
        c1.msf_MainEmail__c = c1.npe01__HomeEmail__c = null;
        update c1;
        Contact cTest1 = [SELECT msf_PercomsSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Todo',cTest1.msf_PercomsSummary__c);
    }
    @isTest static void updateContactInformationSummary_WithAllOther(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        
        c1.npe01__HomeEmail__c = 'a@a.com';
        c1.MailingCity = null;
        c1.MailingState = null;
        c1.MailingPostalCode = null;
        c1.MailingCountry = null;
        
        
        c1.MailingStreet = c1.OtherStreet ='girona';
        c1.OtherCity ='barcelona';
        c1.OtherState ='barcelona';
        c1.OtherPostalCode ='17018';
        c1.OtherCountry ='españa';
        c1.Phone = '911111111';
        c1.msf_NoEmail__c = false;
        
        update c1;
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Todo',cTest1.msf_ContactInformationSummary__c);
        
    }    
    
    @isTest static void updateContactInformationSummary_UpdateCertificadoFiscal_Recibir(){
        Contact c2 = [SELECT Id, MailingStreet, MailingCity, 
                      MailingState, MailingPostalCode, MailingCountry, msf_NIF__c, msf_fiscalNif__c,
                      msf_NoCorreoPostal__c, msf_NoSMS__c, msf_NoEmail__c, msf_NoMi__c, msf_NoCertificadoFiscalCP__c, msf_NoCertificadoFiscalSms__c 
                      FROM Contact WHERE msf_NIF__c = '89670090J' LIMIT 1];
        c2.MailingStreet = null;
        c2.MailingCity = null;
        c2.MailingState = null;
        c2.MailingPostalCode = null;
        c2.MailingCountry = null;
        c2.msf_NoCorreoPostal__c = c2.msf_NoSMS__c = c2.msf_NoEmail__c = c2.msf_NoMi__c = true;
        update c2;

        Contact cTest2 = [SELECT Id, msf_SoloCertificadoFiscal__c
                          FROM Contact WHERE Id = :c2.Id LIMIT 1];
        System.assert(cTest2.msf_SoloCertificadoFiscal__c);
    }  
    @isTest static void updateContactInformationSummary_UpdateCertificadoFiscal_NoRecibir(){
        Contact c2 = [SELECT Id, FirstName, LastName, msf_NIF__c, MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry,msf_SoloCertificadoFiscal__c
                      FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        c2.msf_MainEmail__c='silver@a.com';
        c2.msf_NoRecibirNada__c = true;
        c2.msf_SoloCertificadoFiscal__c = !c2.msf_SoloCertificadoFiscal__c;
        update c2;
        Contact cTest2 = [SELECT Id, msf_SoloCertificadoFiscal__c FROM Contact WHERE Id = :c2.Id LIMIT 1];
        
        System.assert(!cTest2.msf_SoloCertificadoFiscal__c);
    }
    @isTest static void updateLastNameWithDot(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c = '43578879C' LIMIT 1];
        c.LastName = 'MSF_ContactFieldsLogic_.TEST_updateLastNameWithDot_LastName1';
        update c;
        
        c = [SELECT Id,LastName FROM Contact WHERE Id = :c.Id LIMIT 1];
        System.assertEquals('Msf_contactfieldslogic_.Test_updatelastnamewithdot_lastname1.', c.LastName);
    }
    @isTest static void updateContactInformationSummary_WithOnlyPhonePlusRestrictedEmailPlusRestrictedPhone(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c1.MailingStreet ='girona';
        c1.MailingCity ='barcelona';
        c1.MailingState ='barcelona';
        c1.MailingPostalCode ='17018';
        c1.MailingCountry ='españa';
        c1.npe01__HomeEmail__c = c1.msf_MainEmail__c = c1.npe01__AlternateEmail__c = null;
        c1.msf_RestrictedPhone__c = '911111111';
        c1.msf_RestrictedMobilePhone__c = '611111111';
        c1.msf_RestrictedEmail__c = 'a@a.com';
        c1.msf_DateReturnedMail1__c = c1.msf_DateReturnedMail2__c = c1.msf_DateReturnedMail3__c = null;
        c1.MobilePhone =  c1.msf_MobilePhone2__c = c1.HomePhone = c1.OtherPhone = null;
        update c1;
        
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Correo+Teléfono restringido+Email restringido', cTest1.msf_ContactInformationSummary__c);
    }
    @isTest static void updateContactInformationSummary_WithOnlyPhonePlusRestrictedEmailPlusRestrictedPhoneOther(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        c1.OtherStreet ='girona';
        c1.OtherCity ='barcelona';
        c1.OtherState ='barcelona';
        c1.OtherPostalCode ='17018';
        c1.OtherCountry ='españa';
        c1.npe01__HomeEmail__c = c1.msf_MainEmail__c = c1.npe01__AlternateEmail__c = null;
        c1.msf_RestrictedPhone__c = '911111111';
        c1.msf_RestrictedMobilePhone__c = '611111111';
        c1.msf_RestrictedEmail__c = 'a@a.com';
        c1.msf_DateReturnedMail1__c = c1.msf_DateReturnedMail2__c = c1.msf_DateReturnedMail3__c = null;
        c1.MobilePhone =  c1.msf_MobilePhone2__c = c1.HomePhone = c1.OtherPhone = null;
        update c1;
        
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Correo+Teléfono restringido+Email restringido', cTest1.msf_ContactInformationSummary__c);
    }
    
    @isTest static void updatePercomsUpdateSummary_NotFoundCaptation(){
        Contact c = [SELECT Id, FirstName, LastName, msf_NIF__c, MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry,msf_SoloCertificadoFiscal__c
                     FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        c.msf_NoEmail__c = c.msf_SoloCertificadoFiscal__c = c.msf_NoComunicacionesOnetoOneTelefono__c = false;
        c.msf_NoCaptacionFondos__c = true;
        update c;
        c = [SELECT msf_ContactInformationSummary__c, msf_PercomsSummary__c FROM Contact WHERE Id =: c.Id  LIMIT 1];
        System.assertEquals('No captación de fondos',c.msf_PercomsSummary__c);
    }
    @isTest static void updatePercomsUpdateSummary_Nothing(){
        Contact c2 = [SELECT Id, FirstName, LastName, msf_NIF__c, MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry,msf_SoloCertificadoFiscal__c
                      FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        c2.msf_SoloCertificadoFiscal__c = c2.msf_NoRecibirNada__c = false;
        c2.msf_NoCaptacionFondos__c = true;
        update c2;
        c2 = [SELECT msf_ContactInformationSummary__c, msf_PercomsSummary__c FROM Contact WHERE Id =: c2.Id  LIMIT 1];
        System.assertEquals('Nada', c2.msf_PercomsSummary__c);
    }
    @isTest static void updatePercoms_NoRecibirNada_NoSoloCertificadoFiscal(){
        Contact c2 = [SELECT Id FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];

        c2.msf_NoRevistaCP__c = c2.msf_NoMemoriaCP__c = c2.msf_NoCaptacionFondosCP__c = c2.msf_NoCertificadoFiscalCP__c  = c2.msf_NoAgradecimientosCP__c = true;
        c2.msf_NoLlamadasBienvenidasEncuestasOtras__c = c2.msf_NoMailingsTematicosCP__c = c2.msf_NoCartasPlanRelacionCP__c = c2.msf_NoInvitacionesEventosCP__c =  true;
        c2.msf_NoComunicacionesOnetoOneCP__c = c2.msf_NoComunicaconesOnetoOneSms__c = c2.msf_NoCertificadoFiscalSms__c = c2.msf_NoCaptacionFondosSms__c = true;   
        c2.msf_NoRevistaEmail__c = c2.msf_NoMemoriaEmail__c = c2.msf_NoCaptacionFondosEmail__c = c2.msf_NoCertificadoFiscalEmail__c = true;
        c2.msf_NoComunicaconesOnetoOneMi__c = c2.msf_NoCertificadoFiscalMi__c = c2.msf_NoCaptacionFondosMi__c = true;
        update c2;

        c2 = [SELECT msf_NoRecibirNada__c, msf_SoloCertificadoFiscal__c FROM Contact WHERE Id =: c2.Id  LIMIT 1];
        System.assert(c2.msf_NoRecibirNada__c);
        System.assert(!c2.msf_SoloCertificadoFiscal__c);
    }
    
    @isTest static void updateSetLangPrfWithNullPostalCode(){
        Contact c2 = [SELECT Id, FirstName, LastName, msf_NIF__c, MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry,msf_SoloCertificadoFiscal__c
                      FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        c2.MailingPostalCode = c2.msf_LanguagePreferer__c = null;
        c2.MobilePhone='698565419';
        update c2;
        c2 = [SELECT msf_LanguagePreferer__c FROM Contact WHERE Id =: c2.Id  LIMIT 1];
        System.assertEquals('ESP', c2.msf_LanguagePreferer__c);
    }
    
    
    @isTest static void updateAutoSetNoMi(){
        Contact c2 = [SELECT Id, FirstName, LastName, msf_NIF__c, MailingStreet, MailingCity, MailingState, MailingPostalCode,MailingCountry,msf_SoloCertificadoFiscal__c
                      FROM Contact WHERE msf_NIF__c = '18931233W' LIMIT 1];
        c2.msf_MainEmail__c='silver@a.com';
        c2.MobilePhone='698565419';
        c2.msf_NoRevistaMi__c = c2.msf_NoMensajesTematicosMi__c = c2.msf_NoMensajesPlanRelacionMi__c = true;
        c2.msf_NoMemoriaMi__c = c2.msf_NoInvitacionesEventosMi__c = c2.msf_NoEncuestaEstudioConcursoMi__c = true;
        c2.msf_NoComunicaconesOnetoOneMi__c = c2.msf_NoCertificadoFiscalMi__c = c2.msf_NoCaptacionFondosMi__c = true;
        c2.msf_NoAgradecimientosMi__c = true;
        update c2;
        c2 = [SELECT msf_NoMi__c FROM Contact WHERE Id =: c2.Id  LIMIT 1];
        System.assert(c2.msf_NoMi__c);
    }
    @isTest static void updateContactInformationSummary_WithAllMailPlusPhonePlusRestrictedEmail(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        
        c1.npe01__HomeEmail__c = c1.msf_MainEmail__c = c1.npe01__AlternateEmail__c = null;
        c1.msf_RestrictedEmail__c = 'a@a.com';
        c1.MailingCity = 'barcelona';
        c1.MailingState = 'barcelona';
        c1.MailingPostalCode = '17018';
        c1.MailingCountry = 'españa';
        
        c1.MailingStreet = c1.OtherStreet ='girona';
        c1.OtherCity = null;
        c1.OtherState = null;
        c1.OtherPostalCode = null;
        c1.OtherCountry = null;
        c1.Phone = '911111111';
        c1.msf_NoEmail__c = false;
        c1.msf_RestrictedPhone__c = '911111111';
        c1.msf_DateReturnedMail1__c = c1.msf_DateReturnedMail2__c = c1.msf_DateReturnedMail3__c = null;       
        
        update c1;
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Correo+Teléfono+Email restringido',cTest1.msf_ContactInformationSummary__c);
        
    }    
    @isTest static void updateContactInformationSummary_WithAllMailPlusPhonePlusRestrictedEmailOther(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        
        c1.npe01__HomeEmail__c = c1.msf_MainEmail__c = c1.npe01__AlternateEmail__c = null;
        c1.msf_RestrictedEmail__c = 'a@a.com';
        c1.MailingCity = null;
        c1.MailingState = null;
        c1.MailingPostalCode = null;
        c1.MailingCountry = null;
        
        c1.MailingStreet = c1.OtherStreet ='girona';
        c1.OtherCity ='barcelona';
        c1.OtherState ='barcelona';
        c1.OtherPostalCode ='17018';
        c1.OtherCountry ='españa';
        c1.Phone = '911111111';
        c1.msf_NoEmail__c = false;
        c1.msf_RestrictedPhone__c = '911111111';
        c1.msf_DateReturnedMail1__c = c1.msf_DateReturnedMail2__c = c1.msf_DateReturnedMail3__c = null;       
        
        update c1;
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Correo+Teléfono+Email restringido',cTest1.msf_ContactInformationSummary__c);
        
    }    
	@isTest static void updateContactInformationSummary_WithAllMailPlusEmailPlusRestrictedPhone(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        
        c1.msf_RestrictedEmail__c = c1.npe01__HomeEmail__c = c1.msf_MainEmail__c = c1.npe01__AlternateEmail__c = 'a@a.com';
        
        c1.MailingCity = 'barcelona';
        c1.MailingState = 'barcelona';
        c1.MailingPostalCode = '17018';
        c1.MailingCountry = 'españa';
        c1.MailingStreet = c1.OtherStreet ='girona';
        
        c1.OtherCity = null;
        c1.OtherState = null;
        c1.OtherPostalCode = null;
        c1.OtherCountry = null;
        
        c1.msf_NoEmail__c = false;
        c1.msf_RestrictedPhone__c = null;
        c1.msf_DateReturnedMail1__c = c1.msf_DateReturnedMail2__c = c1.msf_DateReturnedMail3__c = null;       
        
        c1.MobilePhone = c1.msf_MobilePhone2__c = c1.HomePhone = c1.OtherPhone = null;
        c1.msf_RestrictedPhone__c = '911111111';
        c1.msf_RestrictedMobilePhone__c = '611111111';

        update c1;
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Correo+Email+Teléfono restringido',cTest1.msf_ContactInformationSummary__c);
        
    }      
	@isTest static void updateContactInformationSummary_WithAllMailPlusEmailPlusRestrictedPhoneOther(){        
        Contact c1 = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, MobilePhone, msf_NoEmail__c FROM Contact WHERE msf_NIF__c = '15573648A' LIMIT 1];
        
        c1.msf_RestrictedEmail__c = c1.npe01__HomeEmail__c = c1.msf_MainEmail__c = c1.npe01__AlternateEmail__c = 'a@a.com';
        
        c1.MailingCity = null;
        c1.MailingState = null;
        c1.MailingPostalCode = null;
        c1.MailingCountry = null;
        c1.MailingStreet = c1.OtherStreet ='girona';
        
        c1.OtherCity = 'barcelona';
        c1.OtherState = 'barcelona';
        c1.OtherPostalCode = '17018';
        c1.OtherCountry = 'españa';
        
        c1.msf_NoEmail__c = false;
        c1.msf_RestrictedPhone__c = null;
        c1.msf_DateReturnedMail1__c = c1.msf_DateReturnedMail2__c = c1.msf_DateReturnedMail3__c = null;       
        
        c1.MobilePhone = c1.msf_MobilePhone2__c = c1.HomePhone = c1.OtherPhone = null;
        c1.msf_RestrictedPhone__c = '911111111';
        c1.msf_RestrictedMobilePhone__c = '611111111';

        update c1;
        Contact cTest1 = [SELECT msf_ContactInformationSummary__c FROM Contact WHERE Id =: c1.Id  LIMIT 1];
        System.assertEquals('Correo+Email+Teléfono restringido',cTest1.msf_ContactInformationSummary__c);
        
    }
    
    private static List<String> leadSource1Desc(){
        Schema.DescribeFieldResult fieldResult = Contact.LeadSource.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    private static List<String> leadSource2Desc(){
        Schema.DescribeFieldResult fieldResult = Contact.msf_LeadSource2Level__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    private static List<String> leadSource3Desc(){
        Schema.DescribeFieldResult fieldResult = Contact.msf_LeadSource3Level__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }

}