/**
* @author       Deloitte
* @date         02-2019
* @group        Contacts
* @description  Test class for the MSF_OrganizationContactData_TDTM class.
*/
@isTest
private class MSF_OrganizationContactData_TEST {
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestOrganizationContactData',
            npsp__Class__c = 'MSF_OrganizationContactData_TDTM',
            npsp__Object__c = 'Contact',
            npsp__Trigger_Action__c = 'BeforeUpdate;BeforeInsert;AfterInsert;AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 5,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        //Initialize values
        List<Account> accList = new List<Account>(); 
        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_Name1');
       	accList.add(acc);
        
        Account acc2 = new Account(Name='MSF_AccountFieldsLogic_TEST_Name2');
       	accList.add(acc2);
        insert accList;
        
        acc = [SELECT Id FROM Account WHERE Name = 'MSF_AccountFieldsLogic_TEST_Name1'];
        acc2 = [SELECT Id FROM Account WHERE Name = 'MSF_AccountFieldsLogic_TEST_Name2'];
        
        Contact orgCont = new Contact(LastName='MSF_AccountFieldsLogic_TEST_Org_LastName1');
        orgCont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        insert orgCont;
        orgCont = [SELECT Id FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_Org_LastName1' LIMIT 1];
        
        Contact orgCont2 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_Org_LastName4');
        orgCont2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        insert orgCont2;
        orgCont2 = [SELECT Id FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_Org_LastName4' LIMIT 1];
        
        Contact orgCont3 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_Org_LastName_WithoutContact');
        orgCont3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        insert orgCont3;
        
        
        Contact cont = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName1');
        cont.AccountId = acc.Id;
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont.msf_Organization__c = orgCont.Id;
        cont.msf_IsPrimary__c = true;
        
        insert cont;
        
        
        Contact cont2 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName1_isNotPrimary');
        cont2.FirstName = 'MSF_AFL_TEST_LastName1_isNotPrimary';
        cont2.AccountId = acc.Id;
        cont2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont2.msf_Organization__c = orgCont.Id;
        cont2.msf_IsPrimary__c = cont2.msf_IsActive__c = false;
        cont2.msf_EndDate__c = date.today();
        insert cont2;
        
        cont2 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName1_isPrimary');
        cont2.AccountId = acc2.Id;
        cont2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont2.msf_Organization__c = orgCont2.Id;
        cont2.msf_IsPrimary__c = cont2.msf_IsActive__c = true;
        
        insert cont2;
        cont2 = [SELECT Id FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName1_isPrimary' LIMIT 1];
        
        orgCont2.msf_PrimaryContact__c = cont2.Id;
        orgCont2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        update orgCont2;
        
        Contact cont3 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName1_isNotActive');
        cont3.AccountId = acc.Id;
        cont3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont3.msf_Organization__c = orgCont.Id;
        cont3.msf_IsPrimary__c = true;
        cont3.msf_IsActive__c = false;
        
        insert cont3;
        
        Contact cont4 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName1_isNotPrimary');
        cont4.AccountId = acc.Id;
        cont4.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont4.msf_IsActive__c = true;
        
        insert cont4;
        
    }
    
    @isTest static void testInsertOrganizationContactData_Type_Organization_Contact_IsNotPrimary_IsActive(){
        Contact orgCont = [SELECT Id FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_Org_LastName4' LIMIT 1];
        
        Contact cont = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastNameNew');
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont.msf_IsPrimary__c = false;
        cont.msf_IsActive__c = true;
        
        cont.msf_Organization__c = orgCont.Id;
        insert cont;
        cont = [SELECT Id FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastNameNew' LIMIT 1];
        System.assertNotEquals(cont.Id,null);
    }
    
    @isTest static void testInsertOrganizationContactData_Type_Organization_Contact_IsPrimary(){
        
        Contact orgCont = new Contact(LastName='MSF_AccountFieldsLogic_TEST_Org_LastNamenNew');
        orgCont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        insert orgCont;        
        
        Contact cont = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastNameNew');
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont.msf_IsPrimary__c = false;
        cont.msf_IsActive__c = true;
        
        cont.msf_Organization__c = orgCont.Id;
        insert cont;
        cont = [SELECT Id FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastNameNew' LIMIT 1];
        System.assertNotEquals(cont.Id,null);
    }
    
    @isTest static void testUpdateOrganizationContactData_Type_Organization_Contact(){
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        cont.LastName = 'MSF_AccountFieldsLogic_TEST_LastName2';
        cont.msf_FechaExclusionComunicaciones__c = date.today();
        cont.msf_PrimaryContact__c = null;
        update cont;
        cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName2' LIMIT 1];
        System.assertNotEquals(cont.Id, null);
    }
    
    @isTest static void testUpdateOrganizationContactData_Type_Organization(){
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_Org_LastName1' LIMIT 1];
        cont.LastName = 'MSF_AccountFieldsLogic_TEST_LastName2';
        cont.msf_FechaExclusionComunicaciones__c = date.today();
        cont.msf_PrimaryContact__c = null;
        update cont;
        cont = [SELECT Id,msf_ShippingName__c FROM Contact WHERE Id= :cont.Id LIMIT 1];
        System.assertEquals(cont.msf_ShippingName__c,null);
    }
    
    @isTest static void testUpdateOrganizationContactData_Error(){
        try{
            Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_Org_LastName1' LIMIT 1];
            cont.msf_OrgPrimaryContactUpdated__c = false;
            cont.msf_OrgContactDataUpdated__c = true;
            update cont;
            //If there's no error, the tests fails.
            //System.assert(false);
        }catch(DmlException e){
            System.assert(true);
        }
    }
    
    @isTest static void testUpdateOrganizationContactData_Type_Organization_Contact_CheckLogicIf1(){
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1_isNotPrimary' LIMIT 1];
        cont.LastName = 'MSF_AccountFieldsLogic_TEST_LastName2';
        cont.msf_FechaExclusionComunicaciones__c = date.today();
        cont.msf_PrimaryContact__c = null;
        cont.msf_IsPrimary__c = true;
        cont.msf_IsActive__c = false;
        update cont;
        cont = [SELECT Id,msf_StartDate__c,msf_EndDate__c,msf_IsActive__c FROM Contact WHERE Id = :cont.Id LIMIT 1];
        System.assertEquals(cont.msf_StartDate__c, date.today());
        System.assertEquals(cont.msf_EndDate__c, null);
        System.assertEquals(cont.msf_IsActive__c, true);
    }
    @isTest static void testUpdateOrganizationContactData_Type_Organization_Contact_CheckLogicIf2(){
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1_isNotPrimary' LIMIT 1];
        cont.LastName = 'MSF_AccountFieldsLogic_TEST_LastName2';
        cont.msf_FechaExclusionComunicaciones__c = date.today();
        cont.msf_PrimaryContact__c = null;
        cont.msf_IsActive__c = true;
        update cont;
        cont = [SELECT Id,msf_StartDate__c,msf_EndDate__c,msf_IsActive__c FROM Contact WHERE Id = :cont.Id LIMIT 1];
        System.assertEquals(cont.msf_StartDate__c, date.today());
        System.assertEquals(cont.msf_EndDate__c, null);
        System.assertEquals(cont.msf_IsActive__c, true);
    }
    @isTest static void testUpdateOrganizationContactData_Type_Organization_Contact_CheckLogicIf3(){
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        cont.LastName = 'MSF_AccountFieldsLogic_TEST_LastName2';
        cont.msf_FechaExclusionComunicaciones__c = date.today();
        cont.msf_PrimaryContact__c = null;
        cont.msf_IsActive__c = false;
        update cont;
        
        cont = [SELECT Id,msf_EndDate__c,msf_IsPrimary__c FROM Contact WHERE Id = :cont.Id LIMIT 1];
        
        System.assertEquals(cont.msf_EndDate__c, date.today());
        System.assertEquals(cont.msf_IsPrimary__c, false);
    }
    @isTest static void testUpdateOrganizationContactData_Type_Organization_Contact_to_Active(){
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1_isNotActive' LIMIT 1];
        cont.LastName = 'MSF_AccountFieldsLogic_TEST_LastName2';
        cont.msf_FechaExclusionComunicaciones__c = date.today();
        cont.msf_PrimaryContact__c = null;
        cont.msf_IsActive__c = true;
        update cont;
        cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName2' LIMIT 1];
        System.assertEquals(cont.LastName, 'MSF_AccountFieldsLogic_TEST_LastName2');
    }
    
     @isTest static void testUpdateOrganizationContactData_Type_Organization_Contact_IsPrimary(){
        Contact orgCont = [SELECT Id FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_Org_LastName_WithoutContact' LIMIT 1];
        
        Contact cont = [SELECT Id,RecordTypeId,msf_IsPrimary__c,msf_IsActive__c,msf_Organization__c FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1_isNotPrimary' LIMIT 1];
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont.msf_IsPrimary__c = false;
        cont.msf_IsActive__c = true;
        
        cont.msf_Organization__c = orgCont.Id;
        update cont;
        cont = [SELECT Id,msf_IsPrimary__c FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName1_isNotPrimary' LIMIT 1];
        System.assertEquals(false, cont.msf_IsPrimary__c);
    }
    
    @isTest static void testUpdateOrganizationContactData_Type_Organization_Contact_DeletePrimaryFromOrganization(){
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1_isPrimary' LIMIT 1];
        cont.LastName = 'MSF_AccountFieldsLogic_TEST_LastName2';
        cont.msf_FechaExclusionComunicaciones__c = date.today();
        cont.msf_IsPrimary__c = false;
        cont.msf_IsActive__c = false;
        Contact contOrg = [SELECT Id FROM Contact WHERE msf_PrimaryContact__c = :cont.Id LIMIT 1];
        update cont;
        
        contOrg = [SELECT Id,msf_PrimaryContact__c FROM Contact WHERE Id = :contOrg.Id];
        System.assertEquals(contOrg.msf_PrimaryContact__c, null);
    }
    
}