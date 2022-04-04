/**
* @author 		Deloitte
* @date 		02-2019
* @group 		Task
* @description	Contains the logic that is applied to some fields based on other fields or related objects.
*/
global without sharing class MSF_TaskFieldsLogic_TDTM extends npsp.TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description  Trigger Handler on Tasks that contains the logic that is applied to some fields based 
    * 				on other fields or related objects.
    * @param        listNew the list of Tasks from trigger new. 
    * @param        listOld the list of Tasks from trigger old. 
    * @param        triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param        objResult the describe for Tasks.
    * @return       dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        
        //Attributes
        List<Task> lNewTasks = (List<Task>) newlist;
        List<Task> lOldTasks = (List<Task>) oldlist;
        Map<Id, Task> mOldTasks = new Map<Id, Task>();
        if(lOldTasks != null){            
            mOldTasks.putAll(lOldTasks);
        }
        
        Set<String> sSubjectAllowedValues = new Set<String>();
        Map<String,msf_InteractionsMasterData__c> mIntMD = new Map<String,msf_InteractionsMasterData__c>();
        mIntMD = getInteractionDependences();
        
        List<RecordType> rTLeads = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead'];
        List<Id> idsRTLeads = new List<Id>(); 
        for (RecordType rt : rTLeads) {
            idsRTLeads.add(rt.Id);
        }
        System.debug('Hello there');
        
        //DML WRAPPER
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
   
        //BEFORE INSERT && BEFORE UPDATE
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate ) {
            sSubjectAllowedValues = getStatusAllowedValues();
			System.debug('Values: '+sSubjectAllowedValues);
            System.debug('Hello there 2');
			List<Id> tasksContactsIds = new List<Id>();             
            for (Task t : lNewTasks) {
                tasksContactsIds.add(t.WhoId);
            }
            Map<Id, Contact> tasksContacts = new Map<Id, Contact>();  
            for (Contact c : [SELECT Id, msf_OppFiscalAmountLastYear__c, msf_FiscalFirstName__c,
                              msf_FiscalLastName1__c, msf_FiscalLastName2__c, msf_fiscalNif__c
                              FROM Contact WHERE Id IN :tasksContactsIds]) {
				tasksContacts.put(c.Id, c);                
            }
            
            for(Task t : lNewTasks){
                if(t.msf_Channel__c != null && !sSubjectAllowedValues.isEmpty() && !sSubjectAllowedValues.contains(t.Subject)){
                    t.Subject.addError(System.label.MSF_INTERACTIONS_SUBJECT_ERROR);    
                }

                if(!mOldTasks.isEmpty() && !mIntMD.isEmpty() && mIntMD.containsKey(t.Subject)){
                    Task oldTask = mOldTasks.get(t.Id);
                    if (oldTask.Subject != t.Subject || oldTask.msf_TaskNumber__c != t.msf_TaskNumber__c){
                        msf_InteractionsMasterData__c intMD = mIntMD.get(t.Subject);
                        t.msf_TaskNumber__c = intMD.msf_TaskNumber__c;
                    }
                }
                
                if(mOldTasks.isEmpty() && !mIntMD.isEmpty() && mIntMD.containsKey(t.Subject)){
                    setDefaultValues(t, mIntMD.get(t.Subject));
                }
                              
                
                if (t.msf_TaskNumber__c == 224 || t.msf_TaskNumber__c == 225 || t.msf_TaskNumber__c == 226 || t.msf_TaskNumber__c == 227) {
                    Contact c = tasksContacts.get(t.WhoId);
                    if (c != null) {
						t.msf_AttributeOne__c = String.valueOf(c.msf_OppFiscalAmountLastYear__c); 
                        t.msf_AttributeTwo__c = String.valueOf(System.today().year() - 1); 
                        t.msf_AttributeThree__c = c.msf_FiscalFirstName__c; 
                        t.msf_AttributeFour__c = c.msf_FiscalLastName1__c; 
                        t.msf_AttributeFive__c = c.msf_FiscalLastName2__c; 
                        t.msf_AttributeSix__c = c.msf_fiscalNif__c;
                    }
                }
            }  
        }
        
        //AFTER INSERT
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
            List<Task> subtasksToAdd = new List<Task>();
            for(Task t : lNewTasks){
               	msf_InteractionsMasterData__c mInt = mIntMD.get(t.Subject);
                 if (mInt != null && mInt.msf_GenerateTask__c != null && t.msf_ParentTaskId__c == null) {
                     Task subTask = new Task();
                     subTask.msf_ParentTaskId__c = String.valueOf(t.Id);
                     subTask.Subject = getTaskSubjectByTaskNumber(String.valueOf(mInt.msf_GenerateTask__c), mIntMD.values());
                     subTask.OwnerId = t.OwnerId;
                     subTask.msf_StartDate__c = t.msf_StartDate__c;
                     subTask.msf_RelatedContact__c = t.msf_RelatedContact__c; 
                     subTask.WhatId = t.WhatId;
                     subTask.WhoId = t.WhoId;
                     subTask.msf_Campaign__c = t.msf_Campaign__c; 
                     subTask.msf_LeadSource__c = t.msf_LeadSource__c; 
                     subTask.ActivityDate = t.ActivityDate;
                     subTask.msf_TypeTemplate__c = t.msf_TypeTemplate__c;
                     subTask.msf_ProactiveReactive__c = 'n/a';
                     subTask.msf_Channel__c = 'n/a';
                     subtasksToAdd.add(subTask);
                 }
            }
            dmlWrapper.objectsToInsert.addAll(subtasksToAdd);
            return dmlWrapper;
        }
       
        //AFTER DELETE
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterDelete) {
            List<Task> childTasksToUpdate = new List<Task>();
            
            childTasksToUpdate.addAll(removeParentFromChildTasks(lOldTasks));
            
            dmlWrapper.objectsToUpdate.addAll(childTasksToUpdate);
            return dmlWrapper;
        }
                
        return null;        
    }
    
    
    // PRIVATE METHODS    
    private static List<Task> removeParentFromChildTasks(List<Task> tasks) {
        List<String> taskIds = new List<String>();
        for (Task t : tasks) {
            String ids = String.valueOf(t.Id);
            taskIds.add(ids);
        }
        
        List<Task> childTasks = [SELECT msf_ParentTaskId__c FROM Task WHERE msf_ParentTaskId__c IN :taskIds];
        for (Task tt : childTasks) {
            tt.msf_ParentTaskId__c = null; 
        }
        return childTasks; 
    }
    
    /*******************************************************************************************************
    * @description  Obtain the values of the Subject picklist field in Task object.
    * @return       Set<String>
    ********************************************************************************************************/ 
    private Set<String> getStatusAllowedValues (){        
        Set<String> sValues = new Set<String>();
        
        Schema.DescribeFieldResult fieldResult = Task.Subject.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry pe : pickListValues){            
            sValues.add(pe.getValue());            
        }
        
        return sValues;
    }
    
    /*******************************************************************************************************
    * @description 	Returns a map that contains all the records of the msf_InteractionsMasterData__c object 
    * 				with the value of the msf_Subject__c field as the key.     
    * @return	 	Map<String, String> has the values recovered.        
    ********************************************************************************************************/
    private Map<String, msf_InteractionsMasterData__c> getInteractionDependences(){        
        Map<String, msf_InteractionsMasterData__c> mReturnValues = new Map<String, msf_InteractionsMasterData__c>();        
        
        for(msf_InteractionsMasterData__c imd : [SELECT msf_Subject__c, msf_Campaign__c, msf_Channel__c, msf_LeadSource__c, msf_Comment__c, msf_TaskNumber__c,
                                                 msf_Status__c, msf_Family__c, msf_Objective__c, msf_ProactiveReactive__c, msf_InboundOutbound__c, msf_Thematic__c,
                                                 msf_Owner__c, msf_AttributeOne__c, msf_AttributeTwo__c, msf_AttributeThree__c, msf_AttributeFour__c, msf_AttributeFive__c, 
                                                 msf_AttributeSix__c, msf_Commitment__c, msf_GenerateTask__c,msf_Thematic2__c,msf_ProductProgram__c, MSF_ServiceOwner__c, msf_TypeTemplate__c
                                                 FROM msf_InteractionsMasterData__c ])
        {              
            mReturnValues.put(imd.msf_Subject__c, imd);                      
        }
        
        return mReturnValues;
    }
    
    
    private String getTaskSubjectByTaskNumber(String taskNumber, List<msf_InteractionsMasterData__c> interactionDependences) {
        String subject = null;
        Integer i = 0; 
        while (subject == null && i < interactionDependences.size()) {
          	msf_InteractionsMasterData__c iM = interactionDependences.get(i);
            if (String.valueOf(iM.msf_TaskNumber__c).equals(taskNumber)) {
                subject = iM.msf_Subject__c;
            }
            i++;
        }
        return subject; 
    }
    
    /*******************************************************************************************************
    * @description 	Returns a map that contains all the records of the msf_InteractionsMasterData__c object 
    * 				with the value of the msf_Subject__c field as the key. 
    * @param        t is the task to which your information is updated.
    * @param        intMD contains the default values for the task.             
    ********************************************************************************************************/
    private void setDefaultValues (Task t, msf_InteractionsMasterData__c intMD){
        
		t.msf_TaskNumber__c = intMD.msf_TaskNumber__c;
        t.msf_StartDate__c = date.today();
        
        if(t.Status == null){
        	t.Status = intMD.msf_Status__c;
        }
        if(t.msf_InboundOutbound__c == null){
        	t.msf_InboundOutbound__c = intMD.msf_InboundOutbound__c;
        }
        if(t.msf_Channel__c == null){
        	t.msf_Channel__c = intMD.msf_Channel__c;
        }
        if(t.msf_ProactiveReactive__c == null){
        	t.msf_ProactiveReactive__c = intMD.msf_ProactiveReactive__c;
        }
        if(t.msf_Campaign__c == null){
        	t.msf_Campaign__c = intMD.msf_Campaign__c;
        }
        if(t.msf_LeadSource__c == null){
            t.msf_LeadSource__c = intMD.msf_LeadSource__c;
        }
        if(t.Description == null){
        	t.Description = intMD.msf_Comment__c;
        }
        if(t.msf_Family__c == null){
        	t.msf_Family__c = intMD.msf_Family__c;
        }
        if(t.msf_Objective__c == null){
        	t.msf_Objective__c = intMD.msf_Objective__c;
        } 
        if (t.msf_Thematic__c == null) {
            t.msf_Thematic__c = intMD.msf_Thematic__c; 
        }
        if (t.msf_Thematic2__c == null) {
            t.msf_Thematic2__c = intMD.msf_Thematic2__c; 
        }
        if (t.msf_Commitment__c == null) {
            t.msf_Commitment__c= intMD.msf_Commitment__c;
        }
        if (t.msf_AttributeOne__c == null) {
            t.msf_AttributeOne__c = intMD.msf_AttributeOne__c;
        }
        if (t.msf_AttributeTwo__c == null) {
            t.msf_AttributeTwo__c = intMD.msf_AttributeTwo__c;
        }
        if (t.msf_AttributeThree__c == null) {
            t.msf_AttributeThree__c = intMD.msf_AttributeThree__c;
        }
        if (t.msf_AttributeFour__c == null) {
            t.msf_AttributeFour__c = intMD.msf_AttributeFour__c;
        }
        if (t.msf_AttributeFive__c == null) {
            t.msf_AttributeFive__c = intMD.msf_AttributeFive__c;
        }
        if (t.msf_AttributeSix__c == null) {
            t.msf_AttributeSix__c = intMD.msf_AttributeSix__c;
        }
        if (t.msf_ProductProgram__c == null) {
            t.msf_ProductProgram__c = intMD.msf_ProductProgram__c;
        }
        if (t.msf_Owner__c == null) {
            t.msf_Owner__c = intMD.MSF_ServiceOwner__c;
        }
        if (t.msf_TypeTemplate__c == null) {
            t.msf_TypeTemplate__c = intMD.msf_TypeTemplate__c; 
        }
        if (t.ActivityDate == null && t.RecurrenceActivityId == null && t.IsRecurrence != true ) {  // Zenit #19563
            t.ActivityDate = date.today();
        }
        
    }   

}