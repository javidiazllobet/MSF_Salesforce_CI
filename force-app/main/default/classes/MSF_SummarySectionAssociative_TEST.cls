@isTest
private class MSF_SummarySectionAssociative_TEST {
    @testSetup static void setup(){
        Id IdRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();  
        Contact cont = new Contact(LastName='MSF_SummarySectionAssociative_TEST_LastName1', RecordTypeId=IdRTContact);
        insert cont;
        msf_Associative__c assoc = new msf_Associative__c(msf_Status__c='Activo', msf_contactId__c=cont.Id);
        insert assoc; 
        Lead lead = new Lead(LastName='MSF_SummarySectionAssociative_TEST_LastName1',Company='MSF_SummarySectionAssociative_TEST_Company1');
        insert lead;        
    }
    
    @isTest static void getObjectTypeTestTrue(){
        Contact cont = [SELECT Id, LastName FROM Contact WHERE LastName = 'MSF_SummarySectionAssociative_TEST_LastName1' LIMIT 1];
        Object obj = MSF_SummarySectionAssociative_CTRL.getObjectType(cont.Id);        
        Map<String, Object> msfa = (Map<String, Object>)obj;
        System.assert((Boolean)msfa.get('isContact'));
    }
    
    @isTest static void getObjectTypeTestFalse(){
        Lead lead = [SELECT Id FROM Lead WHERE LastName = 'MSF_SummarySectionAssociative_TEST_LastName1' LIMIT 1];
        Object obj = MSF_SummarySectionAssociative_CTRL.getObjectType(lead.Id);  
        Map<String, Object> msfa = (Map<String, Object>)obj;
        System.assert(!(Boolean)msfa.get('isContact'));
    }
    @isTest static void getContactInformationTest(){
        Id IdOrgRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();  
        
        Contact cont = [SELECT Id, msf_IsAssosiative__c,RecordTypeId FROM Contact WHERE LastName = 'MSF_SummarySectionAssociative_TEST_LastName1' LIMIT 1];

        Map<String,Object> contactInfo = (Map<String,Object>) MSF_SummarySectionAssociative_CTRL.getContactInformation(cont.Id);
        Contact returnData = (Contact)contactInfo.get('contact');
        System.assertEquals(returnData, cont);
        System.assertEquals(contactInfo.get('numEndorsements'),0);
    }
    
    
    @isTest static void getAssociativeInformationTestTrue(){
        Contact cont = [SELECT Id, LastName FROM Contact WHERE LastName = 'MSF_SummarySectionAssociative_TEST_LastName1' LIMIT 1];
        Map<String,Object> Associatives = (Map<String,Object>)MSF_SummarySectionAssociative_CTRL.getAssociativeInformation(cont.Id);
        System.assertNotEquals(Associatives.get('associative'),null);
    }
    @isTest static void getAssociativeInformationTestFalse(){
        Contact cont = new Contact(LastName='MSF_AssociativeSectionInContact_TEST_LastName2');
        Map<String,Object> Associatives = (Map<String,Object>)MSF_SummarySectionAssociative_CTRL.getAssociativeInformation(cont.Id);
        System.assertEquals(Associatives.get('associative'),null);
    }
    @isTest static void getLeadInformationTest(){
        Lead ld = [SELECT Id FROM LEAD WHERE LastName = 'MSF_SummarySectionAssociative_TEST_LastName1' LIMIT 1];
        Map<String,Object> leadFound = (Map<String,Object>)MSF_SummarySectionAssociative_CTRL.getLeadInformation(ld.Id);        
        System.assertNotEquals(leadFound.get('ld'),null);
    }    
    
}