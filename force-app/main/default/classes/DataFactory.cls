/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 06-01-2022
 * @last modified by  : sheredia@omegacrmconsulting.com
**/
@isTest
public with sharing class DataFactory {
    
    public static Contact getIndividualContact(String lastName, String marcaEstrategica, Integer currentAmount, Integer amountLifeTime, String delReason){
        return new Contact(
            LastName = lastName, 
            RecordTypeId = RecordTypes.individualContactID,
            msf_RecalculateLevel__c = true,
            Marca_estrategica__c = marcaEstrategica,
            msf_LevelHCCurrentFiscalYear__c = currentAmount,
            msf_LevelHCLifetime__c = amountLifeTime,
            msf_ContactDeleteReason__c = delReason
        );
    }

    public static Contact getOrganizationContact(String lastName, String marcaEstrategica, Integer currentAmount, Integer amountLifeTime, String delReason){
        return new Contact(
            LastName = lastName, 
            RecordTypeId = RecordTypes.organizationContactID,
            msf_RecalculateLevel__c = true,
            Marca_estrategica__c = marcaEstrategica,
            msf_LevelHCCurrentFiscalYear__c = currentAmount,
            msf_LevelHCLifetimeVD__c = amountLifeTime + 1,
            msf_LevelHCLifetime__c = amountLifeTime ,
            msf_ContactDeleteReason__c = delReason
        );
    }

    public static Contact getOrganizationContact(String lastName, String marcaEstrategica, Integer currentAmount, Integer amountLifeTime, String delReason, String orgType){
        return new Contact(
            LastName = lastName, 
            RecordTypeId = RecordTypes.organizationContactID,
            msf_RecalculateLevel__c = true,
            Marca_estrategica__c = marcaEstrategica,
            msf_LevelHCCurrentFiscalYear__c = currentAmount,
            msf_LevelHCLifetimeVD__c = amountLifeTime + 1,
            msf_LevelHCLifetime__c = amountLifeTime ,
            msf_ContactDeleteReason__c = delReason,
            msf_OrganizationType__c = orgType
        );
    }

    public static Campaign getCampaign(String name, String promotorID, Boolean isFinal, String recordTypeId){
        return new Campaign(
            Name = name,
            msf_PromoterIndividual__c = promotorID, 
            msf_FinalCampaign__c = isFinal,
            RecordTypeId = recordTypeId
        );
    }
    
    public static Opportunity getOpportunity(String name, String stage, String type, String recordTypeId, String contactId, Date close){
        return new Opportunity(
            Name = name,
            RecordTypeId = recordTypeId,
            StageName = stage,
            Type = type,
            CloseDate = close == null ? System.today() : close,
            npsp__Primary_Contact__c = contactId
        );
    }
    
    public static Opportunity getDonationCobrada(String contactId, Date close, String paymentId){
        return new Opportunity(
            Name = 'LevelCalculationOpportunity',
            RecordTypeId = RecordTypes.donationID,
            StageName = 'Cobrada',
            Type = 'One off Donation',
            CloseDate = close == null ? System.today() : close,
            npsp__Primary_Contact__c = contactId,
            Amount = 10,
            msf_EntryDate__c = close == null ? System.today() : close,
            npsp4hub__Payment_Method__c = 'TRANSFERENCIA BANCARIA',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Payment_Profile__c = paymentId,
            npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA'
        );
    }
    
    public static cpm__Payment_Profile__c getPayment(String contactId){
        return new cpm__Payment_Profile__c(
            cpm__Contact__c = contactId,
            recordtypeId = RecordTypes.IBANID,
            cpm__IBAN__c = 'ES4714577504091166875044',
            msf_HolderFirstName__c = 'Test',
            msf_HolderLastName1__c = 'a',
            msf_HolderLastName2__c = 'a',
            msf_NIF__c = null,
            cpm__Holder_Name__c = '',
            cpm__Active__c = true
        ); 
    }
    
    public static Case getCase(String status, String recordTypeId, String contactId){
        return new Case(
            RecordTypeId = recordTypeId,
            Status = status,
            ContactId = contactId
        );
    }
    
    public static npe03__Recurring_Donation__c getRecurringDonation(Date datee, String status, String recordTypeId, String contactId){
        return new npe03__Recurring_Donation__c(
            RecordTypeId = recordTypeId,
            npe03__Open_Ended_Status__c = status,
            npe03__Contact__c = contactId,
            npsp4hub__Payment_Method__c = 'Direct Debit',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA',
            npe03__Installment_Period__c = 'Monthly',
            npe03__Date_Established__c = datee
        );
    }

    public static User getUser(String email, String username, String firstname, String lastname, String alias, String profile) {
        return new User(Email = email, Username = username, FirstName = firstname, LastName = lastname, Alias = alias, 
        TimeZoneSidKey = 'Australia/Sydney', LocaleSidKey ='en_US', EmailEncodingKey ='UTF-8',LanguageLocaleKey ='en_US', ProfileId = profile);
    }
}