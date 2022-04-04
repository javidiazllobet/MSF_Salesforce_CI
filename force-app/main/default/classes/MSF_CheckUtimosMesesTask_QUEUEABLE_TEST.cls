/**
* @author 		Omega
* @date 		01/07/2021
* @group 		Task
* @description	Test ZenIT#25762
*/
@isTest
public class MSF_CheckUtimosMesesTask_QUEUEABLE_TEST {
    
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
        
        Task taskCF2 = new Task();
        taskCF2.msf_Thematic__c='Certificado fiscal';
        taskCF2.ActivityDate = Date.today();
        taskCF2.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF2);
        
        Task taskCF3 = new Task();
        taskCF3.msf_Thematic__c='Certificado fiscal';
        taskCF3.ActivityDate = Date.today();
        taskCF3.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF3);
        
        Task taskCF4 = new Task();
        taskCF4.msf_Thematic__c='Certificado fiscal';
        taskCF4.ActivityDate = Date.today();
        taskCF4.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF4);
        
        Task taskCF5 = new Task();
        taskCF5.msf_Thematic__c='Certificado fiscal';
        taskCF5.ActivityDate = Date.today();
        taskCF5.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF5);
        
        Task taskCF6 = new Task();
        taskCF6.msf_Thematic__c='Certificado fiscal';
        taskCF6.ActivityDate = Date.today();
        taskCF6.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF6);
        
        Task taskCF7 = new Task();
        taskCF7.msf_Thematic__c='Certificado fiscal';
        taskCF7.ActivityDate = Date.today();
        taskCF7.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF7);
        
        Task taskCF8 = new Task();
        taskCF8.msf_Thematic__c='Certificado fiscal';
        taskCF8.ActivityDate = Date.today();
        taskCF8.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF8);
        
        Task taskCF9 = new Task();
        taskCF9.msf_Thematic__c='Certificado fiscal';
        taskCF9.ActivityDate = Date.today();
        taskCF9.msf_IsFromLastMonthsBool__c = false;
        listTaskToInsert.add(taskCF9);
        
        insert listTaskToInsert;
        
 	}
    
    @isTest static void Test_CheckUltimosMesesTask_SCHED(){
        Test.startTest();
        System.enqueueJob(new MSF_CheckUtimosMesesTask_QUEUEABLE());
    	Test.stopTest();         
    }
}