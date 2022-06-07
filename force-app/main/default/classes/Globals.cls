/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : sheredia@omegacrmconsulting.com
**/
public with sharing class Globals {
    
    public static Boolean bEcoUser {get{ 
        if (bEcoUser == null)
        bEcoUser = [SELECT Id, msf_EconomicProcessUser__c FROM User WHERE Id =: UserInfo.getUserId()].msf_EconomicProcessUser__c;        
        return bEcoUser ;
    }set;}

    public static ID adminProfileID {get{ 
        if (adminProfileID == null)
        adminProfileID = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;        
        return adminProfileID ;
    }set;}

    public static List<msf_LeadSourceMasterData__c> leadSources {get{ 
        if (leadSources == null)
        leadSources = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c FROM msf_LeadSourceMasterData__c];        
        return leadSources ;
    }set;}

}