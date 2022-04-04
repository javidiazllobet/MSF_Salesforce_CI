/**
* @author 		Omega
* @date 		01/07/2021
* @group 		Task
* @description	Test ZenIT#25762
*/
@isTest
public class MSF_UncheckUMTask_QUEUEABLE_TEST {
    
	@testSetup static void setup(){
        Date dateSixYearsAgo = Date.today() - 365*7;
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
        taskCF.msf_Thematic__c = 'Área Socio Web';
        taskCF.ActivityDate = dateSixYearsAgo;
        taskCF.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF);
        
        Task taskCF2 = new Task();
        taskCF2.msf_Thematic__c  = 'Área Socio Web';
        taskCF2.ActivityDate = dateSixYearsAgo;
        taskCF2.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF2);
        
        Task taskCF3 = new Task();
        taskCF3.msf_Thematic__c  = 'Área Socio Web';
        taskCF3.ActivityDate = dateSixYearsAgo;
        taskCF3.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF3);
        
        Task taskCF4 = new Task();
        taskCF4.msf_Thematic__c  = 'Área Socio Web';
        taskCF4.ActivityDate = dateSixYearsAgo;
        taskCF4.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF4);
        
        Task taskCF5 = new Task();
        taskCF5.msf_Thematic__c  = 'Área Socio Web';
        taskCF5.ActivityDate = dateSixYearsAgo;
        taskCF5.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF5);
        
        Task taskCF6 = new Task();
        taskCF6.msf_Thematic__c  = 'Área Socio Web';
        taskCF6.ActivityDate = dateSixYearsAgo;
        taskCF6.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF6);
        
        Task taskCF7 = new Task();
        taskCF7.msf_Thematic__c  = 'Área Socio Web';
        taskCF7.ActivityDate = dateSixYearsAgo;
        taskCF7.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF7);
        
        Task taskCF8 = new Task();
        taskCF8.msf_Thematic__c  = 'Área Socio Web';
        taskCF8.ActivityDate = dateSixYearsAgo;
        taskCF8.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF8);
        
        Task taskCF9 = new Task();
        taskCF9.msf_Thematic__c  = 'Área Socio Web';
        taskCF9.ActivityDate = dateSixYearsAgo;
        taskCF9.msf_IsFromLastMonthsBool__c = true;
        listTaskToInsert.add(taskCF9);
        
        insert listTaskToInsert;
        
 	}
    
    @isTest static void Test_UncheckUltimosMesesTask_QUEUEABLE(){
        Test.startTest();
        System.enqueueJob(new MSF_UncheckUtimosMesesTask_QUEUEABLE());
    	Test.stopTest();         
     
    }
}