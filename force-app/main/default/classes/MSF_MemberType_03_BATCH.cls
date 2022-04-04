/**
* @author       Deloitte
* @date         01-2019
* @group        Contacts
* @description  Calculation of member type.
*/
global without sharing class MSF_MemberType_03_BATCH implements Database.Batchable<sObject>{
    
    global final String query; 
    
    global MSF_MemberType_03_BATCH (){
        String queryStep = '';
        queryStep = 'SELECT Id, msf_NextMemberTypeCheck__c ';
        queryStep += 'FROM Contact ';
        queryStep += 'WHERE RecordType.DeveloperName IN (\'Individual_Contact\',\'Organization\') ';
        queryStep += 'AND (msf_RecalculateMemberType__c = TRUE ';
        queryStep += 'OR msf_MemberType__c = null ';
        queryStep += 'OR msf_NextMemberTypeCheck__c = null ';
        queryStep += 'OR msf_NextMemberTypeCheck__c < TOMORROW)';
        query = queryStep; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){

        List<Contact> lConToUpdate = new List<Contact>();
        lConToUpdate.addAll(MSF_SharedMethods_UTIL.contactMemberType(scope));
        
        // DML statements
        if(!lConToUpdate.isEmpty()){            
            Database.SaveResult[] srList = Database.update(lConToUpdate, false);            
            //*
            List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 

            for (Database.SaveResult sr : srList) { // Iterate through each returned result
                if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                    for(Database.Error err : sr.getErrors()) {
                        msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_MemberType_03', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
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
        System.debug('END BATCH - MSF_MemberType_03_BATCH');
    }    
}