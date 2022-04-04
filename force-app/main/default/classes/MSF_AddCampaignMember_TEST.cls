/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Opportunity
* @description	test class for the MSF_OpportunitiesFieldsLogic_TDTM class.
*/
@isTest
private class MSF_AddCampaignMember_TEST {
	@testSetup static void setup(){
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestOpportunitiesFieldsLogic',
            npsp__Class__c = 'MSF_AddCampaignMember_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        
        //Contacts
        List<Contact> lCon = new List<Contact>(); 
        lcon.add(new Contact(LastName='MSF_AddCampaignMember_TEST_LastName1', msf_BeginDateMSF__c=date.today()));
        lcon.add(new Contact(LastName='MSF_AddCampaignMember_TEST_LastName2',msf_BeginDateMSF__c=date.today()));
        lcon.add(new Contact(LastName='contact1',msf_BeginDateMSF__c=date.today().addMonths(-2)));
        system.debug('lCon: ' + lCon);
        insert lcon;
        
        //Campaign
        List<Campaign> lCampaign = new List<Campaign>();
        lCampaign.add(new Campaign(Name='MSFAddCampaignMemberTESTCampaign1',msf_FinalCampaign__c = false));
        lCampaign.add(new Campaign(Name='MSFAddCampaignMemberTESTCampaign2',msf_FinalCampaign__c = false));
        lCampaign.add(new Campaign(Name='MSFAddCampaignMemberTESTCampaign3',msf_FinalCampaign__c = false));
        lCampaign.add(new Campaign(Name='MSFAddCampaignMemberTESTCampaign4',msf_FinalCampaign__c = false));
        lCampaign.add(new Campaign(Name='MSFAddCampaignMemberTESTCampaign5',msf_FinalCampaign__c = false));
        system.debug('lCampaign: ' + lCampaign);
        insert lCampaign;
        
        //CampaignMember
        CampaignMember cM = new CampaignMember();
        cM.ContactId 	= lCon.get(0).Id;
        cM.CampaignId 	= lCampaign.get(1).Id; 
        system.debug('cM: ' + cM);
        insert cM;
        
        //CampaignMemberStatus
        CampaignMemberStatus cMS = new CampaignMemberStatus();
        cMS.CampaignId = lCampaign.get(1).Id; 
        cMS.Label = Label.npsp.campaignMemberStatusNonResponded;
        cMS.SortOrder = 4;
        system.debug('cMS: ' + cMS);
        insert cMS; 
    }
    
    @isTest static void testAfterInsertAndAfterUpdate() {
         Opportunity o = new Opportunity (
            Name ='RatingOpportunity1',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId(),
            CloseDate = date.today(),
            Type= 'One off Donation',
            Amount = 10,
            StageName='Cobrada',
            npsp4hub__Payment_Method__c = 'EFECTIVO S.C.',
            npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA',
            npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA'
        );
        o.npsp__Primary_Contact__c 	= [SELECT Id FROM Contact WHERE LastName = 'MSF_AddCampaignMember_TEST_LastName1' LIMIT 1].Id;
        o.CampaignId 				= [SELECT Id FROM Campaign WHERE Name = 'MSFAddCampaignMemberTESTCampaign1' LIMIT 1].Id;
        o.msf_CurrentCampaign__c 	= [SELECT Id FROM Campaign WHERE Name = 'MSFAddCampaignMemberTESTCampaign2' LIMIT 1].Id;
        o.msf_ModificationCampaign__c = [SELECT Id FROM Campaign WHERE Name = 'MSFAddCampaignMemberTESTCampaign3' LIMIT 1].Id;
        insert o;
        
        o.npsp__Primary_Contact_Campaign_Member_Status__c = 'TEST';
        o.msf_CurrentCampaign__c 		= [SELECT Id FROM Campaign WHERE Name = 'MSFAddCampaignMemberTESTCampaign4' LIMIT 1].Id;
        o.msf_ModificationCampaign__c 	= [SELECT Id FROM Campaign WHERE Name = 'MSFAddCampaignMemberTESTCampaign5' LIMIT 1].Id;
        update o; 
    }
}