/**
* @author 		Omega CRM
* @date 		11-2021
* @group 		Contacts
* @description	test class for the MSF_CopyLevelAndProgramContact_TDTM class.
*/
@isTest
public class MSF_CopyLevelAndProgramContact_TEST {
    @TestSetup
    static void testSetup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestLevelFieldChanges',
            npsp__Class__c = 'MSF_CopyLevelAndProgramContact_TDTM',
            npsp__Object__c = 'Contact',
            npsp__Trigger_Action__c = 'BeforeUpdate, BeforeInsert, AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = false,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 

        List<npsp__Level__c> listLevel = new List<npsp__Level__c>();
        listLevel.add(new npsp__Level__c(
        	Name='MSF_LevelFieldsChanges_TEST_Contact_Level_Name',
            npsp__Target__c	= 'Contact',
            npsp__Level_Field__c='MSF_LevelFieldsChanges_TEST_Contact_Level_Field',
            npsp__Source_Field__c='MSF_LevelFieldsChanges_TEST_Contact_Level_Source_Field'
        ));
        insert listLevel;

        Campaign c = new Campaign(Name = 'Captación 2018', msf_IsOnline__c = 'Si', msf_Objective__c = 'Desconocido', msf_OwnBy__c = 'Digital',
        msf_Segment__c = 'Organizaciones', msf_Thematic__c = '91');
        insert c;

        Contact Organization = new Contact();
        Organization.LastName = 'Test Organization 1';
        Organization.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Organization.msf_OrganizationType__c = 'Company';
        Organization.LeadSource = 'Cupón';
        Organization.msf_EntryCampaign__c = c.Id;
        Organization.msf_RelationshipLevel__c = listLevel[0].Id;
        Organization.msf_Program__c = 'Vehículo donación de Gran Donante = YES';
        insert Organization;

        Contact Organization2 = new Contact();
        Organization2.LastName = 'Test Organization 2';
        Organization2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Organization2.msf_OrganizationType__c = 'Company';
        Organization2.LeadSource = 'Cupón';
        Organization2.msf_EntryCampaign__c = c.Id;
        Organization2.msf_RelationshipLevel__c = listLevel[0].Id;
        Organization2.msf_Program__c = 'Prospectos Empresas & Colectivos Mass';
        insert Organization2;

    }

    @isTest 
    static void copyLevelAndProgramContactTest1 (){
        Contact organization = [SELECT id FROM Contact WHERE LastName = 'Test Organization 1' LIMIT 1];
        Campaign campanha = [SELECT id FROM Campaign WHERE name = 'Captación 2018'];
        Contact OrganizationContact = new Contact();
        OrganizationContact.LastName = 'Test OrganizationContact 2';
        OrganizationContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        OrganizationContact.msf_OrganizationType__c = 'Company';
        OrganizationContact.LeadSource = 'Cupón';
        OrganizationContact.msf_EntryCampaign__c = campanha.Id;
        OrganizationContact.msf_Organization__c = organization.Id;

        test.startTest();
        insert OrganizationContact;
        test.stopTest();

        Contact OrganizationContacto = [SELECT id, msf_Program__c FROM Contact WHERE LastName = 'Test OrganizationContact 2' LIMIT 1];
        system.assertEquals('Vehículo donación de Gran Donante = YES', OrganizationContacto.msf_Program__c);
    }

    @isTest 
    static void copyLevelAndProgramContactTest2 (){
        Contact organization = [SELECT id FROM Contact WHERE LastName = 'Test Organization 1' LIMIT 1];
        Campaign campanha = [SELECT id FROM Campaign WHERE name = 'Captación 2018'];
        Contact OrganizationContact = new Contact();
        OrganizationContact.LastName = 'Test OrganizationContact 2';
        OrganizationContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        OrganizationContact.msf_OrganizationType__c = 'Company';
        OrganizationContact.LeadSource = 'Cupón';
        OrganizationContact.msf_EntryCampaign__c = campanha.Id;
        OrganizationContact.msf_Organization__c = organization.Id;
        insert OrganizationContact;

        Contact organization2 = [SELECT id FROM Contact WHERE LastName = 'Test Organization 2' LIMIT 1];
        OrganizationContact.msf_Organization__c = organization2.Id;

        test.startTest();
        update OrganizationContact;
        test.stopTest();

        Contact OrganizationContacto = [SELECT id, msf_Program__c FROM Contact WHERE LastName = 'Test OrganizationContact 2' LIMIT 1];
        system.assertEquals('Prospectos Empresas & Colectivos Mass', OrganizationContacto.msf_Program__c);
    }

    @isTest 
    static void copyLevelAndProgramContactTest3 (){
        Contact organization = [SELECT id FROM Contact WHERE LastName = 'Test Organization 1' LIMIT 1];
        Campaign campanha = [SELECT id FROM Campaign WHERE name = 'Captación 2018'];
        Contact OrganizationContact = new Contact();
        OrganizationContact.LastName = 'Test OrganizationContact 2';
        OrganizationContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        OrganizationContact.msf_OrganizationType__c = 'Company';
        OrganizationContact.LeadSource = 'Cupón';
        OrganizationContact.msf_EntryCampaign__c = campanha.Id;
        OrganizationContact.msf_Organization__c = organization.Id;
        insert OrganizationContact;

        Contact organizationTest1 = [SELECT id, msf_Program__c FROM Contact WHERE LastName = 'Test Organization 1' LIMIT 1];
        organizationTest1.msf_Program__c = 'Prospectos Empresas & Colectivos Mass';

        test.startTest();
        update organizationTest1;
        test.stopTest();

        Contact OrganizationContacto = [SELECT id, msf_Program__c FROM Contact WHERE LastName = 'Test OrganizationContact 2' LIMIT 1];
        system.assertEquals('Prospectos Empresas & Colectivos Mass', OrganizationContacto.msf_Program__c);
    }

    @isTest 
    static void copyLevelAndProgramContactTestBulk (){
        List<Contact> listContact =  new List<Contact>();
        Contact organization = [SELECT id FROM Contact WHERE LastName = 'Test Organization 1' LIMIT 1];
        Contact organization2 = [SELECT id FROM Contact WHERE LastName = 'Test Organization 2' LIMIT 1];
        Campaign campanha = [SELECT id FROM Campaign WHERE name = 'Captación 2018'];
        Contact OrganizationContact = new Contact();
        OrganizationContact.LastName = 'Test OrganizationContact 1';
        OrganizationContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        OrganizationContact.msf_OrganizationType__c = 'Company';
        OrganizationContact.LeadSource = 'Cupón';
        OrganizationContact.msf_EntryCampaign__c = campanha.Id;
        OrganizationContact.msf_Organization__c = organization.Id;

        Contact OrganizationContact2 = new Contact();
        OrganizationContact2.LastName = 'Test OrganizationContact 2';
        OrganizationContact2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        OrganizationContact2.msf_OrganizationType__c = 'Company';
        OrganizationContact2.LeadSource = 'Cupón';
        OrganizationContact2.msf_EntryCampaign__c = campanha.Id;
        OrganizationContact2.msf_Organization__c = organization2.Id;

        Contact OrganizationContact3 = new Contact();
        OrganizationContact3.LastName = 'Test OrganizationContact 3';
        OrganizationContact3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        OrganizationContact3.msf_OrganizationType__c = 'Company';
        OrganizationContact3.LeadSource = 'Cupón';
        OrganizationContact3.msf_EntryCampaign__c = campanha.Id;
        OrganizationContact3.msf_Organization__c = organization.Id;

        listContact.add(OrganizationContact);
        listContact.add(OrganizationContact2);
        listContact.add(OrganizationContact3);

        test.startTest();
        insert listContact;
        test.stopTest();

        Contact OrganizationContacto = [SELECT id, msf_Program__c FROM Contact WHERE LastName = 'Test OrganizationContact 1' LIMIT 1];
        Contact OrganizationContacto2 = [SELECT id, msf_Program__c FROM Contact WHERE LastName = 'Test OrganizationContact 2' LIMIT 1];
        Contact OrganizationContacto3 = [SELECT id, msf_Program__c FROM Contact WHERE LastName = 'Test OrganizationContact 3' LIMIT 1];
        system.assertEquals('Vehículo donación de Gran Donante = YES', OrganizationContacto.msf_Program__c);
        system.assertEquals('Prospectos Empresas & Colectivos Mass', OrganizationContacto2.msf_Program__c);
        system.assertEquals('Vehículo donación de Gran Donante = YES', OrganizationContacto3.msf_Program__c);
    }

}