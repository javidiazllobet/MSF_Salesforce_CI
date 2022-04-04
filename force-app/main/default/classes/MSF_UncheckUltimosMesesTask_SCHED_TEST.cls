/**
* @author 		Omega
* @date 		29/04/2021
* @group 		Task
* @description	Test ZenIT#25762
*/
@isTest
public class MSF_UncheckUltimosMesesTask_SCHED_TEST {
    
	@testSetup static void setup(){
        Date dateSixYearsAgo = Date.today() - 365*6;
        List<Task> listTaskToInsert = new List<Task>();
        
        Task taskLlamada = new Task();
        taskLlamada.msf_Channel__c = 'Llamada';
        taskLlamada.ActivityDate = dateSixYearsAgo;
        taskLlamada.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskLlamada);
        
        Task task = new Task();
        task.ActivityDate = dateSixYearsAgo;
        task.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(task);
        
        Task taskCF = new Task();
        taskCF.msf_Thematic__c = 'Certificado fiscal';
        taskCF.ActivityDate = dateSixYearsAgo;
        taskCF.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF);
        
        insert listTaskToInsert;
        
 	}
    
    @isTest static void Test_UncheckUltimosMesesTask_SCHED(){
        
        Test.startTest();
        String CRON_EXP = '0 0 0 L * ? *';
        String jobId = System.schedule('MSF_UncheckUltimosMesesTask_SCHED_TEST', CRON_EXP, new MSF_UncheckUltimosMesesTask_SCHED());
    	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    	Test.stopTest();        
     
    }
}