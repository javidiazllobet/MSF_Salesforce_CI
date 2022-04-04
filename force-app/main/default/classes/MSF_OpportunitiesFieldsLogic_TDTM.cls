/**
* @author 		Deloitte
* @date 		10-2018
* @group 		Opportunity
* @description	Opportunity fields management and name.
*/

global without sharing class MSF_OpportunitiesFieldsLogic_TDTM extends npsp.TDTM_Runnable {
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        
        //Current User
        Boolean bEcoUser = [SELECT Id, msf_EconomicProcessUser__c FROM User WHERE Id =: UserInfo.getUserId()].msf_EconomicProcessUser__c;
        
        //Attributes
        List<Opportunity> lNewOpp = (List<Opportunity>) newlist;        
        List<Opportunity> lOldOpp = (List<Opportunity>) oldlist;
        Map<Id, Opportunity> mOldOpp = new Map<Id, Opportunity>();
        if(lOldOpp != null){            
            mOldOpp.putAll(lOldOpp);
        }
        
        List<Contact> lContactsToUpdate = new List<Contact>(); 
        
        Set<ID> sCont = new Set<ID>();
        Set<ID> sCamp = new Set<ID>();
        Set<ID> sRD = new Set<ID>();
        
        Map<Id, Contact> mCont = new Map<Id, Contact>();
        Map<Id, Campaign> mCamp = new Map<Id, Campaign>();
        Map<Id, npe03__Recurring_Donation__c> mRD = new Map<Id, npe03__Recurring_Donation__c>();
        
        Map<String,Schema.RecordTypeInfo> mOppRtInfo = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName(); 
        Map<Id,Schema.RecordTypeInfo> mOppRtInfoById = Schema.SObjectType.Opportunity.getRecordTypeInfosById();   
        Map<ID,Schema.RecordTypeInfo> mRdRtInfo = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosById();
        
        
        //Comprobar si se pueden modificar las opportunidades;  
        Boolean canUpdate = true;
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            system.debug('beforeUpdate or AfterUpdate');
            canUpdate = checkCanUpdateOpps(lNewOpp, mOldOpp);
        }
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeDelete) {
            canUpdate = checkCanUpdateOpps(lOldOpp, mOldOpp);
        }
        if (canUpdate == false) {
            return null;
        }
        
        
        
        //BeforeInsert
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {            
            
            for(Opportunity o :lNewOpp){                                
                if(o.npe03__Recurring_Donation__c != null){
                    sRD.add(o.npe03__Recurring_Donation__c);    
                }
            }                       
            
            if(!sRD.isEmpty()){
                mRD.putAll([SELECT Id, RecordTypeId FROM npe03__Recurring_Donation__c WHERE Id IN: sRD]);
            }
            
            for(Opportunity o :lNewOpp){
                if(o.npe03__Recurring_Donation__c != null){
                    if(mRdRtInfo.get(mRD.get(o.npe03__Recurring_Donation__c).RecordTypeId).getDeveloperName() == 'Associate'){
                        o.RecordTypeId = mOppRtInfo.get('Membership').getRecordTypeId();
                        o.Type = 'Membership';    
                    }else{
                        o.RecordTypeId = mOppRtInfo.get('Donation').getRecordTypeId();
                        o.Type = 'Recurrent Donation';	    
                    }   
                }         
            }
        }
        
        //BEFORE INSERT && BEFORE UPDATE
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate){ 
            
            Boolean isInsert = triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert;
            Id rtAnonymous = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Anonymous').getRecordTypeId();
            
            MSF_SharedMethods_UTIL smUtil = new MSF_SharedMethods_UTIL();            
            Map<String, msf_LeadSourceMasterData__c> mLeadSourceValues = smUtil.getLeadSourceDependencies();
            
            Set<ID> sOppId = new Set<ID>();
            Set<ID> sContAccount = new Set<ID>();
            Set<ID> sContAux = new Set<ID>();   
            
            if (!mOldOpp.isEmpty()) {
            	for(Opportunity o :lNewOpp){         
                    Id oldContact = mOldOpp.get(o.Id).npsp__Primary_Contact__c;
                    if(o.npsp__Primary_Contact__c != oldContact && o.npsp__Primary_Contact__c != null) {
                         sCont.add(o.npsp__Primary_Contact__c);
                    }
                    sCont.add(oldContact);
                }
            }
            
            if(!sCont.isEmpty()){
                mCont.putAll([SELECT RecordTypeId FROM Contact WHERE Id IN: sCont ]);
            }
            
                        
            for(Opportunity o :lNewOpp){                
                sOppId.add(o.id);
                
                if(o.CampaignId != null){
                    sCamp.add(o.CampaignId);
                }  
                
                if(o.npsp__Primary_Contact__c != null){
                    sCont.add(o.npsp__Primary_Contact__c);
                    
                    if(o.AccountId == null){
                        sContAccount.add(o.npsp__Primary_Contact__c);
                    } 
                    
                    if(mOldOpp.isEmpty()){
                        sContAux.add(o.npsp__Primary_Contact__c);
                    } 
                    
                    if(!mOldOpp.isEmpty()){
                        Opportunity oldOpp = mOldOpp.get(o.Id);
                        Id oldContactId = oldOpp.npsp__Primary_Contact__c;
                        if(o.npsp__Primary_Contact__c != oldContactId) {
                            sContAccount.add(o.npsp__Primary_Contact__c);
                            sContAux.add(o.npsp__Primary_Contact__c); 
                            
                            //Si la oportunidad se reasigna de un contacto anónimo a otro no anónimo
                            Contact oldContact = mCont.get(oldContactId);
                           	Contact newContact = mCont.get(o.npsp__Primary_Contact__c);
                            if (newContact != null && oldContact != null && isInsert == false && 
                                newContact.RecordTypeId != rtAnonymous && oldContact.RecordTypeId == rtAnonymous) {
                                o.msf_ChangeNoAnonymousContact__c = true;
                                o.msf_DonationVehicleContact__c = newContact.Id; 
                            }
                        } 
                    }
                }
            } 
            
            if(!sCont.isEmpty()){
                mCont.putAll([SELECT Id, msf_BeginDateMSF__c, msf_Program__c, msf_MailingSegment__c, AccountId, 
                              (SELECT CloseDate FROM Opportunities WHERE Type != 'SMS Donor' AND IsWon = true AND ID NOT IN: sOppId ORDER BY CloseDate ASC LIMIT 1) 
                              FROM Contact WHERE Id IN: sCont ]); 
            }
            
            for(Opportunity o :lNewOpp){
                setNameOpp(o, mOppRtInfo, mOppRtInfoById); 
                if(!bEcoUser){
                    //setNameOpp(o, mOppRtInfo, mOppRtInfoById); 
                    //setLeadSourceDependencies(o, mLeadSourceValues);
                    if(sContAccount.contains(o.npsp__Primary_Contact__c) ){
                        setAccount(o, mCont, sContAccount);   
                    }
                }
                else {
                    if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
                        //setNameOpp(o, mOppRtInfo, mOppRtInfoById); 
                        //setLeadSourceDependencies(o, mLeadSourceValues);
                        if(sContAccount.contains(o.npsp__Primary_Contact__c) ){
                            setAccount(o, mCont, sContAccount);   
                        }
                    }
                }
                setLeadSourceDependencies(o, mLeadSourceValues);
                setOppFields(o, mCont, sContAux);
                
                if(!bEcoUser){
                    setRating(o, mCont);
                    setCampaigns(o);
                }
                else {
                    if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
                        setRating(o, mCont);
                        setCampaigns(o);
                    }
                }

                setLeadSource(o);
                setCampaignMember(o);
                
                if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate 
                    && mOldOpp.get(o.Id) != null 
                    && o.RecordTypeId == mOppRtInfo.get('Legacy').getRecordTypeId() 
                    && (o.StageName !='Devuelta' || o.StageName !='Impagada'|| o.StageName !='Cancelada'|| o.StageName !='Cobrada')
                    && o.StageName != mOldOpp.get(o.Id).StageName) 
                {
                    o.CloseDate = Date.today();
                }

            }                    
        }
        
        //AFET INSERT && AFTER UPDATE
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate){  
            
            Set<ID> sOppInstall = new Set<ID>(); 
            Set<Id> lIdsRecurringDonationsToUpdate = new Set<Id>();
            
            for(Opportunity o :lNewOpp){                
                if(o.npsp__Primary_Contact__c != null){
                    sCont.add(o.npsp__Primary_Contact__c);
                }      
                
                //Stage Impagada + el código de devolución es diferente al fallecido + es una oportunidad asociada a una recurring
                if (o.StageName == 'Impagada' && o.npe03__Recurring_Donation__c != null 
                    && (
                    		(o.msf_LastReasonCodeReceived__c != null && o.msf_LastReasonCodeReceived__c != 'MD07') 
                        ||   o.msf_LastReasonCodeReceived__c == null
                   	   )
                   ) 
                {
                        lIdsRecurringDonationsToUpdate.add(o.npe03__Recurring_Donation__c);
                    
                } 
            }
            
            //Lógica de Recurring 
            if (lIdsRecurringDonationsToUpdate.isEmpty() == false) {
                //closeImpagoRecurringDonations(lIdsRecurringDonationsToUpdate);
                MSF_CloseRecurringDonations_01_BATCH myBatchObject = new MSF_CloseRecurringDonations_01_BATCH(lIdsRecurringDonationsToUpdate); 
                Id batchRecurringId = Database.executeBatch(myBatchObject);
            }
            
            //Lógica de contacto; 
            if(!sCont.isEmpty()){
                mCont.putAll([SELECT Id, msf_BeginDateMSF__c, msf_FirstCampaingColaboration__c, msf_DateFirstDonation__c, msf_DateLastDonation__c, msf_EntryCampaign__c, 
                              msf_MemberType__c, msf_IsActiveDonor__c, msf_IsActiveRecurringDonor__c, msf_FirstCampaignColaborationChannel__c,
                              npsp__Deceased__c, msf_ContactDeleteReason__c
                              FROM Contact WHERE Id IN: sCont ]);
                
                List<Contact> tempContacts = new List<Contact>();
                tempContacts = MSF_SharedMethods_UTIL.contactMemberType(mCont.values());
                
                Map<Id,Contact> tempMap = new Map<Id,Contact>(tempContacts);
                			 
                for(Opportunity o :lNewOpp){                 
                    if(o.npsp__Primary_Contact__c != null && mCont.containsKey(o.npsp__Primary_Contact__c)){
                        Opportunity oldOpp = mOldOpp.get(o.Id);
                        Contact cToUpdate = setContactFields(o, mCont.get(o.npsp__Primary_Contact__c), tempMap);
                        if (cToUpdate != null) {
                            lContactsToUpdate.add(cToUpdate);    
                        }
                    }
                }
            }
        }
        
        //AfterDelete
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete){            
            for(Opportunity op : lOldOpp){
                if(op.npsp__Primary_Contact__c != null){
                    lContactsToUpdate.add(new Contact(Id=op.npsp__Primary_Contact__c,msf_RecalculateMemberType__c=TRUE));
                }
            }    
        }
        
        //DML Operations
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToUpdate.addAll((List<Contact>) lContactsToUpdate);
        
        if(lContactsToUpdate.isEmpty()){
            return null;
        }
        
        return dmlWrapper;
    }
    
    
    // PRIVATE METHODS
    
    
    private Boolean checkCanUpdateOpps(List<Opportunity> lNewOpp, Map<Id, Opportunity> mOldOpp) {
        Boolean canUpdate = true; 
        
        //Mirar si el usuario que ejecuta el trigger es Admin
        Id profileId = UserInfo.getProfileId();
        Boolean isAdmin = [SELECT PermissionsModifyAllData FROM Profile WHERE Id =: profileId].PermissionsModifyAllData;
        Boolean bEcoUser = [SELECT Id, msf_EconomicProcessUser__c FROM User WHERE Id =: UserInfo.getUserId()].msf_EconomicProcessUser__c;
        
        if (isAdmin == false && bEcoUser == false) {
            //PaymentSchedules;
            List<String> paymentSchedulesStatus = new List<String>{'Done'}; 
            system.debug('paymentSchedulesStatus: ' + paymentSchedulesStatus);
                List<cpm__Payment_Schedule__c> paymentSchedulesList = [SELECT Id, cpm__Status__c, cpm__PaymentMethod__c, cpm__Selection_Date__c FROM cpm__Payment_Schedule__c WHERE cpm__Status__c NOT IN :paymentSchedulesStatus]; 
                system.debug('paymentSchedulesList: ' + paymentSchedulesList);
            if (paymentSchedulesList.isEmpty() == false) {
                for (Opportunity opp : lNewOpp) {
                    Opportunity oldOpp = mOldOpp.get(opp.Id);
                    if (oldOpp == null) { oldOpp = opp; }
                    //Mirar si opportunidad esta "Puesta al cobro" o "Devuelta"
                    if (oldOpp.StageName.equals('Puesta al cobro') || oldOpp.StageName.equals('Devuelta') ||
                        opp.StageName.equals('Puesta al cobro')    || opp.StageName.equals('Devuelta')) {
                            for (cpm__Payment_Schedule__c ps : paymentSchedulesList) {
                                if ((oldOpp.CloseDate <= ps.cpm__Selection_Date__c && oldOpp.npsp4hub__Payment_Method__c == ps.cpm__PaymentMethod__c) ||
                                    (opp.CloseDate <= ps.cpm__Selection_Date__c && opp.npsp4hub__Payment_Method__c == ps.cpm__PaymentMethod__c)) {
                                        canUpdate = false; 
                                        opp.addError(System.Label.MSF_OPPORTUNITY_BLOCKED); 
                                    }
                            }
                        }
                }   
            }
        }
        
        
        return canUpdate;
    }
    
    
    
    //************* Set values of the following fields: msf_LeadSource2Level__c; msf_LeadSource3Level__c *************
    private void setLeadSourceDependencies(Opportunity o, Map<String, msf_LeadSourceMasterData__c> mLsValues){
        if(mLsValues.containsKey(o.LeadSource)){
            o.msf_LeadSource2Level__c = mLsValues.get(o.LeadSource).msf_LeadSource2__c;
            o.msf_LeadSource3Level__c = mLsValues.get(o.LeadSource).msf_LeadSource3__c;
        }
    }
    
    private void setCampaignMember(Opportunity o) {
        Id recordTypeIdMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId(); 
        if (o.RecordTypeId != recordTypeIdMembership) {
            String status = 'Respondida (op abierta)'; 
            if (o.IsClosed) {
                status = 'Respondida (cerrada)'; 
            }
            o.npsp__Primary_Contact_Campaign_Member_Status__c = status; 
        }
    }
    
    private void setNameOpp(Opportunity o, Map<String,Schema.RecordTypeInfo> mOppRtInfo, Map<Id,Schema.RecordTypeInfo> mOppRtInfoById){
        
        if(o.RecordTypeId == mOppRtInfo.get('Donation').getRecordTypeId()){
            if(o.Type == 'Recurrent Donation'){
                String month = String.valueOf(o.CloseDate.month());
                if(month.length()==1){
                    month = '0'+month;
                }
                o.name = o.Type + ' - ' + month + '-' + o.CloseDate.year();
            }else{
                o.name = o.Type;                
            }
        }else if(o.RecordTypeId == mOppRtInfo.get('Historical').getRecordTypeId()){
            o.name = 'S- Historical Donation '+ o.CloseDate.year();   
        }else{
            if(o.RecordTypeId == mOppRtInfo.get('Legacy').getRecordTypeId()){
                o.name = o.Type;
            }
            else{
                o.name = mOppRtInfoById.get(o.RecordTypeId).getName();
            }                       
        }
        
        o.name = o.name.replace('Ñ','N');
        o.name = o.name.replace('ñ','n');
        o.name = o.name.replace('Ç','C');
        o.name = o.name.replace('ç','c');        
    }
    
    private Contact setContactFields (Opportunity o, Contact c, Map<Id, Contact> memberTypeContacts){    	
        Boolean updateContact = false; 
        
        if(c.msf_BeginDateMSF__c == null || c.msf_BeginDateMSF__c > o.msf_EntryDate__c){
            if (c.msf_BeginDateMSF__c != o.msf_EntryDate__c) { c.msf_BeginDateMSF__c = o.msf_EntryDate__c; 	updateContact = true;}
            if (c.msf_EntryCampaign__c != o.CampaignId) 	 { c.msf_EntryCampaign__c = o.CampaignId; 		updateContact = true; }
            if(o.IsWon){
                if (c.msf_FirstCampaingColaboration__c != o.CampaignId) { c.msf_FirstCampaingColaboration__c = o.CampaignId; updateContact = true; }
                if (c.msf_FirstCampaignColaborationChannel__c != o.LeadSource) { c.msf_FirstCampaignColaborationChannel__c = o.LeadSource; updateContact = true;}                
            }
        }
        
        if(c.msf_FirstCampaingColaboration__c == null && o.IsWon){
            if (c.msf_FirstCampaingColaboration__c != o.CampaignId) 		{ c.msf_FirstCampaingColaboration__c = o.CampaignId; updateContact = true;}
            if (c.msf_FirstCampaignColaborationChannel__c != o.LeadSource) 	{ c.msf_FirstCampaignColaborationChannel__c = o.LeadSource;updateContact = true; }
        }
        
        if(o.msf_TypeFundraisingContribution__c == 'D' && o.IsWon){
            if(c.msf_DateFirstDonation__c == null || c.msf_DateFirstDonation__c > o.msf_EntryDate__c){
                if (c.msf_DateFirstDonation__c != o.CloseDate) { c.msf_DateFirstDonation__c = o.CloseDate; updateContact = true; }    
            }
            if(c.msf_DateLastDonation__c == null || c.msf_DateLastDonation__c < o.msf_EntryDate__c){
                if (c.msf_DateLastDonation__c != o.CloseDate) { c.msf_DateLastDonation__c = o.CloseDate; updateContact = true; }       
            }
        }         
        
        //Contacto fallecido; 
        if (o.msf_LastReasonCodeReceived__c != null && o.msf_LastReasonCodeReceived__c == 'MD07' 
            && c.npsp__Deceased__c == false && c.msf_ContactDeleteReason__c != 'Deceased') {
                c.npsp__Deceased__c = true; 
                c.msf_ContactDeleteReason__c = 'Deceased'; 
                updateContact = true; 
            }
                
        
        if(memberTypeContacts.containsKey(c.Id)){
            Contact mC = memberTypeContacts.get(c.Id);
            
            if (c.msf_MemberType__c != mC.msf_MemberType__c) 		{ c.msf_MemberType__c = mC.msf_MemberType__c; updateContact = true; }
            if (c.msf_IsActiveDonor__c != mC.msf_IsActiveDonor__c)  { c.msf_IsActiveDonor__c = mC.msf_IsActiveDonor__c; updateContact = true; }
            if (c.msf_IsActiveRecurringDonor__c != mC.msf_IsActiveRecurringDonor__c) { c.msf_IsActiveRecurringDonor__c = mC.msf_IsActiveRecurringDonor__c; updateContact = true; }
        }
         
        if (updateContact) {
            return c;    
        }
        else {
            return null; 
        }
        
    }
    
    private void setAccount (Opportunity o, Map<Id,Contact> mConAccount, Set<ID> sContacts){        
        if(o.npsp__Primary_Contact__c != null && !sContacts.isEmpty() && !mConAccount.isEmpty() && sContacts.contains(o.npsp__Primary_Contact__c)){
            o.AccountId = mConAccount.get(o.npsp__Primary_Contact__c).AccountId;   
        }
    }
    
    private void setOppFields (Opportunity o, Map<Id,Contact> mContAux, Set<ID> sContacts){
        if(o.npsp__Primary_Contact__c != null && !sContacts.isEmpty() && !mContAux.isEmpty() && sContacts.contains(o.npsp__Primary_Contact__c)){
            o.msf_Program__c = mContAux.get(o.npsp__Primary_Contact__c).msf_Program__c;
            o.msf_MailingSegment__c = mContAux.get(o.npsp__Primary_Contact__c).msf_MailingSegment__c;
        } 
    }
    
    private void setRating (Opportunity o, Map<Id,Contact> mCont){
        if(!mCont.isEmpty() && o.npsp__Primary_Contact__c != null){
            Contact tempC = mCont.get(o.npsp__Primary_Contact__c);            
            
            o.msf_Rating__c = 'Frio';
            if (tempC.msf_BeginDateMSF__c != null){
                if(o.msf_EntryDate__c <= tempC.msf_BeginDateMSF__c.addDays(20)){
                    o.msf_Rating__c = 'Frio';
                }
                else if(tempC.Opportunities != null && tempC.Opportunities.isEmpty() && o.msf_EntryDate__c > tempC.msf_BeginDateMSF__c.addDays(20)){
                    o.msf_Rating__c = 'Templado';
                }
                else if(tempC.Opportunities != null && !tempC.Opportunities.isEmpty()){
                    o.msf_Rating__c = 'Caliente';
                }
            }
        }
    }
    
    private List<cpm__Installment__c> getInstallments (Set<ID> sOppIds){
        List<cpm__Installment__c> updateInstallments = new List<cpm__Installment__c>();
        
        for(cpm__Installment__c ins : [SELECT Id FROM cpm__Installment__c WHERE npsp4hub__Opportunity__c IN: sOppIds]){
            ins.cpm__Status__c = 'Pending recollection';
            updateInstallments.add(ins);	    
        }        
        
        return updateInstallments;
    }
    
    private void setCampaigns (Opportunity o){
        if(o.CampaignId != null){
            if(o.msf_ModificationCampaign__c == null){
                o.msf_ModificationCampaign__c = o.CampaignId;
            }
            if(o.msf_CurrentCampaign__c == null){
                o.msf_CurrentCampaign__c = o.CampaignId;
            }
        } 
    }
    
    private void setLeadSource (Opportunity o){
        if(o.LeadSource != null){
            if(o.msf_CurrentLeadSource1__c == null){
                o.msf_CurrentLeadSource1__c = o.LeadSource;
                o.msf_CurrentLeadSource2__c = o.msf_LeadSource2Level__c;
                o.msf_CurrentLeadSource3__c = o.msf_LeadSource3Level__c;
            }
        } 
    }
	
	/*******************************************************************************************************
    * @description 	Close all the recurring donations for Impago
    * @param 		lIdsRecurringDonations Recurring Donations to Close for Impago -> Baja Socio						
    ********************************************************************************************************/
/*    
    @future
    private static void closeImpagoRecurringDonations(Set<ID> lIdsRecurringDonations){
		
		List<npe03__Recurring_Donation__c> lRecurringDonationsToUpdate = [SELECT Id,npe03__Open_Ended_Status__c, msf_CancelationReason__c 
                                               FROM npe03__Recurring_Donation__c WHERE Id IN :lIdsRecurringDonations];
		if (lRecurringDonationsToUpdate.isEmpty() == false) {
			for (npe03__Recurring_Donation__c rC : lRecurringDonationsToUpdate) {
				rC.npe03__Open_Ended_Status__c = 'Closed'; 
				rC.msf_CancelationReason__c = 'Unpaid'; 
			}
			Savepoint sp = Database.setSavepoint();
        
			try{
                system.debug('--ENTER closeImpagoRecurringDonations--');
				update lRecurringDonationsToUpdate;
                system.debug('--FIN closeImpagoRecurringDonations--');
			}catch(DMLException dmlEx){
                system.debug('--ERROR1 closeImpagoRecurringDonations--');
				Database.rollback(sp);
                system.debug(dmlEx);
			}catch(Exception ex){
                system.debug('--ERROR2 closeImpagoRecurringDonations--');
				Database.rollback(sp);
				system.debug(ex);
			}
		}
		
		//dmlWrapper.objectsToUpdate.addAll((List<npe03__Recurring_Donation__c>) lRecurringDonationsToUpdate);
		
    }
*/
    
}