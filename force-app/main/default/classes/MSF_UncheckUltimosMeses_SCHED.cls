/**
* @author 		Omega
* @date 		29/04/2021
* @group 		Opportunity
* @description	Job to check and update the field msf_IsFromLastMonthsBool__c ZenIT#25762
*/
global class MSF_UncheckUltimosMeses_SCHED implements Schedulable {
    global void execute(SchedulableContext context){ 
       System.enqueueJob(new MSF_UncheckUtimosMeses_QUEUEABLE());
    }
}