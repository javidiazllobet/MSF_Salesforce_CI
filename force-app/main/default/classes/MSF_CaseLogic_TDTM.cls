/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Case
* @description	Task creation in the stages in the case object.
*/

global without sharing class MSF_CaseLogic_TDTM extends npsp.TDTM_Runnable {
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject>oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){ 
 
        List<Case> lNewCase = (List<Case>) newlist;
        List<Case> lOldCase = (List<Case>) oldlist;
        Map<Id, Case> mOldCase = new Map<Id, Case>();
        if(lOldCase != null){            
            mOldCase.putAll(lOldCase);
        }
        
        List<Task> lTask = new List<Task>();
        
        //Estados de los casos que crean una tarea; 
        List<String> statesCreateTask = new List<String>{'Pendiente envio Info','Enviar info extra', 'Enviar prespuesto', 'Pendiente info para diseño',
            'Enviar diseño', 'Enviar datos de pago', 'Enviar a Imprenta', 'Enviar email agradecimiento', 
            'Petición IS Recibida', 'Pendiente respuesta', 'Llamada Programada', 'Pendiente OK  presupuesto', 
            'Pendiente aprobación diseño', 'Pendiente justificante', 'Rechazada', 'Enviar petición info diseño'
            };
                
        //AFTER INSERT && AFTER UPDATE; 
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate ) {            
            for(Case c :lNewCase){
                if(mOldCase.isEmpty() || c.Status != mOldCase.get(c.Id).Status){
                    if(statesCreateTask.contains(c.Status)) {                    
                        lTask.addAll(setTask(c.Status, c.ContactId, c.Id));
                    }
                }
            }
        }
        
        //DML Operations
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToInsert.addAll((List<Task>)lTask);
        
        if(lTask.isEmpty()){
            return null;
        }
        
        return dmlWrapper;
    }
    
    
    //Private Methods
    
    /*******************************************************************************************************
    * @description 	Define a task based on the parameters provided
    * @param		Status is a String to set the name of the contact
    * @param		contactId is a Id of the contact of the case to assign the task
    * @param		caseId is a Id of the case to assign the task
    * @return 		List of Task to create.		
    ********************************************************************************************************/
    private List<Task> setTask(String Status, Id contactId, Id caseId){
        List<Task> taskToCreate = new List<Task>();
        String subject;
        String taskStatus = 'Pendiente'; 
        
        //RecordType Celebraciones; 
        if(Status == 'Pendiente envio Info'){
            subject = 'Solicita Información de Celebraciones';
            taskStatus = 'Realizada';
        }
        else if (Status == 'Pendiente respuesta') {
            subject = 'Responde a Información de Celebraciones';
        }
        else if (Status == 'Llamada Programada') {
            subject = 'MSF Seguimiento Programada Celebraciones';
        }
        else if(Status == 'Enviar info extra'){
            subject = 'MSF Envío Información Extra Celebraciones';
        }
        else if(Status == 'Enviar prespuesto'){
            subject = 'MSF Envío Presupuesto Celebraciones';
        }
        else if (Status == 'Pendiente OK  presupuesto') {
            subject = 'Responde a Información de Celebraciones';
        }
        else if (Status == 'Enviar petición info diseño') {
            subject = 'MSF Solicita Información Diseño Celebraciones'; 
        }
        else if(Status == 'Pendiente info para diseño'){
            subject = 'Responde a Información de Celebraciones';
        }
        else if(Status == 'Enviar diseño'){
            subject = 'MSF Envío Confirmación Diseño Celebraciones';
        }
        else if (Status == 'Pendiente aprobación diseño') {
            subject = 'Responde a Información de Celebraciones';
        }
        else if(Status == 'Enviar datos de pago'){
            subject = 'MSF Envío Datos Pago Celebraciones';
        }
        else if (Status == 'Pendiente justificante') {
            subject = 'Envía a MSF Justificante Pago Celebraciones'; 
        }
        else if(Status == 'Enviar a Imprenta'){
            subject = 'MSF Envío a Imprenta Celebraciones';
        }
        else if(Status == 'Enviar email agradecimiento'){
            subject = 'MSF Agradecimiento Celebraciones';
        }

        //RecordType Iniciativa solidaria
        else if(Status == 'Petición IS Recibida'){
            subject = 'Propone Iniciativa Solidaria';
            taskStatus = 'Realizada'; 
        }
        else if (Status == 'Rechazada') {
            subject = 'MSF Aviso Rechazo Iniciativa Solidaria'; 
        }
    	
        //Crear la Tarea por defecto; 
        Task tNew =  new Task(
            Subject = subject,
            Status = taskStatus
        );
        taskToCreate.add(tNew);
        
       //Set default values for each  new task; 
       for (Task t : taskToCreate) {
           t.OwnerId = UserInfo.getUserId();
           t.WhoId = contactId;
           t.WhatId = caseId;
           t.ActivityDate = date.today();
       }
        
        return taskToCreate;
    }
}