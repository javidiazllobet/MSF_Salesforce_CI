public with sharing class MSF_ModificacionMasivaTareasController {
    
    @AuraEnabled
    public static DataTableWrapper getTask(String recId){
        List<Task> listTask = new List<Task>();
        
        if (String.isNotBlank(recId)){
            listTask = [SELECT Id, ActivityDate, Status, Subject, OwnerId, Owner.name, WhatId, WhoId 
            FROM Task
            WHERE ID >: recId  
            ORDER BY Id ASC NULLS LAST
            LIMIT 20];
        } else {
            listTask = [SELECT Id, ActivityDate, Status, Subject, OwnerId, Owner.name, WhatId, WhoId 
            FROM Task
            ORDER BY Id ASC NULLS LAST
            LIMIT 20];
        }
        String items = System.Label.MSF_Items;
        String nombreTabla = System.Label.MSF_NombreTabla;
        DataTableWrapper listDataTable = new DataTableWrapper();
        listDataTable.listTask = listTask;
        listDataTable.totalCount = Database.countQuery('SELECT count() FROM Task');
        listDataTable.items = items;
        listDataTable.nombreTabla = nombreTabla;

        return listDataTable;
    }

    //wrapper class for data table
    public class DataTableWrapper {
        @AuraEnabled
        public List<Task> listTask;
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public String items;
        @AuraEnabled
        public String nombreTabla;
    }
}