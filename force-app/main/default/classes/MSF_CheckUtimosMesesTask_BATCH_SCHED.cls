/**
* @author 		Omega
* @date 		08/09/2021
* @group 		Task
* @description	Test ZenIT#25762
*/
global class MSF_CheckUtimosMesesTask_BATCH_SCHED implements Schedulable{
    private Integer lim, items;
    public MSF_CheckUtimosMesesTask_BATCH_SCHED(Integer lim, Integer items) {
        this.lim = lim;
        this.items = items;
    }

    global void execute(SchedulableContext context){ 
        MSF_CheckUtimosMesesTask_BATCH myBatchObject = new MSF_CheckUtimosMesesTask_BATCH(lim);
        Id batchId = Database.executeBatch(myBatchObject,items);
     }
}