/**
* @author       Deloitte
* @date         01-2019
* @group        Contact.
* @description  Test class for the MSF_CreateOrganizationAccounts_TDTM class.
*/
@isTest
private class MSF_CreateOrganizationAccounts_TEST {
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestCreateOrganizationAccounts',
            npsp__Class__c = 'MSF_CreateOrganizationAccounts_TDTM',
            npsp__Object__c = 'Contact',
            npsp__Trigger_Action__c = 'BeforeUpdate;AfterDelete;AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 4,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        //Initialize values
        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_Name1');
        insert acc;

        Account acc2 = new Account(Name='MSF_AccountFieldsLogic_TEST_Name2');
        insert acc2;
        
        Contact cont = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName1');
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        cont.AccountId = acc.Id;
        
        insert cont;
        
        Contact cont2 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName1OC');
        cont2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        cont2.msf_Organization__c = cont.Id;
        insert cont2;
        
        Contact cont3 = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName2OC');
        cont3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        cont3.AccountId = acc2.Id;
        insert cont3;
        
        
        Opportunity opp = new Opportunity(npsp__Primary_Contact__c=cont.Id);
        opp.Name='testUpdateCreateOrganizationAccountsSetAccName1';
        opp.StageName='Propuesta';
        opp.CloseDate = date.today();
        
        insert opp;
                
    }
    @isTest static void testUpdateCreateOrganizationAccounts(){
        List<Contact> cont = [SELECT Id,LastName FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        cont[0].LastName='MSF_AccountFieldsLogic_TEST_LastName2';
        update cont;
        cont = [SELECT Id FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName2' LIMIT 1];
        System.assertNotEquals(0,cont.size());
    }
    
    @isTest static void testUpdateCreateOrganizationAccountsWithoutAcc(){
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        cont.LastName='MSF_AccountFieldsLogic_TEST_LastName2';
        cont.AccountId = null;
        update cont;
        cont = [SELECT Id, AccountId FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName2' LIMIT 1];
        System.assertNotEquals(null,cont.AccountId);
    }
    
    @isTest static void testUpdateCreateOrganizationAccountsSetAcc(){
        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_Name141');
        insert acc;
        acc = [SELECT Id FROM Account WHERE Name = 'MSF_AccountFieldsLogic_TEST_Name141'];
        
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        cont.LastName='MSF_AccountFieldsLogic_TEST_LastName2';
        cont.AccountId = acc.Id;
        update cont;
        
        cont = [SELECT Id, AccountId FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName2' LIMIT 1];
        System.assertNotEquals(cont.AccountId,null);
    }
    
    @isTest static void testUpdateCreateOrganizationAccountsMoveOpportunities(){
        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_Name141');
        insert acc;
        acc = [SELECT Id FROM Account WHERE Name = 'MSF_AccountFieldsLogic_TEST_Name141'];
        
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        cont.LastName='MSF_AccountFieldsLogic_TEST_LastName2';
        cont.AccountId = acc.Id;
                
        update cont;
        
        cont = [SELECT Id, AccountId FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName2' LIMIT 1];
        System.assertNotEquals(cont.AccountId,null);
    }
    
    @isTest static void testUpdateCreateOrganizationAccountsMoveContacts(){
        Contact contOrg = new Contact(LastName='MSF_AccountFieldsLogic_TEST_Name141');
        contOrg.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        insert contOrg;
        contOrg = [SELECT Id FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_Name141'];

        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_Name141');
        insert acc;
        acc = [SELECT Id FROM Account WHERE Name = 'MSF_AccountFieldsLogic_TEST_Name141'];
        
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName2OC' LIMIT 1];
        cont.LastName='MSF_AccountFieldsLogic_TEST_LastName2';
        cont.AccountId = acc.Id;
        cont.msf_Organization__c=contOrg.Id;
        
        Opportunity opp = new Opportunity(npsp__Primary_Contact__c=cont.Id);
        opp.Name='testUpdateCreateOrganizationAccountsSetAccName1';
        opp.StageName='Propuesta';
        opp.CloseDate = date.today();
        
        insert opp;
        
        update cont;
        
        cont = [SELECT Id, AccountId FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName2' LIMIT 1];
        System.assertNotEquals(cont.AccountId,null);
    }

    @isTest static void testDeleteCreateOrganizationContacts(){
        Contact cont = [SELECT Id, LastName FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        delete cont;
        List<Contact> result = [SELECT Id, LastName FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        System.assert(result.isEmpty(), 'Contact still exists');
    }
    
    @isTest static void testDeleteCreateOrganizationAccounts(){
        Contact cont = [SELECT Id,AccountId FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName2OC' LIMIT 1];
        delete cont;

        List<Contact> result = [SELECT Id, Name FROM Contact WHERE LastName = 'MSF_AccountFieldsLogic_TEST_LastName2OC' LIMIT 1];
        System.assert(result.isEmpty(), 'Contact still exists');
        
        List<Account> resultAcc = [SELECT Id FROM Account WHERE Name = 'MSF_AccountFieldsLogic_TEST_Name2' LIMIT 1];
        System.assert(resultAcc.isEmpty(), 'Account still exists');
    }
}