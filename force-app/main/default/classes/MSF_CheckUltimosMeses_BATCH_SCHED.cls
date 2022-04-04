/**
* @author 		Omega
* @date 		09/08/2021
* @group 		Opportunity
* @description	Job to check and update the field msf_IsFromLastMonthsBool__c ZenIT#25762
*/
global class MSF_CheckUltimosMeses_BATCH_SCHED implements Schedulable{
    private Integer lim, items, query;

    public MSF_CheckUltimosMeses_BATCH_SCHED(Integer lim, Integer items, Integer query) {
        this.lim = lim;
        this.items = items;
        this.query = query;
    }

    global void execute(SchedulableContext context){ 
        MSF_CheckUtimosMeses_BATCH myBatchObject = new MSF_CheckUtimosMeses_BATCH(lim, query);
        Id batchId = Database.executeBatch(myBatchObject,items);
     }
}