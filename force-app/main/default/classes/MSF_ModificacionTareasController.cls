public with sharing class MSF_ModificacionTareasController {
    @AuraEnabled
    public static List<String> getPickListValuesStatus(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }     
         return pickListValuesList;
     }

     @AuraEnabled
    public static List<String> getPickListValuesSubject(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Task.Subject.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }     
         return pickListValuesList;
     }

     @AuraEnabled
     public static string submitDate(List<String> Ids, String  Subject, String Status, Date DueDate, String Owner){
         try {
             system.debug('Ids.size: ' + Ids.size());
             system.debug('Ids: ' + Ids + ' Subject: ' + Subject + ' Status: ' + Status + ' DueDate: ' + DueDate + ' Owner: ' + Owner);
             Set<Id> setId =  new Set<Id>();
             List<Task> listTask = new List<Task>();
             for (String id: Ids){
                setId.add(id);
                Task tarea = new Task();
                tarea.Id =  id;
                if (!String.isBlank(Subject) && Subject != '--none--'){
                    tarea.Subject =  Subject;
                }
                if (!String.isBlank(Status) && Status != '--none--'){
                    tarea.Status = Status;
                }
                if (DueDate != null && String.valueOf(DueDate) != '1900-01-01'){
                    tarea.ActivityDate = DueDate;
                }
                if (!String.isBlank(Owner)){
                    tarea.OwnerId = Owner;
                }
                listTask.add(tarea);
             }
             system.debug('listTask: ' + listTask);
             system.debug('listTask.size: ' + listTask.size());
             if (!listTask.isEmpty()){
                update listTask;
             }
             return 'success';
         } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
         }
     }
}