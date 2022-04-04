/**
* @author       Deloitte
* @date         06-2019
* @group        Task.
* @description  Controller for the lightning component MSF_ChainedTask
*/
public without sharing class MSF_ChainedTasks_CTRL {

    @AuraEnabled
    public static Object getChainedTasks(String parentId) {
     	List<Task> tasks = new List<Task>();
        Map<String, Object> returnData = new Map<String,Object>();
        
        Task currentTask = [SElECT Id, msf_ChainedTaskBlock__c, msf_ChainedTaskBlock__r.Id FROM Task WHERE Id =: parentId LIMIT 1];
        
        if (currentTask.msf_ChainedTaskBlock__c != null) {
			Id chainedTaskBlockId = currentTask.msf_ChainedTaskBlock__r.Id;
            tasks = [SELECT Id, Subject, Status, Description
                     FROM Task
                     WHERE msf_ChainedTaskBlock__c =: chainedTaskBlockId
                     AND Id !=: parentId
                ];                
        }
        returnData.put('data', tasks);
        
        return returnData;
    }
}