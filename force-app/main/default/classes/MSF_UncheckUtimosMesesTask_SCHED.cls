/**
* @author 		Omega
* @date 		27/09/2021
* @group 		Task
* @description	Job to check and update the field msf_IsFromLastMonthsBool__c ZenIT#25762
*/
global  class MSF_UncheckUtimosMesesTask_SCHED implements Schedulable{
    private Integer lim, items;
    public MSF_UncheckUtimosMesesTask_SCHED(Integer lim, Integer items) {
        this.lim = lim;
        this.items = items;
    }

    global void execute(SchedulableContext context){ 
        MSF_UncheckUtimosMesesTask_BATCH myBatchObject = new MSF_UncheckUtimosMesesTask_BATCH(lim);
        Id batchId = Database.executeBatch(myBatchObject,items);
     }
}