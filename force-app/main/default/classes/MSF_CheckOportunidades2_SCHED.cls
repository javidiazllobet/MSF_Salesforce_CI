/**
* @author 		Omega
* @date 		20/08/2021
* @group 		Opportunity
* @description	Job to check and update the field msf_IsFromLastMonthsBool__c ZenIT#25762
*/
global class MSF_CheckOportunidades2_SCHED implements Schedulable {
    global void execute(SchedulableContext context){ 
       System.enqueueJob(new MSF_CheckOportunidades2_QUEUEABLE());
    }
}