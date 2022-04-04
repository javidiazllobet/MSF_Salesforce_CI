/**
* @author 		Omega
* @date 		29/04/2021
* @group 		Task
* @description	Job to uncheck and update the field msf_IsFromLastMonthsBool__c ZenIT#25762 y ZenIT#26287
*/
global class MSF_UncheckUltimosMesesTask_SCHED implements Schedulable {
    global void execute(SchedulableContext context){ 
       System.enqueueJob(new MSF_UncheckUtimosMesesTask_QUEUEABLE());
    }
}