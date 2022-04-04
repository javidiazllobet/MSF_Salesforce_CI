public without sharing class MSF_FormF2F_CTRL {
    
    //***** GET INFO METHODS *****
    
    @AuraEnabled
    public static Integer getNumConvertation(Integer numConversationActual, Boolean addConversation){
        
        try{
            List<msf_Conversation__c> info = [SELECT msf_NumConversation__c 
                                              FROM msf_Conversation__c 
                                              WHERE msf_IdCanvasser__c =: UserInfo.getUserId() AND msf_DayWorked__c = TODAY LIMIT 1];
            
            if(info.isEmpty()){
                msf_Conversation__c nwInfoCanvasser = new msf_Conversation__c();
                nwInfoCanvasser.msf_IdCanvasser__c = UserInfo.getUserId();
                nwInfoCanvasser.msf_NumConversation__c = addConversation ? 1 : 0; 
                nwInfoCanvasser.msf_DayWorked__c = Date.today();
                Insert nwInfoCanvasser;
                return addConversation ? 1 : 0; 
            }else{
                Integer numConversation = Integer.valueOf(info[0].msf_NumConversation__c);
                if(addConversation){
                    info[0].msf_NumConversation__c = numConversation+1;
                    update info;
                }
                return Integer.valueOf(info[0].msf_NumConversation__c);
            }
        }catch(exception e){
            System.debug('An unexpected error has occurred: '+e);
            return null; 
        }
    }
    
    @AuraEnabled
    public static Object getCanvasser(){
        
        User userCan = [SELECT Id, name, msf_Place__c, msf_Campaign__c, msf_City__c FROM User WHERE id =: UserInfo.getUserId() LIMIT 1];
        return userCan;
    }
    
    @AuraEnabled
    public static Object getSocio(String docId, Boolean isOrg){        
        
        Map<String, Object> out = new Map<String, Object>();
        List<npe03__Recurring_Donation__c> rdonation = new List<npe03__Recurring_Donation__c>();
        List<SObject> socio = new List<SObject>();
        String rtDevName = isOrg ? 'Organization' : 'Individual_Contact';
        socio = [SELECT id, Name, FirstName, LastName, Suffix, msf_NIF__c, toLabel(Gender__c), 
                 msf_LanguagePreferer__c, Birthdate, msf_PrimaryContact__r.FirstName, msf_PrimaryContact__r.LastName, 
                 msf_PrimaryContact__r.Suffix, msf_PrimaryContact__r.msf_NIF__c, msf_PrimaryContact__r.msf_fiscalNif__c,
                 msf_PrimaryContact__r.Title, msf_PrimaryContact__r.MobilePhone
                 FROM Contact WHERE msf_NIF__c =: docId 
                 AND RecordType.DeveloperName =: rtDevName LIMIT 1];
        
        if(!socio.isEmpty()){
            rdonation = [SELECT id FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c =: socio[0].Id AND npe03__Open_Ended_Status__c = 'Open' AND RecordType.DeveloperName = 'Recurring_donation' LIMIT 1];
        }else{
            return null;
        }       
        
        out.put('socio', socio[0]);
        out.put('rdonation', rdonation);
        
        return out;
    }
    
    @AuraEnabled
    public static List<String>  getDate(){
        
        date myDate = date.today();
        List<String> myList = new List<String>();
        for(integer i=1;i<=13;i++){
            date firstDate = myDate.toStartOfMonth();
            firstDate = firstDate.addMonths(i);
            String x = '0'+firstDate.format();
            myList.add(x);
        }
        return myList;
    }
    
    @AuraEnabled
    public static List<String> getLanguage(){
        
        Schema.DescribeFieldResult fieldResult = Contact.msf_LanguagePreferer__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String> ();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getValue());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getGender(){
        
        Schema.DescribeFieldResult fieldResult = Contact.Gender__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String> ();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getPeriod(Boolean uniqueadd, Boolean uniqueOnly){
        
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        List<String> options = new List<String> ();
        
        if(uniqueOnly){
            options.add(System.Label.MSF_FORM_F2F_UNIQUE_DONATION);
            return options;
        }else{
            for(Schema.PicklistEntry p : pickListValues){
                options.add(p.getLabel());
            }
            if(uniqueadd){
                options.add(System.Label.MSF_FORM_F2F_UNIQUE_DONATION);
            }
            return options;
        }
    }
    
    @AuraEnabled
    public static Object getMemberInfo(Id memberId){
        
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        String labelPeriod;
        
        List<Contact> lMember = new List<Contact>();
        List<npe03__Recurring_Donation__c> lQuota = new List<npe03__Recurring_Donation__c>();        
        
        Map<String, Object> mMemberInfo = new Map<String, Object>();
        mMemberInfo.put('member',null);
        mMemberInfo.put('quota',null);
        
        if(memberId != null){
            
            lMember = [SELECT FirstName, LastName , Name
                       FROM Contact 
                       WHERE Id =: memberId];
            
            lQuota = [SELECT Id, npe03__Contact__c, npe03__Installment_Period__c, npe03__Amount__c, npe03__Last_Payment_Date__c, npe03__Next_Payment_Date__c, npe03__Date_Established__c 
                      FROM npe03__Recurring_Donation__c 
                      WHERE npe03__Contact__c =: memberId 
                      AND Recordtype.DeveloperName = 'Recurring_donation' 
                      AND npe03__Open_Ended_Status__c = 'Open' 
                      LIMIT 1];
            
            if(!lQuota.isEmpty()){
                for(Schema.PicklistEntry p : pickListValues){
                    if(p.getValue() == lQuota[0].npe03__Installment_Period__c){
                        labelPeriod = p.getLabel();
                    }
                } 
            } 
            
            mMemberInfo.put('member',lMember.isEmpty() ? null : lMember[0]);
            mMemberInfo.put('quota',lQuota.isEmpty() ? null : lQuota[0]);
            mMemberInfo.put('labelPeriod',lQuota.isEmpty() ? null : labelPeriod);
        }
        
        return mMemberInfo;
    } 
    
    //***** SET INFO METHODS *****
    
    @AuraEnabled
    public static Map<String, Object> setContact(Contact infoC, User canvasser, npe03__Recurring_Donation__c infoO, Opportunity infoOU, cpm__Payment_Profile__c infoPP, Contact infoRep, Boolean isSocio, Boolean isOrg, Decimal amount, String campaignName, Lead incompleteLead){       
        
        Savepoint sp = Database.setSavepoint();
        
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('title',System.Label.MSF_FORM_F2F_SAVE_RECORD);
        mResult.put('type','error');
        mResult.put('msg',System.Label.MSF_FORM_F2F_ERROR_HAS_OCURRED);
        try{
            Schema.DescribeFieldResult fieldResult = Contact.Gender__c.getDescribe(); 
            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
            
            RecordType rt = (isOrg) ? [SELECT id FROM recordtype WHERE developername= 'Organization' AND SobjectType = 'Contact' LIMIT 1] : [SELECT id FROM recordtype WHERE developername= 'Individual_Contact' AND SobjectType = 'Contact' LIMIT 1];
                
            infoC.RecordTypeId = rt.ID; 
            ID campaignId = getCampaignID(campaignName);
            id idContact;
            String genderValue;
            
            List<Contact> masterContact = new List<Contact>();
            List<Contact> contactRep = new List<Contact>();
                        
            RecordType rtOC = [SELECT id FROM recordtype WHERE developername= 'Organization_Contact' AND sobjectType='Contact' LIMIT 1];
            
            if(isSocio == true){                
                masterContact = [SELECT id, FirstName, LastName, Suffix, Birthdate, msf_MainEmail__c, msf_NIF__c,
                             MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingCountry,
                             HomePhone, MobilePhone, msf_LanguagePreferer__c, Gender__c, msf_Canvasser__c, msf_CityCanvasser__c, 
                             msf_FiscalFirstName__c, msf_FiscalLastName1__c, msf_FiscalLastName2__c, msf_fiscalNif__c, AccountId, msf_PrimaryContact__c
                             FROM Contact 
                             WHERE msf_NIF__c=: infoC.msf_NIF__c
                             LIMIT 1];                
                
                Boolean isBackup = (isORg && masterContact[0].msf_PrimaryContact__c != null) ? true : false;
                masterContact[0] = mergeFieldContact(masterContact[0] , infoC, isBackup);
                try{
                    update masterContact;  
                }
                catch(System.DmlException ex){
                    if(ex.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                        Database.rollback(sp);
                        mResult.put('msg',System.Label.MSF_FORM_F2F_CONTACT_ALREADY_EXISTS);
                        return mResult;
                    }
                    mResult.put('msg',ex.getDmlMessage(0));
                    return mResult;
                }
                
                idContact = masterContact[0].Id;
                  
                if(infoRep != null){
                    id idcontactRep;
                    /*contactRep = [SELECT id, FirstName, LastName, Suffix, MobilePhone, Title, msf_Organization__c, msf_IsPrimary__c, msf_FiscalFirstName__c, msf_FiscalLastName1__c, msf_FiscalLastName2__c, msf_fiscalNif__c
                                  FROM Contact 
                                  WHERE AccountId =: masterContact[0].AccountId AND 
                                  RecordType.DeveloperName = 'Organization_Contact' AND Name =: infoRep.FirstName+' '+infoRep.LastName LIMIT 1];*/
                    system.debug(infoRep);
                    if (infoRep.msf_NIF__c != null) {
                    	contactRep = [SELECT id, FirstName, LastName, Suffix, MobilePhone, Title, msf_Organization__c, msf_IsPrimary__c, msf_FiscalFirstName__c, msf_FiscalLastName1__c, msf_FiscalLastName2__c, msf_fiscalNif__c
                                      FROM Contact 
                                      WHERE AccountId =: masterContact[0].AccountId AND 
                                      RecordType.DeveloperName = 'Organization_Contact' 
                                      AND msf_NIF__c =: infoRep.msf_NIF__c LIMIT 1];
                        system.debug(contactRep);
                    }
                    if(!contactRep.isEmpty()){
                        contactRep[0] = mergeFieldContact(contactRep[0] , infoRep, false);
                        system.debug(contactRep[0]);
                        update contactRep;
                        system.debug(contactRep);
                        idcontactRep = contactRep[0].id;
                    }else{
                        infoRep.RecordTypeId=rtOC.ID;
                        infoRep.msf_BeginDateMSF__c = incompleteLead != null ? incompleteLead.createdDate.date() : Date.today();
                        infoRep.msf_Organization__c = masterContact[0].Id;
                        infoRep.msf_isPrimary__c = masterContact[0].msf_PrimaryContact__c == null ? true : false;
                        infoRep.msf_IsActive__c = true;
                        infoRep.AccountId = masterContact[0].AccountId;
                        infoRep.msf_ModificationChannel__c = 'F2F';
                        
                        insert infoRep;
                        idcontactRep = infoRep.id;
                    }
                }                
            }else{
                if(masterContact.isEmpty()){//WHEN ISN'T LEAD
                    if(infoO != null){
                        infoC.msf_FirstCampaignEntryRecurringDonor__c = campaignId != null ? campaignId : null;
                        infoC.msf_FirstEntryDateRecurringDonor__c = Date.today();
                        infoC.msf_EntryDateCurrentRecurringDonor__c = Date.today();
                    } 
                    
                    infoC.msf_BeginDateMSF__c = incompleteLead != null ? incompleteLead.createdDate.date() : Date.today();
                    for(Schema.PicklistEntry p : pickListValues){// get gender value
                        if(p.getLabel() == infoC.Gender__c){
                            genderValue = p.getValue();
                        }
                    }
                    
                    infoC.msf_EntryCampaign__c = campaignId != null ? campaignId : null;
                    infoC.Gender__c = genderValue;
                    infoC.LeadSource = 'Personal con tablet';
                    infoC.msf_ModificationChannel__c = 'F2F';
                    
                    try{
                        insert infoC;
                    }
                    catch(System.DmlException ex){
                        if(ex.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                            Database.rollback(sp);
                            mResult.put('msg',System.Label.MSF_FORM_F2F_CONTACT_ALREADY_EXISTS);
                            
                            return mResult;
                        }
                        mResult.put('msg',ex.getDmlMessage(0));
                        
                        return mResult;
                    }
                    
                    idContact = infoC.Id;
                    
                    if(isOrg && idContact != null){
                        contactRep = [SELECT AccountId FROM Contact WHERE id =: idContact];
                        if(!contactRep.isEmpty()){
                            infoRep.RecordTypeId=rtOC.ID;
                            infoRep.msf_BeginDateMSF__c = incompleteLead != null ? incompleteLead.createdDate.date() : Date.today();
                            infoRep.msf_Organization__c = idContact;
                            infoRep.AccountId = contactRep[0].AccountId;
                            infoRep.msf_isPrimary__c = true;
                            infoRep.LeadSource = 'Personal con tablet';
                            infoRep.msf_EntryCampaign__c = campaignId != null ? campaignId : null;
                            infoRep.msf_ModificationChannel__c = 'F2F';
                            insert infoRep;
                        }
                    }
                }
                else{
                    mResult.put('title',System.Label.MSF_FORM_F2F_SAVE_RECORD);
                    mResult.put('type','error');
                    mResult.put('msg',System.Label.MSF_FORM_F2F_CONTACT_ALREADY_EXISTS);
                    
                    return mResult;
                }
            }
            if(idContact != null && infoPP != null){
                Id idPP = managePaymentProfile(infoPP, idContact, isSocio);
                
                createDonation(idPP, infoO, infoOU, amount, campaignId, idContact);
                
                if(incompleteLead != null){
                    moveSignatures(incompleteLead,idContact);
                } 
                
                //Generate_PDF                
                //GeneratePDF(idContact, false);
            }   
            
            mResult.put('idContact',idContact);
            mResult.put('title',System.Label.MSF_FORM_F2F_SAVE_RECORD);
            mResult.put('type','success');
            mResult.put('msg',System.Label.MSF_FORM_F2F_DATA_SAVED_CORRECTLY);
            
            return mResult;
            
        }catch(exception e){
            System.debug('An unexpected error has occurred: '+e);
            Database.rollback(sp);
            mResult.put('msg', e.getMessage()); 
        }
        
        return mResult;
    }    
    
    @AuraEnabled
    public static boolean GeneratePDF (id idContact, boolean increaseQuota){
        Boolean updateOk = true;
        Contact conPDF = new Contact();
        conPDF.Id = idContact;
        conPDF.msf_F2FGeneratePDF__c = true;
        if(increaseQuota){
        	conPDF.msf_F2FTemplateNumber__c = 5;   
        }
        
        try{
            update conPDF;              
        }catch(Exception ex){
            updateOk = false;
        }
        
        return updateOk;         
    }
    
    @AuraEnabled
    public static Map<String, Object> setLead(Lead infoLead, Task infoTask, Decimal amount, Lead incompleteLead){
        
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('title',System.Label.MSF_FORM_F2F_SAVE_RECORD);
        mResult.put('type','error');
        mResult.put('msg',System.Label.MSF_FORM_F2F_ERROR_HAS_OCURRED);
        
        RecordType rt = [SELECT id FROM recordtype WHERE developername= 'Individual' AND SobjectType = 'Lead'  LIMIT 1];
        infoLead.RecordTypeId=rt.ID;
        
        try{            
            if(incompleteLead != null && incompleteLead.Id != null){
                infoLead.Id	= incompleteLead.Id;
                List<Task> ts = [SELECT id FROM Task WHERE WhoId =:incompleteLead.Id];
                if(!ts.isEmpty()){
                    infoTask.Id=ts[0].Id;
                    
                    upsert infoTask; 
                }
            }
            infoLead.msf_Opp_npe03_Amount__c = amount;
            infoLead.LeadSource = 'Personal con tablet';
            
            upsert infoLead;
            
            if(incompleteLead == null && infoLead.Id != null &&  infoTask != null){//cuando es un nuevo lead
                infoTask.WhoId	= infoLead.Id;
                
                insert infoTask;
            }
            
            mResult.put('idLead',infoLead.Id);
            mResult.put('title',System.Label.MSF_FORM_F2F_SAVE_RECORD);
            mResult.put('type','success');
            mResult.put('msg',System.Label.MSF_FORM_F2F_DATA_SAVED_CORRECTLY);
            
            return mResult;
        }catch(exception e){
            mResult.put('msg', e.getMessage()); 
        }
        return mResult;
    }
    
    @AuraEnabled
    public static Object createNewQuota(String campaignName, npe03__Recurring_Donation__c RD, Date quotaDate, String frequency, Decimal amount, User canvasser, Id contactId){ 
        
        Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        String period;
        ID campaignId = getCampaignID(campaignName);
        
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('title',System.Label.MSF_FORM_F2F_QUOTA_UPDATED);
        mResult.put('type','error');
        mResult.put('msg',System.Label.MSF_FORM_F2F_ERROR_HAS_OCURRED);
        
        if(RD != null){
            try{
                for(Schema.PicklistEntry p : pickListValues){
                    if(p.getLabel() == frequency){
                        period = p.getValue();
                    }
                }
                RD.msf_CurrentCampaign__c = campaignId != null ? campaignId : null;
                RD.npe03__Date_Established__c = quotaDate;
                RD.npe03__Installment_Period__c = period;
                RD.npe03__Amount__c = amount;
                RD.msf_CurrentLeadSource1__c = 'Personal con tablet';
                RD.msf_Canvasser__c = canvasser.Name != null ? canvasser.Name : null;
                RD.msf_CityCanvasser__c = canvasser.msf_City__c != null ? canvasser.msf_City__c : null;
                RD.msf_PlaceCanvasser__c = canvasser.msf_Place__c != null ? canvasser.msf_Place__c : null;
                
                Update RD;
                
                //GeneratePDF(contactId, true);
                
                mResult.put('title',System.Label.MSF_FORM_F2F_QUOTA_UPDATED);
                mResult.put('type','success');
                mResult.put('msg',System.Label.MSF_FORM_F2F_DATA_SAVED_CORRECTLY);
                
                return mResult; 
            }catch (Exception ex){
                mResult.put('msg', ex.getMessage());  
            }            
        }        
        return mResult;
    }
    
    
    //***** PRIVATE METHODS *****
    
    private static Contact mergeFieldContact(Contact value1, Contact value2, Boolean isBackup){ 
        
        if(isBackup){
            if(value2.msf_MainEmail__c != null) {
                value1.msf_MainEmailBackup__c = value1.msf_MainEmail__c != value2.msf_MainEmail__c ? value2.msf_MainEmail__c : value1.msf_MainEmail__c; 
            }
            if(value2.MailingStreet != null) {
                value1.msf_MailingStreetBackup__c = value1.MailingStreet != value2.MailingStreet ? value2.MailingStreet : value1.MailingStreet;
            }
            if(value2.MailingPostalCode != null) {
                value1.msf_MailingPostalCodeBackup__c = value1.MailingPostalCode != value2.MailingPostalCode ? value2.MailingPostalCode : value1.MailingPostalCode;
            }
            if(value2.MailingCity != null) {
                value1.msf_MailingCityBackup__c = value1.MailingCity != value2.MailingCity ? value2.MailingCity : value1.MailingCity;
            }
            if(value2.MailingState != null) {
                value1.msf_MailingStateBackup__c = value1.MailingState != value2.MailingState ? value2.MailingState : value1.MailingState;
            }
            if(value2.MailingCountry != null) {
                value1.msf_MailingCountryBackup__c = value1.MailingCountry != value2.MailingCountry ? value2.MailingCountry : value1.MailingCountry;
            }
            if(value2.HomePhone != null) {
                value1.msf_HomePhoneBackup__c = value1.HomePhone != value2.HomePhone ? value2.HomePhone : value1.HomePhone;
            }
            if(value2.msf_LanguagePreferer__c != null) {
                value1.msf_LanguagePreferer__c = value1.msf_LanguagePreferer__c != value2.msf_LanguagePreferer__c ? value2.msf_LanguagePreferer__c : value1.msf_LanguagePreferer__c;
            }
        }
        else{
            if(value2.Title != null) {
                value1.Title= value1.Title != value2.Title ? value2.Title : value1.Title;
            }
            if(value2.Suffix != null) {
                value1.Suffix= value1.Suffix != value2.Suffix ? value2.Suffix : value1.Suffix;
            }
            if(value2.Birthdate != null) {
                value1.Birthdate= value1.Birthdate != value2.Birthdate ? value2.Birthdate : value1.Birthdate;
            }
            if(value2.msf_MainEmail__c != null) {
                value1.msf_MainEmail__c = value1.msf_MainEmail__c != value2.msf_MainEmail__c ? value2.msf_MainEmail__c : value1.msf_MainEmail__c; 
            }
            if(value2.MailingStreet != null) {
                value1.MailingStreet = value1.MailingStreet != value2.MailingStreet ? value2.MailingStreet : value1.MailingStreet;
            }
            if(value2.MailingPostalCode != null) {
                value1.MailingPostalCode = value1.MailingPostalCode != value2.MailingPostalCode ? value2.MailingPostalCode : value1.MailingPostalCode;
            }
            if(value2.MailingCity != null) {
                value1.MailingCity = value1.MailingCity != value2.MailingCity ? value2.MailingCity : value1.MailingCity;
            }
            if(value2.MailingState != null) {
                value1.MailingState = value1.MailingState != value2.MailingState ? value2.MailingState : value1.MailingState;
            }
            if(value2.MailingCountry != null) {
                value1.MailingCountry = value1.MailingCountry != value2.MailingCountry ? value2.MailingCountry : value1.MailingCountry;
            }
            if(value2.HomePhone != null) {
                value1.HomePhone = value1.HomePhone != value2.HomePhone ? value2.HomePhone : value1.HomePhone;
            }
            if(value2.MobilePhone != null) {
                value1.MobilePhone = value1.MobilePhone != value2.MobilePhone ? value2.MobilePhone : value1.MobilePhone;
            }
            if(value2.msf_LanguagePreferer__c != null) {
                value1.msf_LanguagePreferer__c = value1.msf_LanguagePreferer__c != value2.msf_LanguagePreferer__c ? value2.msf_LanguagePreferer__c : value1.msf_LanguagePreferer__c;
            }
            if(value2.Gender__c != null) {
                value1.Gender__c = value1.Gender__c != value2.Gender__c ? value2.Gender__c : value1.Gender__c;
            }
            if(value2.msf_FiscalFirstName__c != null) {
                value1.msf_FiscalFirstName__c = value1.msf_FiscalFirstName__c != value2.msf_FiscalFirstName__c ? value2.msf_FiscalFirstName__c : value1.msf_FiscalFirstName__c;
            }
            if(value2.msf_FiscalLastName1__c != null) {
                value1.msf_FiscalLastName1__c = value1.msf_FiscalLastName1__c != value2.msf_FiscalLastName1__c ? value2.msf_FiscalLastName1__c : value1.msf_FiscalLastName1__c;
            }
            if(value2.msf_FiscalLastName2__c != null) {
                value1.msf_FiscalLastName2__c = value1.msf_FiscalLastName2__c != value2.msf_FiscalLastName2__c ? value2.msf_FiscalLastName2__c : value1.msf_FiscalLastName2__c;
            }
            if(value2.msf_fiscalNif__c != null) {
                value1.msf_fiscalNif__c = value1.msf_fiscalNif__c != value2.msf_fiscalNif__c ? value2.msf_fiscalNif__c : value1.msf_fiscalNif__c;
            }
            if (value2.FirstName != null) {
                value1.FirstName = value2.FirstName;
            }
            if (value2.LastName != null) {
                value1.LastName = value2.LastName;
            }
        }
        value1.msf_ModificationChannel__c = 'F2F';
        value1.msf_F2FTemplateNumber__c = value2.msf_F2FTemplateNumber__c;
        
        return value1;
    }
    
    private static void moveSignatures (Lead incompleteLead, ID idToLink){
        
        List<ContentDocumentLink> lCDL = new List<ContentDocumentLink>();
        List<Lead> lLead = new List<Lead>();        
        
        if(incompleteLead.msf_FirmaDonante__c || incompleteLead.msf_FirmaRepresentante__c || incompleteLead.msf_FirmaTitular__c){
            for(ContentDocumentLink cdl : [SELECT LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId =: incompleteLead.Id]){
                ContentDocumentLink tempCDL = new ContentDocumentLink(); 
                tempCDL.LinkedEntityId = idToLink;
                tempCDL.ContentDocumentId = cdl.ContentDocumentId;
                tempCDL.ShareType = cdl.ShareType;
                lCDL.add(tempCDL);    
            }
            
            upsert lCDL;
        }        
        
        lLead.add(incompleteLead);
        
        delete lLead;
    }  
    
    private static ID managePaymentProfile (cpm__Payment_Profile__c infoPP, ID targetId, Boolean exist){
        
        Id idPP = null; 
        infoPP.cpm__Contact__c = targetId; 
        infoPP.msf_ModificationChannel__c = 'F2F';
        
        if(exist){
            List<cpm__Payment_Profile__c> masterPP = [SELECT id FROM cpm__Payment_Profile__c WHERE cpm__IBAN__c =:infoPP.cpm__IBAN__c AND msf_NIF__c =:infoPP.msf_NIF__c LIMIT 1];
            
            if(!masterPP.isEmpty()){ 
                idPP = masterPP[0].id;
            }else{           
                insert infoPP;
                idPP = infoPP.Id; 
            }  
        }else{
            insert infoPP;
            idPP = infoPP.Id; 
        }
        
        return idPP;        
    }
    
    private static void createDonation (ID idPP, npe03__Recurring_Donation__c infoO, Opportunity infoOU, Decimal amount, ID campaignId, ID targetId){        
        
        if(infoO != null){ 
            Schema.DescribeFieldResult fieldResult = npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe(); 
            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
            String period;
            for(Schema.PicklistEntry p : pickListValues){
                if(p.getLabel() == infoO.npe03__Installment_Period__c){
                    period = p.getValue();
                }
            }
            infoO.npe03__Installment_Period__c = period;
            infoO.npe03__Amount__c = amount;
            infoO.npe03__Recurring_Donation_Campaign__c = campaignId != null ? campaignId : null;
            infoO.npsp4hub__Payment_Profile__c = idPP;
            infoO.npe03__Contact__c = targetId; 
            infoO.msf_LeadSource1__c = 'Personal con tablet';
            
            insert infoO;            
        }
        
        if(infoOU != null){ 
            RecordType rtd = [SELECT id FROM recordtype WHERE developername= 'Donation' AND SobjectType = 'Opportunity' LIMIT 1];            
            infoOU.RecordTypeId =rtd.Id;
            infoOU.CampaignId = campaignId != null ? campaignId : null;            
            infoOU.CloseDate = date.valueOf(infoOU.CloseDate);
            infoOU.npsp4hub__Payment_Profile__c = idPP;
            Contact c =[SELECT AccountId FROM Contact WHERE Id =: targetId];
            infoOU.AccountId = c.AccountId;
            infoOU.npsp__Primary_Contact__c = targetId;
            infoOU.LeadSource = 'Personal con tablet';
            infoOU.Amount = amount;
            
            insert infoOU;
        } 
    }
    
    private static Id getCampaignID(String campaignName){
        
        List<Campaign> lCampaign = new List<Campaign>();
        if(campaignName != null){
            lCampaign = [SELECT Id FROM Campaign WHERE Name =: campaignName LIMIT 1];
            if(!lCampaign.isEmpty()){
                return lCampaign[0].Id;  
            }
        }
        lCampaign = [SELECT Id FROM Campaign WHERE Name ='Alta F2F' LIMIT 1];
        if(lCampaign.isEmpty()){
            RecordType rtd = [SELECT id FROM recordtype WHERE developername= 'Default' AND SobjectType = 'Campaign' LIMIT 1];
            Campaign nwCampaign = new Campaign();
            nwCampaign.RecordTypeId = rtd.Id;
            nwCampaign.Name = 'Alta F2F';
            nwCampaign.IsActive =true; 
            nwCampaign.msf_OwnBy__c = 'Captación';
            nwCampaign.msf_Objective__c = 'Captación de socios o donantes';
            nwCampaign.msf_OutboundChannel1__c = 'F2F';
            nwCampaign.msf_Segment__c = 'Frio individuos';
            nwCampaign.msf_Thematic__c = '99';
            nwCampaign.msf_IsOnline__c = 'No';            
            
            Insert nwCampaign;
            
            return nwCampaign.Id;
        }
        else{
            return lCampaign[0].Id;
        }
        /*List<User> lCanvaser = [SELECT msf_Campaign__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(!lCanvaser.isEmpty()){
        	lCampaign = [SELECT Id FROM Campaign WHERE Name =: lCanvaser[0].msf_Campaign__c LIMIT 1];
            if(!lCampaign.isEmpty()){
            	return lCampaign[0].Id;  
            }
        }*/
        
    }    
}