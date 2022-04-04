/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 02-23-2022
 * @last modified by  : sheredia@omegacrmconsulting.com
**/
global with sharing class ConvertLeadToContact implements dupcheck.dc3Plugin.InterfaceConvert {

    global static void afterConvert(Database.LeadConvertResult leadConvertResult, Task taskData) {
        ID leadID = leadConvertResult.getLeadId();
        ID contactID = leadConvertResult.getContactId();

        if (contactID != NULL){
            List<Opportunity> oppFromLead = [SELECT ID, npsp__Primary_Contact__c, msf_LeadId__c FROM Opportunity WHERE msf_LeadId__c =: leadID];
            
            for (Opportunity opp : oppFromLead){
                opp.npsp__Primary_Contact__c = contactID;
                opp.msf_LeadId__c = null;
            }

            update oppFromLead;
        }

    }
    
    global static void beforeConvert(Database.LeadConvert leadConvertData) {
        

    }

    global static void convertFailed(Database.LeadConvert leadConvertData, dupcheck.dc3Exception.ConvertException exceptionData) {

    }

}