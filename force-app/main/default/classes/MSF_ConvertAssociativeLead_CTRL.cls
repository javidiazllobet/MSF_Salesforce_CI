/**
* @author       Deloitte
* @date         12-2018
* @group        Lead/Associative.
* @description  Controller for the lightning component MSF_ConvertAssociativeLead
*/
public without sharing class MSF_ConvertAssociativeLead_CTRL {
    
    private static final Integer CANTIDAD_CUOTA = 10;
    
    @AuraEnabled
    public static Object getLeadInformation(ID leadId){
        
        Map<String,Object> outputMap = new Map<String,Object>();        
        List<Contact> lDuplicateContacts = new List<Contact>(); 
        
        Lead currentLead = getAllLeadInformation(leadId);
        
        lDuplicateContacts = [SELECT Id, Name, msf_NIF__c, msf_Phone__c, msf_MainEmail__c, MailingAddress,
                              msf_MemberType__c, msf_IsActiveRecurringDonor__c, 
                              (SELECT Id FROM Asociativos__r)
                              FROM Contact 
                              WHERE RecordType.DeveloperName = 'Individual_Contact'
                              AND ((msf_NIF__c =: currentLead.msf_NIF__c AND msf_NIF__c != null) 
                                   OR (msf_MainEmail__c =: currentLead.Email AND msf_MainEmail__c != null))
                             ];
        
        outputMap.put('lead',currentLead);
        outputMap.put('contacts',lDuplicateContacts);        
        
        return outputMap;        
    }
    
    @AuraEnabled
    public static Object setNewAssociativePerson(ID leadId){
        
        Map<String,Object> outputMap = new Map<String,Object>();
        outputMap.put('title','Conversión correcta');
        outputMap.put('msg','Se ha creado el contacto asociado.');
        outputMap.put('type','success');
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            Lead leadToConvert = getAllLeadInformation(leadId);																//Get lead information         
            ID contactId = setNewContact(leadToConvert, null);																//Create the new contact
            ID associativeId = setNewAssociativeInformation(leadToConvert, contactId); 										//Create the associative information
            moveFiles(leadToConvert, associativeId);																		//Move the possible attachments to the new associative record.
            setNewEndorsingInformation(leadToConvert, contactId);															//Create endorsement records
            setCampaignMembers(leadToConvert, contactId);																	//Move AGs Assistance to contact
            if(!leadToConvert.msf_ExemptOfPayment__c && leadToConvert.msf_PaymentMethod__c == 'Domiciliación bancaria'){
                ID paymentProfileId = setNewPaymentProfile(leadToConvert, contactId); 										//Create the payment profile
                setNewAssociativeQuota(leadToConvert, contactId, paymentProfileId); 										//Create the associative quota
            }
            List<Lead> lSMSLeads = setSMSDonations(leadToConvert, contactId); 												//Search SMS matching leads  
            deleteLeads(leadToConvert, lSMSLeads);																			//Delete the associative lead and the possible SMS matching leads 
            
            outputMap.put('goToSobject',contactId);
        }catch(Exception ex){
            System.debug('Se ha producido un error al crear el nuevo asociado: '+ex.getLineNumber()+' /// '+ex.getCause()+' /// '+ex.getTypeName()+' /// '+ex.getMessage()+' /// '+ex.getStackTraceString());
            Database.rollback(sp);
            outputMap.put('title','Se ha producido un error.');
            outputMap.put('msg',ex.getMessage());
            outputMap.put('type','error');
            outputMap.put('goToSobject',leadId);            
        }
        
        return outputMap; 
    }
    
    @AuraEnabled
    public static Object setMemberAsAssociativePerson(ID leadId, ID selectedContactId){
        Map<String,Object> outputMap = new Map<String,Object>();
        outputMap.put('title','Conversión correcta');
        outputMap.put('msg','Se ha convertido el contacto a asociado.');
        outputMap.put('type','success');
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            Lead leadToConvert = getAllLeadInformation(leadId);																//Get lead information         
            ID contactId = mergeContact(leadToConvert, selectedContactId);													//Merge the lead and contact
            ID associativeId = setNewAssociativeInformation(leadToConvert, contactId); 										//Create the associative information
            moveFiles(leadToConvert, associativeId);																		//Move the possible attachments to the new associative record.
            setNewEndorsingInformation(leadToConvert, contactId);															//Create endorsement records
            setCampaignMembers(leadToConvert, contactId);																	//Move AGs Assistance to contact
            if(!leadToConvert.msf_ExemptOfPayment__c && leadToConvert.msf_PaymentMethod__c == 'Domiciliación bancaria'){
                ID paymentProfileId = checkExistPaymentProfile(leadToConvert, contactId); 									//Create the payment profile
                setNewAssociativeQuota(leadToConvert, contactId, paymentProfileId); 										//Create the associative quota
            }
            List<Lead> lSMSLeads = setSMSDonations(leadToConvert, contactId); 												//Search SMS matching leads  
            deleteLeads(leadToConvert, lSMSLeads);																			//Delete the associative lead and the possible SMS matching leads 
            
            outputMap.put('goToSobject',contactId);
        }catch(Exception ex){
            System.debug('Se ha producido un error al convertir el contacto en asociado: '+ex.getLineNumber()+' /// '+ex.getCause()+' /// '+ex.getTypeName()+' /// '+ex.getMessage()+' /// '+ex.getStackTraceString());
            Database.rollback(sp);
            outputMap.put('title','Se ha producido un error.');
            outputMap.put('msg',ex.getMessage());
            outputMap.put('type','error');
            outputMap.put('goToSobject',leadId);            
        }
        
        return outputMap;    
    }
    
    
    // PRIVATE METHODS
    
    private static Lead getAllLeadInformation(ID leadId){
        Lead leadInfo = new Lead();
        
        leadInfo = [SELECT Id, msf_Status__c, Name, CreatedDate, LeadSource, msf_EntryCampaign__c,
                    FirstName, LastName, Suffix, msf_NIF__c, msf_Gender__c, msf_Birthdate__c,  msf_isSanitary__c, msf_Passport__c,					// Personal information
                    msf_LanguagePreferer__c, Email, msf_OtherEmail__c, Phone, MobilePhone, msf_AssociativePhone__c, 								// Contact information
                    Country, State, PostalCode, City, Street, 																						// Contact information
                    msf_ExemptOfPayment__c, msf_PaymentMethod__c,																					// Payment information
                    msf_IBANCode__c, msf_IBANEntity__c, msf_IBANOffice__c, msf_IBANDC__c, msf_IBANAccountNumber__c,									// Bank information
                    msf_RecDona_npe03_Next_Payment_Date__c, msf_Opp_npe03_Amount__c,																// Payment information
                    msf_EndorsedByOne__c, msf_EndorsedByTwo__c,																						// Endorsed by
                    msf_receiveEmailCommunications__c,																								// Associative communication permissions
                    msf_AcceptStatutes__c, msf_AcceptDataProtectionPolicy__c, msf_NoCriminalRecord__c,  											// Different confirmations checks
					msf_StaffType__c,																												// MSF experience             
                    GW_Volunteers__Volunteer_Skills__c,
                    msf_MoreInfo__c
                    FROM Lead 
                    WHERE Id =: leadId 
                    LIMIT 1];
        
        return leadInfo;
    }
    
    private static ID setNewContact(Lead ld, ID ContactId){        
        Map<String,Schema.RecordTypeInfo> mRtInfo = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();        
        ID returnContactId = ContactId;
        
        Contact newAssociativeContact = new Contact(
            RecordTypeId = mRtInfo.get('Individual_Contact').getRecordTypeId(),
            msf_IsAssosiative__c = true,
            FirstName = ld.FirstName,
            LastName = ld.LastName,
            Suffix = ld.Suffix,
            msf_NIF__c = ld.msf_NIF__c,
            MobilePhone = ld.MobilePhone,           
            Phone = ld.Phone,
            msf_MainEmail__c = ld.Email,            
            MailingCountry = ld.Country,
            MailingState = ld.State,
            MailingPostalCode = ld.PostalCode,
            MailingCity = ld.City,
            MailingStreet = ld.Street,            
            Gender__c = ld.msf_Gender__c,
            Birthdate = ld.msf_Birthdate__c,
            GW_Volunteers__Volunteer_Skills__c = ld.GW_Volunteers__Volunteer_Skills__c,
            msf_BeginDateMSF__c = ld.CreatedDate.date(),
            LeadSource = ld.LeadSource,
            msf_EntryCampaign__c = ld.msf_EntryCampaign__c
            // ##### ADD ALL FIELDS TO NEED MAPPING ##### //
        );           
        insert newAssociativeContact;
        
        return newAssociativeContact.Id;
    }
    
    private static ID mergeContact(Lead ld, ID ContactId){
        Contact c = [SELECT Id, FirstName, LastName, Suffix, msf_NIF__c, Gender__c, Birthdate, GW_Volunteers__Volunteer_Skills__c,
                     MobilePhone, Phone, msf_MainEmail__c, MailingCountry, MailingState, MailingPostalCode, MailingCity, MailingStreet, 
                     msf_EntryCampaign__c
                     // ##### ADD ALL FIELDS TO NEED MAPPING ##### //
                     FROM Contact 
                     WHERE Id =: ContactId
                     LIMIT 1];         
        
        c.msf_IsAssosiative__c = true;
        c.FirstName = c.FirstName == null ? ld.FirstName : c.FirstName;
        c.LastName = c.LastName == null ? ld.LastName : c.LastName;
        c.Suffix = c.Suffix == null ? ld.Suffix : c.Suffix;
        c.msf_NIF__c = c.msf_NIF__c == null ? ld.msf_NIF__c : c.msf_NIF__c;        
        c.MobilePhone = c.MobilePhone == null ? ld.MobilePhone : c.MobilePhone;
        c.Phone = c.Phone == null ? ld.Phone : c.Phone;
        c.msf_MainEmail__c = c.msf_MainEmail__c == null ? ld.Email : c.msf_MainEmail__c;
        c.MailingCountry = c.MailingCountry == null ? ld.Country : c.MailingCountry;
        c.MailingState = c.MailingState == null ? ld.State : c.MailingState;
        c.MailingPostalCode = c.MailingPostalCode == null ? ld.PostalCode : c.MailingPostalCode;
        c.MailingCity = c.MailingCity == null ? ld.City : c.MailingCity;
        c.MailingStreet = c.MailingStreet == null ? ld.Street : c.MailingStreet;        
        c.Gender__c = c.Gender__c == null ? ld.msf_Gender__c : c.Gender__c;
        c.Birthdate = c.Birthdate == null ? ld.msf_Birthdate__c : c.Birthdate;
        c.GW_Volunteers__Volunteer_Skills__c = c.GW_Volunteers__Volunteer_Skills__c == null ? ld.GW_Volunteers__Volunteer_Skills__c : c.GW_Volunteers__Volunteer_Skills__c;
		c.msf_EntryCampaign__c = c.msf_EntryCampaign__c == null ? ld.msf_EntryCampaign__c : c.msf_EntryCampaign__c;  
        // ##### ADD ALL FIELDS TO NEED MAPPING ##### //
        
        update c;
        
        return c.Id;
    }
    
    private static ID setNewAssociativeInformation(Lead ld, Id contactId){        
        msf_Associative__c newAssociativeDetail = new msf_Associative__c(
            msf_ContactId__c = contactId,
            //Name = will be autonumeric,
            msf_StartDateAssociative__c = date.today(),
            msf_receiveEmailCommunications__c = ld.msf_receiveEmailCommunications__c,
            msf_AssociativePhone__c = ld.msf_AssociativePhone__c,
            msf_FirstAssociativeEmail__c = ld.Email,
            msf_SecondAssociativeEmail__c = ld.msf_OtherEmail__c,
            msf_LanguagePreferer__c = ld.msf_LanguagePreferer__c,
            msf_IsSanitaryManual__c = ld.msf_isSanitary__c,
            msf_ExemptOfPayment__c = ld.msf_ExemptOfPayment__c,
            msf_Passport__c = ld.msf_Passport__c,
            msf_AcceptStatutes__c = ld.msf_AcceptStatutes__c,
            msf_AcceptDataProtectionPolicy__c = ld.msf_AcceptDataProtectionPolicy__c,
            msf_NoCriminalRecord__c = ld.msf_NoCriminalRecord__c,
            msf_StaffType__c = ld.msf_StaffType__c,
            msf_PaymentMethod__c = ld.msf_PaymentMethod__c,
            msf_MoreInfo__c = ld.msf_MoreInfo__c
            // ##### ADD ALL FIELDS TO NEED MAPPING ##### //
        );        
        insert newAssociativeDetail;       
        
        return newAssociativeDetail.Id;
    }
    
    private static void moveFiles (Lead ld, ID associativeId){
        List<ContentDocumentLink> lCDL = new List<ContentDocumentLink>();  
        
        for(ContentDocumentLink cdl : [SELECT LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId =: ld.Id]){
            ContentDocumentLink tempCDL = new ContentDocumentLink(); 
            tempCDL.LinkedEntityId = associativeId;
            tempCDL.ContentDocumentId = cdl.ContentDocumentId;
            tempCDL.ShareType = cdl.ShareType;
            lCDL.add(tempCDL);    
        }         
        insert lCDL;
    }  
    
    private static void setNewEndorsingInformation(Lead ld, Id contactId){        
        List<msf_Endorsement__c> lEndorsements = new List<msf_Endorsement__c>();
        
        msf_Endorsement__c firstEndorse = new msf_Endorsement__c();
        msf_Endorsement__c secondEndorse = new msf_Endorsement__c();
        
        if(ld.msf_EndorsedByOne__c != null){
            firstEndorse.msf_isEndorsing__c = ld.msf_EndorsedByOne__c;
            firstEndorse.msf_IsEndorsed__c = contactId;
            lEndorsements.add(firstEndorse);
        }
        
        if(ld.msf_EndorsedByTwo__c != null){
            secondEndorse.msf_isEndorsing__c = ld.msf_EndorsedByTwo__c;
            secondEndorse.msf_IsEndorsed__c = contactId; 
            lEndorsements.add(secondEndorse);  
        }  
        
        insert lEndorsements;
    }  
    
    private static void setCampaignMembers(Lead ld, Id contactId){        
        List<CampaignMember> lCMToDelete = new List<CampaignMember>();
        List<CampaignMember> lCMToInsert = new List<CampaignMember>();
        
        for(CampaignMember cm : [SELECT Id, CampaignId, Description, LeadSource, Status, Type,                                 
                                 Salutation, Title, Name, FirstName, LastName, 
                                 City, Country, State, Street, PostalCode, Email, Fax, MobilePhone, Phone, 
                                 FirstRespondedDate,  HasResponded,                                                               
                                 CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp, 
                                 msf_CRMExternalId__c, msf_Segment__c
                                 // ##### ALL FIELDS TO CLONED (THINKING IN ALL THE DATA THAT WANT TO KEEP IN CAMPAIGN MEMBER ) ##### //
                                 FROM CampaignMember WHERE LeadId =: ld.Id])
        { 
            CampaignMember tempCM = cm.clone(false, true, true, true);			
            tempCM.ContactId = contactId;            
            
            lCMToInsert.add(tempCM);            
            lCMToDelete.add(cm);
        }
        
        delete lCMToDelete;
        insert lCMToInsert;        
    }
    
    private static ID setNewPaymentProfile(Lead ld, Id contactId){        
        Map<String,Schema.RecordTypeInfo> mRtInfo = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName(); 
        cpm__Payment_Profile__c newPaymentProfile = new cpm__Payment_Profile__c(
            cpm__Contact__c = contactId,
            recordtypeId = mRtInfo.get('IBAN').getRecordTypeId(),
            cpm__IBAN__c = (ld.msf_IBANCode__c + ld.msf_IBANEntity__c + ld.msf_IBANOffice__c + ld.msf_IBANDC__c + ld.msf_IBANAccountNumber__c),
            msf_HolderFirstName__c = ld.FirstName,
            msf_HolderLastName1__c = ld.LastName,
            msf_HolderLastName2__c = ld.Suffix,
            msf_NIF__c = ld.msf_NIF__c,
            cpm__Holder_Name__c = ld.FirstName + ' ' + ld.LastName + ' ' + ld.Suffix,
            cpm__Active__c = true
        );        
        insert newPaymentProfile;  
        
        return newPaymentProfile.Id;
    }
    
    private static ID checkExistPaymentProfile(Lead ld, Id contactId){        
        ID ppId;        
        String sIBAN = ld.msf_IBANCode__c + ld.msf_IBANEntity__c + ld.msf_IBANOffice__c + ld.msf_IBANDC__c + ld.msf_IBANAccountNumber__c;
        
        List<cpm__Payment_Profile__c> lPaymentList = [SELECT Id 
                                                      FROM cpm__Payment_Profile__c
                                                      WHERE cpm__Contact__c =: contactId 
                                                      AND cpm__IBAN__c =: sIBAN 
                                                      AND msf_NIF__c =: ld.msf_NIF__c
                                                      AND cpm__Active__c = true
                                                     ];
        if(lPaymentList.isEmpty()){
            ppId = setNewPaymentProfile(ld, contactId); 
        }else{
            ppId = lPaymentList[0].Id;    
        }
        
        return ppId;
    }
    
    private static void setNewAssociativeQuota(Lead ld, Id contactId, Id ppId){        
        Map<String,Schema.RecordTypeInfo> mRtInfo = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName(); 
        npe03__Recurring_Donation__c newAssociativeDetail = new npe03__Recurring_Donation__c(
            RecordTypeId = mRtInfo.get('Associate').getRecordTypeId(),
            Name = 'Cuota',
            npe03__Contact__c = contactId,
            npe03__Amount__c = CANTIDAD_CUOTA,
            npe03__Open_Ended_Status__c = 'Open',
            npe03__Date_Established__c = ld.msf_RecDona_npe03_Next_Payment_Date__c != null ? ld.msf_RecDona_npe03_Next_Payment_Date__c : date.today(),
            npe03__Installment_Period__c = 'Yearly',
            npe03__Installments__c = 0,
            npsp4hub__Payment_Profile__c = ppId,  
            npsp4hub__Payment_Method__c = Test.isRunningTest() ? 'ideal' : 'Direct Debit',
            npsp4hub__Payment_Processor__c = Test.isRunningTest() ? 'DummyExtension-PSP' : 'PaymentHub-SEPA',
            npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA',  
            npe03__Recurring_Donation_Campaign__c = ld.msf_EntryCampaign__c
            
        );

        insert newAssociativeDetail;        
    }
    
    private static List<Lead> setSMSDonations(Lead ld, Id contactId){        
        Id RTDonationId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        Contact cInfo = [SELECT AccountId FROM Contact WHERE Id =: contactId LIMIT 1];
        
        List<Lead> lSMSLead = new List<Lead>();
        List<Opportunity> lSMSDonations = new List<Opportunity>();
        
        for(Lead l : [SELECT Id,
                      (SELECT Id FROM Oportunidades__r)
                      FROM Lead 
                      WHERE RecordType.DeveloperName = 'Individual' AND LeadSource = 'SMS' 
                      AND MobilePhone =: ld.MobilePhone 
                      AND MobilePhone != null
                     ])
        {
            lSMSLead.add(l);            
            if(!l.Oportunidades__r.isEmpty()){
                lSMSDonations.addAll(l.Oportunidades__r);     
            }			           
        }
        
        for(Opportunity o : lSMSDonations){
            o.msf_LeadId__c = null;
            o.AccountId = cInfo.AccountId;
            o.npsp__Primary_Contact__c = contactId;
        }        
        
        update lSMSDonations; 
        
        return lSMSLead;
    }
    
    private static void deleteLeads (Lead associativeLeadToDelete, List<Lead> lSMSLeadToDelete){        
        List<Lead> lLeadsToDelete = new List<Lead>(); 
        
        lLeadsToDelete.add(associativeLeadToDelete);	//Associative lead
        lLeadsToDelete.addAll(lSMSLeadToDelete);		//SMS matching leads
        
        delete lLeadsToDelete;
    }
    
}