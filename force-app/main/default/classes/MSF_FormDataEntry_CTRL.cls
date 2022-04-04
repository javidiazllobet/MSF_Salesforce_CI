public without sharing class MSF_FormDataEntry_CTRL {
        
    public class opt{
        public String value;
        public String label;
        
        opt(string v, string l){
            this.value = v;
            this.label = l;
        }
    }
    
    @AuraEnabled
    public static Object getMemberInfo(String recordId){        
        
        Map<String, Object> out = new Map<String, Object>();
        out.put('existContact', false);
        out.put('contact', null);
        out.put('isOrg', false);
        out.put('hasPrimaryContact', false);
        out.put('primaryContact', null);
        
        List<Contact> member = [SELECT Id, FirstName, LastName, Suffix, 
                                msf_MainEmail__c, HomePhone, MobilePhone,
                                MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingCountry,                                
                                msf_NIF__c, msf_LanguagePreferer__c,
                                Gender__c, Birthdate,  
                             	msf_OrganizationType__c, msf_FundationType__c, 
                                msf_PrimaryContact__c,
                                recordTypeId, msf_IsAssosiative__c, msf_NoRecibirNada__c
                                FROM Contact 
                                WHERE Id =: recordId 
                                LIMIT 1];
        
        if(!member.isEmpty()){
            Contact con = member[0];
            
            out.put('existContact', true);
            out.put('contact', con);
            
            ID rdOrg = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();             
            if(con.RecordTypeId == rdOrg){
                out.put('isOrg', true);  
                
                if(con.msf_PrimaryContact__c != null){
                    List<Contact> primaryContact = [SELECT Id, FirstName, LastName, Suffix, 
                                                    msf_MainEmail__c, HomePhone, MobilePhone, 
                                                    MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingCountry,   
                                                    msf_fiscalNif__c, Title, msf_NoRecibirNada__c
                                                    FROM Contact 
                                                    WHERE Id =: con.msf_PrimaryContact__c 
                                                    AND RecordType.DeveloperName = 'Organization_Contact'
                                                    LIMIT 1]; 
                    
                    if(!primaryContact.isEmpty()){
                    	out.put('hasPrimaryContact', true);
        				out.put('primaryContact', primaryContact[0]);    
                    }else{
                    	out.put('hasPrimaryContact', false);
        				out.put('primaryContact', new Contact());    
                    }
                }   
            }
        }
        
        return out;
    }
    
    @AuraEnabled
    public static Map<String,sObject> initializeSobjects(){
        Map<String,sObject> out = new Map<String,sObject>();
        out.put('newContact', new Contact());
        out.put('newPrimaryContact', new Contact());
        out.put('newPayProf', new cpm__Payment_Profile__c());
        
        return out;
    }

    @AuraEnabled
    public static Object getLanguage(){
        return getOptions(Contact.msf_LanguagePreferer__c.getDescribe());
    }
    
    @AuraEnabled
    public static Object getGender(){
        return getOptions(Contact.Gender__c.getDescribe());
    }
    
    @AuraEnabled
    public static Object getOrganizationType(){ 
        return getOptions(Contact.msf_OrganizationType__c.getDescribe());
    }
    
    @AuraEnabled
    public static Object getFundationType(){      
        return getOptions(Contact.msf_FundationType__c.getDescribe());
    }
    
    @AuraEnabled
    public static Object getPayMethod(){
        
        final String profileMSI = 'Fundraising MID';
        final List<String> lstPayMethodToProfileMSI = new List<String>{'Direct Debit'};

        //## Obtenemos el nombre del perfil del usuario
        Id profileId= userinfo.getProfileId();
        String profileName=[SELECT Id, Name FROM Profile WHERE Id=:profileId].Name;

        if (profileMSI != profileName){
            return getOptions(Opportunity.npsp4hub__Payment_Method__c.getDescribe());
        }else{
            Schema.DescribeFieldResult fieldResult = Opportunity.npsp4hub__Payment_Method__c.getDescribe(); 
            List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
            
            Map<String,String> mTypeOpp = new Map<String,String> ();
            List<Object> options = new List<Object> ();
            
            for(Schema.PicklistEntry p : pickListValues){
                if(p.isActive() && lstPayMethodToProfileMSI.contains(p.getValue())){ //38751
                    options.add(new opt(p.getValue(), p.getLabel()));
                }
            }

            return JSON.serialize(options);
        }
    }
    
    @AuraEnabled
    public static Object getLeadSource(){
        return getOptions(Opportunity.LeadSource.getDescribe());
    }
    
    @AuraEnabled
    public static Object getFrequencies(){
        return getOptions(npe03__Recurring_Donation__c.npe03__Installment_Period__c.getDescribe());
    }
    
    @AuraEnabled
    public static Object getModificationChannels(){
        List<Schema.PicklistEntry> pickListValues = Contact.msf_ModificationChannel__c.getDescribe().getPicklistValues();        
        List<Object> options = new List<Object> ();
        
        Set<String> sExcludeValues = new Set<String>{'New','F2F','Unique file integration'};
            
            for(Schema.PicklistEntry p : pickListValues){
                if(p.isActive() && !sExcludeValues.contains(p.getValue()) ){                    
                    options.add(new opt(p.getValue(), p.getLabel()));    
                }
            }
        
        return JSON.serialize(options);
    }

    @AuraEnabled
    public static Object getPayProf(String payMethodSelected, String recordId){

        String rtName = ''; 
        Boolean isCC = false;
        List<Object> ppOptions = new List<Object>(); 
        
        if(payMethodSelected == 'Direct Debit' || payMethodSelected == 'TALÓN BANCARIO ESTÁNDAR' || payMethodSelected == 'PAGARÉS'){
            rtName = 'IBAN';
        }
        else if(payMethodSelected == 'CreditCard'){
        	rtName = 'Credit_Card'; 
            isCC = true;
        }else{
            ppOptions.add(new opt('disabled', System.Label.MSF_FORM_DE_NOT_SELECTABLE));
        } 
        
        if(recordId != null){
            for(cpm__Payment_Profile__c pp : [SELECT Id, RecordType.Name, CreatedDate FROM cpm__Payment_Profile__c 
                                              WHERE cpm__Active__c = true 
                                              AND cpm__Contact__c =: recordId 
                                              AND RecordType.DeveloperName =: rtName])
            {
                ppOptions.add(new opt(pp.Id, pp.RecordType.Name + '_' + pp.CreatedDate.date().day()+'-'+pp.CreatedDate.date().month()+'-'+pp.CreatedDate.date().year()));                
            }            
        }
        if(rtName == 'IBAN'){ //add in the last the picklist
            ppOptions.add(new opt('new', System.Label.MSF_FORM_DE_NEW));
        }
        if(ppOptions.isEmpty() && isCC){
            ppOptions.add(new opt('noCC', System.Label.MSF_FORM_DE_HAS_NOT_CREDIT_CARD));    
        }
        
        return JSON.serialize(ppOptions);
    }
    
    @AuraEnabled
    public static Object getOppType(String payMethodSelected){
        final String profileMSI = 'Fundraising MID';
        //final List<String> lstPayMethodToProfileMSI = new List<String>{'Direct Debit'};

        //## Obtenemos el nombre del perfil del usuario
        Id profileId= userinfo.getProfileId();
        String profileName=[SELECT Id, Name FROM Profile WHERE Id=:profileId].Name;


        Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        Map<String,String> mTypeOpp = new Map<String,String> ();
        List<Object> options = new List<Object> ();
        
        for(Schema.PicklistEntry p : pickListValues){
            mTypeOpp.put(p.getValue(),p.getLabel());
        } 
        
        if((profileName!=profileMSI)&&(payMethodSelected == 'Direct Debit' || payMethodSelected == 'CreditCard' || payMethodSelected == 'TRANSFERENCIA BANCARIA' || payMethodSelected == 'TC ONLINE' ||
           payMethodSelected == 'PAYPAL' || payMethodSelected == 'TRUSTLY - TR ONLINE' || payMethodSelected == 'TALÓN BANCARIO ESTÁNDAR' || payMethodSelected == 'EFECTIVO S.C.'))
        {
            options.add(new opt('One off Donation', mTypeOpp.get('One off Donation')));
            
            if(payMethodSelected == 'Direct Debit' || payMethodSelected == 'CreditCard'){
                options.add(new opt('Recurrent Donation', mTypeOpp.get('Recurrent Donation')));
                options.add(new opt('Recurrent Donation Membership', System.Label.MSF_FORM_DE_RECURRENT_DONATION_MEMBERSHIP));
                options.add(new opt('Recovered Quota', mTypeOpp.get('Recovered Quota')));
            } 
            else if(payMethodSelected == 'TRANSFERENCIA BANCARIA'){
                options.add(new opt('SMS Operator', mTypeOpp.get('SMS Operator')));
                options.add(new opt('SMS Donor', mTypeOpp.get('SMS Donor')));
                options.add(new opt('Employee or client Donation', mTypeOpp.get('Employee or client Donation')));
            }
            
            options.add(new opt('Solidarity initiative', mTypeOpp.get('Solidarity initiative')));
            options.add(new opt('Solidarity Wedding', mTypeOpp.get('Solidarity Wedding')));
            options.add(new opt('Matching Gift', mTypeOpp.get('Matching Gift')));
            options.add(new opt('Membership', mTypeOpp.get('Membership')));
            
        }       
        else if((profileName!=profileMSI)&&(payMethodSelected == 'INICIATIVA SOLIDARIA ONLINE')){
            options.add(new opt('Solidarity initiative', mTypeOpp.get('Solidarity initiative')));
        }
        else if((profileName!=profileMSI)&&(payMethodSelected == 'EFECTIVO ASOCIATIVO' || payMethodSelected == 'ACMA')){//solo para asociativo
            options.add(new opt('Membership', mTypeOpp.get('Membership')));
        }
        else if((profileName!=profileMSI)&&(payMethodSelected == 'GIRO POSTAL' || payMethodSelected == 'EFECTIVO RECEPCIÓN' || payMethodSelected == 'PAGARÉS' || payMethodSelected == 'TALÓN NO ESTÁNDAR EN EUROS' || payMethodSelected == 'TALÓN NO ESTÁNDAR EXTRANJERO' || payMethodSelected == 'GIRO POSTAL RECEPCIÓN')){
            options.add(new opt('One off Donation', mTypeOpp.get('One off Donation')));
            options.add(new opt('Matching Gift', mTypeOpp.get('Matching Gift'))); 
            options.add(new opt('Membership', mTypeOpp.get('Membership')));
        }
        else if((profileName!=profileMSI)&&(payMethodSelected == 'CUENTA ABOGADO/CUENTA PUENTE')){
            options.add(new opt('One off Donation', mTypeOpp.get('One off Donation')));
        }
        else if((profileName!=profileMSI)&&(payMethodSelected == 'GRANT')){
            options.add(new opt('Grant', mTypeOpp.get('Grant')));
        }
        else if((profileName!=profileMSI)&&(payMethodSelected == 'EN ESPECIE-SERVICIOS' || payMethodSelected == 'EN ESPECIE-INMOVILIZADO')){
            options.add(new opt('In-Kind Gift', mTypeOpp.get('In-Kind Gift')));
        }
        else if((profileName!=profileMSI)&&(payMethodSelected == 'HERENCIAS Y LEGADOS')){
            options.add(new opt('Pago de Herencia', mTypeOpp.get('Pago de Herencia')));
            options.add(new opt('Herencia', mTypeOpp.get('Herencia')));
        }
        else if((profileName==profileMSI)&&(payMethodSelected == 'Direct Debit')){
            options.add(new opt('One off Donation', mTypeOpp.get('One off Donation')));
            options.add(new opt('Recovered Quota', mTypeOpp.get('Recovered Quota')));
            options.add(new opt('Recurrent Donation', mTypeOpp.get('Recurrent Donation')));
        }

        return JSON.serialize(options);
    }
    
    @AuraEnabled
    public static Object getInKindTypes(boolean isImmobilized){
        List<Schema.PicklistEntry> pickListValues = Opportunity.npsp__In_Kind_Type__c.getDescribe().getPicklistValues();        
        List<Object> options = new List<Object> ();
        
        for(Schema.PicklistEntry p : pickListValues){
            if(p.isActive()){
                if(isImmobilized && p.getValue() == 'Inmovilizado'){
                	options.add(new opt(p.getValue(), p.getLabel()));  
                    break;
                }
                else if(!isImmobilized && p.getValue() != 'Inmovilizado'){
                	options.add(new opt(p.getValue(), p.getLabel()));    
                }	
            }
        }

        return JSON.serialize(options);
    }
    
    @AuraEnabled
    public static Object getTarget(boolean isTransfer){
        List<Schema.PicklistEntry> pickListValues = Opportunity.npsp4hub__Target__c.getDescribe().getPicklistValues();
        List<Object> options = new List<Object> ();
        
        for(Schema.PicklistEntry p : pickListValues){
            if(p.isActive()){
                if(isTransfer){
                    options.add(new opt(p.getValue(), p.getLabel()));  
                }else{
                    if(p.getValue() == 'LA CAIXA CCC OPERATIVA'){
                        options.add(new opt(p.getValue(), p.getLabel()));   
                        break;
                    }
                }	
            }
        } 
        if(options.isEmpty()){
            options.add(new opt('None', 'N/A'));       
        }       
        
        return JSON.serialize(options);
    }
        
    private static Object getOptions(Schema.DescribeFieldResult fr){
    	List<Schema.PicklistEntry> pickListValues = fr.getPicklistValues();        
        List<Object> options = new List<Object> ();
        
        for(Schema.PicklistEntry p : pickListValues){
            if(p.isActive()){//#27620 - Omega. Se elimina la siguiente condición para incluir el telemarketing como opción: && p.getValue() != 'Telemarketing'
                options.add(new opt(p.getValue(), p.getLabel()));
            }
        }
		
        return JSON.serialize(options);
    }
    
    @AuraEnabled
    public static cpm__Payment_Profile__c getPaymentProfileInfo(String ppId){ 

        List<cpm__Payment_Profile__c> lPP = new List<cpm__Payment_Profile__c>();
        if(ppId != 'new'){
            lPP = [SELECT Id, cpm__IBAN__c, msf_NIF__c, msf_HolderFirstName__c, msf_HolderLastName1__c, msf_HolderLastName2__c 
                   FROM cpm__Payment_Profile__c 
                   WHERE cpm__Active__c = true AND Id =: ppId];
        }
        else{
            lPP.add(new cpm__Payment_Profile__c());
        }

        return lPP[0];
    }
    
  @AuraEnabled
    public static Map<String, Object> saveProcess(Boolean isNewContact, Boolean isIndividual, Boolean hasPriCont, Boolean checkPriCont, Contact contactInfo, Contact priCont, cpm__Payment_Profile__c payProf, String payProfHolder, Decimal amount, String payReference, String trancode, String orderId, String autCode, String oppType, String inkindType, Date donationDate, String rdFrequency, npsp__General_Accounting_Unit__c gau, String payMethod, String target, String entryLeadSource, Campaign entryCampaign, String modChannel, String oppDescription){
     	System.debug('modChannel: '+modChannel);
        system.debug('Target: '+target);
        Savepoint sp = Database.setSavepoint();

        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('title',System.Label.MSF_FORM_F2F_SAVE_RECORD);
        mResult.put('type','ERROR');
        mResult.put('msg',System.Label.MSF_FORM_F2F_ERROR_HAS_OCURRED);
        
        Map<String,Schema.RecordTypeInfo> mRtContactInfo = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
        Map<String,Schema.RecordTypeInfo> mRtOpportunitytInfo = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        Map<String,Schema.RecordTypeInfo> mRtRecurringDonationInfo = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName();
        Map<String,Schema.RecordTypeInfo> mRtPaymentProfileInfo = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName();
        
        Boolean usePaymentProfile = (payMethod == 'Direct Debit' || payMethod == 'CreditCard' || payMethod == 'TALÓN BANCARIO ESTÁNDAR' || payMethod == 'PAGARÉS');
        Boolean useOrderId = (payMethod == 'TC ONLINE' || payMethod == 'TRUSTLY - TR ONLINE' || payMethod == 'PAYPAL' || payMethod == 'INICIATIVA SOLIDARIA ONLINE');
		
        //#25849 - OMEGA - Comprobamos si no se ha indicado valor y si es así lo dejamos a null, el método setLanguagePreferer de la clase MSF_ContactFieldsLogic_TDTM ya se encargará de darle valor
        if(contactInfo.msf_LanguagePreferer__c != null){
            if(contactInfo.msf_LanguagePreferer__c == 'none'){
                contactInfo.msf_LanguagePreferer__c = null;
            }
        }
        
        try{
			contactInfo.msf_ModificationChannel__c = modChannel;
            
            if(isNewContact){
                if(isIndividual){
                    contactInfo.RecordTypeId = mRtContactInfo.get('Individual_Contact').getRecordTypeId();
                } 
                else{
                    contactInfo.RecordTypeId = mRtContactInfo.get('Organization').getRecordTypeId(); 
                }
                contactInfo.LeadSource = entryLeadSource;
                contactInfo.msf_EntryCampaign__c = entryCampaign.Id;
                contactInfo.msf_ConfirmedLanguage__c = false;
                contactInfo.msf_ModificationChannel__c = 'New';
            }
            
            try{
                upsert contactInfo;
            }catch(System.DmlException ex){
                if(ex.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                    Database.rollback(sp);
                    mResult.put('msg',System.Label.MSF_FORM_F2F_CONTACT_ALREADY_EXISTS);
                    return mResult;
                }
                mResult.put('msg',ex.getDmlMessage(0));
                return mResult;
            }
            
            if(!isIndividual && checkPriCont){
                priCont.msf_ModificationChannel__c = modChannel;
                if((!isNewContact && !hasPriCont) || (isNewContact && checkPriCont)){
                	priCont.RecordTypeId = mRtContactInfo.get('Organization_Contact').getRecordTypeId();
                    priCont.LeadSource = entryLeadSource;
                    priCont.msf_EntryCampaign__c = entryCampaign.Id;
                    priCont.msf_Organization__c = contactInfo.Id;
                    priCont.msf_ConfirmedLanguage__c = true;
                    priCont.msf_FiscalFirstName__c = priCont.FirstName;
                    priCont.msf_FiscalLastName1__c = priCont.LastName;
                    priCont.msf_FiscalLastName2__c = priCont.Suffix;
                    priCont.msf_MainEmail__c = contactInfo.msf_MainEmail__c;
                    priCont.HomePhone = contactInfo.HomePhone;
                    priCont.MobilePhone = contactInfo.MobilePhone;
                    priCont.msf_NoRecibirNada__c = contactInfo.msf_NoRecibirNada__c;
                    priCont.msf_ModificationChannel__c = 'New';
                }   
                upsert priCont;
            }

            if((payProf != null && payProf.Id == null) && usePaymentProfile){ 
                if(payProfHolder == 'member'){
                    if(!isIndividual && checkPriCont){
                        payProf.msf_HolderFirstName__c = priCont.FirstName; 
                        payProf.msf_HolderLastName1__c = priCont.LastName;
                        payProf.msf_HolderLastName2__c = priCont.Suffix;
                        payProf.cpm__Holder_Name__c = ((priCont.FirstName+' '+priCont.LastName).trim()+(priCont.Suffix != null ? ' '+priCont.Suffix : ''));
                        payProf.msf_NIF__c = priCont.msf_fiscalNif__c;
                    }
                    else{
                        payProf.msf_HolderFirstName__c = contactInfo.FirstName; 
                        payProf.msf_HolderLastName1__c = contactInfo.LastName;
                        payProf.msf_HolderLastName2__c = contactInfo.Suffix;
                        payProf.cpm__Holder_Name__c = ((contactInfo.FirstName != null ? contactInfo.FirstName : '').trim() + ' ' + (contactInfo.LastName).trim() + (contactInfo.Suffix != null ? ' '+contactInfo.Suffix : ''));
                        payProf.msf_NIF__c = contactInfo.msf_NIF__c;
                    } 
                } 
                else if(payProfHolder == 'other'){
                    payProf.cpm__Holder_Name__c = ((payProf.msf_HolderFirstName__c+' '+payProf.msf_HolderLastName1__c).trim()+(payProf.msf_HolderLastName2__c != null ? ' '+payProf.msf_HolderLastName2__c : ''));
                }
                
                payProf.msf_ModificationChannel__c = 'New';
                payProf.RecordTypeId = mRtPaymentProfileInfo.get('IBAN').getRecordTypeId();
                payProf.cpm__Contact__c = contactInfo.Id;
                payProf.cpm__Active__c = true;  
                
                insert payProf;
            }
            
            String sPaymentProcessor = 'PaymentHub-SEPA';
            if(payMethod == 'CreditCard'){
            	sPaymentProcessor = 'PaymentHub-Redsys';
            }
            
            if(String.isBlank(target)){
             	target = 'LA CAIXA CCC OPERATIVA';   
            }
            
            if(oppType == 'Recurrent Donation' || oppType == 'Recurrent Donation Membership'){ 
            	npe03__Recurring_Donation__c newRd = new npe03__Recurring_Donation__c();
                newRd.RecordTypeId = oppType == 'Recurrent Donation Membership' ? mRtRecurringDonationInfo.get('Associate').getRecordTypeId() : mRtRecurringDonationInfo.get('Recurring_donation').getRecordTypeId();
                newRd.npe03__Contact__c = contactInfo.Id;
                newRd.Name = 'Recurring donation';
                newRd.npe03__Open_Ended_Status__c = 'Open';
                newRd.npe03__Date_Established__c = Date.today();
                newRd.npe03__Next_Payment_Date__c = donationDate;
                newRd.npe03__Installment_Period__c = oppType == 'Recurrent Donation Membership' ? 'Yearly' : rdFrequency;  
                newRd.npe03__Amount__c = amount;
                
                newRd.npsp4hub__Payment_Profile__c = payProf.Id;
                newRd.npsp4hub__Payment_Method__c = payMethod;
                newRd.npsp4hub__Payment_Processor__c = sPaymentProcessor;
                newRd.npsp4hub__Target__c = target;                
                newRd.msf_LeadSource1__c = entryLeadSource;
                newRd.npe03__Recurring_Donation_Campaign__c = entryCampaign.Id;
                
                insert newRd;
            }
            else{
                Opportunity opp = new Opportunity();
                opp.Name = 'Unique donation';
                opp.npsp__Primary_Contact__c = contactInfo.Id;
                opp.Type = oppType;
                opp.npsp__In_Kind_Type__c = inkindType; 
                opp.Amount = amount;
                opp.CloseDate = donationDate;
				opp.StageName = 'Puesta al cobro';
                opp.Description = oppDescription;
                    
                opp.npsp4hub__Payment_Method__c = payMethod;
                opp.npsp4hub__Payment_Processor__c = sPaymentProcessor;
                opp.npsp4hub__Target__c = target;                
                opp.LeadSource = entryLeadSource;
                opp.CampaignId = entryCampaign.Id;
           
                if(oppType == 'Grant'){
                	opp.RecordTypeId = mRtOpportunitytInfo.get('Grant').getRecordTypeId();   
                }
                else if(oppType == 'In-Kind Gift'){
                	opp.RecordTypeId = mRtOpportunitytInfo.get('In_Kind_Gift').getRecordTypeId();      
                }
                else if(oppType == 'Matching Gift'){
                	opp.RecordTypeId = mRtOpportunitytInfo.get('Matching_Gift').getRecordTypeId();    
                }
                else if(oppType == 'Membership'){
                	opp.RecordTypeId = mRtOpportunitytInfo.get('Membership').getRecordTypeId();    
                }
                else if(oppType == 'Herencia' || oppType == 'Pago de Herencia'){
                	opp.RecordTypeId = mRtOpportunitytInfo.get('Legacy').getRecordTypeId();    
                }
                else{
                	opp.RecordTypeId = mRtOpportunitytInfo.get('Donation').getRecordTypeId(); 
                }
                
                if(usePaymentProfile){
                    opp.npsp4hub__Payment_Profile__c = payProf.Id;
                    
                    if(payMethod == 'Direct Debit' || payMethod == 'CreditCard'){
                        opp.StageName = 'Puesta al cobro';                          
                    }else{
                        opp.StageName = 'Cobrada';                      	   
                    }                        
                }else{
                    opp.StageName = 'Cobrada';
                }
                if(useOrderId){
                    opp.msf_PaymentOrderId__c = orderId;
                    opp.msf_PaymentAuthorisationCode__c = autCode;
                }
                
                try{
                    insert opp; 
                }catch(System.DmlException e){
                    Database.rollback(sp);
                    if(e.getDmlType(0) == StatusCode.DUPLICATE_VALUE){                        
                        mResult.put('msg',System.Label.MSF_FORM_DE_ERROR_DUPLICATE_ORDER_ID);
                    }else{
                    	mResult.put('msg',e.getDmlMessage(0));   
                    }                    
                    return mResult;
                }
                                
                if(opp.StageName == 'Cobrada'){
                	cpm__Installment__c ins = new cpm__Installment__c();
                    ins.RecordTypeId = Schema.SObjectType.cpm__Installment__c.getRecordTypeInfosByDeveloperName().get('Receivable').getRecordTypeId();
                    ins.cpm__Contact__c = contactInfo.Id;  
                    ins.cpm__Amount__c = amount;
                    ins.cpm__Amount_Open__c = 0;
                    // ins.cpm__Bank_Statement_Description__c -> ### nombre de la opp, mirar logica del trigger ###
                    ins.cpm__Source__c = 'PaymentHub-for-NPSP';
                    ins.cpm__Target__c = target;
                    ins.cpm__Status__c = 'Collected';
                    ins.cpm__Due_Date__c = donationDate;
                    ins.cpm__Last_Collection_Date__c = donationDate;                    
                    ins.cpm__Original_Due_Date__c = donationDate; 
                    ins.npsp4hub__Opportunity__c = opp.Id;
                    ins.cpm__Payment_Processor__c = sPaymentProcessor;                    
                    ins.cpm__Payment_Method__c = payMethod;
                    if(usePaymentProfile){
                    	ins.cpm__Payment_Profile__c = payProf.Id; 
                    }  
                    if(useOrderId){
                        ins.cpm__Payment_Transaction_Id__c = orderId;
                    }
                    
                    insert ins;
                
                	cpm__Payment__c pay = new cpm__Payment__c();
                    pay.cpm__Amount__c = amount;
                    pay.cpm__Collection_Date__c = donationDate;
                    pay.cpm__Contact__c = contactInfo.Id; 
                    pay.cpm__Installment__c = ins.Id;
                    pay.cpm__Payment_Reference__c = payReference;
                    pay.msf_Trancode__c = trancode;
                    pay.cpm__Target__c = target;
                    pay.cpm__Payment_Processor__c = sPaymentProcessor;                    
                    pay.cpm__Payment_Method__c = payMethod;
                    if(usePaymentProfile){
                    	pay.cpm__Payment_Profile__c = payProf.Id; 
                    }  
                    if(useOrderId){
                        pay.cpm__Payment_Reference__c = orderId;
                        pay.msf_PaymentAuthorisationCode__c = autCode;
                    }
                    
                    insert pay;
                }
                
                
                List<String> noGauOppTypes = new List<String>{
                'Recurrent Donation Membership', 'Membership', 'Recurrent Donation'
                };
               
                if(noGauOppTypes.contains(oppType) == false && gau != null && gau.Id != null){
                    npsp__Allocation__c gauAll = new npsp__Allocation__c();
                    gauAll.npsp__Percent__c= 100;
                    gauAll.npsp__General_Accounting_Unit__c = gau.Id;
                    gauAll.npsp__Opportunity__c = opp.Id;
                    
                    
                    insert gauAll;
                }
            }
            
            mResult.put('contactId',contactInfo.Id);
            mResult.put('type','SUCCESS');
            mResult.put('msg',System.Label.MSF_FORM_F2F_DATA_SAVED_CORRECTLY);
            
            
        }catch(Exception ex){ 
            Database.rollback(sp);
            mResult.put('msg', ex.getMessage()); 
        }
        return mResult;
    }
    
    @AuraEnabled
    public static Date nextRecurringDate (){
    	Date d = Date.newInstance(Date.today().addMonths(1).year(), Date.today().addMonths(1).month(), 1); 
        return d;
    }
}