/**
* @author       Deloitte
* @date         04-2019
* @group        Campaign
* @description  test class for the MSF_DisableCampaigns_BATCH class.
*/

@isTest private class MSF_DisableCampaigns_TEST {
	
    @testSetup static void setup(){        
        List<Campaign> lCampaigns = new List<Campaign>();
        Date dStartDate = date.today().addDays(-6);
        Date dEndDate = date.today().addDays(-5);
        
        for(Integer x=0; x<3; x++){
            Campaign c = new Campaign(
            	Name = 'Campaign'+x,
                isActive = true,
                StartDate = dStartDate,
                EndDate = dEndDate,
                msf_FinalCampaign__c = false
            );

            lCampaigns.add(c);
            System.debug(c);
            dStartDate = dStartDate.addDays(5);
            dEndDate = dEndDate.addDays(5);
        }
        
        Date todayDate = date.today();
        for (Integer i = 0; i < 3; i++) {
            Campaign c = new Campaign(
            	Name = '22Campaign'+i,
                isActive = false,
                StartDate = todayDate,
                EndDate = todayDate.addDays(2),
                msf_FinalCampaign__c = false
            );
            lCampaigns.add(c);
            todayDate = todayDate.addDays(1);
        }
        
        insert lCampaigns;
    }
    
    @isTest static void DisableCampaigns_BatchTest(){
        Test.startTest();
            MSF_DisableCampaigns_BATCH myBatch = new MSF_DisableCampaigns_BATCH();
            Id batchId = Database.executeBatch(myBatch);
        Test.stopTest();
        
        Map<String,Campaign> mCam = new Map<String,Campaign>();
        for(Campaign c : [SELECT Id, Status, isActive, Name FROM Campaign WHERE Name LIKE 'Campaign%' ]){
        	mCam.put(c.Name,c);    
        }
		System.debug(mCam);        
        System.assertEquals(mCam.get('Campaign0').isActive, false, 'The campaign 0 has not been disabled');
        System.assertEquals(mCam.get('Campaign1').isActive, false, 'The campaign 1 has not been disabled');
        System.assertEquals(mCam.get('Campaign2').isActive, true, 'The campaign 2 has not been changed');
    }
    
    @isTest static void DisableCampaigns_SchedulerTest (){
        Test.startTest();           
            String CRON_EXP = '0 0 0 * * ? *';
            String jobId = System.schedule('MSF - MemberTypeTest',CRON_EXP, new MSF_DisableCampaigns_BATCH());
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];       
        System.assert(ct != null, 'Job is not exist.');
        System.assert(ct.NextFireTime != null, 'Job is not schedule.');
    }    

}