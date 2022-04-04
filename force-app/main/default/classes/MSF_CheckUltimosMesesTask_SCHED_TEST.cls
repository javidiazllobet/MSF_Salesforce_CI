/**
* @author 		Omega
* @date 		29/04/2021
* @group 		Opportunity
* @description	Test ZenIT#25762
*/
@isTest
public class MSF_CheckUltimosMesesTask_SCHED_TEST {
    
	@testSetup static void setup(){
        List<Task> listTaskToInsert = new List<Task>();
        
        Task taskLlamada = new Task();
        taskLlamada.msf_Channel__c = 'Llamada';
        taskLlamada.ActivityDate = Date.today();
        taskLlamada.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskLlamada);
        
        Task task = new Task();
        task.ActivityDate = Date.today();
        task.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(task);
        
        Task taskCF = new Task();
        taskCF.msf_Thematic__c='Certificado fiscal';
        taskCF.ActivityDate = Date.today();
        taskCF.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF);
        
        insert listTaskToInsert;
        
 	}
    
    @isTest static void Test_CheckUltimosMesesTask_SCHED(){
        
        Test.startTest();
        String CRON_EXP = '0 0 0 L * ? *';
        String jobId = System.schedule('MSF_CheckUltimosMesesTask_SCHED_TEST', CRON_EXP, new MSF_CheckUltimosMesesTask_SCHED());
    	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    	Test.stopTest();        
     
    }
}