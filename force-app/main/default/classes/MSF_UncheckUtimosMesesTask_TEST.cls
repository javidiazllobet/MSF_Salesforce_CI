/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 03-24-2022
 * @last modified by  : sheredia@omegacrmconsulting.com
**/
@isTest
public class MSF_UncheckUtimosMesesTask_TEST {

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
    
    @isTest static void Test_UncheckUltimosMeses_QUEUEABLE(){
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new MSF_UncheckUtimosMesesTask_SCHED(50, 10));
    	Test.stopTest();    
    }
    
}