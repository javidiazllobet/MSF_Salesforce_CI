/**
* @author       Deloitte
* @date         11-2020
* @group        Contacts
* @description  Calculation of member type.
*/
global without sharing  class MSF_ActualizarFlagsMCContacto_BATCH implements Database.Batchable<sObject> {

    global final String query; 
    
    global MSF_ActualizarFlagsMCContacto_BATCH (){
        String queryStep = '';
        queryStep = 'SELECT Id, Subject, Status, WhoId ';
        queryStep += 'FROM Task ';
        queryStep += 'WHERE (Subject =\'Se Queja Presión en Captación Fondos\' OR Subject =\'Solicita Confidencialidad Herencias\') ';
        queryStep += 'AND WhoId != null';
        
        query = queryStep; 
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> scope){
        System.debug('Start ActualizarFlagsMCContacto batch');
        //Get related contacts Ids
        Set<Id> idsContacts = new Set<Id>();
        Set<Id> idsContactsToUnmarkPressure = new Set<Id>();
        Set<Id> idsContactsToUnmarkConfid = new Set<Id>();
        Set<Id> idsContactsToMarkPressure = new Set<Id>();
        Set<Id> idsContactsToMarkConfid = new Set<Id>();
        for(Task tarea: scope){
            if(String.valueOf(tarea.WhoId).startsWith('003')){
                idsContacts.add(tarea.WhoId);
                if(tarea.Status =='Cancelada' && tarea.Subject == 'Se Queja Presión en Captación Fondos') idsContactsToUnmarkPressure.add(tarea.WhoId);
                else if(tarea.Status !='Cancelada' && tarea.Subject == 'Se Queja Presión en Captación Fondos') idsContactsToMarkPressure.add(tarea.WhoId);
                else if(tarea.Status =='Cancelada' && tarea.Subject == 'Solicita Confidencialidad Herencias') idsContactsToUnmarkConfid.add(tarea.WhoId);
                else if(tarea.Status !='Cancelada' && tarea.Subject == 'Solicita Confidencialidad Herencias') idsContactsToMarkConfid.add(tarea.WhoId);
            }
        }
        
        //Get all related open tasks for contacts with cancelled tasks (to unmark), check also archived tasks
        List<Task> otherRelatedOpenTasks = [SELECT Id, Subject, Status, WhoId FROM Task WHERE Status != 'Cancelada' AND
                                      		((WhoId IN: idsContactsToUnmarkPressure AND Subject ='Se Queja Presión en Captación Fondos') OR 
                                       		(WhoId IN: idsContactsToUnmarkConfid AND Subject ='Solicita Confidencialidad Herencias')) AND
                                            isDeleted = FALSE ALL ROWS];
        
        //If the contacts have open tasks we remove them from the list to unmark and add them to the list to mark
        for(Task tarea: otherRelatedOpenTasks){
            if(tarea.Subject == 'Se Queja Presión en Captación Fondos'){
                idsContactsToUnmarkPressure.remove(tarea.WhoId);
                idsContactsToMarkPressure.add(tarea.WhoId);
            } 
            else if (tarea.Subject == 'Solicita Confidencialidad Herencias'){
                idsContactsToUnmarkConfid.remove(tarea.WhoId);
                idsContactsToMarkConfid.add(tarea.WhoId);
            }
        }
        
        //Query all relatedContacts
        List<Contact> relatedContacts = [SELECT Id, msf_PressureComplaint__c, msf_LegacyConfidentiality__c FROM Contact WHERE Id IN : idsContacts];
        
        //Prepare contacts to update
        List<Contact> contactsToUpdate = new List<Contact>();
        Boolean updateContact;
        for(Contact contact: relatedContacts){
            updateContact = FALSE;
            if(contact.msf_PressureComplaint__c == FALSE && idsContactsToMarkPressure.contains(contact.Id)){
                contact.msf_PressureComplaint__c = TRUE;
                updateContact = TRUE;
            } else if(contact.msf_PressureComplaint__c == TRUE && idsContactsToUnmarkPressure.contains(contact.Id)){
                contact.msf_PressureComplaint__c = FALSE;
                updateContact = TRUE;
            }
            if(contact.msf_LegacyConfidentiality__c == FALSE && idsContactsToMarkConfid.contains(contact.Id)){
                contact.msf_LegacyConfidentiality__c = TRUE;
                updateContact = TRUE;
            } else if(contact.msf_LegacyConfidentiality__c == TRUE && idsContactsToUnmarkConfid.contains(contact.Id)){
                contact.msf_LegacyConfidentiality__c = FALSE;
                updateContact = TRUE;
            }
            
            if(updateContact) contactsToUpdate.add(contact);
        }

        //Update DML
        update contactsToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_ActualizarFlagsMCContacto_BATCH');
    }
}