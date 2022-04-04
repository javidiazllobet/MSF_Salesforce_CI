/**
* @author       Deloitte
* @date         02-2019
* @group        Opportunities, Contact.
* @description  test class for the MSF_Chained_CTRL class.
*/
@isTest
private class MSF_ChildTasks_TEST {
    @testSetup static void setup(){
        
        
        Task t = new Task();
        t.Subject = 'ACTUA COMO ALTAVOZ'; 
        t.Description = 'TEST';
        t.Status = 'Pendiente';
        insert t; 
        
        Task tC = new Task();
        tC.Subject = 'ACTUA COMO ALTAVOZ'; 
        tC.Description = 'TEST';
        tC.Status = 'Pendiente';
        tC.msf_ParentTaskId__c = t.Id; 
        insert tC; 
        
    }
    
    @IsTest
    private static void test(){
		Id ids = [SELECT Id FROM Task WHERE msf_ParentTaskId__c = null LIMIT 1].Id;
		MSF_ChildTasks_CTRL.getChildTasks(String.valueOf(ids), 1, 1);  
        MSF_ChildTasks_CTRL.getChildTasks(String.valueOf(ids), 0, 0);  
    }
}