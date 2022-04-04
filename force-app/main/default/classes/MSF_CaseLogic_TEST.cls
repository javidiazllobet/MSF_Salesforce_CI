/**
* @author 		Deloitte
* @date 		10-2018
* @group 		Case
* @description	test class for the MSF_CaseLogic_TDTM clases.
*/
@isTest
private class MSF_CaseLogic_TEST {
    @testSetup static void setup(){  
        
        ID CaseCelebrationsRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSF_IS_Celebrations').getRecordTypeId();
        ID CaseSolidarityInitiative_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSF_IS_Solidarity_Initiative').getRecordTypeId();

        List<Case> listCaseTest1 = new List<Case>();
        List<String> listStatusCase = new List<String>{'Pendiente envio Info','Enviar info extra', 'Enviar prespuesto', 'Pendiente info para diseño',
            'Enviar diseño', 'Enviar datos de pago', 'Enviar a Imprenta', 'Enviar email agradecimiento', 
            'Petición IS Recibida', 'Pendiente respuesta', 'Llamada Programada', 'Pendiente OK  presupuesto', 
            'Pendiente aprobación diseño', 'Pendiente justificante', 'Rechazada'
            };
                
        npsp__Trigger_Handler__c thCase = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestCaseLogic',
            npsp__Class__c = 'MSF_CaseLogic_TDTM',
            npsp__Object__c = 'Case',
            npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCase; 
        
        for(Integer i = 0; i <= listStatusCase.size()-1; i++){
            Case c = new Case(
                Status = listStatusCase[i],
                Origin = 'BETTERNOW',
                RecordTypeId = (i == listStatusCase.size() ? CaseSolidarityInitiative_RT : CaseCelebrationsRT)
            );
            listCaseTest1.add(c);
        }
        
        Insert listCaseTest1;
       
    }
    
    @isTest static void createTaskForOwnerCase(){
        List<Task> ts = [SELECT Id FROM Task];
        System.assertEquals(14, ts.size());
    } 
    
}