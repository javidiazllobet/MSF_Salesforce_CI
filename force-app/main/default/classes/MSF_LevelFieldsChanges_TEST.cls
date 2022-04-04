/**
* @author       Deloitte
* @date         01-2019
* @group        Contact
* @description  test class for the MSF_LevelFieldsChanges_TDTM class.
*/
@isTest
public class MSF_LevelFieldsChanges_TEST {
    
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestLevelFieldChanges',
            npsp__Class__c = 'MSF_LevelFieldsChanges_TDTM',
            npsp__Object__c = 'Contact',
            npsp__Trigger_Action__c = 'BeforeUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        //Initialize values
        List<Contact> listContactTest = new List<Contact>();
        Contact cont = new Contact(LastName = 'MSF_LevelFIelds_Changes_Test_LastName1');
        cont.msf_Forced__c = '121'; 
        cont.msf_PotentialAccordingOfficer__c = '121'; 
        cont.msf_IsStrategic__c = false; 
        cont.msf_ContactInformationSummary__c = 'ResumenDatos'; 
        cont.msf_PercomsSummary__c = 'ResumenDatos'; 
        cont.msf_RelationshipMidDonorsProgram__c = cont.msf_RelationshipMajorDonorsProgram__c = 'Mantenimiento'; 
        cont.msf_IsAssosiative__c = cont.msf_IsPublicPerson__c  = false;
        cont.msf_LevelHCLifetime__c = cont.msf_LevelHCLifetimeVD__c  = 0.01; 
        cont.msf_LevelHCNextFiscalYear__c = 0.01; 
        cont.msf_LevelHCCurrentFiscalYear__c = 0.01; 
        cont.msf_LevelHCOneFiscalYearAgo__c = 0.01;
        cont.msf_LevelHCTwoFiscalYearsAgo__c = 0.01; 
        cont.msf_LevelSCNextFiscalYear__c = 0.01; 
        cont.msf_LevelsCCurrentFiscalYear__c = 0.01; 
        cont.msf_LevelSCOneFiscalYearAgo__c = 0.01;
        cont.msf_LevelsCTwoFiscalYearsAgo__c = 0.01; 
        cont.msf_RecalculateLevel__c = false;
        listContactTest.add(cont);
        insert listContactTest;
        List<npsp__Level__c> listLevel = new List<npsp__Level__c>();
        listLevel.add(new npsp__Level__c(
        	Name='MSF_LevelFieldsChanges_TEST_Contact_Level_Name',
            npsp__Target__c	= 'Contact',
            npsp__Level_Field__c='MSF_LevelFieldsChanges_TEST_Contact_Level_Field',
            npsp__Source_Field__c='MSF_LevelFieldsChanges_TEST_Contact_Level_Source_Field'
        ));
        insert listLevel;
    }
    
    @isTest static void test_no_change(){
        Contact cont = [SELECT Id, FirstName FROM Contact Where LastName = 'MSF_LevelFIelds_Changes_Test_LastName1' LIMIT 1];
        cont.FirstName = 'Hello';
        update cont;
        cont = [SELECT Id, FirstName, msf_RecalculateLevel__c FROM Contact Where LastName = 'MSF_LevelFIelds_Changes_Test_LastName1' LIMIT 1];
        System.assert(!cont.msf_RecalculateLevel__c);
    }
    
    @isTest static void test_msf_Forced_c(){
        Contact cont = [SELECT Id, msf_Forced__c,msf_RecalculateLevel__c FROM Contact Where LastName = 'MSF_LevelFIelds_Changes_Test_LastName1' LIMIT 1];
        cont.msf_Forced__c = '12Few';
        update cont;
        cont = [SELECT Id, msf_Forced__c,msf_RecalculateLevel__c FROM Contact Where LastName = 'MSF_LevelFIelds_Changes_Test_LastName1' LIMIT 1];
        System.assert(cont.msf_RecalculateLevel__c);
    }
    
    @isTest static void test_LevelChange(){
        Contact cont = [SELECT Id, FirstName FROM Contact Where LastName = 'MSF_LevelFIelds_Changes_Test_LastName1' LIMIT 1];
        cont.msf_Level__c = [SELECT Id FROM npsp__Level__c 
                             WHERE Name='MSF_LevelFieldsChanges_TEST_Contact_Level_Name' LIMIT 1].Id;
        cont.msf_RelationshipLevel__c = [SELECT Id FROM npsp__Level__c 
                                         WHERE Name='MSF_LevelFieldsChanges_TEST_Contact_Level_Name' LIMIT 1].Id;
        update cont;
        cont = [SELECT msf_FechaCambioLevelEconomico__c FROM Contact Where Id = :cont.Id LIMIT 1];
        System.assertEquals(date.today(), cont.msf_FechaCambioLevelEconomico__c);
    }
    
    @isTest static void test_msf_LevelHCTwoFiscalYearsAgo_c(){
        Contact cont = [SELECT Id, msf_LevelHCTwoFiscalYearsAgo__c,msf_RecalculateLevel__c FROM Contact Where LastName = 'MSF_LevelFIelds_Changes_Test_LastName1' LIMIT 1];
        cont.msf_LevelHCTwoFiscalYearsAgo__c = 0.02;
        update cont;
        cont = [SELECT Id, msf_LevelHCTwoFiscalYearsAgo__c,msf_RecalculateLevel__c FROM Contact Where LastName = 'MSF_LevelFIelds_Changes_Test_LastName1' LIMIT 1];
        System.assert(cont.msf_RecalculateLevel__c);
    }
}