/**
* @author       Deloitte
* @date         02-2019
* @group        Opportunities, Contact.
* @description  test class for the MSF_Chained_CTRL class.
*/
@isTest
private class MSF_ChainedTasks_TEST {

    @testSetup static void setup(){
        
        msf_ChainedTaskBlock__c cTb = new msf_ChainedTaskBlock__c();
        insert cTb; 
        
        
        Task t = new Task();
        t.Subject = 'ACTUA COMO ALTAVOZ'; 
        t.Description = 'TEST';
        t.Status = 'Pendiente';
        t.msf_ChainedTaskBlock__c = cTb.Id; 
        insert t; 
        
        
    }
    
    @IsTest
    private static void test(){
		Id ids = [SELECT Id FROM Task LIMIT 1].Id;
		MSF_ChainedTasks_CTRL.getChainedTasks(ids);        
    }
}