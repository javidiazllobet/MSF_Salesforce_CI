/**
* @author 		Deloitte
* @date 		11-2018
* @group 		Recurring donation.
* @description	Logic of some fields and the change of quota.
*/
global without sharing class MSF_RecurringDonation_TDTM extends npsp.TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description	Trigger Handler on Recurring Donations that handles the logic of some fields and the 
    * 				change of quota. 
    * @param 		listNew the list of Recurring Donations from trigger new. 
    * @param 		listOld the list of Recurring Donations from trigger old. 
    * @param 		triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param 		objResult the describe for Recurring Donations 
    * @return 		dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
    	
        //Attributes
        List<npe03__Recurring_Donation__c> lNewRD = (List<npe03__Recurring_Donation__c>) newlist;
        List<npe03__Recurring_Donation__c> lOldRD = (List<npe03__Recurring_Donation__c>) oldlist;
        Map<Id, npe03__Recurring_Donation__c> mOldRD = new Map<Id, npe03__Recurring_Donation__c>();
        if(lOldRD != null){            
            mOldRD.putAll(lOldRD);
        }

        List<Contact> lContactsToUpdate = new List<Contact>();
        List<msf_QuotaModification__c> lModificationQuotasToInsert = new List<msf_QuotaModification__c>();
        
        Map<String,Schema.RecordTypeInfo> mRdRtInfo = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName(); 
        ID rtRD = mRdRtInfo.get('Recurring_donation').getRecordTypeId();
        
        Set<ID> sContactIds = new Set<ID>();   
        
        //Actions
        if(triggerAction != npsp.TDTM_Runnable.Action.AfterDelete){
            for(npe03__Recurring_Donation__c rd : lNewRD){
                if(rd.npe03__Contact__c != null){
                    sContactIds.add(rd.npe03__Contact__c);    
                }
            }
        }
                  
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert){
        	//allowNewRD(lNewRD, sContactIds, rtRD);	  
        }       
        
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {	            
            
            MSF_SharedMethods_UTIL smUtil = new MSF_SharedMethods_UTIL();            
            Map<String, msf_LeadSourceMasterData__c> mLeadSourceValues = smUtil.getLeadSourceDependencies();
            
            for(npe03__Recurring_Donation__c rd : lNewRD){                
                setCurrentCampaign(rd);
                setCurrentLeadSource(rd);
            	setLeadSourceDependencies(rd, mLeadSourceValues);          
            }
        }
        
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate){            
            for(npe03__Recurring_Donation__c rd : lNewRD){
                if(rd.npe03__Open_Ended_Status__c != mOldRD.get(rd.Id).npe03__Open_Ended_Status__c){
                    if(rd.npe03__Open_Ended_Status__c == 'Closed'){
                        rd.msf_CancelationDate__c = Date.today();     
                    }else{
                        rd.msf_CancelationDate__c = null;
                        rd.msf_CancelationReason__c = null;
                    }                    
                }                
                setRdName(rd, mRdRtInfo, mOldRD.isEmpty());
            }            
        }
                 
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {	  
            List<Contact> lc = new List<Contact>();  
            
            if(!sContactIds.isEmpty()){
                lc = setContactFields(lNewRD, sContactIds);
                //if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
                List<Contact> tempContacts = new List<Contact>();
                tempContacts = MSF_SharedMethods_UTIL.contactMemberType(lc);
                
                Map<Id,Contact> tempMap = new Map<Id,Contact>(tempContacts);
                
                for(Contact c : lc){
                    if(tempMap.containsKey(c.Id)){
                        c.msf_MemberType__c = tempMap.get(c.Id).msf_MemberType__c ;
                        c.msf_IsActiveDonor__c = tempMap.get(c.Id).msf_IsActiveDonor__c ;
                        c.msf_IsActiveRecurringDonor__c = tempMap.get(c.Id).msf_IsActiveRecurringDonor__c ;
                    }
                }                
                //}
                
                if(lc != null && !lc.isEmpty()){
                    lContactsToUpdate.addAll(lc);
                } 
            }

            List<msf_QuotaModification__c> lqm = createQuotaModification(lNewRD, mOldRD);
            if(lqm != null && !lqm.isEmpty()){
            	lModificationQuotasToInsert.addAll(lqm);             
            } 
        }
                
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete){
            for(npe03__Recurring_Donation__c rd : lOldRD){
                if(rd.npe03__Contact__c != null){
                    lContactsToUpdate.add(new Contact(Id=rd.npe03__Contact__c,msf_RecalculateMemberType__c=TRUE));
                }
            }   
        }
        
        //DML Operations
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToUpdate.addAll((List<Contact>)lContactsToUpdate);
        dmlWrapper.objectsToInsert.addAll((List<msf_QuotaModification__c>)lModificationQuotasToInsert);
        
        if(lContactsToUpdate.isEmpty() && lModificationQuotasToInsert.isEmpty()){
            return null;
        }
        
        return dmlWrapper;
    }
    
    // PRIVATE METHODS
    
    /*******************************************************************************************************
    * @description	Set the values in the 'LeadSource2; LeadSource3' fields in lead depending of the value 
    * 				of the 'LeadSource1' field.
    * @param 		rd is the Recurrent Donation to update the Name. 
    * @param 		mRdRtInfo is a map that contains information of recurrent donations record types.
    ********************************************************************************************************/
    private void setRdName(npe03__Recurring_Donation__c rd, Map<String,Schema.RecordTypeInfo> mRdRtInfo, Boolean isNew){
        String sDate = '';
        Integer day = Date.today().day(); 
        Integer month = Date.today().month();
        Integer year = Date.today().year(); 
                
        if(!isNew) {
            day = rd.createdDate.day();
            month = rd.createdDate.month();
            year = rd.createdDate.year();
        }
        
        String sDay = String.valueOf(day);
		String sMonth = String.valueOf(month); 
        
        if (day < 10) { sDay = '0' + sDay; }
        if (month < 10) { sMonth = '0' + sMonth; }
        
        sDate = '_' + sDay + '-' + sMonth + '-' + String.valueOf(year);
        
        if(rd.RecordTypeId == mRdRtInfo.get('Recurring_donation').getRecordTypeId()){
        	rd.Name = 'Cuota'+sDate;   
        }else if(rd.RecordTypeId == mRdRtInfo.get('Associate').getRecordTypeId()){
          	rd.Name = 'Cuota de asociado'+sDate;    
        }        
    }
    
	/*******************************************************************************************************
    * @description	Set the values in the 'LeadSource2; LeadSource3' fields in lead depending of the value 
    * 				of the 'LeadSource1' field.
    * @param 		rd is the Recurrent Donation to update its fields. 
    * @param 		mLsValues is a map that contains values for fields 'LeadSource2; LeadSource3'
    ********************************************************************************************************/
    private void setLeadSourceDependencies(npe03__Recurring_Donation__c rd, Map<String, msf_LeadSourceMasterData__c> mLsValues){
        if(mLsValues.containsKey(rd.msf_LeadSource1__c)){
            rd.msf_LeadSource2__c = mLsValues.get(rd.msf_LeadSource1__c).msf_LeadSource2__c;
            rd.msf_LeadSource3__c = mLsValues.get(rd.msf_LeadSource1__c).msf_LeadSource3__c;
        }
        if(mLsValues.containsKey(rd.msf_CurrentLeadSource1__c)){
            rd.msf_CurrentLeadSource2__c = mLsValues.get(rd.msf_CurrentLeadSource1__c).msf_LeadSource2__c;
            rd.msf_CurrentLeadSource3__c = mLsValues.get(rd.msf_CurrentLeadSource1__c).msf_LeadSource3__c;
        }
    }
    
    /*******************************************************************************************************
    * @description	
    * @param 		 
    ********************************************************************************************************/
    private void setCurrentCampaign(npe03__Recurring_Donation__c rd){
        if(rd.npe03__Recurring_Donation_Campaign__c != null && rd.msf_CurrentCampaign__c == null){
        	rd.msf_CurrentCampaign__c = rd.npe03__Recurring_Donation_Campaign__c;   
        }
    }
    
    /*******************************************************************************************************
    * @description	
    * @param 		 
    ********************************************************************************************************/
    private void setCurrentLeadSource(npe03__Recurring_Donation__c rd){
        if(rd.msf_LeadSource1__c != null && rd.msf_CurrentLeadSource1__c == null){
        	rd.msf_CurrentLeadSource1__c = rd.msf_LeadSource1__c;   
        }
    }
    
	/*******************************************************************************************************
    * @description	
    * @param 		
    * @param 	
    * @return	
    ********************************************************************************************************/
    private List<Contact> setContactFields(List<npe03__Recurring_Donation__c> lRD, Set<ID> sCon){

        List<Contact> lReturnContacts = new List<Contact>();
        Map<ID,Contact> mCon = new Map<ID,Contact>();
        mCon.putAll( [SELECT Id, 
                      msf_BeginDateMSF__c,
                      msf_FirstEntryDateRecurringDonor__c,
                      msf_EntryDateCurrentRecurringDonor__c,
                      msf_LastRecurringDonationDate__c,
                      msf_DateFirstRecurringDonorQuota__c,
                      msf_DateLastRecurringDonorQuota__c,
                      msf_LastAnnualizedQuota__c,
                      msf_FirstAnnualizedQuota__c, 
                      msf_FirstCampaignEntryRecurringDonor__c,
                      msf_FirstCampaignRecurringDonorChannel__c,
                      msf_ValueRecurringDonorCont__c, 
                      npsp__Deceased__c,
                      (SELECT id, msf_AnnualizedQuota__c FROM R00N80000002bOmREAU__r WHERE npe03__Open_Ended_Status__c = 'Open' AND RecordType.DeveloperName = 'Recurring_donation')
                      FROM Contact WHERE ID IN: sCon]);
        
        if(!mCon.isEmpty()){            
            for(npe03__Recurring_Donation__c rd : lRD){
                if(mCon.containskey(rd.npe03__Contact__c)){
                	Contact tempC = mCon.get(rd.npe03__Contact__c);  
                    Decimal iAnnualizedQuota = 0;

                    if(!tempC.R00N80000002bOmREAU__r.isEmpty()){
                        for(npe03__Recurring_Donation__c cRD : tempC.R00N80000002bOmREAU__r){
                        	iAnnualizedQuota += cRD.msf_AnnualizedQuota__c;    
                        }   
                    }
         
                    if(rd.npe03__Open_Ended_Status__c == 'Open'){
                        if(tempC.msf_BeginDateMSF__c == null || tempC.msf_BeginDateMSF__c > rd.npe03__Date_Established__c){
                            tempC.msf_BeginDateMSF__c = rd.npe03__Date_Established__c; 
                            tempC.msf_EntryCampaign__c = rd.npe03__Recurring_Donation_Campaign__c;
                        } 
                        if(tempC.msf_FirstEntryDateRecurringDonor__c == null || tempC.msf_FirstEntryDateRecurringDonor__c > rd.npe03__Date_Established__c){
                            tempC.msf_FirstEntryDateRecurringDonor__c = rd.npe03__Date_Established__c;
                            tempC.msf_FirstAnnualizedQuota__c = iAnnualizedQuota;
                            tempC.msf_FirstCampaignEntryRecurringDonor__c = rd.npe03__Recurring_Donation_Campaign__c;
                            tempC.msf_FirstCampaignRecurringDonorChannel__c = rd.msf_LeadSource1__c;
                        }  
                        if(tempC.msf_EntryDateCurrentRecurringDonor__c == null || tempC.msf_EntryDateCurrentRecurringDonor__c < rd.npe03__Date_Established__c){
                            tempC.msf_EntryDateCurrentRecurringDonor__c = rd.npe03__Date_Established__c;
                        }
                        if(tempC.msf_DateFirstRecurringDonorQuota__c == null || tempC.msf_DateFirstRecurringDonorQuota__c > rd.npe03__Last_Payment_Date__c){
                            tempC.msf_DateFirstRecurringDonorQuota__c = rd.npe03__Last_Payment_Date__c;
                        }
                        if(tempC.msf_DateLastRecurringDonorQuota__c == null || tempC.msf_DateLastRecurringDonorQuota__c < rd.npe03__Last_Payment_Date__c){
                            tempC.msf_DateLastRecurringDonorQuota__c = rd.npe03__Last_Payment_Date__c;
                        }
                        tempC.msf_LastAnnualizedQuota__c = iAnnualizedQuota;
                        tempC.msf_ValueRecurringDonorCont__c = iAnnualizedQuota;
                    }else if(rd.npe03__Open_Ended_Status__c == 'Closed' ){
                        if(tempC.msf_LastRecurringDonationDate__c == null || tempC.msf_LastRecurringDonationDate__c < rd.msf_CancelationDate__c){
                            tempC.msf_LastRecurringDonationDate__c = rd.msf_CancelationDate__c;
                        }  
                        tempC.msf_ValueRecurringDonorCont__c = iAnnualizedQuota;
                        if(iAnnualizedQuota !=0){
                            tempC.msf_LastAnnualizedQuota__c = iAnnualizedQuota;
                        }
                    }
                    
                    if(tempC.msf_FirstAnnualizedQuota__c == null){
                        tempC.msf_FirstAnnualizedQuota__c = iAnnualizedQuota;
                    } 
                    
                    if(tempC.msf_FirstCampaignEntryRecurringDonor__c == null){
                        tempC.msf_FirstCampaignEntryRecurringDonor__c = rd.npe03__Recurring_Donation_Campaign__c;
                        tempC.msf_FirstCampaignRecurringDonorChannel__c = rd.msf_LeadSource1__c;
                    }        
                    
                    if(rd.msf_CancelationReason__c == 'Deceased' && !tempC.npsp__Deceased__c){
                        tempC.npsp__Deceased__c = true;
                        tempC.msf_ContactDeleteReason__c = rd.MSF_CancelationReason__c;
                    }
                    
                    lReturnContacts.add(tempC);
                }
            }        
            
            if(!lReturnContacts.isEmpty()){
            	return lReturnContacts;    
            }            
        }
        
        return null;        
    }
    
    /*******************************************************************************************************
    * @description	
    * @param 		
    * @param 
    * @param
    * @return		
    ********************************************************************************************************/
    private List<msf_QuotaModification__c> createQuotaModification(List<npe03__Recurring_Donation__c> lNewRD, Map<Id,npe03__Recurring_Donation__c> mOldRD){
        
        Boolean isInsert = mOldRD.isEmpty();
        
        List<msf_QuotaModification__c> lNewQM = new List<msf_QuotaModification__c>();
        
        for(npe03__Recurring_Donation__c rd : lNewRD){
            
            if(rd.npe03__Open_Ended_Status__c != 'Closed'){
                
                Datetime dt = Datetime.now();
                Long l = dt.getTime();                
                
                msf_QuotaModification__c tempQM = new msf_QuotaModification__c();
                tempQM.msf_RecurringDonation__c = rd.Id;
                tempQM.msf_CampaignInfluence__c = rd.msf_CurrentCampaign__c;
                tempQM.msf_NewAmount__c = rd.npe03__Amount__c;	
                tempQM.msf_NewRecurringPeriod__c = rd.npe03__Installment_Period__c;	
                tempQM.msf_NewAnnualizedQuota__c = rd.msf_AnnualizedQuota__c;  
                tempQM.msf_LeadSource1__c = rd.msf_CurrentLeadSource1__c;
                tempQM.msf_Canvasser__c = rd.msf_Canvasser__c;
                tempQM.msf_CityCanvasser__c = rd.msf_CityCanvasser__c;
                tempQM.msf_PlaceCanvasser__c = rd.msf_PlaceCanvasser__c;
                tempQM.msf_ContactId__c = rd.npe03__Contact__c;
                
                if(isInsert){
                    tempQM.Name = ('I - '+l);
                    tempQM.msf_ChangeType__c = 'Initial';                    
                    tempQM.msf_ChangeAmount__c = rd.npe03__Amount__c;
                    tempQM.msf_ChangeAnnualizedQuota__c = rd.msf_AnnualizedQuota__c;                    
                    
                    lNewQM.add(tempQM);
                }else{
                    npe03__Recurring_Donation__c oldRD = mOldRD.get(rd.Id);      
                    
                    if(rd.msf_AnnualizedQuota__c != oldRD.msf_AnnualizedQuota__c){                        
                        
                        if(rd.msf_AnnualizedQuota__c > oldRD.msf_AnnualizedQuota__c){
                            tempQM.Name = ('A - '+l);
                            tempQM.msf_ChangeType__c = 'Increase';
                            tempQM.msf_ChangeAnnualizedQuota__c = rd.msf_AnnualizedQuota__c - oldRD.msf_AnnualizedQuota__c;  
                        }else{
                            tempQM.Name = ('D - '+l);
                            tempQM.msf_ChangeType__c = 'Decrease'; 
                            tempQM.msf_ChangeAnnualizedQuota__c = oldRD.msf_AnnualizedQuota__c - rd.msf_AnnualizedQuota__c;  
                        }
                        
                        if(rd.npe03__Amount__c > oldRD.npe03__Amount__c){
                        	tempQM.msf_ChangeAmount__c = rd.npe03__Amount__c - oldRD.npe03__Amount__c;    
                        }else{
                        	tempQM.msf_ChangeAmount__c = oldRD.npe03__Amount__c - rd.npe03__Amount__c;    
                        }
                        
                        lNewQM.add(tempQM);
                    }              
                }                 
            }              
        }       
        
        return lNewQM;        
    }
    
    /*******************************************************************************************************
    * @description	
    * @param 		
    * @param
    * @param 		
    ********************************************************************************************************/
    /*private void allowNewRD (List<npe03__Recurring_Donation__c> lNewRD, Set<ID> sCon, Id idRTQuota){
    	Set<ID> sConWithRD = new Set<ID>();
        
        for(npe03__Recurring_Donation__c rd : [SELECT npe03__Contact__c 
                                               FROM npe03__Recurring_Donation__c 
                                               WHERE npe03__Contact__c IN: sCon 
                                               AND npe03__Open_Ended_Status__c = 'Open' 
                                               AND RecordTypeId =: idRTQuota])
        {
            sConWithRD.add(rd.npe03__Contact__c);
        }
        
        for(npe03__Recurring_Donation__c rd : lNewRD){
            if(sConWithRD.contains(rd.npe03__Contact__c)){
            	rd.addError(System.Label.MSF_RD_ERROR_NEW_OPEN);    
            }
        }
    }*/

}