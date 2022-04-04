/**
* @author       Deloitte
* @date         06-2019
* @group        Task.
* @description  Controller for the lightning component MSF_MSF_ChildTasks
*/
public without sharing class MSF_ChildTasks_CTRL {

    @AuraEnabled
    public static Object getChildTasks(String parentId, Integer page, Integer nrows) {
        Integer totalRowsReturned = nrows*page;
        Integer offset = nrows*(page-1);
        List<Task> tasks = null;
        
        Map<String, Object> returnData = new Map<String,Object>();
        returnData.put('moreThanReturned', false);
        
        if(page == 0 && nrows == 0){
            tasks = [SELECT Id, Subject, Status, Description
                     FROM Task
                     WHERE msf_ParentTaskId__c =: parentId
                    ]; 
        }else{
            tasks = [SELECT Id, Subject, Status, Description
                     FROM Task
                     WHERE msf_ParentTaskId__c =: parentId
                     LIMIT :nrows OFFSET :offset
                    ];   
            Integer totalRows = getTotalRows(parentId);
            returnData.put('moreThanReturned', totalRows > totalRowsReturned);
        }
        returnData.put('data', tasks);
        
        return returnData;
    }
    
     private static Integer getTotalRows(String parentId){
        Integer numRows = [SELECT count() 
                           FROM Task
                           WHERE msf_ParentTaskId__c =: parentId
                          ];
        return numRows;
    }   
}