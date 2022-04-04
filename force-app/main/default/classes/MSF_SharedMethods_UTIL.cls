/**
* @author       Deloitte
* @date         02-2019
* @group        SObjects.
* @description  This class contains methods that can be used for different SObjects.
*/
public without sharing class MSF_SharedMethods_UTIL {

    
    public static List<Contact> contactMemberType(List<Contact> contacts) {
        List<Contact> lCon = new List<Contact>();
        
        Set<ID> sConWithRDOpen = new Set<ID>();        
        Set<ID> sConWithRDClose = new Set<ID>();
        Set<ID> sConWithoutRD = new Set<ID>();
        
        Set<ID> sConWithDonationLastYear = new Set<ID>();
        Set<ID> sConWithDonationBeforeLastYear = new Set<ID>();
        Set<ID> sConWithDonationSMS = new Set<ID>();
        Set<ID> sConWithoutDonation = new Set<ID>();
        
        for(Contact s : contacts){  
            sConWithoutRD.add(s.Id);
            sConWithoutDonation.add(s.Id);
        } 
        
        //Check recurring donations
        for(npe03__Recurring_Donation__c rd : [SELECT npe03__Contact__c 
                                               FROM npe03__Recurring_Donation__c 
                                               WHERE npe03__Contact__c IN: sConWithoutRD 
                                               AND npe03__Open_Ended_Status__c = 'Open' 
                                               AND RecordType.DeveloperName = 'Recurring_donation'])
        {
            sConWithRDOpen.add(rd.npe03__Contact__c);
        }
        sConWithoutRD.removeAll(sConWithRDOpen);
        
        for(npe03__Recurring_Donation__c rd : [SELECT npe03__Contact__c 
                                               FROM npe03__Recurring_Donation__c 
                                               WHERE npe03__Contact__c IN: sConWithoutRD 
                                               AND npe03__Open_Ended_Status__c = 'Closed' 
                                               AND RecordType.DeveloperName = 'Recurring_donation'])
        {
            sConWithRDClose.add(rd.npe03__Contact__c);
        }        
        sConWithoutRD.removeAll(sConWithRDClose);
        
        //Check donations
        for(Contact con : [SELECT Id, Name, (SELECT Id, CloseDate, msf_TypeFundraisingContribution__c, StageName 
                                       FROM Opportunities 
                                       WHERE msf_TypeFundraisingContribution__c IN ('D','G','I')
                                       AND Type != 'SMS Donor'
                                       AND (
                                           (CloseDate = LAST_N_DAYS:365 AND IsWon = true) 
                                           OR 
                                           (StageName = 'Puesta al cobro' AND CreatedDate = LAST_N_DAYS:365)
                                       )
                                       ORDER BY CloseDate DESC
                                       LIMIT 1) 
                           FROM Contact 
                           WHERE Id IN: sConWithoutDonation])
        {
            if(con.Opportunities != null && !con.Opportunities.isEmpty()){
                con.msf_NextMemberTypeCheck__c = con.Opportunities[0].CloseDate.addYears(1);
                lCon.add(con);
                sConWithDonationLastYear.add(con.Id);    
            }
        }
        sConWithoutDonation.removeAll(sConWithDonationLastYear); 
        
        for(Contact con : [SELECT Id, (SELECT Id 
                                       FROM Opportunities 
                                       WHERE msf_TypeFundraisingContribution__c IN ('D','G','I') 
                                       AND Type != 'SMS Donor'
                                       AND (
                                           (CloseDate < LAST_N_DAYS:365 AND IsWon = true) 
                                           OR 
                                           (StageName = 'Puesta al cobro' AND CreatedDate < LAST_N_DAYS:365)
                                       )
                                       LIMIT 1) 
                           FROM Contact 
                           WHERE Id IN: sConWithoutDonation])
        {
            con.msf_NextMemberTypeCheck__c = date.today().addYears(1);
            lCon.add(con);
            if(con.Opportunities != null && !con.Opportunities.isEmpty()){
                sConWithDonationBeforeLastYear.add(con.Id);    
            }
        }
        sConWithoutDonation.removeAll(sConWithDonationBeforeLastYear); 
        
        for(Contact con : [SELECT Id, (SELECT Id
                                       FROM Opportunities 
                                       WHERE msf_TypeFundraisingContribution__c IN ('D','G','I') 
                                       AND Type = 'SMS Donor'
                                       LIMIT 1) 
                           FROM Contact 
                           WHERE Id IN: sConWithoutDonation])
        {
            if(con.Opportunities != null && !con.Opportunities.isEmpty()){
                sConWithDonationSMS.add(con.Id);    
            }
        }

        //Define type of member
        for(Contact con : lCon){
            
            if(sConWithRDOpen.contains(con.Id)){
                con.msf_IsActiveRecurringDonor__c = 'Socio';
                
                if(sConWithDonationLastYear.contains(con.Id)){
                    con.msf_MemberType__c = 'Socio + Donante';
                    con.msf_IsActiveDonor__c = 'Donante';
                }   
                else if(sConWithDonationBeforeLastYear.contains(con.Id)){
                    con.msf_MemberType__c = 'Socio + Exdonante';
                    con.msf_IsActiveDonor__c = 'Exdonante';
                }
                else if(sConWithoutDonation.contains(con.Id)){
                    con.msf_MemberType__c = 'Socio';
                    con.msf_IsActiveDonor__c = 'Nunca';
                } 
            }   
            else if(sConWithRDClose.contains(con.Id)){
                con.msf_IsActiveRecurringDonor__c = 'Baja';
                
                if(sConWithDonationLastYear.contains(con.Id)){
                    con.msf_MemberType__c = 'Baja + Donante';
                    con.msf_IsActiveDonor__c = 'Donante';
                }   
                else if(sConWithDonationBeforeLastYear.contains(con.Id)){
                    con.msf_MemberType__c = 'Baja + Exdonante';
                    con.msf_IsActiveDonor__c = 'Exdonante';
                }
                else if(sConWithoutDonation.contains(con.Id)){
                    con.msf_MemberType__c = 'Baja';
                    con.msf_IsActiveDonor__c = 'Nunca';
                }    
            }
            else if(sConWithoutRD.contains(con.Id)){
                con.msf_IsActiveRecurringDonor__c = 'Nunca';
                
                if(sConWithDonationLastYear.contains(con.Id)){
                    con.msf_MemberType__c = 'Donante';
                    con.msf_IsActiveDonor__c = 'Donante';
                }   
                else if(sConWithDonationBeforeLastYear.contains(con.Id)){
                    con.msf_MemberType__c = 'Exdonante';
                    con.msf_IsActiveDonor__c = 'Exdonante';
                }
                else if(sConWithDonationSMS.contains(con.Id)){
                    con.msf_MemberType__c = 'Nada (Donante SMS)';
                    con.msf_IsActiveDonor__c = 'Nunca';
                }
                else if(sConWithoutDonation.contains(con.Id)){
                    con.msf_MemberType__c = 'Nada';
                    con.msf_IsActiveDonor__c = 'Nunca';
                } 
            }
            
            con.msf_RecalculateMemberType__c = FALSE;
            con.msf_RecalculateLevel__c = TRUE;
        }
        
        
        return lCon; 
    }
    
    
    /*******************************************************************************************************
    * @description 	Returns a series of attributes in a map based on the value selected in the 'lead source' 
    * 				field of different objects.
    * @param 		sLeadSourceLevelOne is the value selected on LeadSource1 field.        
    * @return	 	Map<String, String> has the values recovered.        
    ********************************************************************************************************/
    public Map<String,String> getLeadSourceDependence(String sLeadSourceLevelOne){
    	
        Map<String,String> mReturnValues = new Map<String,String>();
        mReturnValues.put('LS2',null);
        mReturnValues.put('LS3',null);
        
        if(String.isNotBlank(sLeadSourceLevelOne)){
            List<msf_LeadSourceMasterData__c> lLsmd = [SELECT msf_LeadSource2__c, msf_LeadSource3__c FROM msf_LeadSourceMasterData__c WHERE msf_LeadSource1__c =: sLeadSourceLevelOne LIMIT 1];    
            if(!lLsmd.isEmpty()){
                mReturnValues.put('LS2',lLsmd[0].msf_LeadSource2__c);
                mReturnValues.put('LS3',lLsmd[0].msf_LeadSource3__c);   
            }
        }        
            
        return mReturnValues;
    }
    
    /*******************************************************************************************************
    * @description 	Returns a map that contains all the records of the msf_LeadSourceMasterData__c object 
    * 				with the value of the msf_leadsource1__c field as the key.     
    * @return	 	Map<String, String> has the values recovered.        
    ********************************************************************************************************/
    public Map<String,msf_LeadSourceMasterData__c> getLeadSourceDependencies(){
        
        Map<String,msf_LeadSourceMasterData__c> mReturnValues = new Map<String,msf_LeadSourceMasterData__c>();        
        
        for(msf_LeadSourceMasterData__c lsmd : [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c FROM msf_LeadSourceMasterData__c ]){              
            mReturnValues.put(lsmd.msf_LeadSource1__c,lsmd);                      
        }
        
        return mReturnValues;
    }
    
    /*******************************************************************************************************
    * @description 	Create a new record of the msf_GDPRLog__c object.
    * @param		o sobject with the new values 		
    * @param		oOld sObject with the old values
    * @param		UserId is a ID of the User object
    * @param		ContactId is a ID of the Contact object
    * @param		PayProfId is a ID of the payment profile objetct
    * @param		isInsert boolean that indicate if the param o is new
    * @param		isDelete boolean that indicate if the param o is delete
    * @param		sFields list of fields to check differences
    * @param		mFields contains the description of fields of a sObject
    * @return 		msf_GDPRLog__c to create
    ********************************************************************************************************/
    public msf_GDPRLog__c createLog (sObject o, sObject oOld, Id UserId, Id ContactId, Id PayProfId, Boolean isInsert, Boolean isDelete, Set<String> sFields, Map<String,Schema.sObjectField> mFields){
        
        Boolean isContact = false;
        String changes = '';
        
        if(isInsert){
         	changes = System.Label.MSF_GDPR_INITIAL_RECORD; 
        }else if(isDelete){
            changes = System.Label.MSF_GDPR_DELETED_RECORD; 
        }else{
         	changes = getChangedFields(o, oOld, sFields, mFields);	
            if(String.isBlank(changes)){
                return null;
            }
        }
        
        String sRecordName = '';
        if(ContactId != null && Schema.Contact.SObjectType == Id.valueOf(String.valueOf(o.get('Id'))).getSobjectType()){            
            if(String.isNotBlank(String.valueOf(o.get('FirstName')))){
                sRecordName = String.valueOf(o.get('FirstName')); 
            }           
            sRecordName += String.isNotBlank(sRecordName) ? (' ' + String.valueOf(o.get('LastName'))) : String.valueOf(o.get('LastName'));            
            if(String.isNotBlank(String.valueOf(o.get('Suffix')))){
            	sRecordName += (' ' + String.valueOf(o.get('Suffix')));    
            }
            isContact = true;
        }else{
        	sRecordName = String.valueOf(o.get('Name'));
        }
        
        msf_GDPRLog__c tempLog = new msf_GDPRLog__c(
        	msf_Object__c = String.valueOf(o.getSObjectType().getDescribe().getLabel()),
            msf_RecordId__c = String.valueOf(o.get('Id')),
            msf_CRMExternalId__c = isContact ? String.valueOf(o.get('msf_CRMExternalId__c')) : String.valueOf(o.get('msf_MemberId__c')), 
            msf_RecordName__c = sRecordName,
			msf_ModificationChannel__c = String.valueOf(o.get('msf_LastModificationChannel__c')),             
            msf_User__c = UserId, 
            msf_ModificationDate__c = Datetime.now(), 
            msf_Contact__c = ((isDelete && PayProfId != null) || !isDelete ) ? ContactId : null,
            msf_PaymentProfile__c = !isDelete ? PayProfId : null,
            msf_Modifications__c = changes
        );
        
        return tempLog;
    }
    
    /*******************************************************************************************************
    * @description 	Create a String with all the values updated in a record
    * @param		oNew sobject with the new values 		
    * @param		oOld sObject with the old values
    * @param		sFields list of fields to check differences
    * @param		mFields contains the description of fields of a sObject
    * @return	 	String that contains all the changed fields       
    ********************************************************************************************************/
    private String getChangedFields(SObject oNew, SObject oOld, Set<String> sFields, Map<String,Schema.sObjectField> mFields) {       
        
        String sChanges = '';
        
        for (String field : sFields) {
            Object v1 = oNew.get(field);
            Object v2 = oOld.get(field);
            if (didFieldChange(v1, v2)) {
                if(mFields.containsKey(field)){
                	sChanges = String.format('{0}', new List<String>{sChanges + mfields.get(field).getDescribe().getLabel() + '\n - ' + System.Label.MSF_GDPR_PREVIOUS_VALUE + ' ' + String.valueOf(v2) + '\n - ' + System.Label.MSF_GDPR_NEW_VALUE + ' ' + String.valueOf(v1) + '\n\n'});    
                }else{
					sChanges = String.format('{0}', new List<String>{sChanges + field + '\n - ' + System.Label.MSF_GDPR_PREVIOUS_VALUE + ' ' + String.valueOf(v2) + '\n - ' + System.Label.MSF_GDPR_NEW_VALUE + ' ' + String.valueOf(v1) + '\n\n'});    
                }                
            }
        }
        
        return sChanges;
    }
    
    /*******************************************************************************************************
    * @description  Compare two objects and return if they are different or equal.
    * @param		v1 object to compare with v2 object	
    * @param		v2 object to compare with v1 object	    
    * @return	 	boolean        
    ********************************************************************************************************/
    private static Boolean didFieldChange(Object v1, Object v2) {
        
        if (v1 == null && v2 == null) {
            return false;
        }
        if (v1 != v2) {
            return true;
        }
        
        return false;
    }
    
}