/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 02-23-2022
 * @last modified by  : sheredia@omegacrmconsulting.com
**/
@istest
public with sharing class ConvertLeadToContactTest {
   
    @TestSetup
    static void makeData(){
        Lead lead = new Lead(LastName = 'Lead Test', Company = 'Company Test', msf_EntryCampaign__c = (new Campaign(Name = 'Campaña Test')).Id ) ;
        insert lead;
        
        Contact con = new Contact(LastName = 'Contact Test');
        insert con;

        Opportunity opp = new Opportunity(Name = 'Opportunity Test', 
            RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Donation'].Id,
            msf_LeadId__c = lead.Id,
            StageName = 'Propuesta',
            CloseDate = System.today() + 7,
            npsp__Primary_Contact__c = null
            );

        insert opp;
    }
    
    @istest static void testConvertLeadAfterConvert(){
        Database.LeadConvert convertData = new database.LeadConvert();
        convertData.setLeadId([SELECT ID FROM Lead WHERE LastName = 'Lead Test'].Id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        convertData.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult convertDataResult = Database.convertLead(convertData);
        
        Test.startTest();
        ConvertLeadToContact.afterConvert(convertDataResult, NULL);
        Test.stopTest();
        
        Opportunity opp = [SELECT ID, npsp__Primary_Contact__c, msf_LeadId__c FROM Opportunity WHERE NAME = 'Opportunity Test' LIMIT 1];

        System.assert( convertDataResult.getContactId() != null, 'Debe crearse un contact a partir de un lead');
        System.assert( opp.npsp__Primary_Contact__c == convertDataResult.getContactId(), 'La opportunidad debe de asociarse al contacto, pero no se ha hecho');
        System.assert( opp.msf_LeadId__c == null, 'La opportunidad no debe estar al lead, pero lo está');

    }
    
}