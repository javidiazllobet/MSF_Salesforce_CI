/**
* @author 		Omega
* @date 		29/04/2021
* @group 		Opportunity
* @description	Test ZenIT#25762
*/
@isTest
public class MSF_UncheckUltimosMeses_SCHED_TEST {
    
	@testSetup static void setup(){
        Date dateSixYearsAgo = Date.today() - 365*6;
        List<Opportunity> listOppToInsert = new List<Opportunity>();
        Opportunity oppD = new Opportunity(Name='ChkUltimosMeses D');
        oppD.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD.StageName = 'Legacy';
        oppD.CloseDate = dateSixYearsAgo;
        oppD.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(oppD);
        
        Opportunity opp = new Opportunity(Name='ChkUltimosMeses');
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp.StageName = 'Legacy';
        opp.CloseDate = dateSixYearsAgo;
        opp.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp);
        
        insert listOppToInsert;
        
 	}
    
    @isTest static void Test_UncheckUltimosMeses_SCHED(){
        
        Test.startTest();
        String CRON_EXP = '0 0 0 L * ? *';
        String jobId = System.schedule('MSF_UncheckUltimosMeses_SCHED', CRON_EXP, new MSF_UncheckUltimosMeses_SCHED());
    	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    	Test.stopTest();        
     
    }
}