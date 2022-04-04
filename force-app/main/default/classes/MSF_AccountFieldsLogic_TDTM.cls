/**
* @author 		Deloitte
* @date 		10-2018
* @group 		Account
* @description	ContactInformationSummary and PercomsSummary fields management.
*/
global without sharing class MSF_AccountFieldsLogic_TDTM extends npsp.TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description	Trigger Handler on Account that handles ***
    * @param 		listNew the list of Account from trigger new. 
    * @param 		listOld the list of Account from trigger old. 
    * @param 		triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param 		objResult the describe for Account
    * @return 		dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
                
        //Attributes
        List<Account> lNewAcc = (List<Account>) newlist;
        List<Account> lOldAcc = (List<Account>) oldlist;
        Map<Id, Account> mOldAcc = new Map<Id, Account>();
        if(lOldAcc != null){            
            mOldAcc.putAll(lOldAcc);
        }
		
        //BEFORE INSERT && BEFORE UPDATE
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {      
 	
            Id IdOrgRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId(); 
            Id IdHHRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId(); 
            
            Set<Id> sPrimaryContacts = new Set<Id>();
            Map<Id, Contact> mNames = new Map<Id, Contact>();
            for(Account a : lNewAcc){
                if(a.npe01__One2OneContact__c != null) {
                	sPrimaryContacts.add(a.npe01__One2OneContact__c);    
                }                    
            }
            
            mNames.putAll([SELECT Id, LastName FROM Contact WHERE ID IN: sPrimaryContacts AND RecordType.Name = 'Organization']);
            
            for(Account a : lNewAcc){
                if(a.RecordTypeId == IdHHRT && a.npe01__One2OneContact__c != null && a.msf_IsPrimaryContactOrg__c && a.CreatedDate != null && a.CreatedDate.date() == date.today()) {
                    a.RecordTypeId = IdOrgRT;
                    a.Type = 'Company';
                    a.npe01__SYSTEM_AccountType__c = null;
                    a.npe01__SYSTEMIsIndividual__c = false;
                    if(!mNames.isEmpty() && mNames.containskey(a.npe01__One2OneContact__c)){
                    	a.Name = 'CUENTA - '+ mNames.get(a.npe01__One2OneContact__c).LastName;   
                    }                    
                }
                else if(a.RecordTypeId == IdOrgRT) {
                    if(!a.msf_IsOrganizationGroup__c && !mNames.isEmpty() && mNames.containskey(a.npe01__One2OneContact__c)){
                    	a.Name = 'CUENTA - '+ mNames.get(a.npe01__One2OneContact__c).LastName;     
                    }
                    if(!a.Name.startsWith('CUENTA - ')){
                    	a.Name = 'CUENTA - '+ a.Name;     
                    }                                                         
                }
                setAccountCountry(a);
            }
        }
        
        return null; 
    }  
    
	// PRIVATE METHODS
    
    private static void setAccountCountry(Account a) {
        if (a.BillingStreet != null && a.BillingCountry == null) {
            a.BillingCountry = 'España'; 
        }
        
        if (a.ShippingStreet != null && a.ShippingCountry == null) {
            a.ShippingCountry = 'España'; 
        }
    }
}