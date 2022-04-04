/**
* @author       Deloitte
* @date         12-2018
* @group        Contact / PaymentProfile.
* @description  Anonymization process of the contact and they payment profiles and organizatión contact in case of a organization.
*/
public without sharing class MSF_AnonymizationProcess_CTRL {

    /*******************************************************************************************************
    * @description	Manage the anonymation process.
    * @param		recordId is a contact ID to anonymize.				
    * @return		Map<String, Object>	than contains the result of the anonymization process.
    ********************************************************************************************************/
    @AuraEnabled
    public static Object anonymizationRecord (ID recordId){
        
        Map<String, Object> mResult = new Map<String, Object>();
        List<Id> lPPids = new List<Id>(); 
        List<Id> cIds = new List<Id>();  
        mResult.put('anonymizationSuccess', false);
        mResult.put('msg',''); 
        String exObError = '';
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            anonymizePaymentProfilesExternal(recordId);
            cIds = anonymizeContact(recordId);            
            lPPids = anonymizePaymentProfiles(recordId);           
            deleteAssociativeInfo(recordId);
            deleteGDPRLogs(recordId);
            deleteAffiliation(recordId);
			deleteRelationships(recordId);   
            deleteFieldTrackingHistory(cIds, lPPids);

            mResult.put('anonymizationSuccess', true); 
            mResult.put('msg', System.Label.MSF_ANONYMIZATION_SUCCESS_MSG);      
        }catch(DMLException dmlEx){
            Database.rollback(sp);
            mResult.put('msg', System.Label.MSF_ERROR + ' ' + dmlEx.getDmlMessage(0));
        }catch(Exception ex){
            Database.rollback(sp);
            mResult.put('msg', System.Label.MSF_ERROR + ' ' + ex.getMessage());
            system.debug(ex);
        }
        
        return mResult;
    }
    
    
    // PRIVATE METHODS
    
    /*******************************************************************************************************
    * @description	Anonymize a contact. If it is an organization, also anonymize the contacts of the 
    * 				organization and your account.
    * @param		contactId is a contact ID to anonymize.							
    ********************************************************************************************************/ 
    private static List<Id> anonymizeContact(Id contactId){
        
        Map<String,Schema.RecordTypeInfo> mRtInfo = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();  
        Boolean isOrg = false;
        
        List<Contact> lConToAnonymize = new List<Contact>();
        List<Account> lAccountsToDelete = new List<Account>();
        
        String sName = 'Miembro eliminado ' + date.today().day() + '-' + date.today().month() + '-' + date.today().year();
        String sWildcard = '.';
        
        Contact con = [SELECT Id, RecordTypeId, AccountId FROM Contact WHERE Id =: contactId ]; 
        isOrg = con.RecordTypeId == mRtInfo.get('Organization').getRecordTypeId();
        
        List<Id> cIds = new List<Id>();        

        if(isOrg){
            for(Contact c : [SELECT Id FROM Contact WHERE msf_Organization__c =: contactId AND RecordType.DeveloperName = 'Organization_Contact']){            
                lConToAnonymize.add(anonymizeContactFields(c, sName, sWildcard, false));    
                cIds.add(c.Id);
            }
            if(!lConToAnonymize.isEmpty()){
                update lConToAnonymize;   
            }
            
            List<Account> a = new List<Account>([SELECT Id, Name FROM Account WHERE npe01__One2OneContact__c =: contactId AND Id =: con.AccountId LIMIT 1]);
            if(!a.isEmpty()){
                a[0].Name = sName;
                a[0].BillingCity = null;
                a[0].BillingCountry = null;
                a[0].BillingPostalCode = null;
                a[0].BillingState = null;
                a[0].BillingStreet = null;
                update a[0];
            }            
        }
        else {
			//Anonimizar Cuenta; 
            Account conAccount = [SELECT Id, npe01__One2OneContact__c, npsp__Number_of_Household_Members__c FROM Account WHERE Id =: con.AccountId LIMIT 1];
            if (conAccount != null) {
                List<Contact> contactsInAccount = [SELECT Id FROM Contact WHERE AccountId =: conAccount.Id];
                if (contactsInAccount.size() == 1) {
                    
                    List<Opportunity> oppsAccount = [SELECT Id, AccountId, npsp__Primary_Contact__c, npsp4hub__Payment_Profile__c FROM Opportunity 
                                                     WHERE AccountId =: conAccount.Id AND StageName = 'Cobrada'];
                    if (oppsAccount.size() >= 1) { //Si hay Oportunidades relacionadas con la cuenta y estan cobradas, no se podrá eliminar la cuenta; 
                        conAccount.Name = 'HOUSEHOLD - ' + sName; 
                        conAccount.npo02__Formal_Greeting__c = sName; 
                        conAccount.npo02__Informal_Greeting__c = sName; 
                        conAccount.BillingCity = null; 
                        conAccount.BillingCountry = null; 
                        conAccount.BillingPostalCode= null; 
                        conAccount.BillingState = null; 
                        conAccount.BillingStreet = null; 
                        conAccount.ShippingCity = null; 
                        conAccount.ShippingCountry = null; 
                        conAccount.ShippingPostalCode = null; 
                        conAccount.ShippingState = null; 
                        conAccount.ShippingStreet = null; 
                        conAccount.msf_IslaBilling__c = null; 
                        conAccount.msf_IslaShipping__c = null; 
                    }
                    else {
                        conAccount.npe01__One2OneContact__c = null; 
                    	con.AccountId = null; 
                        
                    	lAccountsToDelete.add(conAccount);    
                    }
                    
                    update conAccount; 
                }
                else {
                    if (conAccount.npe01__One2OneContact__c == con.Id) { // Es contacto principal de la cuenta; 
                        List<Contact> accountContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId =: con.AccountId AND Id != :con.Id];
                        
                        conAccount.npe01__One2OneContact__c = accountContacts.get(0).Id;
                        update conAccount; 
                    }
                    con.AccountId = null;
                }
            }        
        }
        
        con = anonymizeContactFields(con, sName, sWildcard, isOrg);
        cIds.add(con.Id);
        
        update con;  
        
        List<Case> caseAccounts = new List<Case>();
        if (!lAccountsToDelete.isEmpty()) {
            //Antes de borrar la cuenta hay que reasignar los casos; 
            caseAccounts = [SELECT Id, AccountId, ContactId FROM Case WHERE AccountId IN :lAccountsToDelete];
            for (Case c : caseAccounts) {
                c.AccountId = null; 
                c.ContactId = null; 
            }
            update caseAccounts;
            
        	delete lAccountsToDelete; 
        }

        if (!caseAccounts.isEmpty()) {
            for (Case c : caseAccounts) {
                c.ContactId = con.Id; 
            }
            update caseAccounts; 
        }
        
		return cIds;
    }
    
    /*******************************************************************************************************
    * @description 	Anonymize fields of the contact object
    * @param		conToAnonymize is the contact to anonymize
    * @param		sFirstName is a string to set the name of the contact
    * @param		sLastName is a string to set the name of the contact
    * @param 		isOrg is a boolean to know if the contact is a organization.		
    * @return 		Contact with the updated fields.		
    ********************************************************************************************************/
    private static Contact anonymizeContactFields(Contact conToAnonymize, String sFirstName, String sLastName, Boolean isOrg){
        
        conToAnonymize.msf_ContactDeleteReason__c = 'Miembro eliminado'; 
        conToAnonymize.msf_Organization__c = null;
        
        conToAnonymize.FirstName = isOrg ? null : sFirstName;
        conToAnonymize.LastName = isOrg ? (sFirstName+' '+sLastName) : sLastName;
        conToAnonymize.Suffix = null;
        conToAnonymize.msf_NIF__c = null;
        conToAnonymize.msf_FiscalFirstName__c = null;
        conToAnonymize.msf_FiscalLastName1__c = null;
        conToAnonymize.msf_FiscalLastName2__c = null; 
        conToAnonymize.msf_fiscalNif__c = null;
        conToAnonymize.Birthdate = null;
        conToAnonymize.msf_birthyear__c = null;
        conToAnonymize.msf_TrustedName__c = null;
        conToAnonymize.msf_Nickname__c = null;
        
        // Contact information
        conToAnonymize.Phone = null;
        conToAnonymize.OtherPhone = null;
        conToAnonymize.MobilePhone = null;
        conToAnonymize.HomePhone = null;
        conToAnonymize.msf_RestrictedPhone__c = null;
        conToAnonymize.msf_RestrictedMobilePhone__c = null;
        conToAnonymize.msf_NoEspPhone__c = null;
        conToAnonymize.msf_NoEspPhoneBackup__c = null;
        conToAnonymize.msf_NoEspMobilePhone__c = null;
        conToAnonymize.msf_MobilePhone2__c = null;
        conToAnonymize.Email = null;
        conToAnonymize.msf_RestrictedEmail__c = null;
        conToAnonymize.msf_MainEmail__c = null;
        conToAnonymize.npe01__WorkEmail__c = null;
        conToAnonymize.npe01__HomeEmail__c = null;
        conToAnonymize.npe01__AlternateEmail__c = null;
        conToAnonymize.MailingCity = null;
        conToAnonymize.MailingCountry = null;
        conToAnonymize.MailingGeocodeAccuracy = null;
        conToAnonymize.MailingLatitude = null;
        conToAnonymize.MailingLongitude = null;
        conToAnonymize.MailingPostalCode = null;
        conToAnonymize.MailingState = null;
        conToAnonymize.MailingStreet = null;
        conToAnonymize.OtherCity = null;
        conToAnonymize.OtherCountry = null;
        conToAnonymize.OtherGeocodeAccuracy = null;
        conToAnonymize.OtherLatitude = null;
        conToAnonymize.OtherLongitude = null;
        conToAnonymize.OtherPostalCode = null;
        conToAnonymize.OtherState = null;
        conToAnonymize.OtherStreet = null;
        conToAnonymize.msf_DateReturnedMail1__c = null;
        conToAnonymize.msf_DateReturnedMail2__c = null;
        conToAnonymize.msf_DateReturnedMail3__c = null;
        
        // Backup contact information
        conToAnonymize.msf_RestrictedPhoneBackup__c = null;
        conToAnonymize.msf_RestrictedMobilePhoneBackup__c = null;
        conToAnonymize.msf_OtherPhoneBackup__c = null;
        conToAnonymize.msf_NoEspMobilePhoneBackup__c = null;
        conToAnonymize.msf_MobilePhoneBackup__c = null;
        conToAnonymize.msf_MobilePhone2Backup__c = null;
        conToAnonymize.msf_HomePhoneBackup__c = null;
        conToAnonymize.msf_RestrictedEmailBackup__c = null;
        conToAnonymize.msf_MainEmailBackup__c = null;
        conToAnonymize.msf_HomeEmailBackup__c = null;
        conToAnonymize.msf_AlternateEmailBackup__c = null;
        conToAnonymize.msf_MailingCityBackup__c = null;
        conToAnonymize.msf_MailingCountryBackup__c = null;
        conToAnonymize.msf_MailingPostalCodeBackup__c = null;
        conToAnonymize.msf_MailingStateBackup__c = null;
        conToAnonymize.msf_MailingStreetBackup__c = null;
        conToAnonymize.msf_OtherCityBackup__c = null;
        conToAnonymize.msf_OtherCountryBackup__c = null;
        conToAnonymize.msf_OtherPostalCodeBackup__c = null;
        conToAnonymize.msf_OtherStateBackup__c = null;
        conToAnonymize.msf_OtherStreetBackup__c = null;
        conToAnonymize.msf_DateReturnedMail1Backup__c = null;
        conToAnonymize.msf_DateReturnedMail2Backup__c = null;
        conToAnonymize.msf_DateReturnedMail3Backup__c = null;
        
        // Other fields        
        conToAnonymize.msf_IsAssosiative__c = false;        
        conToAnonymize.msf_IsPrimary__c = false;
        conToAnonymize.msf_NoRecibirNada__c = true;          
        conToAnonymize.npsp__is_Address_Override__c = false;
        
        return conToAnonymize;
    }
    
    /*******************************************************************************************************
    * @description 	Anonymize fields of the payment profile object
    * @param 		contactId is a contact ID from which to search your payment profiles to anonymize.						
    ********************************************************************************************************/
    private static List<Id> anonymizePaymentProfiles(Id contactId){
        
        List<cpm__Payment_Profile__c> lPayProToAnonymize = new List<cpm__Payment_Profile__c>(); 
        List<Id> lPPids = new List<Id>(); 
        
        for(cpm__Payment_Profile__c pp : [SELECT id FROM cpm__Payment_Profile__c WHERE cpm__Contact__c =: contactId]){
        	
            pp.msf_HolderFirstName__c = null;  
            pp.msf_HolderLastName1__c = null;
            pp.msf_HolderLastName2__c = null;
            pp.msf_NIF__c = null;
            pp.cpm__Holder_Name__c = null;            
            pp.cpm__Bank_Account__c = 'ES8200000000000000000000';
            pp.cpm__IBAN__c = 'ES8200000000000000000000';            
            pp.cpm__Credit_Card_Number__c = null;
            pp.cpm__CCV__c = null;
            pp.cpm__Token_Issuer__c = null;
            pp.cpm__Token__c = null;            
            pp.msf_CRMExternalId__c = null;            
            pp.cpm__Active__c = false;
            
            lPayProToAnonymize.add(pp);
            lPPids.add(pp.Id);
        }
        
        if(!lPayProToAnonymize.isEmpty()){
        	update lPayProToAnonymize;   
            
            return lPPids;
        }   
        
        return null;
    }
    
    /*******************************************************************************************************
    * @description 	Anonymize fields of the payment profile object
    * @param 		contactId is a contact ID from which to search your payment profiles to anonymize.						
    ********************************************************************************************************/
    private static void anonymizePaymentProfilesExternal(Id contactId){
        
        List<msf_payment_profile_h__x> lPayProToAnonymize = new List<msf_payment_profile_h__x>();  

        Contact c = new Contact();        
        
        c = [SELECT msf_CRMExternalId__c FROM Contact WHERE Id =: contactId LIMIT 1];                
        
        List<msf_payment_profile_h__x> lpph = new List<msf_payment_profile_h__x>();
        lpph = [SELECT id, cpm_Holder_Name_c__c, cpm_IBAN_c__c, cpm_Token_Issuer_c__c, cpm_Token_c__c, msf_CRMExternalId_c__c, cpm_Active_c__c, cpm_Contact_c__c
                FROM msf_payment_profile_h__x 
                WHERE cpm_Contact_c__c =: c.msf_CRMExternalId__c]; 
        
        for(msf_payment_profile_h__x pp : lpph){
            
            pp.cpm_Holder_Name_c__c = 'null';            
            pp.cpm_IBAN_c__c = 'ES8200000000000000000000';            
            pp.cpm_Token_Issuer_c__c = null;
            pp.cpm_Token_c__c = null;            
            pp.msf_CRMExternalId_c__c = pp.cpm_Contact_c__c+'_ES8200000000000000000000'; 
            pp.ExternalId = c.msf_CRMExternalId__c+'_ES8200000000000000000000';
            pp.cpm_Active_c__c = false;
            
            lPayProToAnonymize.add(pp);
        }
        
        if(!lPayProToAnonymize.isEmpty()){
            List<Database.SaveResult> srl = Database.updateImmediate(lPayProToAnonymize); 
            for(Database.SaveResult sr : srl){           
                if(!sr.isSuccess()){                      
                    for(Database.Error err : sr.getErrors()) {                                          
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());                       
                    } 
                }	
            }
        }             
    }
    
    /*******************************************************************************************************
    * @description 	Removes records of the Associative and Endorsement objects of a contact.
    * @param 		contactId is a contact ID from which to search your GDPR logs to delete.						
    ********************************************************************************************************/
    private static void deleteAssociativeInfo(Id contactId){
        
        List<Sobject> lAssociativeInfoToDelete = new List<SObject>();
                
        for(msf_Associative__c asso : [SELECT Id FROM msf_Associative__c WHERE msf_ContactId__c =: contactId]){
        	lAssociativeInfoToDelete.add(asso);		
        }
        for(msf_Endorsement__c endo : [SELECT Id FROM msf_Endorsement__c WHERE msf_isEndorsing__c =: contactId OR msf_IsEndorsed__c =: contactId]){
        	lAssociativeInfoToDelete.add(endo);		
        }
        
        if(!lAssociativeInfoToDelete.isEmpty()){
        	delete lAssociativeInfoToDelete;   
        }                
    }
    
    /*******************************************************************************************************
    * @description 	Removes records of the msf_GDPRLog__c object of a contact.
    * @param 		contactId is a contact ID from which to search your GDPR logs to delete.						
    ********************************************************************************************************/
    private static void deleteGDPRLogs(Id contactId){
        
        List<msf_GDPRLog__c> lGDPRLogsToDelete = new List<msf_GDPRLog__c>();       
        
        for(msf_GDPRLog__c log : [SELECT Id FROM msf_GDPRLog__c WHERE msf_Contact__c =: contactId]){
        	lGDPRLogsToDelete.add(log);		
        }
        
        if(!lGDPRLogsToDelete.isEmpty()){
        	delete lGDPRLogsToDelete;   
        }                
    }
    
    private static void deleteAffiliation(Id contactId) {
        List<npe5__Affiliation__c> affiliationsToDelete = new List<npe5__Affiliation__c>(); 
        
        for (npe5__Affiliation__c aff : [SELECT ID FROm npe5__Affiliation__c WHERE npe5__Contact__c =: contactId]) {
            affiliationsToDelete.add(aff);
        }
        
        if (!affiliationsToDelete.isEmpty()) {
            delete affiliationsToDelete; 
        }
    }
    
    
    private static void deleteRelationships(Id contactId) {
        List<npe4__Relationship__c> relationsToDelete = new List<npe4__Relationship__c>(); 
        
        for (npe4__Relationship__c r : [SELECT Id FROM npe4__Relationship__c WHERE npe4__Contact__c =: contactId OR npe4__RelatedContact__c =: contactId]) {
            relationsToDelete.add(r);
        }
        
        if (!relationsToDelete.isEmpty()) {
            delete relationsToDelete; 
        }
    }
    
    
    /*******************************************************************************************************
    * @description 	Removes records of the msf_GDPRLog__c object of a contact.
    * @param 		contactId is a contact ID from which to search your GDPR logs to delete.						
    ********************************************************************************************************/
    @future
    private static void deleteFieldTrackingHistory(List<ID> contactId, List<ID> lPP){
        
		List<ContactHistory> lCh = new List<ContactHistory>([SELECT Id FROM ContactHistory WHERE ContactId IN: contactId]);
        if(!lCh.isEmpty()){
         	delete lCh;   
        }
        
        if (lPP != null) {
            List<cpm__Payment_Profile__History> lPPh = new List<cpm__Payment_Profile__History>([SELECT Id FROM cpm__Payment_Profile__History WHERE ParentId IN: lPP]);
            if(!lPPh.isEmpty()){
                delete lPPh;   
            } 
        }
        
    }
    
}