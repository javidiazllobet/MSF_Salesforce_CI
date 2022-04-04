/**
* @author       Deloitte
* @date         02-2019
* @group        Contact.
* @description  test class for the MSF_NewOrganizationContact_CTRL class.
*/
@isTest
private class MSF_NewOrganizationContact_TEST {

    @testSetup static void setup(){
        ID idRTOrgCon = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        ID idRTOrg = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        
        Contact cOrg = new Contact(            
            RecordTypeId = idRTOrg,
            LastName = 'Contact_TEST_Setup_Org_SurName1',
            HomePhone = '911111111',
            MobilePhone = '611111111',
            Email = 'a@org.com',
            Title = 'Contact_TEST_Setup_Org_Role'
        );
        insert cOrg;
        
        Contact c = new Contact(            
            RecordTypeId = idRTOrgCon,
            msf_Organization__c = cOrg.Id,
            FirstName = 'Contact_TEST_Setup_Name1',
            LastName = 'Contact_TEST_Setup_SurName1',
            Suffix = 'Contact_TEST_Setup_SurName2',
            HomePhone = '911111111',
            MobilePhone = '611111111',
            Email = 'b@org.com',
            Title = 'Contact_TEST_Setup_Role',
            msf_IsPrimary__c = false
        );
        insert c;
    }
    
    @isTest static void testCrearContactoOrganizacionSuccess(){
        Campaign c = new Campaign (Name='Cam1', msf_FinalCampaign__c = false);
        insert c;
        
        Id idOrg = [SELECT Id FROM Contact WHERE LastName = 'Contact_TEST_Setup_Org_SurName1' LIMIT 1].Id;
        
        Schema.DescribeFieldResult fieldResult = Contact.msf_LanguagePreferer__c.getDescribe();
       	List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        String langPrfLabel = pickListValues[0].getLabel();
        
        fieldResult = Contact.Gender__c.getDescribe();
       	pickListValues = fieldResult.getPicklistValues();
        String genderLabel = pickListValues[0].getLabel();
                                                      
		Map<String, Object> out = (Map<String, Object> )MSF_NewOrganizationContact_CTRL.crearContactoOrganizacion(idOrg, 'name', 'Surname', 'Surname', '931111111', '612111111',  'c@org.com', 'Mr.', genderLabel, langPrfLabel, false, 'LeadSource', c.Id);     
		System.assert((Boolean)out.get('isSuccess'),(String)out.get('msg'));        
    }
    
    @isTest static void testCrearContactoOrganizacionFailure(){
        Campaign c = new Campaign (Name='Cam1', msf_FinalCampaign__c = false);
        insert c;
        
        Id idOrg = [SELECT Id FROM Contact WHERE FirstName = 'Contact_TEST_Setup_Name1' and LastName = 'Contact_TEST_Setup_SurName1' LIMIT 1].Id;
		Map<String, Object> out = (Map<String, Object> )MSF_NewOrganizationContact_CTRL.crearContactoOrganizacion(idOrg, 'name', 'Surname', 'Surname', '911111111', '611111111',  'b@org.com', 'Lord', '', '', false, 'LeadSource', c.Id);        
        System.assert(!(Boolean)out.get('isSuccess'),'Contact has been inserted. That should not happen');
    }
    
    @isTest static void testGetGender(){
        List<String> contOrg = MSF_NewOrganizationContact_CTRL.getGender();
        System.assertNotEquals(null,contOrg,'Gender list must not be null');
    }
    
    @isTest static void testGetPrfLanguage(){
        List<String> contOrg = MSF_NewOrganizationContact_CTRL.getPrfLanguage();
        System.assertNotEquals(null,contOrg,'Language list must not be null');
    }
}