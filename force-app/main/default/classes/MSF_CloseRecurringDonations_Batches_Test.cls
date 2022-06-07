/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : sheredia@omegacrmconsulting.com
**/
@isTest
public with sharing class MSF_CloseRecurringDonations_Batches_Test {

    @TestSetup
    static void makeData(){
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestOpportunitiesFieldsLogic',
            npsp__Class__c = 'MSF_OpportunitiesFieldsLogic_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 6,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
               
        Id idRDAssc = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Associate').getRecordTypeId();
        Id IdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        List<npe03__Recurring_Donation__c> lRecDon = new List<npe03__Recurring_Donation__c>();
        List<Contact> lcon = new List<Contact>();
        List<cpm__Payment_Profile__c> lppInsert = new List<cpm__Payment_Profile__c>();
        Map<String,Schema.RecordTypeInfo> mRtPaymentProfileInfo = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName();
        
        //Campaign
        Campaign c = new Campaign(Name='MSFOpportunitiesFieldsLogicTESTName1', msf_FinalCampaign__c = false, msf_BetterNowExternalId__c = 'TEST01OFL', msf_CustomExternalId__c = 'TEST02OFL');
        insert c;
        Campaign camp1 = new Campaign(Name='CampaignRatingOppTemplado',msf_FinalCampaign__c = false, msf_BetterNowExternalId__c = 'TEST01Rating', msf_CustomExternalId__c = 'TEST02Rating');
        insert camp1;
        
        //Recurring Donation
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c(
            Name='MSF_OpportunitiesFieldsLogic_TEST_Name1',
            npsp4hub__Payment_Method__c = 'Direct Debit',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
        );
        lRecDon.add(recDon);
        
        npe03__Recurring_Donation__c recDon2 = new npe03__Recurring_Donation__c(
            Name='MSF_OpportunitiesFieldsLogic_TEST_Name2',
            RecordTypeId=idRDAssc,
            npsp4hub__Payment_Method__c = 'Direct Debit',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
        );
        lRecDon.add(recDon2);        
        insert lRecDon;
        
        //Contacts
        lcon.add(new Contact(LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1', msf_BeginDateMSF__c=date.today()));
        lcon.add(new Contact(LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2',msf_BeginDateMSF__c=date.today()));
        lcon.add(new Contact(LastName='contact1',msf_BeginDateMSF__c=date.today().addMonths(-2)));
        insert lcon;                   

    }

    @isTest static void testBatch01AsBatch() {
        ID donationID = [SELECT ID FROM npe03__Recurring_Donation__c LIMIT 1].ID;

        try{
            Test.startTest();
            Id batchJobId = Database.executeBatch(new MSF_CloseRecurringDonations_01_BATCH(new Set<ID>{donationID}), 10);
            Test.stopTest();
        }catch(Exception e){
            System.assert(false, 'Error: ' + e);
        }
    }

    @isTest static void testBatch01AsSchedule() {
        ID donationID = [SELECT ID FROM npe03__Recurring_Donation__c LIMIT 1].ID;
        MSF_CloseRecurringDonations_01_BATCH schedule = new MSF_CloseRecurringDonations_01_BATCH(new Set<ID>{donationID});
        String sch = '0 0 8 13 2 ?';

        try {
            Test.startTest();
            System.schedule('Schedule Test', sch, schedule);
            Test.stopTest();
        }catch (Exception e) {
            System.assert(false, 'Error: ' + e);
        }

    }

}