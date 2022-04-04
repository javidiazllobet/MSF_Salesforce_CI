@isTest
public class MSF_ConvertAssociativeLead_TEST {
    
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
        
        Campaign camp = new Campaign(Name='MSFConvertAssociativeLeadTESTcamp1',msf_FinalCampaign__c = false);
        insert camp;
        
        Contact c = new Contact(
            FirstName='FirstName1',
            LastName= 'LastName1',
            msf_MainEmail__c = 'm@m.com',
            msf_NIF__c='43578879C',
            msf_IsAssosiative__c = true
        );
        insert c;
        
        Contact c2 = new Contact(
            FirstName='FirstName2',
            LastName= 'LastName2',
            msf_MainEmail__c = 'm@mm.com',
            msf_NIF__c='82970393D',
            msf_IsAssosiative__c = true
        );
        insert c2;
        
        Lead lead = new Lead(RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId(), 
                             Company='Company1',
                             FirstName='FirstName1',
                             LastName='LastName1',
                             Suffix = 'Suffix1',
                             msf_NIF__c = '94939216T',
                             Email='a@a.com',   
                             msf_AssociativePhone__c = '911111111',
                             Phone = '911111111',
                             MobilePhone='611111111',
                             LeadSource='SMS',
                             msf_ExemptOfPayment__c=false,
                             msf_IBANCode__c = 'ES21',
                             msf_IBANEntity__c = '2059',
                             msf_IBANOffice__c = '7074',
                             msf_IBANDC__c = '08',
                             msf_IBANAccountNumber__c = '0558221500',
                             msf_noCriminalRecord__c = true,
                             msf_AcceptStatutes__c = true,
                             msf_acceptDataProtectionPolicy__c = true,   
                             msf_MoreInfo__c = 'test', 
                             msf_EndorsedByOne__c = c.Id,
                             msf_EndorsedByTwo__c = c2.Id);        
        insert lead;
        
        //Contentlink lead1
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Header_Picture1'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        content.origin = 'H';
        insert content;
        
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE id =:content.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = lead.id;
        contentlink.ContentDocumentId = cv.ContentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink; 
        //End contentlink Contentlink lead1
        
        Lead lead2 = new Lead(RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Associative').getRecordTypeId(),
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
                              msf_IBANCode__c = 'ES27',
                              msf_IBANEntity__c = '0013',
                              msf_IBANOffice__c = '1494',
                              msf_IBANDC__c = '95',
                              msf_IBANAccountNumber__c = '8887610140',     
                              msf_noCriminalRecord__c = true,
                              msf_AcceptStatutes__c = true,
                              msf_acceptDataProtectionPolicy__c = true,                             
                              msf_EndorsedByOne__c = c.Id,
                              msf_EndorsedByTwo__c = c2.Id);  
        insert lead2;
        
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
                              msf_EndorsedByOne__c = c.Id,
                              msf_EndorsedByTwo__c = c2.Id);      
        insert lead3;
        
        Lead lead4 = new Lead(RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId(),
                              Company='Company4',
                              FirstName='FirstName4',
                              LastName='LastName4',
                              Suffix = 'Suffix4',
                              msf_NIF__c = '43578879C',
                              Email='a@a4.com',   
                              msf_AssociativePhone__c = '911111114',
                              Phone = '911111114',
                              MobilePhone='611111114',
                              LeadSource='SMS',
                              msf_ExemptOfPayment__c=false,
                              msf_IBANCode__c = 'ES91',
                              msf_IBANEntity__c = '1004',
                              msf_IBANOffice__c = '6063',
                              msf_IBANDC__c = '91',
                              msf_IBANAccountNumber__c = '9233907664',     
                              msf_noCriminalRecord__c = true,
                              msf_AcceptStatutes__c = true,
                              msf_acceptDataProtectionPolicy__c = true,                             
                              msf_EndorsedByOne__c = c.Id,
                              msf_EndorsedByTwo__c = c2.Id); 
        insert lead4;

        CampaignMember campMem = new CampaignMember(CampaignId=camp.Id, LeadId = lead2.Id);
        insert campMem;
        
        Opportunity opp = new Opportunity(msf_LeadId__c=lead2.Id, Name='MSFConvertAssociativeLeadTESTopp1', StageName='SMS Donor', Amount=5, CloseDate=date.today(), CampaignId = camp.Id);
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
        
        String sIBAN = lead3.msf_IBANCode__c + lead3.msf_IBANEntity__c + lead3.msf_IBANOffice__c + lead3.msf_IBANDC__c + lead3.msf_IBANAccountNumber__c;
        cpm__Payment_Profile__c payment = new cpm__Payment_Profile__c(cpm__Contact__c=c.Id, 
                                                                      cpm__IBAN__c=sIBAN, 
                                                                      msf_NIF__c=lead3.msf_NIF__c, 
                                                                      cpm__Active__c=true,
                                                                      RecordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName().get('IBAN').getRecordTypeId()
                                                                     );
        insert payment;
    }
    
    @isTest static void getLeadInformationTest(){
        Lead ld = [SELECT Id FROM lead WHERE LastName='LastName1' LIMIT 1];
        Map<String, Object> LeadList = (Map<String, Object> )MSF_ConvertAssociativeLead_CTRL.getLeadInformation(ld.Id);
        Lead returnedLead = (Lead)LeadList.get('lead');
        System.assertEquals(ld.Id,returnedLead.Id);
        System.assertEquals(((List<Object>)LeadList.get('contacts')).size(),0);
    }
    
    @isTest static void setNewAssociativePersonTestSuccess(){
        Lead ld = [SELECT Id,LastName FROM Lead WHERE LastName='LastName2' LIMIT 1];
        Map<String,Object> data = (Map<String,Object>)MSF_ConvertAssociativeLead_CTRL.setNewAssociativePerson(ld.Id);
        Id contactId = (ID)data.get('goToSobject');
        System.assertNotEquals(contactId,ld.Id);
    }
    
    @isTest static void setNewAssociativePersonTestError(){
        Lead ld = [SELECT Id,LastName FROM Lead WHERE LastName='LastName1' LIMIT 1];
        Map<String,Object> data = (Map<String,Object>)MSF_ConvertAssociativeLead_CTRL.setNewAssociativePerson(ld.Id);
        Id contactId = (ID)data.get('goToSobject');
        System.assertEquals(contactId,ld.Id);
    }
    
    @isTest static void setMemberAsAssociativePersonTestSuccess(){
        Lead ld = [SELECT Id,LastName FROM Lead WHERE LastName='LastName2' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName='LastName1' LIMIT 1];
        Map<String,Object> returnData = (Map<String,Object>)MSF_ConvertAssociativeLead_CTRL.setMemberAsAssociativePerson(ld.Id,cont.Id);
        System.assertNotEquals(ld.Id,returnData.get('goToSobject'));
    }
    
    @isTest static void setMemberAsAssociativePersonTestError(){
        Lead ld = [SELECT Id,LastName FROM Lead WHERE LastName='LastName1' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName='LastName1' LIMIT 1];
        Map<String,Object> returnData = (Map<String,Object>)MSF_ConvertAssociativeLead_CTRL.setMemberAsAssociativePerson(ld.Id,cont.Id);
        System.assertEquals(ld.Id,returnData.get('goToSobject'));
    }
    
    @isTest static void setMemberAsAssociativePersonTestErrorWithPaymentProfile(){
        Lead ld = [SELECT Id,LastName FROM Lead WHERE LastName='LastName3' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName='LastName1' LIMIT 1];
        Map<String,Object> returnData = (Map<String,Object>)MSF_ConvertAssociativeLead_CTRL.setMemberAsAssociativePerson(ld.Id,cont.Id);
        System.assertEquals(ld.Id,returnData.get('goToSobject'));
    }
}