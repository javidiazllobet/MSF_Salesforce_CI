/**
* @author 		Deloitte
* @date 		10-2018
* @group 		Contacts
* @description	ContactInformationSummary and PercomsSummary fields management.
*/
global without sharing class MSF_ContactFieldsLogic_TDTM extends npsp.TDTM_Runnable {
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        //Attributes
        List<Contact> lNewCon = (List<Contact>) newlist;
        List<Contact> lOldCon = (List<Contact>) oldlist;
        Map<Id, Contact> mOldCon = new Map<Id, Contact>();
        if(lOldCon != null){            
            mOldCon.putAll(lOldCon);
        }
        
        Map<ID,Contact> mContactChanged = new Map<ID,Contact>();
        List<Contact> ContactToDesactive = new List<Contact>();
        List<Contact> lOrgUpsert = new List<Contact>();
        List<Contact> deceasedContacts = new List<Contact>();
        
        Map<String, List<sObject>> objectsToUpdate = new Map<String, List<sObject>>();

        String type;        
        
        //BEFORE INSERT
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert){
            for(Contact c : lNewCon){
                if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId() || 
                   c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId() ){
                    c.npsp__is_Address_Override__c  = true;
                }
            }
        }
        
        //BEFORE INSERT || BEFORE UPDATE
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert ||triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate ) {
            
            MSF_SharedMethods_UTIL smUtil = new MSF_SharedMethods_UTIL();            
            Map<String, msf_LeadSourceMasterData__c> mLeadSourceValues = smUtil.getLeadSourceDependencies();
            for(Contact c : lNewCon){
                Contact oldContact = mOldCon.get(c.Id);
                type = getIdRT(c);
				checkNoRecibirNada(c);
                setAutomaticPercoms(c, mOldCon.isEmpty() ? new Contact() : mOldCon.get(c.Id));
                setContactInformationSummary(c);
                setPercomsSummary(c); 
                setLanguagePreferer(c, mOldCon.get(c.Id));                
                setName(c); 
                if (oldContact != null){
                    setFiscalInformation(c, oldContact, type);
                } else {
                    setFiscalInformation(c, type);
                }
                setBirthyear(c);
                setDataBaseEntry(c);
                setEmailField(c);
                setPhoneField(c);
                setLeadSourceDependencies(c,mLeadSourceValues);
                setContactAddress(c);
                setNickname(c, type);
                setFiscalNameToUpperCase(c);
                if(c.msf_NIF__c != null && type!=null){
                    if(!getValidateNif(c.msf_NIF__c, type)){
                        c.msf_NIF__c.addError(System.Label.MSF_CONTACT_NIF_NIE_CIF_ERROR);
                    }
                }
                if(c.msf_fiscalNif__c != null){
                    if(!getValidateNif(c.msf_fiscalNif__c, type)){
                        c.msf_fiscalNif__c.addError(System.Label.MSF_CONTACT_NIF_NIE_ERROR);
                    }
                    c.msf_fiscalNif__c = c.msf_fiscalNif__c.toUpperCase().trim();
                }
                if (contactIsDeceased(c)) {
                    c.msf_ContactDeleteReason__c = 'Deceased';
            		c.npsp__Deceased__c = true; 
                }
                
                if (c.MobilePhone != null) {
                	c.msf_MobilePhonePrefixEsp__c = '34' + c.MobilePhone; 
                }
                else {
                    c.msf_MobilePhonePrefixEsp__c = null; 
                }
            }
        }
        
        //AFTER UPDATE
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            Id orgRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
            Id orgContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
            
            Map<Id, List<Contact>> mOrgContacts = new Map<Id, List<Contact>>();
            
            for (Contact c : lNewCon) {
                Contact oldC = mOldCon.get(c.Id);
                if (c.RecordTypeId == orgRTId && oldC != null && oldC.msf_ShippingEntity__c != c.msf_ShippingEntity__c) {
                    mOrgContacts.put(c.Id, null);
                }
            }
           
            if (mOrgContacts.keyset().isEmpty() == false) {
                for (Contact c : [SELECT Id, msf_Organization__c FROM Contact WHERE RecordtypeId =: orgContactRTId AND msf_Organization__c IN :mOrgContacts.keyset()]) {
					List<Contact> orgContacts = mOrgContacts.get(c.msf_Organization__c);                    
                    if (orgContacts == null) {
                        orgContacts = new List<Contact>(); 
                    }
                    orgContacts.add(c);
                    mOrgContacts.put(c.msf_Organization__c, orgContacts);
                } 
            }
            
            
            for (Integer i = 0; i < lNewCon.size(); i++) {
                Contact oldC = lOldCon.get(i);
                Contact newC = lNewCon.get(i);
                if (contactIsDeceased(oldC, newC)) {
                    deceasedContacts.add(newC);
                }
                
                if (oldC.msf_ShippingEntity__c != newC.msf_ShippingEntity__c && newC.RecordTypeId == orgRTId) {
                    List<Contact> orgContacts = mOrgContacts.get(newC.Id);
                    if (orgContacts != null) {
                        for (Contact c : orgContacts) {
                            c.msf_ShippingEntity__c = newC.msf_ShippingEntity__c;
                        }
                        objectsToUpdate.put(newC.Id, orgContacts);   
                    }
                }
                
            }
            if(!deceasedContacts.isEmpty()) objectsToUpdate.putAll(contactDeceasedProcess(deceasedContacts));
        }
        
        /*** DML OPERATIONS ***/
        if (objectsToUpdate.isEmpty()) {
            return null; 
        }
        else {
			npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
            for (String key : objectsToUpdate.keyset()) {
                List<sObject> l = objectsToUpdate.get(key);
                dmlWrapper.objectsToUpdate.addAll(l);
            }
            return dmlWrapper;
        }      
    }
    
    
    // PRIVATE METHODS
    
    private void setFiscalNameToUpperCase(Contact c) {
        if (c.msf_FiscalFirstName__c != null) {
            c.msf_FiscalFirstName__c = c.msf_FiscalFirstName__c.toUpperCase(); 
        }
        if (c.msf_FiscalLastName1__c != null) {
            c.msf_FiscalLastName1__c = c.msf_FiscalLastName1__c.toUpperCase();
        }
        if (c.msf_FiscalLastName2__c != null) {
           c.msf_FiscalLastName2__c = c.msf_FiscalLastName2__c.toUpperCase();
        }
    }
    
    private void setNickName(Contact c, String type) {
        if (type == 'Individual_Contact' && c.msf_Nickname__c == null) {
            c.msf_Nickname__c = c.FirstName; 
        }
    }
    
    private void setContactAddress(Contact c) {
        if (c.MailingStreet != null && c.MailingCountry == null) {
            c.MailingCountry = 'España'; 
        }
        
        if (c.OtherStreet != null && c.OtherCountry == null) {
            c.OtherCountry = 'España'; 
        }
    }
    
    private void checkNoRecibirNada(Contact c) {
        if (c.msf_ContactDeleteReason__c != null) {
            c.msf_NoRecibirNada__c = true;  
        } 
    }
    
    private Boolean contactIsDeceased(Contact c) {
        Boolean isDeceased = false;
        String reason = c.msf_ContactDeleteReason__c; 
        if ('Deceased'.equals(reason) || c.npsp__Deceased__c == true) {
            isDeceased = true; 
        }
        return isDeceased; 
    }
    
    private Boolean contactIsDeceased(Contact oldC, Contact c) {
        Boolean isDeceased = false;
        if (oldC.npsp__Deceased__c == false  && c.npsp__Deceased__c == true) {
			isDeceased = true; 
        }
        return isDeceased; 
    }
    
    private Map<String, List<sObject>> contactDeceasedProcess(List<Contact> contacts) {
        Map<String, List<sObject>> ret = new Map<String, List<sObject>>();
        
        //Recurring Donations; 
        List<npe03__Recurring_Donation__c> recurringDonations = [SELECT Id, msf_CancelationReason__c, npe03__Open_Ended_Status__c 
                                                                 FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c IN :contacts
                                                                 AND npe03__Open_Ended_Status__c = 'Open'];
        for (npe03__Recurring_Donation__c rD : recurringDonations) {
            rD.msf_CancelationReason__c = 'Deceased'; 
            rD.npe03__Open_Ended_Status__c = 'Closed'; 
        }
        ret.put('recurringDonations', recurringDonations);
        
        //Opps
        List<Opportunity> opps = [SELECT Id, msf_ReasonLoss__c, StageName, RecordType.DeveloperName FROM Opportunity 
                                  WHERE npsp__Primary_Contact__c IN :contacts AND npe03__Recurring_Donation__c = null 
                                  AND IsClosed = false];
        for (Opportunity o : opps) {
            o.msf_ReasonLoss__c = 'Otras causas';
            if(o.RecordType.DeveloperName != 'Legacy') o.StageName = 'Perdida o Rechazada'; 
            else o.StageName = 'Perdida (fallecidos)';
        }
        ret.put('opps', opps);
        
        //msf_Associative__c
        List<msf_Associative__c> ass = [SELECT Id, msf_CancellationReason__c FROM msf_Associative__c 
                                        WHERE msf_ContactId__c IN :contacts AND msf_Status__c = 'Activo']; 
        for (msf_Associative__c a : ass) {
            a.msf_CancellationReason__c = 'Fallecido'; 
            a.msf_Status__c = 'Baja';
        }
        ret.put('ass', ass);
        
        return ret; 
    }
    
    
    //************* get recortype (type) *************
    private String getIdRT (Contact c){
        String type;
        if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId()){
            type = 'Organization';
        }
        else if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId()){ 
            type = 'Individual_Contact';
        }
        else if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId()){
            type = 'Organization_Contact';
        }
        else{
            type = null;
        }    
        return type;
    }
    
    //************* Set values of the following fields: msf_LeadSource2Level__c; msf_LeadSource3Level__c *************
    private void setLeadSourceDependencies(Contact c, Map<String, msf_LeadSourceMasterData__c> mLsValues){
        if(mLsValues.containsKey(c.LeadSource)){
            c.msf_LeadSource2Level__c = mLsValues.get(c.LeadSource).msf_LeadSource2__c;
            c.msf_LeadSource3Level__c = mLsValues.get(c.LeadSource).msf_LeadSource3__c;
        }
    }
    
    //************* Summary contact (msf_ContactInformationSummary__c) *************
    private void setContactInformationSummary (Contact c){
        
         if((c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null)
           && (c.msf_Phone__c == null)
           && (c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null)
           && (c.msf_RestrictedEmail__c == null)
           && (c.msf_ReturnedMail__c || (c.MailingStreet == null || c.MailingCity == null || c.MailingPostalCode == null) 
           && (c.OtherStreet == null || c.OtherCity == null || c.OtherPostalCode == null )))
        {
            c.msf_ContactInformationSummary__c = 'Sólo teléfono restringido';
        }
        
        else if((c.msf_Phone__c != null || c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null)
           && (c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null)
           && (c.msf_RestrictedEmail__c == null)
           && (c.msf_ReturnedMail__c || (c.MailingStreet == null || c.MailingCity == null || c.MailingPostalCode == null) 
           && (c.OtherStreet == null || c.OtherCity == null || c.OtherPostalCode == null)))
        {
            c.msf_ContactInformationSummary__c = 'Sólo teléfono';
        }
        
        else if(c.msf_RestrictedEmail__c != null
            	&& (c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null)
                && (c.msf_RestrictedPhone__c == null && c.msf_RestrictedMobilePhone__c == null)
                && (c.msf_Phone__c == null )
                && (c.msf_ReturnedMail__c || (c.MailingStreet == null || c.MailingCity == null || c.MailingPostalCode == null) 
                && (c.OtherStreet == null || c.OtherCity == null || c.OtherPostalCode == null)))
        {
            c.msf_ContactInformationSummary__c = 'Sólo email restringido';
        }  
        
        else if((c.npe01__HomeEmail__c != null || c.msf_MainEmail__c != null || c.npe01__AlternateEmail__c != null || c.msf_RestrictedEmail__c != null)
                && (c.msf_RestrictedPhone__c == null && c.msf_RestrictedMobilePhone__c == null)
                && (c.msf_Phone__c == null )
                && (c.msf_ReturnedMail__c || (c.MailingStreet == null || c.MailingCity == null || c.MailingPostalCode == null) 
                && (c.OtherStreet == null || c.OtherCity == null || c.OtherPostalCode == null)))
        {
            c.msf_ContactInformationSummary__c = 'Sólo email';
        } 
        
        else if(((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                 || (c.OtherStreet != null && c.OtherCity != null  && c.OtherPostalCode != null)) 
                && (c.msf_RestrictedPhone__c == null && c.msf_RestrictedMobilePhone__c == null)
                && (c.msf_RestrictedEmail__c == null)
                && c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null && c.msf_Phone__c == null 
                && !c.msf_ReturnedMail__c)
        {
            c.msf_ContactInformationSummary__c = 'Sólo correo';
        }
        
        else if(((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                 || (c.OtherStreet != null && c.OtherCity != null  && c.OtherPostalCode != null)) 
                && (c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null)
                && (c.msf_RestrictedEmail__c != null)
                && (c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null && c.msf_Phone__c == null) 
                && !c.msf_ReturnedMail__c)
        {
            c.msf_ContactInformationSummary__c = 'Correo+Teléfono restringido+Email restringido';
        }
        
        else if(c.msf_RestrictedEmail__c != null
                && (c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null)
                && ((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                    ||( c.OtherStreet != null && c.OtherCity != null  && c.OtherPostalCode != null)) 
                && (c.msf_Phone__c != null || c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null) && !c.msf_ReturnedMail__c)
        {
            c.msf_ContactInformationSummary__c = 'Correo+Teléfono+Email restringido';
        }
        
        else if((c.msf_RestrictedEmail__c != null || c.npe01__HomeEmail__c != null || c.msf_MainEmail__c != null || c.npe01__AlternateEmail__c != null)
                && ((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                    ||( c.OtherStreet != null && c.OtherCity != null  && c.OtherPostalCode != null )) 
                && (c.msf_Phone__c == null)
                && (c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null) && !c.msf_ReturnedMail__c)
        {
            c.msf_ContactInformationSummary__c = 'Correo+Email+Teléfono restringido';
        }
        
        else if(c.msf_RestrictedEmail__c != null
                && (c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null)
                && ((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                    ||( c.OtherStreet != null && c.OtherCity != null  && c.OtherPostalCode != null)) 
                && (c.msf_Phone__c == null) && !c.msf_ReturnedMail__c
            	&& (c.msf_RestrictedPhone__c == null && c.msf_RestrictedMobilePhone__c == null))
        {
            c.msf_ContactInformationSummary__c = 'Email restringido+Correo';
        }
        
        else if((c.npe01__HomeEmail__c != null || c.msf_MainEmail__c != null || c.npe01__AlternateEmail__c != null || c.msf_RestrictedEmail__c != null ) 
                && ((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                    ||( c.OtherStreet != null && c.OtherCity != null  && c.OtherPostalCode != null)) 
                && (c.msf_Phone__c == null) && !c.msf_ReturnedMail__c
            	&& (c.msf_RestrictedPhone__c == null && c.msf_RestrictedMobilePhone__c == null))
        {
            c.msf_ContactInformationSummary__c = 'Email+Correo';
        }	
        
        else if(c.msf_RestrictedEmail__c != null
                && (c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null)
            	&& (c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null) 
                && (c.msf_Phone__c == null) 
                && ( c.msf_ReturnedMail__c || (c.MailingStreet == null || c.MailingCity == null || c.MailingPostalCode == null) 
                    && (c.OtherStreet == null || c.OtherCity == null ||  c.OtherPostalCode == null) ))
        {
            c.msf_ContactInformationSummary__c = 'Email restringido+Teléfono restringido';
        }
        
        else if((c.npe01__HomeEmail__c != null || c.msf_MainEmail__c != null || c.npe01__AlternateEmail__c != null || c.msf_RestrictedEmail__c != null) 
                && (c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null)
                && (c.msf_Phone__c == null) 
                && ( c.msf_ReturnedMail__c || (c.MailingStreet == null || c.MailingCity == null || c.MailingPostalCode == null) 
                    && (c.OtherStreet == null || c.OtherCity == null ||  c.OtherPostalCode == null) ))
        {
            c.msf_ContactInformationSummary__c = 'Email+Teléfono restringido';
        }
        
        else if(c.msf_RestrictedEmail__c != null
                && (c.msf_Phone__c != null || c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null) 
            	&& (c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null) 
                && ( c.msf_ReturnedMail__c || (c.MailingStreet == null || c.MailingCity == null || c.MailingPostalCode == null) 
                    && (c.OtherStreet == null || c.OtherCity == null ||  c.OtherPostalCode == null) ))
        {
            c.msf_ContactInformationSummary__c = 'Email restringido+Teléfono';
        }
        
        else if((c.npe01__HomeEmail__c != null || c.msf_MainEmail__c != null || c.npe01__AlternateEmail__c != null || c.msf_RestrictedMobilePhone__c != null) 
                && (c.msf_Phone__c != null || c.msf_RestrictedEmail__c != null) 
                && ( c.msf_ReturnedMail__c || (c.MailingStreet == null || c.MailingCity == null || c.MailingPostalCode == null) 
                    && (c.OtherStreet == null || c.OtherCity == null ||  c.OtherPostalCode == null ) ))
        {
            c.msf_ContactInformationSummary__c = 'Email+Teléfono';
        }
        
        else if(((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                 || ( c.OtherStreet != null && c.OtherCity != null && c.OtherPostalCode != null))                
                && (c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null)
                && c.msf_Phone__c == null
                && (c.msf_RestrictedEmail__c == null)
                && c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null
                && !c.msf_ReturnedMail__c)
        {
            c.msf_ContactInformationSummary__c = 'Teléfono restringido+Correo';
        }
        
        else if(((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                 || ( c.OtherStreet != null && c.OtherCity != null && c.OtherPostalCode != null))                
                && (c.msf_Phone__c != null || c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null)
                && (c.msf_RestrictedEmail__c == null)
                && c.npe01__HomeEmail__c == null && c.msf_MainEmail__c == null && c.npe01__AlternateEmail__c == null
                && !c.msf_ReturnedMail__c)
        {
            c.msf_ContactInformationSummary__c = 'Teléfono+Correo';
        }
        
        else if((c.npe01__HomeEmail__c != null || c.msf_MainEmail__c != null || c.npe01__AlternateEmail__c != null || c.msf_RestrictedEmail__c != null) 
                && ((c.MailingStreet != null && c.MailingCity != null && c.MailingPostalCode != null) 
                    || ( c.OtherStreet != null && c.OtherCity != null && c.OtherPostalCode != null)) 
                && (c.msf_Phone__c != null || c.msf_RestrictedPhone__c != null || c.msf_RestrictedMobilePhone__c != null)
                && !c.msf_ReturnedMail__c
               )
        {
            c.msf_ContactInformationSummary__c = 'Todo';
        }
        
        else{
            c.msf_ContactInformationSummary__c = 'No data';
        }    
    }
    
    //************* Set automatic percoms(c.msf_NoCorreoPostal__c && c.msf_NoTelefono__c && c.msf_NoSMS__c && c.msf_NoEmail__c && c.msf_NoMi__c) *************
    private void setAutomaticPercoms (Contact c, Contact cOld){
        
        if(c.msf_SoloCertificadoFiscal__c != cOld.msf_SoloCertificadoFiscal__c){ 
            if(c.msf_NoRecibirNada__c != cOld.msf_NoRecibirNada__c ){
                c.msf_SoloCertificadoFiscal__c = false;
            }else{
                if(c.msf_SoloCertificadoFiscal__c){
                    c.msf_NoCertificadoFiscalCP__c = false;
                    c.msf_NoCertificadoFiscalSms__c = false;
                    c.msf_NoCertificadoFiscalEmail__c = false;
                    c.msf_NoCertificadoFiscalMi__c = false;
                    c.msf_NoInformacionTestamentaria__c = true;
                    c.msf_NoCesionImagenPromocion__c = true;
                    c.msf_NoCaptacionFondos__c= true;
                    c.msf_NoTelefono__c = true;
                    c.msf_NoRevistaCP__c = true;
                    c.msf_NoMemoriaCP__c = true;
                    c.msf_NoCaptacionFondosCP__c = true;
                    c.msf_NoAgradecimientosCP__c = true;
                    c.msf_NoLlamadasBienvenidasEncuestasOtras__c = true;
                    c.msf_NoMailingsTematicosCP__c = true;
                    c.msf_NoCartasPlanRelacionCP__c = true;
                    c.msf_NoInvitacionesEventosCP__c = true;
                    c.msf_NoComunicacionesOnetoOneCP__c= true;
                    c.msf_NoRevistaSms__c = true;
                    c.msf_NoMensajesTematicosSms__c = true;
                    c.msf_NoMensajesPlanRelacionSms__c = true;
                    c.msf_NoMemoriaSms__c = true;
                    c.msf_NoInvitacionesEventosSms__c = true;
                    c.msf_NoEncuestaEstudioConcursoSms__c = true;
                    c.msf_NoComunicaconesOnetoOneSms__c = true;
                    c.msf_NoCaptacionFondosSms__c = true;
                    c.msf_NoAgradecimientosSms__c = true;
                    c.msf_NoRevistaEmail__c = true;
                    c.msf_NoMemoriaEmail__c = true;
                    c.msf_NoCaptacionFondosEmail__c = true;
                    c.msf_NoAgradecimientosEmail__c = true;
                    c.msf_NoEncuestaEstudioConcursoEmail__c = true;
                    c.msf_NoEmailingsTematicosEmail__c = true;
                    c.msf_NoPlanRelacionEmail__c = true;
                    c.msf_NoInvitacionesEventosEmail__c = true;
                    c.msf_NoNewsletterEmail__c = true;
                    c.msf_NoComunicacionesOnetoOneEmail__c = true;
                    c.msf_NoRevistaMi__c = true;
                    c.msf_NoMensajesTematicosMi__c = true;
                    c.msf_NoMensajesPlanRelacionMi__c = true;
                    c.msf_NoMemoriaMi__c = true;
                    c.msf_NoInvitacionesEventosMi__c = true;
                    c.msf_NoEncuestaEstudioConcursoMi__c = true;
                    c.msf_NoComunicaconesOnetoOneMi__c = true;
                    c.msf_NoCaptacionFondosMi__c = true;
                    c.msf_NoAgradecimientosMi__c = true;
                }else{
                    c.msf_NoRecibirNada__c = true;
                }
            }           
        }else{
            if(c.msf_NoInformacionTestamentaria__c && c.msf_NoCesionImagenPromocion__c && c.msf_NoCaptacionFondos__c && c.msf_NoTelefono__c 
               && c.msf_NoRevistaCP__c && c.msf_NoMemoriaCP__c && c.msf_NoCaptacionFondosCP__c && c.msf_NoAgradecimientosCP__c 
               && c.msf_NoLlamadasBienvenidasEncuestasOtras__c && c.msf_NoMailingsTematicosCP__c && c.msf_NoCartasPlanRelacionCP__c 
               && c.msf_NoInvitacionesEventosCP__c && c.msf_NoComunicacionesOnetoOneCP__c && c.msf_NoRevistaSms__c 
               && c.msf_NoMensajesTematicosSms__c && c.msf_NoMensajesPlanRelacionSms__c && c.msf_NoMemoriaSms__c && c.msf_NoInvitacionesEventosSms__c
               && c.msf_NoEncuestaEstudioConcursoSms__c && c.msf_NoComunicaconesOnetoOneSms__c && c.msf_NoCaptacionFondosSms__c 
               && c.msf_NoAgradecimientosSms__c && c.msf_NoRevistaEmail__c && c.msf_NoMemoriaEmail__c && c.msf_NoCaptacionFondosEmail__c 
               && c.msf_NoAgradecimientosEmail__c && c.msf_NoEncuestaEstudioConcursoEmail__c && c.msf_NoEmailingsTematicosEmail__c && c.msf_NoPlanRelacionEmail__c
               && c.msf_NoInvitacionesEventosEmail__c && c.msf_NoNewsletterEmail__c && c.msf_NoComunicacionesOnetoOneEmail__c && c.msf_NoRevistaMi__c 
               && c.msf_NoMensajesTematicosMi__c && c.msf_NoMensajesPlanRelacionMi__c && c.msf_NoMemoriaMi__c && c.msf_NoInvitacionesEventosMi__c 
               && c.msf_NoEncuestaEstudioConcursoMi__c && c.msf_NoComunicaconesOnetoOneMi__c && c.msf_NoCaptacionFondosMi__c && c.msf_NoAgradecimientosMi__c 
               && c.msf_NoCorreoPostal__c && c.msf_NoSMS__c && c.msf_NoEmail__c && c.msf_NoMi__c && !c.msf_NoCertificadoFiscalCP__c && !c.msf_NoCertificadoFiscalSms__c 
               && !c.msf_NoCertificadoFiscalEmail__c && !c.msf_NoCertificadoFiscalMi__c
              ){
                  c.msf_SoloCertificadoFiscal__c = true;
              }
            else{
                c.msf_SoloCertificadoFiscal__c = false;
            }
        }
        
        if(c.msf_NoRecibirNada__c != cOld.msf_NoRecibirNada__c ){
            c.msf_NoCaptacionFondos__c = c.msf_NoRecibirNada__c;
            c.msf_NoCorreoPostal__c = c.msf_NoRecibirNada__c;
            c.msf_NoTelefono__c = c.msf_NoRecibirNada__c;
            c.msf_NoSMS__c = c.msf_NoRecibirNada__c;
            c.msf_NoEmail__c = c.msf_NoRecibirNada__c;
            c.msf_NoMi__c = c.msf_NoRecibirNada__c;
            c.msf_NoInformacionTestamentaria__c = c.msf_NoRecibirNada__c;
            c.msf_NoCesionImagenPromocion__c = c.msf_NoRecibirNada__c;
            c.msf_SoloCertificadoFiscal__c = false;
        }
        
        if(c.msf_NoCaptacionFondos__c != cOld.msf_NoCaptacionFondos__c){
            c.msf_NoCaptacionFondosCP__c = c.msf_NoCaptacionFondos__c;
            c.msf_NoCaptacionFondosEmail__c = c.msf_NoCaptacionFondos__c;
            c.msf_NoCaptacionFondosMi__c = c.msf_NoCaptacionFondos__c;
            c.msf_NoCaptacionFondosSms__c = c.msf_NoCaptacionFondos__c;
            c.msf_NoTelemarketingCaptacionFondos__c = c.msf_NoCaptacionFondos__c;
        }else{
            if(c.msf_NoCorreoPostal__c && c.msf_NoEmail__c && c.msf_NoMi__c && c.msf_NoSMS__c && c.msf_NoTelefono__c /*&&
               c.msf_NoCaptacionFondosCP__c && c.msf_NoCaptacionFondosEmail__c && c.msf_NoCaptacionFondosMi__c &&
               c.msf_NoCaptacionFondosSms__c && c.msf_NoTelemarketingCaptacionFondos__c*/){
                   c.msf_NoCaptacionFondos__c = true;
               }else{
                   c.msf_NoCaptacionFondos__c = false;
               }
        }
        
        if(c.msf_NoCorreoPostal__c != cOld.msf_NoCorreoPostal__c && !c.msf_SoloCertificadoFiscal__c){
            c.msf_NoRevistaCP__c = c.msf_NoCorreoPostal__c;
            c.msf_NoMemoriaCP__c = c.msf_NoCorreoPostal__c;
            c.msf_NoCaptacionFondosCP__c = c.msf_NoCorreoPostal__c;
            c.msf_NoCertificadoFiscalCP__c = c.msf_NoCorreoPostal__c; 
            c.msf_NoAgradecimientosCP__c = c.msf_NoCorreoPostal__c;
            c.msf_NoLlamadasBienvenidasEncuestasOtras__c = c.msf_NoCorreoPostal__c;
            c.msf_NoMailingsTematicosCP__c = c.msf_NoCorreoPostal__c;
            c.msf_NoCartasPlanRelacionCP__c = c.msf_NoCorreoPostal__c;
            c.msf_NoInvitacionesEventosCP__c = c.msf_NoCorreoPostal__c;
            c.msf_NoComunicacionesOnetoOneCP__c= c.msf_NoCorreoPostal__c;
        }else{
            if(c.msf_NoRevistaCP__c && c.msf_NoMemoriaCP__c && c.msf_NoCaptacionFondosCP__c && c.msf_NoCertificadoFiscalCP__c  && c.msf_NoAgradecimientosCP__c &&
               c.msf_NoLlamadasBienvenidasEncuestasOtras__c && c.msf_NoMailingsTematicosCP__c && c.msf_NoCartasPlanRelacionCP__c && c.msf_NoInvitacionesEventosCP__c && 
               c.msf_NoComunicacionesOnetoOneCP__c )
            {
                c.msf_NoCorreoPostal__c = true;
            }else{
                c.msf_NoCorreoPostal__c = false; 
            }
        }
        
        if(c.msf_NoTelefono__c != cOld.msf_NoTelefono__c ){
            c.msf_NoTelemarketingCaptacionFondos__c = c.msf_NoTelefono__c;
            c.msf_NoAgradecimientosTelefono__c = c.msf_NoTelefono__c;
            c.msf_NoEncuestaEstudioConcursoTelefono__c = c.msf_NoTelefono__c;
            c.msf_NoPlanRelacionTelefono__c = c.msf_NoTelefono__c;
            c.msf_NoInvitacionesEventosTelefono__c = c.msf_NoTelefono__c;
            c.msf_NoComunicacionesOnetoOneTelefono__c = c.msf_NoTelefono__c;           
        }else{
            if(c.msf_NoTelemarketingCaptacionFondos__c && c.msf_NoAgradecimientosTelefono__c && c.msf_NoEncuestaEstudioConcursoTelefono__c &&
               c.msf_NoPlanRelacionTelefono__c && c.msf_NoInvitacionesEventosTelefono__c && c.msf_NoComunicacionesOnetoOneTelefono__c)
            {
                c.msf_NoTelefono__c = true;
            }else{
                c.msf_NoTelefono__c = false;
            }
        }
        
        if(c.msf_NoSMS__c != cOld.msf_NoSMS__c && !c.msf_SoloCertificadoFiscal__c){
            c.msf_NoRevistaSms__c = c.msf_NoSMS__c;
            c.msf_NoMensajesTematicosSms__c = c.msf_NoSMS__c;
            c.msf_NoMensajesPlanRelacionSms__c = c.msf_NoSMS__c;
            c.msf_NoMemoriaSms__c = c.msf_NoSMS__c;
            c.msf_NoInvitacionesEventosSms__c = c.msf_NoSMS__c;
            c.msf_NoEncuestaEstudioConcursoSms__c = c.msf_NoSMS__c;
            c.msf_NoComunicaconesOnetoOneSms__c = c.msf_NoSMS__c;
            c.msf_NoCertificadoFiscalSms__c = c.msf_NoSMS__c;
            c.msf_NoCaptacionFondosSms__c = c.msf_NoSMS__c;
            c.msf_NoAgradecimientosSms__c = c.msf_NoSMS__c;           
        }else{
            if(c.msf_NoRevistaSms__c && c.msf_NoMensajesTematicosSms__c && c.msf_NoMensajesPlanRelacionSms__c &&
               c.msf_NoMemoriaSms__c && c.msf_NoInvitacionesEventosSms__c && c.msf_NoEncuestaEstudioConcursoSms__c &&
               c.msf_NoComunicaconesOnetoOneSms__c && c.msf_NoCertificadoFiscalSms__c && c.msf_NoCaptacionFondosSms__c &&
               c.msf_NoAgradecimientosSms__c)
            {
                c.msf_NoSMS__c = true;
            }else{
                c.msf_NoSMS__c = false;
            }
        }
        
        if(c.msf_NoEmail__c != cOld.msf_NoEmail__c && !c.msf_SoloCertificadoFiscal__c){
            c.msf_NoRevistaEmail__c = c.msf_NoEmail__c;
            c.msf_NoMemoriaEmail__c = c.msf_NoEmail__c;
            c.msf_NoCaptacionFondosEmail__c = c.msf_NoEmail__c; 
            c.msf_NoCertificadoFiscalEmail__c = c.msf_NoEmail__c;
            c.msf_NoAgradecimientosEmail__c = c.msf_NoEmail__c;
            c.msf_NoEncuestaEstudioConcursoEmail__c = c.msf_NoEmail__c;
            c.msf_NoEmailingsTematicosEmail__c = c.msf_NoEmail__c;
            c.msf_NoPlanRelacionEmail__c = c.msf_NoEmail__c;
            c.msf_NoInvitacionesEventosEmail__c = c.msf_NoEmail__c;
            c.msf_NoNewsletterEmail__c = c.msf_NoEmail__c;
            c.msf_NoComunicacionesOnetoOneEmail__c = c.msf_NoEmail__c;  
        }else{
            if(c.msf_NoRevistaEmail__c && c.msf_NoMemoriaEmail__c && c.msf_NoCaptacionFondosEmail__c && c.msf_NoCertificadoFiscalEmail__c &&
              c.msf_NoAgradecimientosEmail__c && c.msf_NoEncuestaEstudioConcursoEmail__c && c.msf_NoEmailingsTematicosEmail__c &&
              c.msf_NoPlanRelacionEmail__c && c.msf_NoInvitacionesEventosEmail__c && c.msf_NoNewsletterEmail__c && c.msf_NoComunicacionesOnetoOneEmail__c)
            {
                c.msf_NoEmail__c = true;
            }else{
                c.msf_NoEmail__c = false;
            }
        }
        
        if(c.msf_NoMi__c != cOld.msf_NoMi__c && !c.msf_SoloCertificadoFiscal__c){
            c.msf_NoRevistaMi__c = c.msf_NoMi__c;
            c.msf_NoMensajesTematicosMi__c = c.msf_NoMi__c;
            c.msf_NoMensajesPlanRelacionMi__c = c.msf_NoMi__c;
            c.msf_NoMemoriaMi__c = c.msf_NoMi__c;
            c.msf_NoInvitacionesEventosMi__c = c.msf_NoMi__c;
            c.msf_NoEncuestaEstudioConcursoMi__c = c.msf_NoMi__c;
            c.msf_NoComunicaconesOnetoOneMi__c = c.msf_NoMi__c;
            c.msf_NoCertificadoFiscalMi__c = c.msf_NoMi__c;
            c.msf_NoCaptacionFondosMi__c = c.msf_NoMi__c;
            c.msf_NoAgradecimientosMi__c = c.msf_NoMi__c;
        }else{
            if(c.msf_NoRevistaMi__c && c.msf_NoMensajesTematicosMi__c && c.msf_NoMensajesPlanRelacionMi__c &&
               c.msf_NoMemoriaMi__c && c.msf_NoInvitacionesEventosMi__c && c.msf_NoEncuestaEstudioConcursoMi__c &&
               c.msf_NoComunicaconesOnetoOneMi__c && c.msf_NoCertificadoFiscalMi__c && c.msf_NoCaptacionFondosMi__c &&
               c.msf_NoAgradecimientosMi__c)
            {
                c.msf_NoMi__c = true;
            }else{
                c.msf_NoMi__c = false;
            }
        }
        
        //validate finish
       // if(c.msf_NoCaptacionFondos__c == cOld.msf_NoCaptacionFondos__c){
            if(c.msf_NoCaptacionFondosCP__c && c.msf_NoCaptacionFondosEmail__c && c.msf_NoCaptacionFondosMi__c &&
               c.msf_NoCaptacionFondosSms__c && c.msf_NoTelemarketingCaptacionFondos__c){
                   c.msf_NoCaptacionFondos__c = true;
               }else{
                   c.msf_NoCaptacionFondos__c = false;
               }
       // }
        
        if(c.msf_NoRecibirNada__c == cOld.msf_NoRecibirNada__c ){
            if(c.msf_NoCaptacionFondos__c && c.msf_NoCorreoPostal__c && c.msf_NoTelefono__c && c.msf_NoSMS__c && c.msf_NoEmail__c &&
               c.msf_NoMi__c && c.msf_NoInformacionTestamentaria__c && c.msf_NoCesionImagenPromocion__c ){
                   c.msf_NoRecibirNada__c=true;
                   c.msf_SoloCertificadoFiscal__c = false;
               }
        }
        
        //***** validate that individual check hasn't been unchecked and msf_NoRecibirNada__c is marked 
        if(!c.msf_NoCaptacionFondos__c || !c.msf_NoCorreoPostal__c || !c.msf_NoTelefono__c || !c.msf_NoSMS__c || 
           !c.msf_NoEmail__c || !c.msf_NoMi__c || !c.msf_NoInformacionTestamentaria__c || !c.msf_NoCesionImagenPromocion__c ){
               c.msf_NoRecibirNada__c = false;
           }
    }
    
    //************* Summary percoms(msf_PercomsSummary__c) *************
    private void setPercomsSummary (Contact c){
        if(c.msf_NoRecibirNada__c ){
            c.msf_PercomsSummary__c = 'Nada';
        }
        else if(!c.msf_NoCaptacionFondos__c && !c.msf_NoCorreoPostal__c && !c.msf_NoTelefono__c && !c.msf_NoSMS__c && !c.msf_NoEmail__c && 
                !c.msf_NoMi__c && !c.msf_NoInformacionTestamentaria__c && !c.msf_NoCesionImagenPromocion__c && !c.msf_SoloCertificadoFiscal__c &&
                //Correo
               	!c.msf_NoRevistaCP__c && !c.msf_NoMemoriaCP__c && !c.msf_NoCaptacionFondosCP__c && !c.msf_NoCertificadoFiscalCP__c  && !c.msf_NoAgradecimientosCP__c &&
               	!c.msf_NoLlamadasBienvenidasEncuestasOtras__c && !c.msf_NoMailingsTematicosCP__c && !c.msf_NoCartasPlanRelacionCP__c && !c.msf_NoInvitacionesEventosCP__c && 
               	!c.msf_NoComunicacionesOnetoOneCP__c &&
                //telefono
               	!c.msf_NoTelemarketingCaptacionFondos__c && !c.msf_NoAgradecimientosTelefono__c && !c.msf_NoEncuestaEstudioConcursoTelefono__c &&
               	!c.msf_NoPlanRelacionTelefono__c && !c.msf_NoInvitacionesEventosTelefono__c && !c.msf_NoComunicacionesOnetoOneTelefono__c &&
                //SMS
               	!c.msf_NoRevistaSms__c && !c.msf_NoMensajesTematicosSms__c && !c.msf_NoMensajesPlanRelacionSms__c &&
               	!c.msf_NoMemoriaSms__c && !c.msf_NoInvitacionesEventosSms__c && !c.msf_NoEncuestaEstudioConcursoSms__c &&
               	!c.msf_NoComunicaconesOnetoOneSms__c && !c.msf_NoCertificadoFiscalSms__c && !c.msf_NoCaptacionFondosSms__c &&
               	!c.msf_NoAgradecimientosSms__c &&
                //Email
                !c.msf_NoRevistaEmail__c && !c.msf_NoMemoriaEmail__c && !c.msf_NoCaptacionFondosEmail__c && !c.msf_NoCertificadoFiscalEmail__c &&
              	!c.msf_NoAgradecimientosEmail__c && !c.msf_NoEncuestaEstudioConcursoEmail__c && !c.msf_NoEmailingsTematicosEmail__c &&
              	!c.msf_NoPlanRelacionEmail__c && !c.msf_NoInvitacionesEventosEmail__c && !c.msf_NoNewsletterEmail__c && !c.msf_NoComunicacionesOnetoOneEmail__c &&
                //MI
                !c.msf_NoRevistaMi__c && !c.msf_NoMensajesTematicosMi__c && !c.msf_NoMensajesPlanRelacionMi__c &&
               	!c.msf_NoMemoriaMi__c && !c.msf_NoInvitacionesEventosMi__c && !c.msf_NoEncuestaEstudioConcursoMi__c &&
               	!c.msf_NoComunicaconesOnetoOneMi__c && !c.msf_NoCertificadoFiscalMi__c && !c.msf_NoCaptacionFondosMi__c &&
               	!c.msf_NoAgradecimientosMi__c
               ) 
        {                        
            c.msf_PercomsSummary__c = 'Todo';
        }
        else if(c.msf_SoloCertificadoFiscal__c)
        {
            c.msf_PercomsSummary__c = 'Sólo certificado fiscal';
        }
        else if(c.msf_NoCaptacionFondos__c){
            c.msf_PercomsSummary__c = 'No captación de fondos';
        }
        else{
            c.msf_PercomsSummary__c = 'Varios';
        }
    }
    
    //************* Preferer language(msf_LanguagePreferer__c) *************
    private void setLanguagePreferer (Contact c, Contact contactOldValue){
        if (c.msf_LanguagePreferer__c == null) {  //#25849 - OMEGA - Se sustituye “Idioma confirmado” por msf_LanguagePreferer__c, si se indica un lenguaje
            if ('CAT'.equals(c.msf_LanguagePreferer__c) == false) { //Si “Idioma de preferencia” es “CAT” , no se cambia el valor de “Idioma de preferencia”.
                if(c.MailingPostalCode != null) {
                    if((String.valueOf(c.MailingPostalCode)).startsWith('08') || 
                       (String.valueOf(c.MailingPostalCode)).startsWith('17') ||
                       (String.valueOf(c.MailingPostalCode)).startsWith('25') ||
                       (String.valueOf(c.MailingPostalCode)).startsWith('43'))
                    {
                        c.msf_LanguagePreferer__c = 'CAT';     
                    }
                    else{
                        c.msf_LanguagePreferer__c = 'ESP';     
                    }
                }else{
                    c.msf_LanguagePreferer__c = 'ESP';     
                }
                
            }
        }else if(c.msf_LanguagePreferer__c != null && c.MailingPostalCode !=null && contactOldValue !=null){//#25849 - OMEGA - si el contacto existente NO tiene rellenado el Código Postal (por lo que tendría el idioma ESP) y se le rellena, si el nuevo CP es de Catalunya tendría que cambiar el idioma a CAT y si es diferente a los de Catalunya, entonces sería ESP
            if(contactOldValue.MailingPostalCode ==null){
                if((String.valueOf(c.MailingPostalCode)).startsWith('08') || 
                   (String.valueOf(c.MailingPostalCode)).startsWith('17') ||
                   (String.valueOf(c.MailingPostalCode)).startsWith('25') ||
                   (String.valueOf(c.MailingPostalCode)).startsWith('43'))
                {
                    c.msf_LanguagePreferer__c = 'CAT';     
                }
                else{
                    c.msf_LanguagePreferer__c = 'ESP';     
                }
            }
        } 
    }
    
    //************* Birth year (msf_birthyear__c) *************
    private void setBirthyear (Contact c){
        if(c.Birthdate != null){
            c.msf_birthyear__c = String.valueOf(c.Birthdate.year());
        }
    } 
    
    //************* Data base entry  *************
    private void setDataBaseEntry (Contact c){
        if(c.msf_BeginDateMSF__c == null){
            c.msf_BeginDateMSF__c = Date.today();
        }
    } 
    
    //************* Email  *************
    private void setEmailField (Contact c){
        if(c.msf_MainEmail__c != null){
            c.Email = c.msf_MainEmail__c;
        }
        else if(c.npe01__HomeEmail__c != null){
        	c.Email = c.npe01__HomeEmail__c;                
        }
        else if(c.npe01__AlternateEmail__c != null){
        	c.Email = c.npe01__AlternateEmail__c;                   
        }
        else
        {
            c.Email = null;
        }
    } 
    
    //************* Phone  *************
    private void setPhoneField (Contact c){
        //For case that use Phone field -> copy msf_Phone__c into Phone
       
        if(c.MobilePhone != null){
            c.Phone = c.MobilePhone;
        }
        else if(c.msf_MobilePhone2__c != null){
        	c.Phone = c.msf_MobilePhone2__c;                
        }
        else if(c.HomePhone != null){
        	c.Phone = c.HomePhone;                   
        }
        else if(c.OtherPhone != null){
        	c.Phone = c.OtherPhone;                   
        }
        else
        {
            c.Phone= null;
        }
        
        
    }
    
    //************* Fiscal section *************

    private void setFiscalInformation (Contact c, String type){
        if (c.msf_CopyTaxData__c == true){
            if(type == 'Organization'){
                c.msf_FiscalFirstName__c = c.LastName != null ? getValue(c.LastName.toUpperCase().trim()) : null;
                c.msf_fiscalNif__c = c.msf_Nif__c != null ? c.msf_NIF__c.toUpperCase().trim()  : null;
            }
            else if (type == 'Organization_Contact'){
                c.msf_FiscalFirstName__c = c.FirstName != null ? getValue(c.FirstName.toUpperCase().trim()) : null;
                c.msf_FiscalLastName1__c = c.LastName != null ? getValue(c.LastName.toUpperCase().trim()) : null;
                c.msf_FiscalLastName2__c = c.Suffix != null ? getValue(c.Suffix.toUpperCase().trim()) : null;
                c.msf_fiscalNif__c = c.msf_NIF__c != null ? c.msf_NIF__c.toUpperCase().trim() : null;
            }
            else if (type == 'Individual_Contact'){ 
                c.msf_FiscalFirstName__c = c.FirstName != null ? getValue(c.FirstName.toUpperCase().trim()) : null;
                c.msf_FiscalLastName1__c = c.LastName != null ? getValue(c.LastName.toUpperCase().trim()) : null;
                c.msf_FiscalLastName2__c = c.Suffix != null ? getValue(c.Suffix.toUpperCase().trim()) : null;
                c.msf_fiscalNif__c = c.msf_NIF__c != null ? c.msf_NIF__c.toUpperCase().trim() : null;
            } 
        }
    }

    private void setFiscalInformation (Contact c, Contact oldContact, String type){
        if(type == 'Organization'){
            if (c.msf_CopyTaxData__c == true && (c.LastName != oldContact.LastName || c.msf_NIF__c != oldContact.msf_NIF__c)){
                c.msf_FiscalFirstName__c = c.LastName != null ? getValue(c.LastName.toUpperCase().trim()) : null;
                c.msf_fiscalNif__c = c.msf_NIF__c != null ? getValue(c.msf_NIF__c.toUpperCase().trim()) : null;
            } else{
                if (c.msf_FiscalFirstName__c != oldContact.msf_FiscalFirstName__c){
                    c.msf_FiscalFirstName__c = c.msf_FiscalFirstName__c != null ? getValue(c.msf_FiscalFirstName__c.toUpperCase().trim()) : null;
                    c.msf_CopyTaxData__c = false;
                }
                if (c.msf_fiscalNif__c != oldContact.msf_fiscalNif__c){
                    c.msf_fiscalNif__c = c.msf_fiscalNif__c != null ? c.msf_fiscalNif__c.toUpperCase().trim() : null;
                    c.msf_CopyTaxData__c = false;
                } 
            }
        }
        else if (type == 'Organization_Contact'){
            if (c.msf_CopyTaxData__c == true && (c.FirstName != oldContact.FirstName || c.LastName != oldContact.LastName || c.Suffix != oldContact.Suffix || c.msf_Nif__c != oldContact.msf_Nif__c)){
                c.msf_FiscalFirstName__c = c.FirstName != null ? getValue(c.FirstName.toUpperCase().trim()) : null;
                c.msf_FiscalLastName1__c = c.LastName != null ? getValue(c.LastName.toUpperCase().trim()) : null;
                c.msf_FiscalLastName2__c = c.Suffix != null ? getValue(c.Suffix.toUpperCase().trim()) : null;
                c.msf_fiscalNif__c = c.msf_Nif__c != null ? c.msf_Nif__c.toUpperCase().trim() : null;
            } else {
                if (c.msf_FiscalFirstName__c != oldContact.msf_FiscalFirstName__c){
                    c.msf_FiscalFirstName__c = c.msf_FiscalFirstName__c != null ? getValue(c.msf_FiscalFirstName__c.toUpperCase().trim()) : null;
                    c.msf_CopyTaxData__c = false;
                } 
                
                if (c.msf_FiscalLastName1__c != oldContact.msf_FiscalLastName1__c){
                    c.msf_FiscalLastName1__c = c.msf_FiscalLastName1__c != null ? getValue(c.msf_FiscalLastName1__c.toUpperCase().trim()) : null;
                    c.msf_CopyTaxData__c = false;
                } 

                if (c.msf_FiscalLastName2__c != oldContact.msf_FiscalLastName2__c){
                    c.msf_FiscalLastName2__c = c.msf_FiscalLastName2__c != null ? getValue(c.msf_FiscalLastName2__c.toUpperCase().trim()) : null;
                    c.msf_CopyTaxData__c = false;
                } 

                if (c.msf_fiscalNif__c != oldContact.msf_fiscalNif__c){
                    c.msf_fiscalNif__c = c.msf_fiscalNif__c != null ? c.msf_fiscalNif__c.toUpperCase().trim() : null;
                    c.msf_CopyTaxData__c = false;
                } 
            }
        }
        else if (type == 'Individual_Contact'){
            if (c.msf_CopyTaxData__c == true && (c.FirstName != oldContact.FirstName || c.LastName != oldContact.LastName || c.Suffix != oldContact.Suffix || c.msf_Nif__c != oldContact.msf_Nif__c)){
                c.msf_FiscalFirstName__c = c.FirstName != null ? getValue(c.FirstName.toUpperCase().trim()) : null;
                c.msf_FiscalLastName1__c = c.LastName != null ? getValue(c.LastName.toUpperCase().trim()) : null;
                c.msf_FiscalLastName2__c = c.Suffix != null ? getValue(c.Suffix.toUpperCase().trim()) : null;
                c.msf_fiscalNif__c = c.msf_Nif__c != null ? c.msf_Nif__c.toUpperCase().trim() : null;
            } else {
                if (c.msf_FiscalFirstName__c != oldContact.msf_FiscalFirstName__c){
                    c.msf_FiscalFirstName__c = c.msf_FiscalFirstName__c != null ? getValue(c.msf_FiscalFirstName__c.toUpperCase().trim()) : null;
                    c.msf_CopyTaxData__c = false;
                } 
                
                if (c.msf_FiscalLastName1__c != oldContact.msf_FiscalLastName1__c){
                    c.msf_FiscalLastName1__c = c.msf_FiscalLastName1__c != null ? getValue(c.msf_FiscalLastName1__c.toUpperCase().trim()) : null;
                    c.msf_CopyTaxData__c = false;
                } 

                if (c.msf_FiscalLastName2__c != oldContact.msf_FiscalLastName2__c){
                    c.msf_FiscalLastName2__c = c.msf_FiscalLastName2__c != null ? getValue(c.msf_FiscalLastName2__c.toUpperCase().trim()) : null;
                    c.msf_CopyTaxData__c = false;
                } 

                if (c.msf_fiscalNif__c != oldContact.msf_fiscalNif__c){
                    c.msf_fiscalNif__c = c.msf_fiscalNif__c != null ? c.msf_fiscalNif__c.toUpperCase().trim() : null;
                    c.msf_CopyTaxData__c = false;
                } 
            }
        } 
    }
    
    private String getValue (String value){
        List<String> specialChars = new list<String>{'!','@','#','$','^','%','*','(',')','+','=','-','[',']','{','}','|',':','<','>','?',',','.','´','`','/', '"'};
            for (Integer i = 0; i < specialChars.size(); i++) {
                value = value.replace(specialChars[i], '');
            }  
        value = value.toUpperCase();
        value = value.replaceAll('\\Á','A');
        value = value.replaceAll('\\À','A');
        value = value.replaceAll('\\Ä','A');
        value = value.replaceAll('\\É','E');
        value = value.replaceAll('\\È','E');
        value = value.replaceAll('\\Ë','E');
        value = value.replaceAll('\\Ì','I');
        value = value.replaceAll('\\Í','I');
        value = value.replaceAll('\\Ï','I');
        value = value.replaceAll('\\Ò','O');
        value = value.replaceAll('\\Ó','O');
        value = value.replaceAll('\\Ö','O');
        value = value.replaceAll('\\Ù','U');
        value = value.replaceAll('\\Ú','U');
        value = value.replaceAll('\\Ü','U');
        return value;
    }
    
    //************* Name (Convert to CamelCase) *************
    private void setName (Contact c){
        if(c.FirstName != null){
            String tempFN = c.FirstName.toLowerCase().trim();
            String FN = '';
            
            for(String s : tempFN.split(' ')){
                FN += s.capitalize();
                FN += ' ';                
            }
            
            c.FirstName = FN.trim();
        }
        
        if(c.LastName != null){
            String tempLN = c.LastName.toLowerCase().trim();
            String LN = '';
            
            for(String s : tempLN.split(' ')){
                LN += s.capitalize();
                LN += ' ';                
            }
            
            if(c.LastName.contains('.')){
                tempLN = LN.trim();
                if(tempLN != '.'){
                    LN='';
                    for(String p : tempLN.split('\\.')){
                        LN += p.capitalize()+'.';
                    }  
                }              
            }
            c.LastName = LN.trim();
        }
        
        if(c.Suffix != null){
            String tempSF = c.Suffix.toLowerCase().trim();
            String SF = '';
            
            for(String s : tempSF.split(' ')){
                SF += s.capitalize();
                SF += ' ';                
            }
            
            c.Suffix = SF.trim();
        }
    }
    
    //************* validate NIF *************
    private Boolean getValidateNif (String value, String type){
        
        String str = value.toUpperCase();
        
        if(type == 'Individual_Contact' || type == 'Organization_Contact'){
            String validChars = 'TRWAGMYFPDXBNJZSQVHLCKET';
            String nifRexp = '(\\d{1,8})([TRWAGMYFPDXBNJZSQVHLCKE]{1})';
            String nieRexp = '([XYZ]{1})(\\d{2,8})([TRWAGMYFPDXBNJZSQVHLCKE]{1})';
            
            if (!Pattern.matches(nifRexp,str) && !Pattern.matches(nieRexp,str)) {
                return false;
            }    
            String nie = str
                .replace('X', '0')
                .replace('Y', '1')
                .replace('Z', '2');
            String letterA = str.substring(str.length()-1);
            Integer charIndex = math.mod(integer.valueof(nie.substring(0, 8)),23);
            String letterB = validChars.substring(charIndex,charIndex+1);
            if (letterB.equals(letterA)) {
                return true;
            }
            return false;
        }
        else if(type == 'Organization'){
            
            String cifRexp = '([ABCDEFGHJKLMNPQRSUVW])(\\d{7})([0-9A-J])';
            if (!Pattern.matches(cifRexp,str)){
                return false;
            }
            String aux = value.substring(0, 8);
            aux = validateCif(aux);
            return value.equals(aux);
            
        }
        return false;
    }
    
    private static String validateCif(String cif) 
    {
        return cif + calculateDigitoControl(cif);
    }
    
    private static Integer OddPosition(String str) 
    {
        Integer aux = Integer.valueOf(str);
        aux = aux * 2;
        aux = (aux / 10) + math.mod(aux, 10);
        return aux;
    }
    
    private static String calculateDigitoControl(String cif) 
    {
        String DIGITO_CONTORL_CIF = 'JABCDEFGHI';
        String CIF_CON_LETRA_FINAL = 'KNPQRSW';
        String str = cif.substring(1, 8);
        String cabecera = cif.substring(0, 1);
        Integer sumaPar = 0;
        Integer sumaImpar = 0;
        Integer sumaTotal;
        for (Integer i = 1; i < str.length(); i += 2) 
        {
            Integer aux = Integer.valueOf('' + str.substring(i,i+1));
            sumaPar += aux;
        }
        for (Integer i = 0; i < str.length(); i += 2) 
        {
            sumaImpar += OddPosition('' + str.substring(i,i+1));
        }
        sumaTotal = sumaPar + sumaImpar;
        Integer resto = math.mod(sumaTotal,10);
        if(resto == 0) sumaTotal = 0;
        else sumaTotal = 10 - resto;
        if (CIF_CON_LETRA_FINAL.contains(cabecera)) 
        {
            str = '' + DIGITO_CONTORL_CIF.substring(sumaTotal,sumaTotal+1);
        } 
        else 
        {
            str = '' + sumaTotal;
        }
        return str;
    }
    
}