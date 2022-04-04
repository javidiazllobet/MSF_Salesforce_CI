/**
* @author       Deloitte
* @date         03-2020
* @group        Contacts
* @description  Calculation of member type.
*/
global without sharing class MSF_MemberType_SociosTemp_BATCH implements Database.Batchable<sObject>{
    
    global final String query; 
    
    global MSF_MemberType_SociosTemp_BATCH (){
        String queryStep = '';
        queryStep = 'SELECT Id, msf_IsActiveRecurringDonor__c,msf_MemberType__c,msf_IsActiveDonor__c ';
        queryStep += 'FROM Contact ';
        queryStep += 'WHERE msf_IsActiveRecurringDonor__c =\'Socio\' ';
        
        query = queryStep; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){

        List<Contact> lConToUpdate = new List<Contact>();
        
        for(Contact con : scope){
            
            if(con.msf_IsActiveRecurringDonor__c == 'Socio')//no haria falta
            {
                if (con.msf_IsActiveDonor__c == 'Donante')
                {
                    con.msf_MemberType__c = 'Socio + Donante';
                }
                else if(con.msf_IsActiveDonor__c == 'Exdonante')
                {
                    con.msf_MemberType__c = 'Socio + Exdonante';
                }
                else if(con.msf_IsActiveDonor__c == 'Nunca')
                {
                    con.msf_MemberType__c = 'Socio';
                }
                lConToUpdate.add(con);
            }
        }

        if(!lConToUpdate.isEmpty()){   
            
            
            Database.SaveResult[] srList = Database.update(lConToUpdate, false);            
            //*
            List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 

            for (Database.SaveResult sr : srList) { // Iterate through each returned result
                if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                    for(Database.Error err : sr.getErrors()) {
                        msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_MemberType_SociosTemp_BATCH', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                        lAPE.add(tempAPE);
                    }
                }
            }
            
            if(!lAPE.isEmpty()){
                insert lAPE;
            }//*/ 
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_MemberType_SociosTemp_BATCH');
    }    
}