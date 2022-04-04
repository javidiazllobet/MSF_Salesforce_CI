/**
* @author 		Omega CRM
* @date 		11-2021
* @group 		Contacts
* @description	test class for the MSF_ModifyLevelEconomico_TDTM class.
*/
@isTest
global with sharing class MSF_ModifyLevelEconomico_TEST {
    @TestSetup
    static void testSetup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'MSF_ModifyLevelEconomico_TDTM',
            npsp__Class__c = 'MSF_ModifyLevelEconomico_TDTM',
            npsp__Object__c = 'Contact',
            npsp__Trigger_Action__c = 'BeforeUpdate;BeforeInsert',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = false,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 

        List<npsp__Level__c> listLevel = new List<npsp__Level__c>();
        listLevel.add(new npsp__Level__c(
        	Name='One to few+',
            npsp__Target__c	= 'Contact',
            npsp__Level_Field__c='MSF_LevelFieldsChanges_TEST_Contact_Level_Field',
            npsp__Source_Field__c='MSF_LevelFieldsChanges_TEST_Contact_Level_Source_Field'
        ));

        listLevel.add(new npsp__Level__c(
        	Name='One to one',
            npsp__Target__c	= 'Contact',
            npsp__Level_Field__c='MSF_LevelFieldsChanges_TEST_Contact_Level_Field',
            npsp__Source_Field__c='MSF_LevelFieldsChanges_TEST_Contact_Level_Source_Field'
        ));
        insert listLevel;

        Campaign c = new Campaign(Name = 'Captación 2018', msf_IsOnline__c = 'Si', msf_Objective__c = 'Desconocido', msf_OwnBy__c = 'Digital',
        msf_Segment__c = 'Organizaciones', msf_Thematic__c = '91');
        insert c;

        Contact individualContact = new Contact();
        individualContact.LastName = 'Test IndividualContact 1';
        individualContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();
        individualContact.msf_OrganizationType__c = 'Company';
        individualContact.LeadSource = 'Cupón';
        individualContact.msf_EntryCampaign__c = c.Id;
        individualContact.msf_RelationshipLevel__c = listLevel[1].Id;
        individualContact.msf_Forced__c = '121';
        insert individualContact;

        Contact individualContact2 = new Contact();
        individualContact2.LastName = 'Test IndividualContact 2';
        individualContact2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();
        individualContact2.msf_OrganizationType__c = 'Company';
        individualContact2.LeadSource = 'Cupón';
        individualContact2.msf_EntryCampaign__c = c.Id;
        individualContact2.msf_RelationshipLevel__c = listLevel[0].Id;
        individualContact2.msf_Forced__c = '12Few';
        insert individualContact2;

    }

    @isTest
    static void modifyLevelEconomicoTest(){
        Id idLevel = [SELECT Id FROM npsp__Level__c WHERE name = 'One to one'].Id;
        Contact individualContact =  [SELECT Id, msf_Forced__c FROM Contact LIMIT 1];
        individualContact.msf_Forced__c = '121';

        test.startTest();
        update individualContact;
        test.stopTest();

        Contact individualContactTest =  [SELECT Id, msf_RelationshipLevel__c FROM Contact LIMIT 1];
        system.assertEquals(idLevel, individualContactTest.msf_RelationshipLevel__c);
    }

    @isTest
    static void modifyLevelEconomico2Test(){
        Id idLevel = [SELECT Id FROM npsp__Level__c WHERE name = 'One to few+'].Id;
        Contact individualContact =  [SELECT Id, msf_Forced__c FROM Contact LIMIT 1];
        individualContact.msf_Forced__c = '12Few';

        test.startTest();
        update individualContact;
        test.stopTest();

        Contact individualContactTest =  [SELECT Id, msf_RelationshipLevel__c FROM Contact LIMIT 1];
        system.assertEquals(idLevel, individualContactTest.msf_RelationshipLevel__c);
    }
}