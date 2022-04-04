/**
* @author       Deloitte
* @date         01-2019
* @group        Account
* @description  test class for the MSF_AccountFieldsLogic_TDTM class.
*/
@isTest
private class MSF_AccountFieldsLogic_TEST {
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestAccountFieldLogic',
            npsp__Class__c = 'MSF_AccountFieldsLogic_TDTM',
            npsp__Object__c = 'Account',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );
        upsert thCon;
        //Initialize values
        Id IdOrgCont = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Contact cont = new Contact(LastName='MSF_AccountFieldsLogic_TEST_LastName1',RecordTypeId=IdOrgCont);
        insert cont;
        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_Name1',
                                  RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId());
        insert acc;
    }
    @isTest static void testInsertOrganizationAcc(){
        Id IdOrgRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId(); 
        Contact cont = [SELECT Id FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_InsertOrgAcct1',RecordTypeId=IdOrgRT);
        acc.npe01__One2OneContact__c=cont.Id;
        insert acc;
        acc = [SELECT Id,Name,npe01__One2OneContact__c FROM Account WHERE Name='CUENTA - MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        System.assertEquals(acc.npe01__One2OneContact__c,cont.Id);
    }
    @isTest static void testInsertOrganizationHHAcc(){
        Id IdHHRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId(); 
        Contact cont = [SELECT Id FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        Account acc = new Account(Name='MSF_AccountFieldsLogic_TEST_InsertHHAcc1',
                                  npe01__One2OneContact__c=cont.Id,
                                  RecordTypeId=IdHHRT
                                 );        
        insert acc;
        acc = [SELECT Id, Name FROM Account WHERE npe01__One2OneContact__c=:cont.Id LIMIT 1];
        System.assertEquals('MSF_AccountFieldsLogic_TEST_InsertHHAcc1',acc.Name);
    }
    @isTest static void testUpdateAcc(){
        Id IdHHRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId(); 
        Contact cont = [SELECT Id FROM Contact WHERE LastName='MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        Account acc = [SELECT Id, Name FROM Account WHERE Name='CUENTA - MSF_AccountFieldsLogic_TEST_Name1' LIMIT 1];
        
        acc.RecordTypeId = IdHHRT;
        acc.npe01__One2OneContact__c=cont.Id;
        update acc;
        acc = [SELECT Id,npe01__One2OneContact__c,type FROM Account WHERE Name = 'CUENTA - MSF_AccountFieldsLogic_TEST_LastName1' LIMIT 1];
        System.assertEquals('Company',acc.type);
    }
}