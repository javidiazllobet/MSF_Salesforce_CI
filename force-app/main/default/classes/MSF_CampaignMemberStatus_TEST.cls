@isTest public class MSF_CampaignMemberStatus_TEST {
    @testSetup static void setup(){
        
        //Create Trigger
        npsp__Trigger_Handler__c thCam = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestCam',
            npsp__Class__c = 'MSF_CampaignLogic_TDTM',
            npsp__Object__c = 'Campaign',
            npsp__Trigger_Action__c = 'AfterInsert',
            npsp__Active__c = true,
            npsp__Load_Order__c = 1,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );
        upsert thCam;
        
        npsp__Trigger_Handler__c thCm = new npsp__Trigger_Handler__c(
                Name = 'TriggerTestCm',
                npsp__Class__c = 'MSF_CampaignMemberStatus_TDTM',
                npsp__Object__c = 'CampaignMember',
                npsp__Trigger_Action__c = 'BeforeUpdate',
                npsp__Active__c = true,
                npsp__Load_Order__c = 1,
                npsp__User_Managed__c = true,
                npsp__Asynchronous__c = false,
                npsp__Usernames_to_Exclude__c = ''
            );
        upsert thCm;
    }
    
    @isTest static void test() {
        Campaign camp = new Campaign(Name = 'Test', msf_OwnBy__c='Otros', msf_IsOnline__c='Si',
                                     msf_Objective__c='Cultivación', msf_OutboundChannel1__c='F2F', msf_Segment__c = 'Frio individuos',
                                    msf_Thematic__c='02');
        insert camp;
        
        Contact c = new Contact(FirstName = 'Test', LastName='Testa');
        insert c; 
        
        CampaignMember cm = new CampaignMember(ContactId = c.id, CampaignId = camp.id);
        insert cm; 
        
        cm.Status = 'Respondida (op abierta)';
        update cm; 
        
        cm.Status = 'Respondida (cerrada)';
        update cm;
        
        cm.Status = 'Impactado';
        update cm; 
    }
}