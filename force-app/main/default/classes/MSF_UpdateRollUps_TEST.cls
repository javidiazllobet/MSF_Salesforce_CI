@isTest
private class MSF_UpdateRollUps_TEST {

    @testSetup static void setup(){
        
        Contact c = new Contact(LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1', msf_BeginDateMSF__c=date.today());
        insert c; 
        
        Campaign camp1 = new Campaign(Name='CampaignRatingOppTemplado',msf_FinalCampaign__c = false, msf_BetterNowExternalId__c = 'TEST01Rating', msf_CustomExternalId__c = 'TEST02Rating');
        insert camp1;
        
        Id oppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        
        //Opportunities
        Opportunity o = new Opportunity (
            Name ='RatingOpportunity1',
            RecordTypeId = oppRT,
            CampaignId = camp1.Id,
            LeadSource = 'Cupón',
            CloseDate = date.today(),
            Type= 'One off Donation',
            npsp__Primary_Contact__c = c.Id,
            Amount = 10,
            StageName='Cobrada',
            npsp4hub__Payment_Method__c = 'EFECTIVO S.C.',
            npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA',
            npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA'
        );
        insert o; 
        
    }
    
    
    @isTest static void testRollUpsContact() {
        Test.startTest();
        MSF_UpdateRollUpsContact_BATCH mta = new MSF_UpdateRollUpsContact_BATCH();
        Id batchId = Database.executeBatch(mta);
        Test.stopTest();
    }
    
    @isTest static void testRollUpsAccount() {
        Test.startTest();
        MSF_UpdateRollUpsAccount_BATCH mta = new MSF_UpdateRollUpsAccount_BATCH();
        Id batchId = Database.executeBatch(mta);
        Test.stopTest();
    }
}