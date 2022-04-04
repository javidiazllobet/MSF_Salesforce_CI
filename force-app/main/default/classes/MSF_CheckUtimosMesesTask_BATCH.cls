public class MSF_CheckUtimosMesesTask_BATCH implements
Database.Batchable<sObject>, Database.Stateful{
    public Integer recordsProcessed = 0;
    public Integer numberErros = 0;
    private Integer lim;

    public MSF_CheckUtimosMesesTask_BATCH(Integer lim){
        this.lim = lim;
    }
    
    public Database.QueryLocator  start(Database.BatchableContext bc) {
        /*return Database.getQueryLocator([SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c 
        From Task where msf_IsFromLastMonthsBool__c = false and msf_IsFromLastMonths__c = true Limit :lim]);*/
        date lastOneYear = date.today()-365*1;
        date lastFiveYears = date.today()-365*5;   
        return Database.getQueryLocator([SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From 
        Task where msf_IsFromLastMonthsBool__c = false and ((ActivityDate >= :lastOneYear AND ActivityDate <= TODAY) 
        OR (msf_Channel__c='Llamada' AND (ActivityDate >=:lastFiveYears AND (ActivityDate <= TODAY)))
        OR msf_Thematic__c IN ('Certificado fiscal','Encuestas','Herencias y Legados')
        OR Subject IN ('Se Queja Presión en Captación Fondos', 'Se Queja Por Llamadas Telemarketing', 'Solicita Información Regalo Solidario')) limit :lim]);
    }


    public void execute(Database.BatchableContext bc, List<Task> records){
        List<Task> listTaskToUpdate = new List<Task>();
        for(Task iTask: records){
            if(iTask.msf_IsFromLastMonths__c == true && iTask.msf_IsFromLastMonthsBool__c == false ){
                iTask.msf_IsFromLastMonthsBool__c = true;            
            	listTaskToUpdate.add(iTask);
                recordsProcessed = recordsProcessed+1;                
            }
        }
        if(!listTaskToUpdate.isEmpty()){
            Database.SaveResult[] results = Database.update(listTaskToUpdate, false);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        numberErros = numberErros + 1;
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Opportunity fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }


    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        System.debug('Job: '+ job.TotalJobItems);
        System.debug('Errores: '+numberErros);
        System.debug(numberErros == recordsProcessed);
        if(job.TotalJobItems==0 || numberErros == recordsProcessed){
            System.debug('No llamar al batch: ');
        }else {
            System.debug('llamarlo otra vez');
            MSF_CheckUtimosMesesTask_BATCH myBatchObject = new MSF_CheckUtimosMesesTask_BATCH(lim);
			Id batchId = Database.executeBatch(myBatchObject,10);
        }
    
    }
}