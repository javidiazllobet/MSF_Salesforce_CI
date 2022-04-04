/**
* @author 		Deloitte
* @date 		03-2019
* @group 		Recurring donation.
* @description	test class for the MSF_RecurringDonation_TDTM class.
*/
@isTest
private class MSF_RecurringDonation_TEST {
    
    @testSetup static void setup(){
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestRecurringDonation',
            npsp__Class__c = 'MSF_RecurringDonation_TDTM',
            npsp__Object__c = 'npe03__Recurring_Donation__c',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        
        List<msf_LeadSourceMasterData__c> lLeadSourceMD = new List<msf_LeadSourceMasterData__c>();
        List<String> leadSource = leadSource1Desc();
        List<String> leadSource2 = leadSource2Desc();
        List<String> leadSource3 = leadSource3Desc();
        for(Integer x = 0; x < leadSource.size(); x ++){
            msf_LeadSourceMasterData__c data = new msf_LeadSourceMasterData__c(msf_LeadSource1__c = leadSource[x], 
                                                                               msf_LeadSource2__c = LeadSource2[math.mod(x, leadSource2.size())], 
                                                                               msf_LeadSource3__c = LeadSource3[math.mod(x, leadSource3.size())]);
            lLeadSourceMD.add(data);
        }
        insert lLeadSourceMD;
        
        List<Contact> lCon = new List<Contact>();
        lCon.add(new Contact(LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1'));
        lCon.add(new Contact(LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2'));
        insert lCon;
        
        Campaign camp = new Campaign(Name='MSFOpportunitiesFieldsLogicTESTName1',msf_FinalCampaign__c = false);
        insert camp;
        
        Contact con = [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2' LIMIT 1];
        
        List<npe03__Recurring_Donation__c> lRd = new List<npe03__Recurring_Donation__c>();
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1Update',
                                                                          npe03__Open_Ended_Status__c = 'Open',
                                                                          npe03__Installment_Period__c = 'Monthly',
                                                                          npe03__Amount__c  = 100, 
                                                                          npsp4hub__Payment_Method__c = 'Direct Debit',
                                                                          npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                                                                          npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
                                                                          );
        
        npe03__Recurring_Donation__c rd2 = new npe03__Recurring_Donation__c(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName2Contact',
                                                                          npe03__Open_Ended_Status__c = 'Open',
                                                                          npe03__Contact__c=con.Id,
                                                                          npe03__Installment_Period__c = 'Monthly',
                                                                          npe03__Amount__c  = 100,
                                                                          npsp4hub__Payment_Method__c = 'Direct Debit',
                                                                          npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                                                                          npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA');
		lRd.add(rd);
		lRd.add(rd2);
        insert lRd;
    }
    
    @isTest static void insertLeadSourceDependencies(){
        Contact con = [SELECT Id,msf_BeginDateMSF__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1];
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1',
                                                                           msf_LeadSource1__c = leadSource1Desc()[0], 
                                                                           npe03__Contact__c = con.Id,
                                                                          npsp4hub__Payment_Method__c = 'Direct Debit',
                                                                          npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                                                                          npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA' 
                                                                          );
        insert rd;
        
        rd = [SELECT msf_LeadSource2__c, msf_LeadSource3__c FROM npe03__Recurring_Donation__c WHERE Id = :rd.Id LIMIT 1];        
        System.assertNotEquals(null, rd.msf_LeadSource2__c, 'Result is not null for msf_LeadSource2__c');
        System.assertNotEquals(null, rd.msf_LeadSource3__c, 'Result is not null for msf_LeadSource3__c');
    }
    
  	@isTest static void insertSetContactFieldsRDOpen(){
        Contact con = [SELECT Id,msf_BeginDateMSF__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1];
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1',
                                                                           npe03__Contact__c = con.Id,
                                                                          npsp4hub__Payment_Method__c = 'Direct Debit',
                                                                          npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                                                                          npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA');
        insert rd;
        rd = [SELECT Id, npe03__Date_Established__c ,
              msf_AnnualizedQuota__c,
              npe03__Recurring_Donation_Campaign__c,
              msf_LeadSource1__c,
              npe03__Last_Payment_Date__c,
              msf_CancelationDate__c
              FROM npe03__Recurring_Donation__c WHERE Id = :rd.Id LIMIT 1];
        
        con = [SELECT Id, msf_BeginDateMSF__c, 
               msf_FirstEntryDateRecurringDonor__c, 
               msf_FirstAnnualizedQuota__c,
               msf_FirstCampaignEntryRecurringDonor__c, 
               msf_FirstCampaignRecurringDonorChannel__c,
               msf_EntryDateCurrentRecurringDonor__c, 
               msf_DateFirstRecurringDonorQuota__c,
               msf_DateLastRecurringDonorQuota__c,
               msf_LastAnnualizedQuota__c, 
               msf_LastRecurringDonationDate__c
               FROM Contact WHERE Id=:con.Id LIMIT 1];   

        
        System.assertEquals(con.msf_BeginDateMSF__c, rd.npe03__Date_Established__c);
        System.assertEquals(con.msf_FirstEntryDateRecurringDonor__c, rd.npe03__Date_Established__c);
        System.assertEquals(con.msf_FirstAnnualizedQuota__c, rd.msf_AnnualizedQuota__c);
        System.assertEquals(con.msf_FirstCampaignEntryRecurringDonor__c, rd.npe03__Recurring_Donation_Campaign__c);
        System.assertEquals(con.msf_FirstCampaignRecurringDonorChannel__c, rd.msf_LeadSource1__c);
        System.assertEquals(con.msf_EntryDateCurrentRecurringDonor__c, rd.npe03__Date_Established__c);
        System.assertEquals(con.msf_DateFirstRecurringDonorQuota__c, rd.npe03__Last_Payment_Date__c);
        System.assertEquals(con.msf_DateLastRecurringDonorQuota__c, rd.npe03__Last_Payment_Date__c);
        System.assertEquals(con.msf_LastAnnualizedQuota__c, rd.msf_AnnualizedQuota__c);
        System.assertEquals(con.msf_LastRecurringDonationDate__c, rd.msf_CancelationDate__c);
        System.assertEquals(con.msf_FirstAnnualizedQuota__c, rd.msf_AnnualizedQuota__c);
    }
    @isTest static void insertSetContactFieldsRDClosed(){
        Contact con = [SELECT Id,msf_BeginDateMSF__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1];
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1',
                                                                           npe03__Open_Ended_Status__c='Closed',
                                                                           msf_CancelationReason__c ='Unpaid',
                                                                           npe03__Contact__c = con.Id);
        insert rd;
        rd = [SELECT Id, msf_CancelationDate__c,
              msf_AnnualizedQuota__c,
              npe03__Recurring_Donation_Campaign__c,
              msf_LeadSource1__c
              FROM npe03__Recurring_Donation__c WHERE Id = :rd.Id LIMIT 1];
        
        con = [SELECT Id, msf_LastRecurringDonationDate__c,
               msf_FirstAnnualizedQuota__c,
               msf_FirstCampaignEntryRecurringDonor__c,
               msf_FirstCampaignRecurringDonorChannel__c
               FROM Contact WHERE Id=:con.Id LIMIT 1];   
        
        
        System.assertEquals(con.msf_LastRecurringDonationDate__c, rd.msf_CancelationDate__c);
        System.assertEquals(con.msf_FirstAnnualizedQuota__c, rd.msf_AnnualizedQuota__c);
        System.assertEquals(con.msf_FirstCampaignEntryRecurringDonor__c, rd.npe03__Recurring_Donation_Campaign__c);
        System.assertEquals(con.msf_FirstCampaignRecurringDonorChannel__c, rd.msf_LeadSource1__c);
        
    }
    @isTest static void insertCurrentCampaign(){ 
        Contact con = [SELECT Id,msf_BeginDateMSF__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1];
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1',
                                                                           msf_LeadSource1__c = leadSource1Desc()[0],
                                                                           npe03__Contact__c = con.Id,
                                                                          npsp4hub__Payment_Method__c = 'Direct Debit',
                                                                          npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                                                                          npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA',
                                                                           npe03__Recurring_Donation_Campaign__c = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id);
        insert rd;
        rd = [SELECT msf_CurrentCampaign__c, npe03__Recurring_Donation_Campaign__c
              FROM npe03__Recurring_Donation__c WHERE Id = :rd.Id LIMIT 1];        
        System.assertEquals(rd.msf_CurrentCampaign__c, rd.npe03__Recurring_Donation_Campaign__c);
    }
    /*@isTest static void inserAllowNewRDError(){ 
        try{
            npe03__Recurring_Donation__c rd = [SELECT Id, npe03__Contact__c
                                               FROM npe03__Recurring_Donation__c
                                               WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_insertLeadSourceDependencies_LastName2_Contact' LIMIT 1];
            Contact con = [SELECT Id, msf_RecalculateMemberType__c FROM Contact WHERE Id = :rd.npe03__Contact__c LIMIT 1];
            rd = new npe03__Recurring_Donation__c(Name='MSF_OpportunitiesFieldsLogic_TEST_insertLeadSourceDependencies_LastName1',
                                                                               npe03__Open_Ended_Status__c = 'Open',
                                                                               RecordTypeId=Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Recurring_donation').getRecordTypeId(),
                                                                              npe03__Contact__c = con.Id);
            insert rd;
        	System.assert(false, 'ERROR: It should not create 2 Recurring Donations for the same donor');
        }catch(DmlException ex){
            System.assert(true);
        }
    }*/
    @isTest static void updateCloseEndStatusRecurringDonation(){
        npe03__Recurring_Donation__c rd = [SELECT Id, npe03__Open_Ended_Status__c ,
                                           msf_CancelationDate__c
                                           FROM npe03__Recurring_Donation__c 
                                           WHERE Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1Update' LIMIT 1];

        rd.msf_CancelationReason__c ='Unpaid';
        rd.npe03__Open_Ended_Status__c = 'Closed';
        update rd;
        rd = [SELECT msf_CancelationDate__c
              FROM npe03__Recurring_Donation__c 
              WHERE Id=:rd.Id LIMIT 1];
        System.assertEquals(Date.today(),rd.msf_CancelationDate__c);
    }
    @isTest static void updateSetContactFieldsRDClosedMoreAmount(){
        Contact con = [SELECT Id,msf_BeginDateMSF__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1];
        npe03__Recurring_Donation__c rd = [SELECT Id,npe03__Amount__c,msf_AnnualizedQuota__c FROM npe03__Recurring_Donation__c
                                           WHERE Name = 'MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1Update' LIMIT 1];

        Double oldAmount = rd.npe03__Amount__c;
        Double oldAnnualizedQuota = rd.msf_AnnualizedQuota__c;
        rd.npe03__Amount__c  = rd.npe03__Amount__c + 50;
        
        update rd;
        rd = [SELECT Id, msf_CancelationDate__c,
              msf_AnnualizedQuota__c,
              npe03__Amount__c,
              npe03__Recurring_Donation_Campaign__c,
              msf_LeadSource1__c
              FROM npe03__Recurring_Donation__c WHERE Id = :rd.Id LIMIT 1];
        
        msf_QuotaModification__c quotaMod = [SELECT Id, msf_ChangeType__c, msf_ChangeAnnualizedQuota__c, msf_ChangeAmount__c
                                             FROM msf_QuotaModification__c WHERE NAME like 'A - %' ORDER BY NAME DESC LIMIT 1];

        System.assertEquals('Increase', quotaMod.msf_ChangeType__c);
        System.assertEquals((rd.msf_AnnualizedQuota__c - oldAnnualizedQuota), quotaMod.msf_ChangeAnnualizedQuota__c, quotaMod);
        System.assertEquals((rd.npe03__Amount__c - oldAmount), quotaMod.msf_ChangeAmount__c);
        
    }
    @isTest static void updateSetContactFieldsRDClosedLessAmount(){
        Contact con = [SELECT Id,msf_BeginDateMSF__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1];
        npe03__Recurring_Donation__c rd = [SELECT Id,npe03__Amount__c,msf_AnnualizedQuota__c FROM npe03__Recurring_Donation__c
                                           WHERE Name = 'MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1Update' LIMIT 1];

        Double oldAmount = rd.npe03__Amount__c;
        Double oldAnnualizedQuota = rd.msf_AnnualizedQuota__c;
        rd.npe03__Amount__c  = rd.npe03__Amount__c - 50;
        
        update rd;
        rd = [SELECT Id, msf_CancelationDate__c,
              msf_AnnualizedQuota__c,
              npe03__Amount__c,
              npe03__Recurring_Donation_Campaign__c,
              msf_LeadSource1__c
              FROM npe03__Recurring_Donation__c WHERE Id = :rd.Id LIMIT 1];
        
        msf_QuotaModification__c quotaMod = [SELECT Id, msf_ChangeType__c, msf_ChangeAnnualizedQuota__c, msf_ChangeAmount__c
                                             FROM msf_QuotaModification__c WHERE NAME like 'D - %' ORDER BY NAME DESC LIMIT 1];

        System.assertEquals('Decrease', quotaMod.msf_ChangeType__c);
        System.assertEquals((oldAnnualizedQuota - rd.msf_AnnualizedQuota__c), quotaMod.msf_ChangeAnnualizedQuota__c, quotaMod);
        System.assertEquals((oldAmount - rd.npe03__Amount__c), quotaMod.msf_ChangeAmount__c);
        
    }
    @isTest static void updateOtherEndStatusRecurringDonation(){
        npe03__Recurring_Donation__c rd = [SELECT Id, npe03__Open_Ended_Status__c,
                                           msf_CancelationDate__c,msf_CancelationReason__c
                                           FROM npe03__Recurring_Donation__c 
                                           WHERE Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1Update' LIMIT 1];
        rd.npe03__Open_Ended_Status__c = 'Other';
        update rd;
        System.assertEquals(null, rd.msf_CancelationDate__c);
        System.assertEquals(null, rd.msf_CancelationReason__c);
    }
    
    
    @isTest static void updateDeceasedRecurringDonation(){
        npe03__Recurring_Donation__c rd = [SELECT Id, MSF_CancelationReason__c, npe03__Contact__c
                                           FROM npe03__Recurring_Donation__c 
                                           WHERE Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName2Contact' LIMIT 1];
        rd.MSF_CancelationReason__c = 'Deceased';
        rd.npe03__Open_Ended_Status__c = 'Closed';
        update rd;
        Contact con = [SELECT Id,npsp__Deceased__c,msf_ContactDeleteReason__c FROM Contact WHERE Id = :rd.npe03__Contact__c LIMIT 1];
        System.assertEquals('Deceased', rd.MSF_CancelationReason__c);
        System.assert(con.npsp__Deceased__c, 'Checkbox Deceased is false / has not been marked');
        System.assertEquals(rd.MSF_CancelationReason__c, con.msf_ContactDeleteReason__c, 'Delete reason is not Deceased');
    }
    @isTest static void deleteStatusRecurringDonation(){
        npe03__Recurring_Donation__c rd = [SELECT Id, npe03__Contact__c
                                           FROM npe03__Recurring_Donation__c
                                           WHERE Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName2Contact' LIMIT 1];
       	delete rd;
        Contact con = [SELECT msf_RecalculateMemberType__c FROM Contact WHERE Id = :rd.npe03__Contact__c LIMIT 1];
        System.assertEquals(TRUE,con.msf_RecalculateMemberType__c);
    }
    //Private methods
    static Integer s_num = 1;
    private static String getFakeId(Schema.SObjectType sot){
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + 
            '0'.repeat(12-result.length()) + result;
    }
    private static List<String> leadSource1Desc(){
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.msf_LeadSource1__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    private static List<String> leadSource2Desc(){
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.msf_LeadSource2__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    private static List<String> leadSource3Desc(){
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.msf_LeadSource3__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
}