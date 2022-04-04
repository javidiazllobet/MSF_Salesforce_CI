/**
* @author 		Deloitte
* @date 		03-2019
* @group 		msf_WorkingHoursCanvasser__c
* @description	test class for the  MSF_WorkingHoursCanvasser_BATCH class.
*/
@isTest
private class MSF_WorkingHoursCanvasser_TEST {
    @testSetup static void setup(){
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Canvasser'];
        UserRole uRol = [SELECT Id,Name FROM UserRole WHERE DeveloperName LIKE '%Captador%' LIMIT 1];
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Campaign cF2F = new Campaign(Name='Alta F2F',msf_FinalCampaign__c = false);
		insert cF2F;

        System.runAs(thisUser){    
            Campaign c = new Campaign(Name='MSFWorkingHoursCanvasserTESTName1',msf_FinalCampaign__c = false);
            insert c;
    
            User u = new User();
            u.Username='user@aa.testcom';
            u.LastName='user@aa.testcom';
            u.Email='user@aa.testcom';
            u.Alias='cc';
            u.CommunityNickname='';
            u.TimeZoneSidKey = 'Europe/Paris';
            u.LocaleSidKey = 'es_ES';
            u.EmailEncodingKey='ISO-8859-1';
            u.ProfileId=prof.Id;
            u.LanguageLocaleKey='ES';
            u.msf_Campaign__c=c.Name;
            u.UserRoleId=uRol.Id;
            
            insert u;
        }      
    }
    
    @isTest static void LevelCalculation_BatchTest(){
        Test.startTest();
        MSF_WorkingHoursCanvasser_BATCH mta = new MSF_WorkingHoursCanvasser_BATCH();
        Id batchId = Database.executeBatch(mta);
        Test.stopTest();
        
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'MSFWorkingHoursCanvasserTESTName1' LIMIT 1];
        User user = [SELECT Id FROM User WHERE Username = 'user@aa.testcom' LIMIT 1];
        List<msf_WorkingHoursCanvasser__c> wHC = [SELECT Id,msf_StartDate__c,msf_CampaignId__c,
                                                  msf_CanvasserId__c FROM msf_WorkingHoursCanvasser__c WHERE msf_CanvasserId__c = :user.Id];
        System.assertEquals(1, wHC.Size());
        System.assertEquals(Date.today().addDays(1), wHC[0].msf_StartDate__c);       
        System.assertEquals(camp.Id, wHC[0].msf_CampaignId__c);       

    }
    
    @isTest static void LevelCalculation_BatchTestNoCampaignDefined(){
        //Must empty the campaing from the user
        User user = [SELECT Id FROM User WHERE Username = 'user@aa.testcom' LIMIT 1];
        user.msf_Campaign__c = null;
        update user;
        
        Test.startTest();
        MSF_WorkingHoursCanvasser_BATCH mta = new MSF_WorkingHoursCanvasser_BATCH();
        Id batchId = Database.executeBatch(mta);
        Test.stopTest();
        
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Alta F2F' LIMIT 1];
        List<msf_WorkingHoursCanvasser__c> WHC = [SELECT Id, msf_StartDate__c, msf_CampaignId__c, msf_CanvasserId__c 
                                                  FROM msf_WorkingHoursCanvasser__c 
                                                  WHERE msf_CanvasserId__c = :user.Id];
        
        System.assertEquals(1, WHC.Size());
        System.assertEquals(Date.today().addDays(1), WHC[0].msf_StartDate__c);       
        System.assertEquals(camp.Id, WHC[0].msf_CampaignId__c, 'ERROR: Campaign name is not Alta F2F');       

    }
    
    @isTest static void LevelCalculation_SchedulerTest (){
        Test.startTest();           
        String CRON_EXP = '0 0 0 * * ? *';
        String jobId = System.schedule('MSF - MemberTypeTest',CRON_EXP, new MSF_WorkingHoursCanvasser_BATCH());
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];       
        System.assert(ct != null, 'Job is not exist.');
        System.assert(ct.NextFireTime != null, 'Job is not schedule.');
    }
}