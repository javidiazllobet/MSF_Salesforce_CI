/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Contact
* @description	Trigger Handler that create GDPR logs
*/

global without sharing class MSF_ContactGDPRLog_TDTM extends npsp.TDTM_Runnable{

    /*******************************************************************************************************
    * @description	Trigger Handler on Contact that manage the changes that must be registered by the GDPR rules.
    * @param 		listNew the list of Contact from trigger new. 
    * @param 		listOld the list of Contact from trigger old. 
    * @param 		triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param 		objResult the describe for Contact.
    * @return 		dmlWraconer. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
    	
        //Attributes
        List<Contact> lNewCon = (List<Contact>) newlist;      
		List<Contact> lOldCon = (List<Contact>) oldlist;
        Map<Id, Contact> mOldCon = new Map<Id, Contact>();
        if(lOldCon != null){            
            mOldCon.putAll(lOldCon);
        }    
        
        MSF_SharedMethods_UTIL sm = new MSF_SharedMethods_UTIL();
   		
        List<msf_GDPRLog__c> lLogsToInsert = new List<msf_GDPRLog__c>();
        
        Map<String,Schema.sObjectField> mObjectFields = Contact.sObjectType.getDescribe().fields.getMap();
        
        Set<String> sfields = new Set<String>{
            
            // ### General information ###
            'FirstName','LastName','Suffix','msf_NIF__c',
            'msf_FiscalFirstName__c','msf_FiscalLastName1__c','msf_FiscalLastName2__c','msf_fiscalNif__c',  
            'msf_ShippingName__c','msf_ShippingSurname1__c','msf_ShippingSurname2__c','msf_ShippingEntity__c',
            'msf_Nickname__c','msf_TrustedName__c',
            
            // ### Phones ### 
            'HomePhone','MobilePhone','OtherPhone','msf_MobilePhone2__c','msf_RestrictedMobilePhone__c','msf_RestrictedPhone__c',           
                
            // ### Phones Descriptions ### 
            'msf_DescHomePhone__c', 'msf_DescMobilePhone__c','msf_DescMobilePhone2__c','msf_DescMobileRestrictedMobile__c',
            'msf_DescNoEspMobilePhone__c','msf_DescNoEspPhone__c','msf_DescOtherPhone__c','msf_DescRestrictedPhone__c',            
             
            // ### Phones Backup ### 
            'msf_HomePhoneBackup__c','msf_MobilePhoneBackup__c','msf_MobilePhone2Backup__c','msf_RestrictedMobilePhoneBackup__c','msf_RestrictedPhoneBackup__c',
                
            // ### Phones Backup Description ### 
            'msf_DescHomePhoneBackup__c','msf_DescMobilePhoneBackup__c','msf_DescMobilePhone2Backup__c','msf_DescMobileRestrictedMobileBackup__c',
            'msf_DescNoEspMobilePhoneBackup__c','msf_DescNoEspPhoneBackup__c','msf_DescOtherPhoneBackup__c','msf_DescRestrictedPhoneBackup__c',
            
			// ### Email ### 
			'Email','msf_MainEmail__c','msf_RestrictedEmail__c','npe01__AlternateEmail__c','npe01__HomeEmail__c',
            'msf_DescAlternateEmail__c','msf_DescHomeEmail__c','msf_DescMainEmail__c','msf_DescRestrictedEmail__c',
            
            // ### Email Backup ### 
            'msf_AlternateEmailBackup__c','msf_HomeEmailBackup__c','msf_MainEmailBackup__c','msf_RestrictedEmailBackup__c',
            'msf_DescAlternateEmailBackup__c','msf_DescHomeEmailBackup__c','msf_DescMainEmailBackup__c','msf_DescRestrictedEmailBackup__c',
                
            // ### Addresses ### 
            'MailingCity','MailingCountry','MailingPostalCode','MailingState','MailingStreet',                
            'OtherCity','OtherCountry', 'OtherPostalCode','OtherState','OtherStreet',   
            
            // ### Addresses backup ### 
            'msf_MailingCityBackup__c','msf_MailingCountryBackup__c','msf_MailingPostalCodeBackup__c', 'msf_MailingStateBackup__c','msf_MailingStreetBackup__c',
            'msf_OtherCityBackup__c','msf_OtherCountryBackup__c','msf_OtherPostalCodeBackup__c','msf_OtherStateBackup__c', 'msf_OtherStreetBackup__c',  
                
            // ### Percoms ###             
            'msf_NoAgradecimientosCP__c','msf_NoAgradecimientosEmail__c','msf_NoAgradecimientosMi__c','msf_NoAgradecimientosSms__c','msf_NoAgradecimientosTelefono__c',
            'msf_NoCaptacionFondos__c','msf_NoCaptacionFondosCP__c','msf_NoCaptacionFondosEmail__c','msf_NoCaptacionFondosMi__c','msf_NoCaptacionFondosSms__c','msf_NoCartasPlanRelacionCP__c',
            'msf_NoCertificadoFiscalCP__c','msf_NoCertificadoFiscalEmail__c','msf_NoCertificadoFiscalMi__c','msf_NoCertificadoFiscalSms__c','msf_NoCesionImagenPromocion__c','msf_NoComunicacionesOnetoOneCP__c',
            'msf_NoComunicacionesOnetoOneEmail__c','msf_NoComunicacionesOnetoOneTelefono__c','msf_NoComunicaconesOnetoOneMi__c','msf_NoComunicaconesOnetoOneSms__c','msf_NoCorreoPostal__c','msf_NoEmail__c',
            'msf_NoEmailingsTematicosEmail__c','msf_NoEncuestaEstudioConcursoEmail__c','msf_NoEncuestaEstudioConcursoMi__c','msf_NoEncuestaEstudioConcursoSms__c','msf_NoEncuestaEstudioConcursoTelefono__c',
            'msf_NoEspMobilePhone__c','msf_NoEspMobilePhoneBackup__c','msf_NoEspPhone__c','msf_NoEspPhoneBackup__c','msf_NoInformacionTestamentaria__c','msf_NoInvitacionesEventosCP__c',
            'msf_NoInvitacionesEventosEmail__c','msf_NoInvitacionesEventosMi__c','msf_NoInvitacionesEventosSms__c','msf_NoInvitacionesEventosTelefono__c','msf_NoLlamadasBienvenidasEncuestasOtras__c',
            'msf_NoMailingsTematicosCP__c','msf_NoMemoriaCP__c','msf_NoMemoriaEmail__c','msf_NoMemoriaMi__c','msf_NoMemoriaSms__c','msf_NoMensajesPlanRelacionMi__c','msf_NoMensajesPlanRelacionSms__c',
            'msf_NoMensajesTematicosMi__c','msf_NoMensajesTematicosSms__c','msf_NoMi__c','msf_NoNewsletOrAgradeOrPRelaEmail__c','msf_NoNewsletterEmail__c','msf_NoPlanRelacionEmail__c',
            'msf_NoPlanRelacionTelefono__c','msf_NoRecibirNada__c','msf_NoRevistaCP__c','msf_NoRevistaEmail__c','msf_NoRevistaMi__c','msf_NoRevistaSms__c','msf_NoSMS__c','msf_NoTelefono__c',
            'msf_NoTelemarketingCaptacionFondos__c','msf_SoloCertificadoFiscal__c'
        };

            
        //Actions
                        
        /*** BEFORE INSERT & BEFORE UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {	
            for(Contact con : lNewCon){            	 
                if(con.msf_ModificationChannel__c != null){
                    con.msf_LastModificationChannel__c = con.msf_ModificationChannel__c;
                    con.msf_ModificationChannel__c = null;
                }
            }   
        }    
        
        /*** AFTER INSERT ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {	
            for(Contact con : lNewCon){            	 
            	msf_GDPRLog__c l = sm.createLog(con, null, UserInfo.getUserId(), con.Id, null, true, false, sfields, mObjectFields);  
                if (l != null){
                	lLogsToInsert.add(l);     
                }
            }   
        }
        /*** AFTER UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {	
        	for(Contact con : lNewCon){
            	msf_GDPRLog__c l = sm.createLog(con, mOldCon.get(con.Id), UserInfo.getUserId(), con.Id, null, false, false, sfields, mObjectFields);  
                if (l != null){
                	lLogsToInsert.add(l);     
                }
            } 	   
        } 
        /*** AFTER DELETE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete) {	
        	for(Contact con : lOldCon){
            	msf_GDPRLog__c l = sm.createLog(con, null, UserInfo.getUserId(), con.Id, null, false, true, null, null);  
                if (l != null){
                	lLogsToInsert.add(l);     
                }
            } 
        }
        
        /*** DML OPERATIONS ***/
        if(lLogsToInsert.isEmpty()){
            return null;
        }
        
        npsp.TDTM_Runnable.DmlWrapper DmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        DmlWrapper.objectsToInsert.addAll((List<msf_GDPRLog__c>) lLogsToInsert);        
        
        return DmlWrapper; 
    } 

}