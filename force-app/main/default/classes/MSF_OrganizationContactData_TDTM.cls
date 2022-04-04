/**
* @author       Deloitte
* @date         01-2019
* @group        Contacts
* @description  Logic of organization contacts
*/
global without sharing class MSF_OrganizationContactData_TDTM extends npsp.TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description  Trigger Handler on Contact that handles the logic of organization contacts. 
    * @param        listNew the list of Contact from trigger new. 
    * @param        listOld the list of Contact from trigger old. 
    * @param        triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param        objResult the describe for Contact
    * @return       dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        
        //Attributes
        List<Contact> lNewCon = (List<Contact>) newlist;
        List<Contact> lOldCon = (List<Contact>) oldlist;
        Map<Id, Contact> mOldCon = new Map<Id, Contact>();
        if(lOldCon != null){            
            mOldCon.putAll(lOldCon);
        }        

        List<Contact> lConactsToUpdate = new List<Contact>();
        
        ID idRTOrg = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        ID idRTOrgCon = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {            
            setOrganizationInfo(lNewCon, idRTOrg, idRTOrgCon, true);
            for(Contact c : lNewCon){
                setShippingSection(c, idRTOrg);
                setPrimaryLogic(c, null, idRTOrgCon);
                manageBackupData(c, null, idRTOrg);                
            }  
        }
        else if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate ) {
            setOrganizationInfo(lNewCon, idRTOrg, idRTOrgCon, false);
            for(Contact c : lNewCon){
                setShippingSection(c, idRTOrg);
                setPrimaryLogic(c, mOldCon.get(c.Id), idRTOrgCon); 
                manageBackupData(c, mOldCon.get(c.Id), idRTOrg);
                if (c.msf_LastModificationChannel__c != 'F2F') { //
                	allowOrBlockOrgUpdate(c, mOldCon.get(c.Id), idRTOrg);
                }
            }    
        }
        else if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert ) {
            lConactsToUpdate.addAll(OrganizationContactsLogic(lNewCon, null, idRTOrg, idRTOrgCon));    
        }
        else if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate ) {
            lConactsToUpdate.addAll(OrganizationContactsLogic(lNewCon, mOldCon, idRTOrg, idRTOrgCon));
        }
        
        //DML Operations
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToUpdate.addAll((List<Contact>)lConactsToUpdate);

        if(lConactsToUpdate.isEmpty() && lConactsToUpdate.isEmpty()){
            return null;
        }
        
        return dmlWrapper;               
    }
    
    
    //PRIVATE METHODS
    
    /*******************************************************************************************************
    * @description  Set the values of the business group and entity as well as marking it as main if, 
    * 				when the contact is created, the organization to which it belongs does not have any contact 
    * 				as the main one.
    * @param        lCon is the list of the new/updated contacts.
    * @param        idRTOrg is the id of the record type Organization.
    * @param        idRTOrgCon is the id of the record type Organization_Contact.
    * @param        isInsert is a flag that indicates if is a insert operation or not.
    ********************************************************************************************************/ 
    private void setOrganizationInfo (List<Contact> lCon, ID idRTOrg, ID idRTOrgCon, Boolean isInsert){        
        Set<ID> sOrgs = new Set<ID>();
        Map<ID,Contact> mOrgs = new Map<ID,Contact>();
        
        for(Contact c : lCon){
            if(c.RecordTypeId == idRTOrgCon && c.msf_Organization__c != null){
                sOrgs.add(c.msf_Organization__c);    
            }  
        }
        
        mOrgs.putAll([SELECT Id, Name, AccountId, msf_PrimaryContact__c, 
                      msf_MailingCountryBackup__c, msf_MailingStateBackup__c, msf_MailingCityBackup__c, msf_MailingPostalCodeBackup__c, msf_MailingStreetBackup__c,
                      msf_OtherCountryBackup__c, msf_OtherStateBackup__c, msf_OtherCityBackup__c, msf_OtherPostalCodeBackup__c, msf_OtherStreetBackup__c,
                      msf_DateReturnedMail1Backup__c, msf_DateReturnedMail2Backup__c, msf_DateReturnedMail3Backup__c
                      FROM Contact WHERE Id IN: sOrgs AND RecordTypeId =: idRTOrg]);

        if(!mOrgs.isEmpty()){
            for(Contact c : lCon){
                if(mOrgs.containsKey(c.msf_Organization__c)){
                    c.AccountId = mOrgs.get(c.msf_Organization__c).AccountId;
                    c.msf_ShippingEntity__c = mOrgs.get(c.msf_Organization__c).Name;
                    // Address section - When the contact of the organization is new, their addresses are automatically filled with the values of the organization.
                    if(isInsert){  
                        if (addressFieldsEmpty(c)) {
                            c.MailingCountry = mOrgs.get(c.msf_Organization__c).msf_MailingCountryBackup__c;
                            c.MailingState = mOrgs.get(c.msf_Organization__c).msf_MailingStateBackup__c;
                            c.MailingCity = mOrgs.get(c.msf_Organization__c).msf_MailingCityBackup__c;
                            c.MailingPostalCode = mOrgs.get(c.msf_Organization__c).msf_MailingPostalCodeBackup__c;
                            c.MailingStreet = mOrgs.get(c.msf_Organization__c).msf_MailingStreetBackup__c;
                            c.OtherCountry = mOrgs.get(c.msf_Organization__c).msf_OtherCountryBackup__c;
                            c.OtherState = mOrgs.get(c.msf_Organization__c).msf_OtherStateBackup__c;
                            c.OtherCity = mOrgs.get(c.msf_Organization__c).msf_OtherCityBackup__c;
                            c.OtherPostalCode = mOrgs.get(c.msf_Organization__c).msf_OtherPostalCodeBackup__c;
                            c.OtherStreet = mOrgs.get(c.msf_Organization__c).msf_OtherStreetBackup__c;
                            c.msf_DateReturnedMail1__c = mOrgs.get(c.msf_Organization__c).msf_DateReturnedMail1Backup__c;
                            c.msf_DateReturnedMail2__c = mOrgs.get(c.msf_Organization__c).msf_DateReturnedMail2Backup__c;
                            c.msf_DateReturnedMail3__c = mOrgs.get(c.msf_Organization__c).msf_DateReturnedMail3Backup__c;
                        }
                    }
                    // Set as primary contact
                    if(isInsert && c.msf_IsActive__c && !c.msf_IsPrimary__c && mOrgs.get(c.msf_Organization__c).msf_PrimaryContact__c == null){
                        c.msf_IsPrimary__c = true;    
                    }
                }
            }   
        }        
    }
    
    private Boolean addressFieldsEmpty(Contact c) {
        Boolean ret = true; 
        List<String> fields = new List<String> {c.MailingCountry, c.MailingState, c.MailingCity, c.MailingPostalCode, 
            									c.MailingStreet, c.OtherCountry, c.OtherState, c.OtherCity, c.OtherPostalCode,
            									c.OtherStreet, String.valueOf(c.msf_DateReturnedMail1__c), String.valueOf(c.msf_DateReturnedMail2__c), 
            									String.valueOf(c.msf_DateReturnedMail3__c)};
        Integer i = 0; 
        
        while(i < fields.size() && ret == true) {
            String f = fields.get(i);
            if (f != null && f != '') {
                ret = false; 
            }
            i++;
        }
        
        return ret; 
    }
    
    /*******************************************************************************************************
    * @description  Set the values on the shipping sectio based on the name and record type.
    * @param        c is the contact to which to establish the values.
    * @param        idRTOrg is the id of the record type Organization.
    ********************************************************************************************************/ 
    private void setShippingSection (Contact c, ID rtOrg){        
        if(c.RecordTypeId == rtOrg){
            if(c.LastName != '.') c.msf_ShippingEntity__c = c.LastName;     
            else c.msf_ShippingEntity__c = null;
        }else{
        	c.msf_ShippingName__c = c.FirstName;
            if(c.LastName != '.') c.msf_ShippingSurname1__c = c.LastName;
            else c.msf_ShippingSurname1__c = null;
            c.msf_ShippingSurname2__c = c.Suffix;     
        }           
    }
    
    /*******************************************************************************************************
    * @description  Set the logic of the primary, active and dates fields of the relationship for an 
    * 				organization contact.
    * @param        c is the contact to which to establish the values.
    * @param        oldC have the previous values of the contact.
    * @param        idRTOrgCon is the id of the record type Organization_Contact.
    ********************************************************************************************************/ 
    private void setPrimaryLogic (Contact c, Contact oldC, ID idRTOrgCon){        
        if(c.RecordTypeId == idRTOrgCon){ 
            if(oldC == null){
                if(c.msf_IsPrimary__c){
                    if(c.msf_StartDate__c == null){
                        c.msf_StartDate__c = date.today();
                    }
                    c.msf_EndDate__c = null;
                    c.msf_IsActive__c = true; 
                }else if(c.msf_IsActive__c){    
                    if(c.msf_StartDate__c == null){
                        c.msf_StartDate__c = date.today();
                    }
                    c.msf_EndDate__c = null; 
                }     
            }else{
                if(c.msf_IsPrimary__c != oldC.msf_IsPrimary__c && c.msf_IsPrimary__c && !c.msf_IsActive__c){
                    if(c.msf_StartDate__c == null){
                        c.msf_StartDate__c = date.today();
                    }
                    c.msf_EndDate__c = null;
                    c.msf_IsActive__c = true; 
                }else if(c.msf_IsActive__c != oldC.msf_IsActive__c){   
                    if(c.msf_IsActive__c){
                        if(c.msf_StartDate__c == null){
                        c.msf_StartDate__c = date.today();
                    }
                        c.msf_EndDate__c = null;     
                    }else{
                        c.msf_EndDate__c = date.today();
                        c.msf_IsPrimary__c = false;
                    }
                }    
            }            
        }        
    }
    
    /*******************************************************************************************************
    * @description  Allow or not edit certain fields depending on whether the organization has primary contact or not.
    * @param        c is the contact to which to establish the values.
    * @param        oldC have the previous values of the contact.
    * @param        idRTOrg is the id of the record type Organization.
    ********************************************************************************************************/ 
    private void allowOrBlockOrgUpdate (Contact c, Contact cOld, ID idRTOrg){        
        if(c.RecordTypeId == idRTOrg){ 
            
            hasContactDataChanges(c, cOld);
            
            if(c.msf_PrimaryContact__c != null && !c.msf_OrgPrimaryContactUpdated__c && c.msf_OrgContactDataUpdated__c){
                c.addError(System.Label.MSF_ORGANIZATION_ERROR_UPDATE);
            }
            
            c.msf_OrgContactDataUpdated__c = false;
            c.msf_OrgPrimaryContactUpdated__c = false;
        }        
    }
    
    /*******************************************************************************************************
    * @description  Check if there are any changes in specific fields of the contact.
    * @param        c is the contact to which to establish the values.
    * @param        oldC have the previous values of the contact.
    ********************************************************************************************************/ 
    private void hasContactDataChanges (Contact c, Contact cOld){        
        if(        
            // Shipping section
            c.msf_ShippingName__c != cOld.msf_ShippingName__c ||
            c.msf_ShippingSurname1__c != cOld.msf_ShippingSurname1__c ||
            c.msf_ShippingSurname2__c != cOld.msf_ShippingSurname2__c ||
            c.msf_Nickname__c != cOld.msf_Nickname__c ||
            c.msf_TrustedName__c != cOld.msf_TrustedName__c ||
            c.msf_LanguagePreferer__c != cOld.msf_LanguagePreferer__c ||
            c.msf_ConfirmedLanguage__c != cOld.msf_ConfirmedLanguage__c || // #26172             
            c.Gender__c != cOld.Gender__c ||
            
            // Phone section
            c.HomePhone != cOld.HomePhone ||
            c.msf_DescHomePhone__c != cOld.msf_DescHomePhone__c ||
            c.MobilePhone != cOld.MobilePhone ||
            c.msf_DescMobilePhone__c != cOld.msf_DescMobilePhone__c ||
            c.OtherPhone != cOld.OtherPhone ||
            c.msf_DescOtherPhone__c != cOld.msf_DescOtherPhone__c ||
            c.msf_MobilePhone2__c != cOld.msf_MobilePhone2__c ||
            c.msf_DescMobilePhone2__c != cOld.msf_DescMobilePhone2__c ||
            c.msf_RestrictedPhone__c != cOld.msf_RestrictedPhone__c ||
            c.msf_DescRestrictedPhone__c != cOld.msf_DescRestrictedPhone__c ||
            c.msf_RestrictedMobilePhone__c != cOld.msf_RestrictedMobilePhone__c ||
            c.msf_DescMobileRestrictedMobile__c != cOld.msf_DescMobileRestrictedMobile__c ||
            c.msf_NoEspPhone__c != cOld.msf_NoEspPhone__c ||
            c.msf_DescNoEspPhone__c != cOld.msf_DescNoEspPhone__c ||
            c.msf_NoEspMobilePhone__c != cOld.msf_NoEspMobilePhone__c ||
            c.msf_DescNoEspMobilePhone__c != cOld.msf_DescNoEspMobilePhone__c ||
            
            // Email section
            c.msf_MainEmail__c != cOld.msf_MainEmail__c ||
            c.msf_DescMainEmail__c != cOld.msf_DescMainEmail__c ||
            c.npe01__HomeEmail__c != cOld.npe01__HomeEmail__c ||
            c.msf_DescHomeEmail__c != cOld.msf_DescHomeEmail__c ||
            c.npe01__AlternateEmail__c != cOld.npe01__AlternateEmail__c ||
            c.msf_DescAlternateEmail__c != cOld.msf_DescAlternateEmail__c ||
            c.msf_RestrictedEmail__c != cOld.msf_RestrictedEmail__c ||
            c.msf_DescRestrictedEmail__c != cOld.msf_DescRestrictedEmail__c ||
            
            // Address section
            c.MailingCountry != cOld.MailingCountry ||
            c.MailingState != cOld.MailingState ||
            c.MailingCity != cOld.MailingCity ||
            c.MailingPostalCode != cOld.MailingPostalCode ||
            c.MailingStreet != cOld.MailingStreet ||
            c.OtherCountry != cOld.OtherCountry ||
            c.OtherState != cOld.OtherState ||
            c.OtherCity != cOld.OtherCity ||
            c.OtherPostalCode  != cOld.OtherPostalCode ||
            c.OtherStreet != cOld.OtherStreet ||
            c.msf_DateReturnedMail1__c != cOld.msf_DateReturnedMail1__c ||
            c.msf_DateReturnedMail2__c != cOld.msf_DateReturnedMail2__c ||
            c.msf_DateReturnedMail3__c != cOld.msf_DateReturnedMail3__c ||
            
            // Percoms section
            c.msf_NoTelemarketingCaptacionFondos__c != cOld.msf_NoTelemarketingCaptacionFondos__c ||
            c.msf_NoTelefono__c != cOld.msf_NoTelefono__c ||
            c.msf_NoRevistaSms__c != cOld.msf_NoRevistaSms__c ||
            c.msf_NoRevistaMi__c != cOld.msf_NoRevistaMi__c ||
            c.msf_NoRevistaEmail__c != cOld.msf_NoRevistaEmail__c ||
            c.msf_NoRevistaCP__c != cOld.msf_NoRevistaCP__c ||
            c.msf_NoRecibirNada__c != cOld.msf_NoRecibirNada__c ||
            c.msf_NoPlanRelacionTelefono__c != cOld.msf_NoPlanRelacionTelefono__c ||
            c.msf_NoPlanRelacionEmail__c != cOld.msf_NoPlanRelacionEmail__c ||
            c.msf_NoNewsletterEmail__c != cOld.msf_NoNewsletterEmail__c ||
            c.msf_NoNewsletOrAgradeOrPRelaEmail__c != cOld.msf_NoNewsletOrAgradeOrPRelaEmail__c ||
            c.msf_NoMi__c != cOld.msf_NoMi__c ||
            c.msf_NoMensajesTematicosSms__c != cOld.msf_NoMensajesTematicosSms__c ||
            c.msf_NoMensajesTematicosMi__c != cOld.msf_NoMensajesTematicosMi__c ||
            c.msf_NoMensajesPlanRelacionSms__c != cOld.msf_NoMensajesPlanRelacionSms__c ||
            c.msf_NoMensajesPlanRelacionMi__c != cOld.msf_NoMensajesPlanRelacionMi__c ||
            c.msf_NoMemoriaSms__c != cOld.msf_NoMemoriaSms__c ||
            c.msf_NoMemoriaMi__c != cOld.msf_NoMemoriaMi__c ||
            c.msf_NoMemoriaEmail__c != cOld.msf_NoMemoriaEmail__c ||
            c.msf_NoMemoriaCP__c != cOld.msf_NoMemoriaCP__c ||
            c.msf_NoMailingsTematicosCP__c != cOld.msf_NoMailingsTematicosCP__c ||
            c.msf_NoLlamadasBienvenidasEncuestasOtras__c != cOld.msf_NoLlamadasBienvenidasEncuestasOtras__c ||
            c.msf_NoInvitacionesEventosTelefono__c != cOld.msf_NoInvitacionesEventosTelefono__c ||
            c.msf_NoInvitacionesEventosSms__c != cOld.msf_NoInvitacionesEventosSms__c ||
            c.msf_NoInvitacionesEventosMi__c != cOld.msf_NoInvitacionesEventosMi__c ||
            c.msf_NoInvitacionesEventosEmail__c != cOld.msf_NoInvitacionesEventosEmail__c ||
            c.msf_NoInvitacionesEventosCP__c != cOld.msf_NoInvitacionesEventosCP__c ||
            c.msf_NoInformacionTestamentaria__c != cOld.msf_NoInformacionTestamentaria__c ||
            c.msf_NoEncuestaEstudioConcursoTelefono__c != cOld.msf_NoEncuestaEstudioConcursoTelefono__c ||
            c.msf_NoEncuestaEstudioConcursoSms__c != cOld.msf_NoEncuestaEstudioConcursoSms__c ||
            c.msf_NoEncuestaEstudioConcursoMi__c != cOld.msf_NoEncuestaEstudioConcursoMi__c ||
            c.msf_NoEncuestaEstudioConcursoEmail__c != cOld.msf_NoEncuestaEstudioConcursoEmail__c ||
            c.msf_NoEmailingsTematicosEmail__c != cOld.msf_NoEmailingsTematicosEmail__c ||
            c.msf_NoEmail__c != cOld.msf_NoEmail__c ||
            c.msf_NoCorreoPostal__c != cOld.msf_NoCorreoPostal__c ||
            c.msf_NoComunicaconesOnetoOneSms__c != cOld.msf_NoComunicaconesOnetoOneSms__c ||
            c.msf_NoComunicaconesOnetoOneMi__c != cOld.msf_NoComunicaconesOnetoOneMi__c ||
            c.msf_NoComunicacionesOnetoOneTelefono__c != cOld.msf_NoComunicacionesOnetoOneTelefono__c ||
            c.msf_NoComunicacionesOnetoOneEmail__c != cOld.msf_NoComunicacionesOnetoOneEmail__c ||
            c.msf_NoComunicacionesOnetoOneCP__c != cOld.msf_NoComunicacionesOnetoOneCP__c ||
            c.msf_NoCesionImagenPromocion__c != cOld.msf_NoCesionImagenPromocion__c ||
            c.msf_NoCertificadoFiscalSms__c != cOld.msf_NoCertificadoFiscalSms__c ||
            c.msf_NoCertificadoFiscalMi__c != cOld.msf_NoCertificadoFiscalMi__c ||
            c.msf_NoCertificadoFiscalEmail__c != cOld.msf_NoCertificadoFiscalEmail__c ||
            c.msf_NoCertificadoFiscalCP__c != cOld.msf_NoCertificadoFiscalCP__c ||
            c.msf_NoCartasPlanRelacionCP__c != cOld.msf_NoCartasPlanRelacionCP__c ||
            c.msf_NoCaptacionFondosSms__c != cOld.msf_NoCaptacionFondosSms__c ||
            c.msf_NoCaptacionFondosMi__c != cOld.msf_NoCaptacionFondosMi__c ||
            c.msf_NoCaptacionFondosEmail__c != cOld.msf_NoCaptacionFondosEmail__c ||
            c.msf_NoCaptacionFondosCP__c != cOld.msf_NoCaptacionFondosCP__c ||
            c.msf_NoCaptacionFondos__c != cOld.msf_NoCaptacionFondos__c ||
            c.msf_NoAgradecimientosTelefono__c != cOld.msf_NoAgradecimientosTelefono__c ||
            c.msf_NoAgradecimientosSms__c != cOld.msf_NoAgradecimientosSms__c ||
            c.msf_NoAgradecimientosMi__c != cOld.msf_NoAgradecimientosMi__c ||
            c.msf_NoAgradecimientosEmail__c != cOld.msf_NoAgradecimientosEmail__c ||
            c.msf_NoAgradecimientosCP__c != cOld.msf_NoAgradecimientosCP__c ||
            c.msf_SoloCertificadoFiscal__c != cOld.msf_SoloCertificadoFiscal__c ||
            
            // Excoms section
            c.msf_NoUMITelefonoEx__c != cOld.msf_NoUMITelefonoEx__c ||
            c.msf_NoUMISMSEx__c != cOld.msf_NoUMISMSEx__c ||
            c.msf_NoUMIPapelEx__c != cOld.msf_NoUMIPapelEx__c ||
            c.msf_NoUMIEmailEx__c != cOld.msf_NoUMIEmailEx__c ||
            c.msf_NoTestamentariosTelefonoEx__c != cOld.msf_NoTestamentariosTelefonoEx__c ||
            c.msf_NoTestamentariosSMSEx__c != cOld.msf_NoTestamentariosSMSEx__c ||
            c.msf_NoTestamentariosPapelEx__c != cOld.msf_NoTestamentariosPapelEx__c ||
            c.msf_NoTestamentariosEmailEx__c != cOld.msf_NoTestamentariosEmailEx__c ||
            c.msf_NoSeptiembreTelefonoEx__c != cOld.msf_NoSeptiembreTelefonoEx__c ||
            c.msf_NoSeptiembrePapelEx__c != cOld.msf_NoSeptiembrePapelEx__c ||
            c.msf_NoSeptiembreEmailEx__c != cOld.msf_NoSeptiembreEmailEx__c ||
            c.msf_NoRevistasPapelEx__c != cOld.msf_NoRevistasPapelEx__c ||
            c.msf_NoRevistasEmailEx__c != cOld.msf_NoRevistasEmailEx__c ||
            c.msf_NoRegaloSolidarioTelefonoEx__c != cOld.msf_NoRegaloSolidarioTelefonoEx__c ||
            c.msf_NoRegaloSolidarioSMSEx__c != cOld.msf_NoRegaloSolidarioSMSEx__c ||
            c.msf_NoRegaloSolidarioPapelEx__c != cOld.msf_NoRegaloSolidarioPapelEx__c ||
            c.msf_NoRegaloSolidarioEmailEx__c != cOld.msf_NoRegaloSolidarioEmailEx__c ||
            c.msf_NoOtrasCultivacionPersonalTelefonoEx__c != cOld.msf_NoOtrasCultivacionPersonalTelefonoEx__c ||
            c.msf_NoOtrasCultivacionPersonalSMSEx__c != cOld.msf_NoOtrasCultivacionPersonalSMSEx__c ||
            c.msf_NoOtrasCultivacionPersonalPersonalEx__c != cOld.msf_NoOtrasCultivacionPersonalPersonalEx__c ||
            c.msf_NoOtrasCultivacionPersonalPapelEx__c != cOld.msf_NoOtrasCultivacionPersonalPapelEx__c ||
            c.msf_NoOtrasCultivacionPersonalEmailEx__c != cOld.msf_NoOtrasCultivacionPersonalEmailEx__c ||
            c.msf_NoOtrasCultivacionMasivaTelefonoEx__c != cOld.msf_NoOtrasCultivacionMasivaTelefonoEx__c ||
            c.msf_NoOtrasCultivacionMasivaSMSEx__c != cOld.msf_NoOtrasCultivacionMasivaSMSEx__c ||
            c.msf_NoOtrasCultivacionMasivaPapelEx__c != cOld.msf_NoOtrasCultivacionMasivaPapelEx__c ||
            c.msf_NoOtrasCultivacionMasivaEmailEx__c != cOld.msf_NoOtrasCultivacionMasivaEmailEx__c ||
            c.msf_NoOtrasCampanasCaptPersTelefonoEx__c != cOld.msf_NoOtrasCampanasCaptPersTelefonoEx__c ||
            c.msf_NoOtrasCampanasCaptPersPapelEx__c != cOld.msf_NoOtrasCampanasCaptPersPapelEx__c ||
            c.msf_NoOtrasCampanasCaptPersEmailEx__c != cOld.msf_NoOtrasCampanasCaptPersEmailEx__c ||
            c.msf_NoOtrasCampanasCaptMasivaTelefonoEx__c != cOld.msf_NoOtrasCampanasCaptMasivaTelefonoEx__c ||
            c.msf_NoOtrasCampanasCaptMasivaSMSEx__c != cOld.msf_NoOtrasCampanasCaptMasivaSMSEx__c ||
            c.msf_NoOtrasCampanasCaptMasivaPapelEx__c != cOld.msf_NoOtrasCampanasCaptMasivaPapelEx__c ||
            c.msf_NoOtrasCampanasCaptMasivaEmailEx__c != cOld.msf_NoOtrasCampanasCaptMasivaEmailEx__c ||
            c.msf_NoNavidadPersonalizadaTelefonoEx__c != cOld.msf_NoNavidadPersonalizadaTelefonoEx__c ||
            c.msf_NoNavidadPersonalizadaPapelEx__c != cOld.msf_NoNavidadPersonalizadaPapelEx__c ||
            c.msf_NoNavidadPersonalizadaEmailEx__c != cOld.msf_NoNavidadPersonalizadaEmailEx__c ||
            c.msf_NoMemoriasPapelEx__c != cOld.msf_NoMemoriasPapelEx__c ||
            c.msf_NoMemoriasEmailEx__c != cOld.msf_NoMemoriasEmailEx__c ||
            c.msf_NoMailingUpgradeTelefonoEx__c != cOld.msf_NoMailingUpgradeTelefonoEx__c ||
            c.msf_NoMailingUpgradeSMSEx__c != cOld.msf_NoMailingUpgradeSMSEx__c ||
            c.msf_NoMailingUpgradePapelEx__c != cOld.msf_NoMailingUpgradePapelEx__c ||
            c.msf_NoMailingUpgradeEmailEx__c != cOld.msf_NoMailingUpgradeEmailEx__c ||
            c.msf_NoJunioTelefonoEx__c != cOld.msf_NoJunioTelefonoEx__c ||
            c.msf_NoJunioPapelEx__c != cOld.msf_NoJunioPapelEx__c ||
            c.msf_NoJunioEmailEx__c != cOld.msf_NoJunioEmailEx__c ||
            c.msf_NoInvitacionesEventosTelefonolEx__c != cOld.msf_NoInvitacionesEventosTelefonolEx__c ||
            c.msf_NoInvitacionesEventosSMSEx__c != cOld.msf_NoInvitacionesEventosSMSEx__c ||
            c.msf_NoInvitacionesEventosPapelEx__c != cOld.msf_NoInvitacionesEventosPapelEx__c ||
            c.msf_NoInvitacionesEventosEmailEx__c != cOld.msf_NoInvitacionesEventosEmailEx__c ||
            c.msf_NoInformeEmpresasTelefonoEx__c != cOld.msf_NoInformeEmpresasTelefonoEx__c ||
            c.msf_NoInformeEmpresasSMSEx__c != cOld.msf_NoInformeEmpresasSMSEx__c ||
            c.msf_NoInformeEmpresasPapelEx__c != cOld.msf_NoInformeEmpresasPapelEx__c ||
            c.msf_NoInformeEmpresasEmailEx__c != cOld.msf_NoInformeEmpresasEmailEx__c ||
            c.msf_NoFiscalTelefonoEx__c != cOld.msf_NoFiscalTelefonoEx__c ||
            c.msf_NoFiscalPapelEx__c != cOld.msf_NoFiscalPapelEx__c ||
            c.msf_NoFiscalEmailEx__c != cOld.msf_NoFiscalEmailEx__c ||
            c.msf_NoEncuestasTelefonoEx__c != cOld.msf_NoEncuestasTelefonoEx__c ||
            c.msf_NoEncuestasPapelEx__c != cOld.msf_NoEncuestasPapelEx__c ||
            c.msf_NoEncuestasEmailEx__c != cOld.msf_NoEncuestasEmailEx__c ||
            c.msf_NoDiciembreTelefonoEx__c != cOld.msf_NoDiciembreTelefonoEx__c ||
            c.msf_NoDiciembrePapelEx__c != cOld.msf_NoDiciembrePapelEx__c ||
            c.msf_NoDiciembreEmailEx__c != cOld.msf_NoDiciembreEmailEx__c ||
            c.msf_NoAgradecimientosDonativosTelefonoEx__c != cOld.msf_NoAgradecimientosDonativosTelefonoEx__c ||
            c.msf_NoAgradecimientosDonativosSMSEx__c != cOld.msf_NoAgradecimientosDonativosSMSEx__c ||
            c.msf_NoAgradecimientosDonativosPapelEx__c != cOld.msf_NoAgradecimientosDonativosPapelEx__c ||
            c.msf_NoAgradecimientosDonativosEmailEx__c != cOld.msf_NoAgradecimientosDonativosEmailEx__c ||
            
            //Excoms section info
            c.msf_DescripcionExclusionComunicaciones__c != cOld.msf_DescripcionExclusionComunicaciones__c ||
            c.msf_FechaExclusionComunicaciones__c != cOld.msf_FechaExclusionComunicaciones__c
        ){
            c.msf_OrgContactDataUpdated__c = true;    
        }    
    }
    
    /*******************************************************************************************************
    * @description  Gets or sets data fields contact backup.
    * @param        c is the contact to which to establish the values.
    * @param        oldC have the previous values of the contact.
    * @param        idRTOrg is the id of the record type Organization.
    ********************************************************************************************************/ 
    private void manageBackupData (Contact c, Contact cOld, ID rtOrg){        
        
        if(c.RecordTypeId == rtOrg){
            if(cOld == null || (cOld != null && c.msf_PrimaryContact__c == null && c.msf_PrimaryContact__c == cOld.msf_PrimaryContact__c)){            
                
                // Phone section
                c.msf_HomePhoneBackup__c = c.HomePhone;
                c.msf_DescHomePhoneBackup__c = c.msf_DescHomePhone__c;
                c.msf_MobilePhoneBackup__c = c.MobilePhone;
                c.msf_DescMobilePhoneBackup__c = c.msf_DescMobilePhone__c;
                c.msf_OtherPhoneBackup__c = c.OtherPhone;
                c.msf_DescOtherPhoneBackup__c = c.msf_DescOtherPhone__c;
                c.msf_MobilePhone2Backup__c = c.msf_MobilePhone2__c;
                c.msf_DescMobilePhone2Backup__c = c.msf_DescMobilePhone2__c;
                c.msf_RestrictedPhoneBackup__c = c.msf_RestrictedPhone__c;
                c.msf_DescRestrictedPhoneBackup__c = c.msf_DescRestrictedPhone__c;
                c.msf_RestrictedMobilePhoneBackup__c = c.msf_RestrictedMobilePhone__c;
                c.msf_DescMobileRestrictedMobileBackup__c = c.msf_DescMobileRestrictedMobile__c;
                c.msf_NoEspPhoneBackup__c = c.msf_NoEspPhone__c;
                c.msf_DescNoEspPhoneBackup__c = c.msf_DescNoEspPhone__c;
                c.msf_NoEspMobilePhoneBackup__c = c.msf_NoEspMobilePhone__c;
                c.msf_DescNoEspMobilePhoneBackup__c = c.msf_DescNoEspMobilePhone__c;
                
                // Email section
                c.msf_MainEmailBackup__c = c.msf_MainEmail__c;
                c.msf_DescMainEmailBackup__c = c.msf_DescMainEmail__c;
                c.msf_HomeEmailBackup__c = c.npe01__HomeEmail__c;
                c.msf_DescHomeEmailBackup__c = c.msf_DescHomeEmail__c;
                c.msf_AlternateEmailBackup__c = c.npe01__AlternateEmail__c;
                c.msf_DescAlternateEmailBackup__c = c.msf_DescAlternateEmail__c;
                c.msf_RestrictedEmailBackup__c = c.msf_RestrictedEmail__c;
                c.msf_DescRestrictedEmailBackup__c = c.msf_DescRestrictedEmail__c;
                
                // Address section      
                c.msf_MailingCountryBackup__c = c.MailingCountry;
                c.msf_MailingStateBackup__c = c.MailingState;
                c.msf_MailingCityBackup__c = c.MailingCity;        
                c.msf_MailingPostalCodeBackup__c = c.MailingPostalCode;
                c.msf_MailingStreetBackup__c = c.MailingStreet;
                c.msf_OtherCountryBackup__c = c.OtherCountry;
                c.msf_OtherStateBackup__c = c.OtherState;
                c.msf_OtherCityBackup__c = c.OtherCity;
                c.msf_OtherPostalCodeBackup__c = c.OtherPostalCode;
                c.msf_OtherStreetBackup__c = c.OtherStreet;
                c.msf_DateReturnedMail1Backup__c = c.msf_DateReturnedMail1__c;
                c.msf_DateReturnedMail2Backup__c = c.msf_DateReturnedMail2__c;
                c.msf_DateReturnedMail3Backup__c = c.msf_DateReturnedMail3__c;
            }
            else if(cOld != null && c.msf_PrimaryContact__c == null && c.msf_PrimaryContact__c != cOld.msf_PrimaryContact__c){
                
                // Shipping section
                c.msf_ShippingName__c = null;
                c.msf_ShippingSurname1__c = null;
                c.msf_ShippingSurname2__c = null;
                c.msf_Nickname__c = null;
                c.msf_TrustedName__c = null;
                c.Gender__c = null;
                
                // Phone section
                c.HomePhone = c.msf_HomePhoneBackup__c;
                c.msf_DescHomePhone__c = c.msf_DescHomePhoneBackup__c;
                c.MobilePhone = c.msf_MobilePhoneBackup__c;
                c.msf_DescMobilePhone__c = c.msf_DescMobilePhoneBackup__c;
                c.OtherPhone =  c.msf_OtherPhoneBackup__c;
                c.msf_DescOtherPhone__c = c.msf_DescOtherPhoneBackup__c;
                c.msf_MobilePhone2__c = c.msf_MobilePhone2Backup__c;
                c.msf_DescMobilePhone2__c = c.msf_DescMobilePhone2Backup__c;
                c.msf_RestrictedPhone__c = c.msf_RestrictedPhoneBackup__c;
                c.msf_DescRestrictedPhone__c = c.msf_DescRestrictedPhoneBackup__c;
                c.msf_RestrictedMobilePhone__c = c.msf_RestrictedMobilePhoneBackup__c;
                c.msf_DescMobileRestrictedMobile__c = c.msf_DescMobileRestrictedMobileBackup__c;
                c.msf_NoEspPhone__c = c.msf_NoEspPhoneBackup__c;
                c.msf_DescNoEspPhone__c = c.msf_DescNoEspPhoneBackup__c;
                c.msf_NoEspMobilePhone__c = c.msf_NoEspMobilePhoneBackup__c;
                c.msf_DescNoEspMobilePhone__c = c.msf_DescNoEspMobilePhoneBackup__c;
                
                // Email section
                c.msf_MainEmail__c = c.msf_MainEmailBackup__c;
                c.msf_DescMainEmail__c = c.msf_DescMainEmailBackup__c;
                c.npe01__HomeEmail__c = c.msf_HomeEmailBackup__c;
                c.msf_DescHomeEmail__c = c.msf_DescHomeEmailBackup__c;
                c.npe01__AlternateEmail__c = c.msf_AlternateEmailBackup__c;
                c.msf_DescAlternateEmail__c = c.msf_DescAlternateEmailBackup__c;
                c.msf_RestrictedEmail__c = c.msf_RestrictedEmailBackup__c;
                c.msf_DescRestrictedEmail__c = c.msf_DescRestrictedEmailBackup__c;
                
                // Address section
                c.MailingCountry = c.msf_MailingCountryBackup__c;
                c.MailingState = c.msf_MailingStateBackup__c;
                c.MailingCity = c.msf_MailingCityBackup__c;
                c.MailingPostalCode = c.msf_MailingPostalCodeBackup__c;
                c.MailingStreet = c.msf_MailingStreetBackup__c;
                c.OtherCountry = c.msf_OtherCountryBackup__c;
                c.OtherState = c.msf_OtherStateBackup__c;
                c.OtherCity = c.msf_OtherCityBackup__c;
                c.OtherPostalCode = c.msf_OtherPostalCodeBackup__c;
                c.OtherStreet = c.msf_OtherStreetBackup__c; 
                c.msf_DateReturnedMail1__c = c.msf_DateReturnedMail1Backup__c;
                c.msf_DateReturnedMail2__c = c.msf_DateReturnedMail2Backup__c;
                c.msf_DateReturnedMail3__c = c.msf_DateReturnedMail3Backup__c;            
            }                
        }
    }  
        
    /*******************************************************************************************************
    * @description  It has the logic to configure the records related to the organization contacts.
    * @param        lNewCon is the list of the new or updated contacts.
    * @param        mOldCon is the map that contains the old values of the updated contacts.
    * @param        idRTOrg is the id of the record type Organization.
    * @param        idRTOrgCon is the id of the record type Organization_Contact.
    * @return       List<Contact> to update after applying the logic.
    ********************************************************************************************************/ 
    private List<Contact> OrganizationContactsLogic (List<Contact> lNewCon, map<ID,Contact> mOldCon, ID idRTOrg, ID idRTOrgCon){

        List<Contact> lUpdateContacts = new List<Contact>();
        
        Map<ID,ID> mOrgPrimaryContact = new Map<ID,ID>();
        Map<ID,ID> mCheckPrimaryContact = new Map<ID,ID>();
        
        Set<Contact> sOrgs = new Set<Contact>();
        Set<Contact> sOrgContacts = new Set<Contact>(); 
        
        Boolean isInsert = (mOldCon == null);
        
        Set<Id> orgsIds = new Set<Id>();
        for (Contact c : lNewCon) {
            if (c.msf_Organization__c != null) {
                orgsIds.add(c.msf_Organization__c);
            }
        }
        Map<Id, Contact> mOrgsByContact = new Map<Id, Contact>();
        for (Contact org : [SELECT Id, msf_PrimaryContact__c, msf_HomePhoneBackup__c,msf_DescHomePhoneBackup__c, msf_MobilePhoneBackup__c, 
                            msf_DescMobilePhoneBackup__c, msf_OtherPhoneBackup__c, msf_DescOtherPhoneBackup__c, msf_MobilePhone2Backup__c, 
                            msf_DescMobilePhone2Backup__c, msf_RestrictedPhoneBackup__c, msf_DescRestrictedPhoneBackup__c, 
                            msf_RestrictedMobilePhoneBackup__c, msf_DescMobileRestrictedMobileBackup__c, msf_NoEspPhoneBackup__c, 
                            msf_DescNoEspPhoneBackup__c, msf_NoEspMobilePhoneBackup__c, msf_DescNoEspMobilePhoneBackup__c, 
                            msf_MainEmailBackup__c, msf_DescMainEmailBackup__c, msf_HomeEmailBackup__c, msf_DescHomeEmailBackup__c, 
                            msf_AlternateEmailBackup__c, msf_DescAlternateEmailBackup__c, msf_RestrictedEmailBackup__c, 
                            msf_DescRestrictedEmailBackup__c, msf_MailingCountryBackup__c, msf_MailingStateBackup__c, 
                            msf_MailingCityBackup__c, msf_MailingPostalCodeBackup__c, msf_MailingStreetBackup__c, msf_OtherCountryBackup__c, 
                            msf_OtherStateBackup__c, msf_OtherCityBackup__c, msf_OtherPostalCodeBackup__c, msf_OtherStreetBackup__c, 
                            msf_DateReturnedMail1Backup__c, msf_DateReturnedMail2Backup__c, msf_DateReturnedMail3Backup__c, msf_ShippingEntity__c
                            FROM Contact WHERE Id IN :orgsIds AND RecordtypeId =: idRTOrg ]) {
            mOrgsByContact.put(org.Id, org);
			
        }

        for(Contact c : lNewCon){
            if(c.RecordTypeId == idRTOrgCon && c.msf_Organization__c != null){  
                if(isInsert || c.msf_IsPrimary__c != mOldCon.get(c.Id).msf_IsPrimary__c){               
                    Contact tempOrg = new Contact();
                                      
                    if(c.msf_IsPrimary__c){                        
                        mOrgPrimaryContact.put(c.msf_Organization__c, c.Id);  
                        tempOrg = setPrimaryContactValuesInOrg(c, mOrgsByContact.get(c.msf_Organization__c)); 
                        sOrgs.add(tempOrg); 
                    }
                    else if(!isInsert){
                        mCheckPrimaryContact.put(c.msf_Organization__c, c.Id);
                    }
                }
                else if(!isInsert && c.msf_IsActive__c != mOldCon.get(c.Id).msf_IsActive__c && !c.msf_IsActive__c){         
                    mCheckPrimaryContact.put(c.msf_Organization__c, c.Id);
                }
                else if(!isInsert && c.msf_IsPrimary__c){                   
                    sOrgs.add(setPrimaryContactValuesInOrg(c, mOrgsByContact.get(c.msf_Organization__c))); 
                }
                
                if(!isInsert && c.msf_Organization__c != mOldCon.get(c.Id).msf_Organization__c && mOldCon.get(c.Id).msf_Organization__c != null){
                    mCheckPrimaryContact.put(mOldCon.get(c.Id).msf_Organization__c, c.Id);      
                }
            }
        }
        
        if(!mOrgPrimaryContact.isEmpty()){
            for(Contact orgConData : [SELECT Id, msf_IsPrimary__c, msf_Organization__c 
                                      FROM Contact 
                                      WHERE msf_Organization__c IN: mOrgPrimaryContact.keySet()
                                      AND Id NOT IN: mOrgPrimaryContact.values() 
                                      AND msf_IsPrimary__c = TRUE
                                      AND RecordtypeId =: idRTOrgCon 
                                     ])
            {
                orgConData.msf_IsPrimary__c = false;
                sOrgContacts.add(orgConData);
            }
        }
        
        if(!mCheckPrimaryContact.isEmpty()){
            for(Contact org : [SELECT Id, msf_PrimaryContact__c 
                               FROM Contact 
                               WHERE Id IN: mCheckPrimaryContact.keySet()
                               AND msf_PrimaryContact__c != null
                               AND RecordtypeId =: idRTOrg 
                              ])
            {
                if(org.msf_PrimaryContact__c == mCheckPrimaryContact.get(org.Id)){
                    org.msf_PrimaryContact__c = null;
                    sOrgs.add(org);
                }
            } 
        }
        
        lUpdateContacts.addAll(sOrgs);
        lUpdateContacts.addAll(sOrgContacts);
        
        return lUpdateContacts;
    }
    
    /*******************************************************************************************************
    * @description  Sets the values of the primary contact record in the organization record.
    * @param        c is the primary contact that has the values to update the organization's record.
    * @return       Contact is the organization record with values of the primary contact.
    ********************************************************************************************************/ 
    private Contact setPrimaryContactValuesInOrg (Contact c, Contact orgC){        
        
        Contact temp;
        
        if (orgC == null) {
            temp = new Contact();
        }
        else {
            temp = orgC; 
        }
        
        temp.Id = c.msf_Organization__c;
        temp.msf_PrimaryContact__c = c.Id;
        Map <String, String> fieldsMap = getFieldsMap();
        
        List<String> fieldsNoBackup = new List<String>{'msf_ShippingEntity', 'msf_ShippingName', 'msf_ShippingSurname1', 'msf_ShippingSurname2', 'msf_Nickname', 'msf_TrustedName', 'msf_LanguagePreferer'};
        
        for (String field : fieldsMap.keyset()) {
            String fC = field + (field.startsWith('msf_') || field.startsWith('npe01') ? '__c' : '');
            String fieldDesc = fieldsMap.get(field); //descripción del campo
            
            if (c.get(fC) != null) { //Contacto tiene informado campo -> machaca info en la empresa; 
                temp.put(fC, c.get(fC)); 
                    
                if (fieldDesc != '') { //Campo si tiene desc; 
                    fieldDesc += '__c';
                    temp.put(fieldDesc, c.get(fieldDesc));
                }
            }
            else { //Contacto no tiene informado campo
                if (fieldsNoBackup.contains(field) == false) {
                    String fieldBackup = (field.startsWith('msf_') == false) ? 'msf_' : '';
                    fieldBackup += field.replaceFirst('npe01__', '') + 'Backup__c'; 
                    
                    if (temp.get(fieldBackup) != null) { //Empresa tiene campo informado en backup -> se queda info backup;
                        temp.put(fC, temp.get(fieldBackup));
                    }
                    else { //Empresa no tiene campo informado en backup -> se queda null; 
                        temp.put(fC, null);
                    }
                    
                    if (fieldDesc != '') { //Campo si tiene desc; Buscar el BackUp de la Desc;
                        String fieldDescBackup = fieldDesc + 'Backup__c';
                        fieldDesc += '__c';
                        temp.put(fieldDesc, temp.get(fieldDescBackup));
                    }
                }
            }
        }
		// Shipping section
        /*temp.msf_ShippingEntity__c = c.msf_ShippingEntity__c;
        temp.msf_ShippingName__c = c.msf_ShippingName__c;
        temp.msf_ShippingSurname1__c = c.msf_ShippingSurname1__c;
        temp.msf_ShippingSurname2__c = c.msf_ShippingSurname2__c;
        /*
        temp.msf_Nickname__c = c.msf_Nickname__c;
        temp.msf_TrustedName__c = c.msf_TrustedName__c;
        temp.msf_LanguagePreferer__c = c.msf_LanguagePreferer__c;
        temp.Gender__c = c.Gender__c;
        
        // Phone section
        temp.HomePhone = c.HomePhone;
        temp.msf_DescHomePhone__c = c.msf_DescHomePhone__c;
        temp.MobilePhone = c.MobilePhone;
        temp.msf_DescMobilePhone__c = c.msf_DescMobilePhone__c;
        temp.OtherPhone = c.OtherPhone;
        temp.msf_DescOtherPhone__c = c.msf_DescOtherPhone__c;
        temp.msf_MobilePhone2__c = c.msf_MobilePhone2__c;
        temp.msf_DescMobilePhone2__c = c.msf_DescMobilePhone2__c;
        temp.msf_RestrictedPhone__c = c.msf_RestrictedPhone__c;
        temp.msf_DescRestrictedPhone__c = c.msf_DescRestrictedPhone__c;
        temp.msf_RestrictedMobilePhone__c = c.msf_RestrictedMobilePhone__c;
        temp.msf_DescMobileRestrictedMobile__c = c.msf_DescMobileRestrictedMobile__c;
        temp.msf_NoEspPhone__c = c.msf_NoEspPhone__c;
        temp.msf_DescNoEspPhone__c = c.msf_DescNoEspPhone__c;
        temp.msf_NoEspMobilePhone__c = c.msf_NoEspMobilePhone__c;
        temp.msf_DescNoEspMobilePhone__c = c.msf_DescNoEspMobilePhone__c;
        
        // Email section 
        temp.msf_MainEmail__c = c.msf_MainEmail__c;
        temp.msf_DescMainEmail__c = c.msf_DescMainEmail__c;
        temp.npe01__HomeEmail__c = c.npe01__HomeEmail__c;
        temp.msf_DescHomeEmail__c = c.msf_DescHomeEmail__c;
        temp.npe01__AlternateEmail__c = c.npe01__AlternateEmail__c;
        temp.msf_DescAlternateEmail__c = c.msf_DescAlternateEmail__c;
        temp.msf_RestrictedEmail__c = c.msf_RestrictedEmail__c;
        temp.msf_DescRestrictedEmail__c = c.msf_DescRestrictedEmail__c;
        
        // Address section      
        temp.MailingCountry = c.MailingCountry;
        temp.MailingState = c.MailingState;
        temp.MailingCity = c.MailingCity;        
        temp.MailingPostalCode = c.MailingPostalCode;
        temp.MailingStreet = c.MailingStreet;
        temp.OtherCountry = c.OtherCountry;
        temp.OtherState = c.OtherState;
        temp.OtherCity = c.OtherCity;
        temp.OtherPostalCode = c.OtherPostalCode;
        temp.OtherStreet = c.OtherStreet;        
        temp.msf_DateReturnedMail1__c = c.msf_DateReturnedMail1__c;
        temp.msf_DateReturnedMail2__c = c.msf_DateReturnedMail2__c;
        temp.msf_DateReturnedMail3__c = c.msf_DateReturnedMail3__c;*/
        
        // Percoms section  
        temp.msf_NoTelemarketingCaptacionFondos__c = c.msf_NoTelemarketingCaptacionFondos__c;
        temp.msf_NoTelefono__c = c.msf_NoTelefono__c;
        temp.msf_NoRevistaSms__c = c.msf_NoRevistaSms__c;
        temp.msf_NoRevistaMi__c = c.msf_NoRevistaMi__c;
        temp.msf_NoRevistaEmail__c = c.msf_NoRevistaEmail__c;
        temp.msf_NoRevistaCP__c = c.msf_NoRevistaCP__c;
        temp.msf_NoRecibirNada__c = c.msf_NoRecibirNada__c;
        temp.msf_NoPlanRelacionTelefono__c = c.msf_NoPlanRelacionTelefono__c;
        temp.msf_NoPlanRelacionEmail__c = c.msf_NoPlanRelacionEmail__c;
        temp.msf_NoNewsletterEmail__c = c.msf_NoNewsletterEmail__c;
        temp.msf_NoNewsletOrAgradeOrPRelaEmail__c = c.msf_NoNewsletOrAgradeOrPRelaEmail__c;
        temp.msf_NoMi__c = c.msf_NoMi__c;
        temp.msf_NoMensajesTematicosSms__c = c.msf_NoMensajesTematicosSms__c;
        temp.msf_NoMensajesTematicosMi__c = c.msf_NoMensajesTematicosMi__c;
        temp.msf_NoMensajesPlanRelacionSms__c = c.msf_NoMensajesPlanRelacionSms__c;
        temp.msf_NoMensajesPlanRelacionMi__c = c.msf_NoMensajesPlanRelacionMi__c;
        temp.msf_NoMemoriaSms__c = c.msf_NoMemoriaSms__c;
        temp.msf_NoMemoriaMi__c = c.msf_NoMemoriaMi__c;
        temp.msf_NoMemoriaEmail__c = c.msf_NoMemoriaEmail__c;
        temp.msf_NoMemoriaCP__c = c.msf_NoMemoriaCP__c;
        temp.msf_NoMailingsTematicosCP__c = c.msf_NoMailingsTematicosCP__c;
        temp.msf_NoLlamadasBienvenidasEncuestasOtras__c = c.msf_NoLlamadasBienvenidasEncuestasOtras__c;
        temp.msf_NoInvitacionesEventosTelefono__c = c.msf_NoInvitacionesEventosTelefono__c;
        temp.msf_NoInvitacionesEventosSms__c = c.msf_NoInvitacionesEventosSms__c;
        temp.msf_NoInvitacionesEventosMi__c = c.msf_NoInvitacionesEventosMi__c;
        temp.msf_NoInvitacionesEventosEmail__c = c.msf_NoInvitacionesEventosEmail__c;
        temp.msf_NoInvitacionesEventosCP__c = c.msf_NoInvitacionesEventosCP__c;
        temp.msf_NoInformacionTestamentaria__c = c.msf_NoInformacionTestamentaria__c;
        temp.msf_NoEncuestaEstudioConcursoTelefono__c = c.msf_NoEncuestaEstudioConcursoTelefono__c;
        temp.msf_NoEncuestaEstudioConcursoSms__c = c.msf_NoEncuestaEstudioConcursoSms__c;
        temp.msf_NoEncuestaEstudioConcursoMi__c = c.msf_NoEncuestaEstudioConcursoMi__c;
        temp.msf_NoEncuestaEstudioConcursoEmail__c = c.msf_NoEncuestaEstudioConcursoEmail__c;
        temp.msf_NoEmailingsTematicosEmail__c = c.msf_NoEmailingsTematicosEmail__c;
        temp.msf_NoEmail__c = c.msf_NoEmail__c;
        temp.msf_NoCorreoPostal__c = c.msf_NoCorreoPostal__c;
        temp.msf_NoComunicaconesOnetoOneSms__c = c.msf_NoComunicaconesOnetoOneSms__c;
        temp.msf_NoComunicaconesOnetoOneMi__c = c.msf_NoComunicaconesOnetoOneMi__c;
        temp.msf_NoComunicacionesOnetoOneTelefono__c = c.msf_NoComunicacionesOnetoOneTelefono__c;
        temp.msf_NoComunicacionesOnetoOneEmail__c = c.msf_NoComunicacionesOnetoOneEmail__c;
        temp.msf_NoComunicacionesOnetoOneCP__c = c.msf_NoComunicacionesOnetoOneCP__c;
        temp.msf_NoCesionImagenPromocion__c = c.msf_NoCesionImagenPromocion__c;
        temp.msf_NoCertificadoFiscalSms__c = c.msf_NoCertificadoFiscalSms__c;
        temp.msf_NoCertificadoFiscalMi__c = c.msf_NoCertificadoFiscalMi__c;
        temp.msf_NoCertificadoFiscalEmail__c = c.msf_NoCertificadoFiscalEmail__c;
        temp.msf_NoCertificadoFiscalCP__c = c.msf_NoCertificadoFiscalCP__c;
        temp.msf_NoCartasPlanRelacionCP__c = c.msf_NoCartasPlanRelacionCP__c;
        temp.msf_NoCaptacionFondosSms__c = c.msf_NoCaptacionFondosSms__c;
        temp.msf_NoCaptacionFondosMi__c = c.msf_NoCaptacionFondosMi__c;
        temp.msf_NoCaptacionFondosEmail__c = c.msf_NoCaptacionFondosEmail__c;
        temp.msf_NoCaptacionFondosCP__c = c.msf_NoCaptacionFondosCP__c;
        temp.msf_NoCaptacionFondos__c = c.msf_NoCaptacionFondos__c;
        temp.msf_NoAgradecimientosTelefono__c = c.msf_NoAgradecimientosTelefono__c;
        temp.msf_NoAgradecimientosSms__c = c.msf_NoAgradecimientosSms__c;
        temp.msf_NoAgradecimientosMi__c = c.msf_NoAgradecimientosMi__c;
        temp.msf_NoAgradecimientosEmail__c = c.msf_NoAgradecimientosEmail__c;
        temp.msf_NoAgradecimientosCP__c = c.msf_NoAgradecimientosCP__c;
        temp.msf_SoloCertificadoFiscal__c = c.msf_SoloCertificadoFiscal__c;
        
        // Excoms section
        temp.msf_NoUMITelefonoEx__c = c.msf_NoUMITelefonoEx__c;
        temp.msf_NoUMISMSEx__c = c.msf_NoUMISMSEx__c;
        temp.msf_NoUMIPapelEx__c = c.msf_NoUMIPapelEx__c;
        temp.msf_NoUMIEmailEx__c = c.msf_NoUMIEmailEx__c;
        temp.msf_NoTestamentariosTelefonoEx__c = c.msf_NoTestamentariosTelefonoEx__c;
        temp.msf_NoTestamentariosSMSEx__c = c.msf_NoTestamentariosSMSEx__c;
        temp.msf_NoTestamentariosPapelEx__c = c.msf_NoTestamentariosPapelEx__c;
        temp.msf_NoTestamentariosEmailEx__c = c.msf_NoTestamentariosEmailEx__c;
        temp.msf_NoSeptiembreTelefonoEx__c = c.msf_NoSeptiembreTelefonoEx__c;
        temp.msf_NoSeptiembrePapelEx__c = c.msf_NoSeptiembrePapelEx__c;
        temp.msf_NoSeptiembreEmailEx__c = c.msf_NoSeptiembreEmailEx__c;
        temp.msf_NoRevistasPapelEx__c = c.msf_NoRevistasPapelEx__c;
        temp.msf_NoRevistasEmailEx__c = c.msf_NoRevistasEmailEx__c;
        temp.msf_NoRegaloSolidarioTelefonoEx__c = c.msf_NoRegaloSolidarioTelefonoEx__c;
        temp.msf_NoRegaloSolidarioSMSEx__c = c.msf_NoRegaloSolidarioSMSEx__c;
        temp.msf_NoRegaloSolidarioPapelEx__c = c.msf_NoRegaloSolidarioPapelEx__c;
        temp.msf_NoRegaloSolidarioEmailEx__c = c.msf_NoRegaloSolidarioEmailEx__c;
        temp.msf_NoOtrasCultivacionPersonalTelefonoEx__c = c.msf_NoOtrasCultivacionPersonalTelefonoEx__c;
        temp.msf_NoOtrasCultivacionPersonalSMSEx__c = c.msf_NoOtrasCultivacionPersonalSMSEx__c;
        temp.msf_NoOtrasCultivacionPersonalPersonalEx__c = c.msf_NoOtrasCultivacionPersonalPersonalEx__c;
        temp.msf_NoOtrasCultivacionPersonalPapelEx__c = c.msf_NoOtrasCultivacionPersonalPapelEx__c;
        temp.msf_NoOtrasCultivacionPersonalEmailEx__c = c.msf_NoOtrasCultivacionPersonalEmailEx__c;
        temp.msf_NoOtrasCultivacionMasivaTelefonoEx__c = c.msf_NoOtrasCultivacionMasivaTelefonoEx__c;
        temp.msf_NoOtrasCultivacionMasivaSMSEx__c = c.msf_NoOtrasCultivacionMasivaSMSEx__c;
        temp.msf_NoOtrasCultivacionMasivaPapelEx__c = c.msf_NoOtrasCultivacionMasivaPapelEx__c;
        temp.msf_NoOtrasCultivacionMasivaEmailEx__c = c.msf_NoOtrasCultivacionMasivaEmailEx__c;
        temp.msf_NoOtrasCampanasCaptPersTelefonoEx__c = c.msf_NoOtrasCampanasCaptPersTelefonoEx__c;
        temp.msf_NoOtrasCampanasCaptPersPapelEx__c = c.msf_NoOtrasCampanasCaptPersPapelEx__c;
        temp.msf_NoOtrasCampanasCaptPersEmailEx__c = c.msf_NoOtrasCampanasCaptPersEmailEx__c;
        temp.msf_NoOtrasCampanasCaptMasivaTelefonoEx__c = c.msf_NoOtrasCampanasCaptMasivaTelefonoEx__c;
        temp.msf_NoOtrasCampanasCaptMasivaSMSEx__c = c.msf_NoOtrasCampanasCaptMasivaSMSEx__c;
        temp.msf_NoOtrasCampanasCaptMasivaPapelEx__c = c.msf_NoOtrasCampanasCaptMasivaPapelEx__c;
        temp.msf_NoOtrasCampanasCaptMasivaEmailEx__c = c.msf_NoOtrasCampanasCaptMasivaEmailEx__c;
        temp.msf_NoNavidadPersonalizadaTelefonoEx__c = c.msf_NoNavidadPersonalizadaTelefonoEx__c;
        temp.msf_NoNavidadPersonalizadaPapelEx__c = c.msf_NoNavidadPersonalizadaPapelEx__c;
        temp.msf_NoNavidadPersonalizadaEmailEx__c = c.msf_NoNavidadPersonalizadaEmailEx__c;
        temp.msf_NoMemoriasPapelEx__c = c.msf_NoMemoriasPapelEx__c;
        temp.msf_NoMemoriasEmailEx__c = c.msf_NoMemoriasEmailEx__c;
        temp.msf_NoMailingUpgradeTelefonoEx__c = c.msf_NoMailingUpgradeTelefonoEx__c;
        temp.msf_NoMailingUpgradeSMSEx__c = c.msf_NoMailingUpgradeSMSEx__c;
        temp.msf_NoMailingUpgradePapelEx__c = c.msf_NoMailingUpgradePapelEx__c;
        temp.msf_NoMailingUpgradeEmailEx__c = c.msf_NoMailingUpgradeEmailEx__c;
        temp.msf_NoJunioTelefonoEx__c = c.msf_NoJunioTelefonoEx__c;
        temp.msf_NoJunioPapelEx__c = c.msf_NoJunioPapelEx__c;
        temp.msf_NoJunioEmailEx__c = c.msf_NoJunioEmailEx__c;
        temp.msf_NoInvitacionesEventosTelefonolEx__c = c.msf_NoInvitacionesEventosTelefonolEx__c;
        temp.msf_NoInvitacionesEventosSMSEx__c = c.msf_NoInvitacionesEventosSMSEx__c;
        temp.msf_NoInvitacionesEventosPapelEx__c = c.msf_NoInvitacionesEventosPapelEx__c;
        temp.msf_NoInvitacionesEventosEmailEx__c = c.msf_NoInvitacionesEventosEmailEx__c;
        temp.msf_NoInformeEmpresasTelefonoEx__c = c.msf_NoInformeEmpresasTelefonoEx__c;
        temp.msf_NoInformeEmpresasSMSEx__c = c.msf_NoInformeEmpresasSMSEx__c;
        temp.msf_NoInformeEmpresasPapelEx__c = c.msf_NoInformeEmpresasPapelEx__c;
        temp.msf_NoInformeEmpresasEmailEx__c = c.msf_NoInformeEmpresasEmailEx__c;
        temp.msf_NoFiscalTelefonoEx__c = c.msf_NoFiscalTelefonoEx__c;
        temp.msf_NoFiscalPapelEx__c = c.msf_NoFiscalPapelEx__c;
        temp.msf_NoFiscalEmailEx__c = c.msf_NoFiscalEmailEx__c;
        temp.msf_NoEncuestasTelefonoEx__c = c.msf_NoEncuestasTelefonoEx__c;
        temp.msf_NoEncuestasPapelEx__c = c.msf_NoEncuestasPapelEx__c;
        temp.msf_NoEncuestasEmailEx__c = c.msf_NoEncuestasEmailEx__c;
        temp.msf_NoDiciembreTelefonoEx__c = c.msf_NoDiciembreTelefonoEx__c;
        temp.msf_NoDiciembrePapelEx__c = c.msf_NoDiciembrePapelEx__c;
        temp.msf_NoDiciembreEmailEx__c = c.msf_NoDiciembreEmailEx__c;
        temp.msf_NoAgradecimientosDonativosTelefonoEx__c = c.msf_NoAgradecimientosDonativosTelefonoEx__c;
        temp.msf_NoAgradecimientosDonativosSMSEx__c = c.msf_NoAgradecimientosDonativosSMSEx__c;
        temp.msf_NoAgradecimientosDonativosPapelEx__c = c.msf_NoAgradecimientosDonativosPapelEx__c;
        temp.msf_NoAgradecimientosDonativosEmailEx__c = c.msf_NoAgradecimientosDonativosEmailEx__c;
        
        //Excoms section info
        temp.msf_DescripcionExclusionComunicaciones__c = c.msf_DescripcionExclusionComunicaciones__c;
        temp.msf_FechaExclusionComunicaciones__c = c.msf_FechaExclusionComunicaciones__c;       

        temp.msf_ConfirmedLanguage__c = c.msf_ConfirmedLanguage__c;//#26172 - 10/05/2021 Propagar tambien el check de idioma confirmado
        
        temp.msf_OrgPrimaryContactUpdated__c = true;
        
        return temp;   
    }    
    
    
    private static Map<String, String> getFieldsMap() {
        //Field, FieldDesc
    	Map <String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('msf_ShippingEntity', '');
        fieldsMap.put('msf_ShippingName', '');
        fieldsMap.put('msf_ShippingSurname1', '');
        fieldsMap.put('msf_ShippingSurname2', '');
        fieldsMap.put('msf_Nickname', '');
        fieldsMap.put('msf_TrustedName', '');
        fieldsMap.put('msf_LanguagePreferer', '');
        fieldsMap.put('HomePhone', 'msf_DescHomePhone');
        fieldsMap.put('MobilePhone', 'msf_DescMobilePhone');
        fieldsMap.put('OtherPhone', 'msf_DescOtherPhone');
        fieldsMap.put('msf_MobilePhone2', 'msf_DescMobilePhone2');
        fieldsMap.put('msf_RestrictedPhone', 'msf_DescRestrictedPhone');
        fieldsMap.put('msf_RestrictedMobilePhone', 'msf_DescMobileRestrictedMobile');
        fieldsMap.put('msf_NoEspPhone', 'msf_DescNoEspPhone');
        fieldsMap.put('msf_NoEspMobilePhone', 'msf_DescNoEspMobilePhone');
        fieldsMap.put('msf_MainEmail', 'msf_DescMainEmail');
        fieldsMap.put('npe01__HomeEmail', 'msf_DescHomeEmail');
        fieldsMap.put('npe01__AlternateEmail', 'msf_DescAlternateEmail');
        fieldsMap.put('msf_RestrictedEmail', 'msf_DescRestrictedEmail');
        fieldsMap.put('MailingCountry', '');
        fieldsMap.put('MailingState', '');
        fieldsMap.put('MailingCity', '');
        fieldsMap.put('MailingPostalCode', '');
        fieldsMap.put('MailingStreet', '');
        fieldsMap.put('OtherCountry', '');
        fieldsMap.put('OtherState', '');
        fieldsMap.put('OtherCity', '');
        fieldsMap.put('OtherPostalCode', '');
        fieldsMap.put('OtherStreet', '');
        fieldsMap.put('msf_DateReturnedMail1', '');
        fieldsMap.put('msf_DateReturnedMail2', '');
        fieldsMap.put('msf_DateReturnedMail3', ''); 
        
        return fieldsMap; 
    }
    
}