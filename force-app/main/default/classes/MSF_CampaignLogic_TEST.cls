/**
* @author       Deloitte
* @date         01-2019
* @group        Campaign
* @description  test class for the MSF_CampaignLogic_TDTM class.
*/
@isTest
private class MSF_CampaignLogic_TEST {
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestCampaignLogic',
            npsp__Class__c = 'MSF_CampaignLogic_TDTM',
            npsp__Object__c = 'Campaign',
            npsp__Trigger_Action__c = 'AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        //Initialize values    
        Contact cont = new Contact(LastName='MSF_CampaignLogic_TEST_LastName1', msf_RecalculateMemberType__c=false);   
        insert cont;
        Campaign camp = new Campaign(Name='MSFCampaignLogicTESTCampaign1', msf_PromoterIndividual__c=cont.Id,msf_FinalCampaign__c = false);
        insert camp;
    }
    @isTest static void testDeleted(){
        Campaign camp = [SELECT Id, Name FROM Campaign Where Name = 'MSFCampaignLogicTESTCampaign1' LIMIT 1];
        delete camp;
        Contact cont = [SELECT Id, msf_RecalculateMemberType__c FROM Contact Where LastName = 'MSF_CampaignLogic_TEST_LastName1' LIMIT 1];
        System.assert(cont.msf_RecalculateMemberType__c);
    }
    @isTest static void testNoPromoter(){
        Campaign camp = [SELECT Id, Name FROM Campaign Where Name = 'MSFCampaignLogicTESTCampaign1' LIMIT 1];
        camp.msf_PromoterIndividual__c=null;
        update camp;
        delete camp;
        Contact cont = [SELECT Id, msf_RecalculateMemberType__c FROM Contact Where LastName = 'MSF_CampaignLogic_TEST_LastName1' LIMIT 1];
        System.assert(!cont.msf_RecalculateMemberType__c);
    }
}