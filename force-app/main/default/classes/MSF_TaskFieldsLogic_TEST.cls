/**
* @author 		Deloitte
* @date 		03-2019
* @group 		Task
* @description	test class for the MSF_TaskFieldsLogic_TDTM class.
*/
@isTest
private class MSF_TaskFieldsLogic_TEST {
    
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestTaskFieldsLogic',
            npsp__Class__c = 'MSF_TaskFieldsLogic_TDTM',
            npsp__Object__c = 'Task',
            npsp__Trigger_Action__c = 'BeforeUpdate;BeforeInsert;AfterInsert;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 2,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        
        List<msf_InteractionsMasterData__c> iMDList = new List<msf_InteractionsMasterData__c>();
        msf_InteractionsMasterData__c imd = new msf_InteractionsMasterData__c(
            msf_Subject__c = 'Actúa Como Altavoz',
            msf_Status__c = 'Pendiente',
            msf_TaskNumber__c = 1001,
            msf_InboundOutbound__c = 'Entrante',
            msf_Channel__c = 'Llamada',
            msf_ProactiveReactive__c = 'Reactiva',
            msf_Campaign__c = null,
            msf_LeadSource__c = null,
            msf_Comment__c = 'Comment',
            msf_Family__c = null,
            msf_Objective__c = null          
        );
        iMDList.add(imd);
        
        msf_InteractionsMasterData__c imd2 = new msf_InteractionsMasterData__c(
            msf_Subject__c = 'Solicita Envío Documentos, Kits o Publicaciones Varios',
            msf_Status__c = 'Realizada',
            msf_TaskNumber__c = 118,
            msf_GenerateTask__c = 211,
            msf_InboundOutbound__c = 'Entrante',
            msf_Channel__c = 'Llamada',
            msf_ProactiveReactive__c = 'Reactiva',
            msf_Campaign__c = null,
            msf_LeadSource__c = null,
            msf_Comment__c = 'Comment',
            msf_Family__c = null,
            msf_Objective__c = 'Petición de documentos o información'         
        );
        iMDList.add(imd2);
        
        msf_InteractionsMasterData__c imd3 = new msf_InteractionsMasterData__c(
            msf_Subject__c = 'MSF Responde a: Solicita Envío Documentos, Kits o Publicaciones Varios',
            msf_Status__c = 'Pendiente',
            msf_TaskNumber__c = 211,
            msf_InboundOutbound__c = 'Entrante',
            msf_Channel__c = 'Llamada',
            msf_ProactiveReactive__c = 'Reactiva',
            msf_Campaign__c = null,
            msf_LeadSource__c = null,
            msf_Comment__c = 'Comment',
            msf_Family__c = null,
            msf_Objective__c = null          
        );
        iMDList.add(imd3);
        
        insert iMDList;
        
        Schema.DescribeFieldResult fieldResult = Task.Subject.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        Task t = new Task(Subject=pickListValues[0].getValue(), msf_Channel__c = 'Llamada');
        insert t;
    }
    
    @isTest static void testGeneratedTask() {
        Task t = new Task(msf_TaskNumber__c=118, Subject='Solicita Envío Documentos, Kits o Publicaciones Varios');
        insert t; 
    }
    
    @isTest static void testSetDefaultValues(){
        Task t = new Task(Subject='Actúa Como Altavoz');
        insert t;
        
        t = [SELECT Id, msf_TaskNumber__c FROM Task WHERE Id =: t.Id LIMIT 1];
        System.assertEquals(1001, t.msf_TaskNumber__c,'ERROR: The default values have not been configured');
    }
    
    @isTest static void testDeleteTask(){
        Task t = new Task(Subject='Actúa Como Altavoz');
        insert t;
        
        delete t;
    }
    
    @isTest static void testSendError_Insert(){
        try{
            Task t = new Task(msf_Channel__c ='Llamada', Subject=null);
            insert t;
            System.assert(false,'ERROR: Error message was not send');
        }catch(DmlException ex){
            System.assert(true);
        }
    }
    
    @isTest static void testSendError_Update(){
        try{
            Schema.DescribeFieldResult fieldResult = Task.Subject.getDescribe(); 
            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
            
			Task t = [SELECT Id, Subject FROM Task WHERE Subject = :pickListValues[0].getValue()];            
            t.Subject = null;
            update t;

            System.assert(false,'ERROR: Error message was not send.');
        }catch(DmlException ex){
            System.assert(true);
        }
    }
}