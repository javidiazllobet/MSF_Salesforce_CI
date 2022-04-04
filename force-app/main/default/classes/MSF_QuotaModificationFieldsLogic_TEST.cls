/**
* @author 		Deloitte
* @date 		03-2019
* @group 		Recurring donation.
* @description	test class for the MSF_QuotaModificationFieldsLogic_TDTM class.
*/
@isTest
private class MSF_QuotaModificationFieldsLogic_TEST {
    @testSetup static void setup(){
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestQuotaModificationFieldsLogic',
            npsp__Class__c = 'MSF_QuotaModificationFieldsLogic_TDTM',
            npsp__Object__c = 'msf_QuotaModification__c',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate',
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
        
        npe03__Recurring_Donation__c RecurringDonation = new npe03__Recurring_Donation__c(Name='MSFOpportunitiesFieldsLogicTESTLastName');
        RecurringDonation.npsp4hub__Payment_Method__c = 'Direct Debit';
        RecurringDonation.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        RecurringDonation.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        insert RecurringDonation;
        
        msf_QuotaModification__c quotaMod = new msf_QuotaModification__c(Name='MSFQuotaModificationFieldsLogicTESTName2');
        quotaMod.msf_RecurringDonation__c =  [SELECT Id FROM npe03__Recurring_Donation__c
                                              WHERE Name = 'MSFOpportunitiesFieldsLogicTESTLastName' LIMIT 1].Id;
        insert quotaMod;
        
        Campaign camp = new Campaign(Name='MSFQuotaModificationFieldsLogicTESTName1',msf_FinalCampaign__c = false);
        insert camp;
    }
    @isTest static void insertQuotaModificationFieldsLogic(){
        msf_QuotaModification__c quotaMod = new msf_QuotaModification__c(Name='MSFQuotaModificationFieldsLogicTESTName1',
                                                                         msf_CampaignInfluence__c = [SELECT Id FROM Campaign
                                                                                                     WHERE Name = 'MSFQuotaModificationFieldsLogicTESTName1' LIMIT 1].Id,
                                                                         msf_RecurringDonation__c = [SELECT Id FROM npe03__Recurring_Donation__c
                                                                                                     WHERE Name = 'MSFOpportunitiesFieldsLogicTESTLastName' LIMIT 1].Id,
                                                                         msf_LeadSource1__c = leadSource1Desc()[0]
                                                                        );
        
        insert quotaMod;
        
        npe03__Recurring_Donation__c result = [SELECT Id, msf_CurrentCampaign__c, msf_CurrentQuotaModification__c
                                               FROM npe03__Recurring_Donation__c 
                                               WHERE Id = :quotaMod.msf_RecurringDonation__c ];
        
        
        System.assertEquals(quotaMod.msf_RecurringDonation__c, result.Id);
        System.assertEquals(quotaMod.Id, result.msf_CurrentQuotaModification__c);
        
    }
    
    @isTest static void updateQuotaModificationFieldsLogic(){
        msf_QuotaModification__c quotaMod = [SELECT Id, msf_CampaignInfluence__c, msf_RecurringDonation__c
                                             FROM msf_QuotaModification__c 
                                             WHERE Name = 'MSFQuotaModificationFieldsLogicTESTName2'];
		msf_QuotaModification__c oldQuotaMod = quotaMod;
        quotaMod.msf_CampaignInfluence__c = [SELECT Id FROM Campaign
                                             WHERE Name = 'MSFQuotaModificationFieldsLogicTESTName1' LIMIT 1].Id;
        update quotaMod;
        System.assertEquals(oldQuotaMod,QuotaMOd);
    }
    private static List<String> leadSource1Desc(){
        Schema.DescribeFieldResult fieldResult = Opportunity.LeadSource.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    private static List<String> leadSource2Desc(){
        Schema.DescribeFieldResult fieldResult = Opportunity.msf_LeadSource2Level__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    private static List<String> leadSource3Desc(){
        Schema.DescribeFieldResult fieldResult = Opportunity.msf_LeadSource3Level__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
}