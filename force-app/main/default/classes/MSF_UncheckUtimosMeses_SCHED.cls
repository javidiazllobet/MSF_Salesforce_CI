global class MSF_UncheckUtimosMeses_SCHED implements Schedulable{
    private Integer lim, items;

    public MSF_UncheckUtimosMeses_SCHED(Integer lim, Integer items) {
        this.lim = lim;
        this.items = items;
    }

    global void execute(SchedulableContext context){ 
        MSF_UncheckUtimosMeses_BATCH myBatchObject = new MSF_UncheckUtimosMeses_BATCH(lim);
        Id batchId = Database.executeBatch(myBatchObject,items);
     }
}