/**
* @author 		Omega
* @date 		29/04/2021
* @group 		Task
* @description	Job to check and update the field msf_IsFromLastMonthsBool__c ZenIT#25762 y ZenIT#26287
*/
global class MSF_CheckUltimosMesesTask_SCHED implements Schedulable {
    global void execute(SchedulableContext context){ 
       System.enqueueJob(new MSF_CheckUtimosMesesTask_QUEUEABLE());
    }
}