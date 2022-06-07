/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 02-05-2022
 * @last modified by  : arubio@omegacrmconsulting.com
**/
public with sharing class RecordTypes {
    
    public static ID individualContactID {get{ 
        if (individualContactID == null)
        individualContactID = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Individual_Contact'].Id;        
        return individualContactID ;
    }set;}

    public static ID organizationContactID {get{ 
        if (organizationContactID == null)
        organizationContactID = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Organization'].Id;        
        return organizationContactID ;
    }set;}

    public static ID oppKingGiftID {get{ 
        if (oppKingGiftID == null)
        oppKingGiftID = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'In_Kind_Gift'].Id;        
        return oppKingGiftID ;
    }set;}

    public static ID defaultCampaignID {get{ 
        if (defaultCampaignID == null)
        defaultCampaignID = [SELECT Id FROM RecordType WHERE SObjectType = 'Campaign' AND DeveloperName = 'Default'].Id;        
        return defaultCampaignID ;
    }set;}

    public static ID donationID {get{ 
        if (donationID == null)
        donationID = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Donation'].Id;        
        return donationID ;
    }set;}

    public static ID oppHerencia {get{ 
        if (oppHerencia == null)
        oppHerencia = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Legacy'].Id;        
        return oppHerencia ;
    }set;}

    public static ID caseTestamentoInfoID {get{ 
        if (caseTestamentoInfoID == null)
        caseTestamentoInfoID = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'MSF_CE_RequestTestamentaryInfo'].Id;        
        return caseTestamentoInfoID ;
    }set;}

    public static ID recurringDonationID {get{ 
        if (recurringDonationID == null)
        recurringDonationID = [SELECT Id FROM RecordType WHERE SObjectType = 'npe03__Recurring_Donation__c' AND DeveloperName = 'Recurring_donation'].Id;        
        return recurringDonationID ;
    }set;}

    public static ID IBANID {get{ 
        if (IBANID == null)
        IBANID = [SELECT Id FROM RecordType WHERE SObjectType = 'cpm__Payment_Profile__c' AND DeveloperName = 'IBAN'].Id;        
        return IBANID ;
    }set;}

}