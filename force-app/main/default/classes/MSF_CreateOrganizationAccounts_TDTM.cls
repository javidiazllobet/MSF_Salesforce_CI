/**
* @author       Deloitte
* @date         01-2019
* @group        Contact.
* @description  Create organization accounts for the new contacts of Organization type.
*/
global without sharing class MSF_CreateOrganizationAccounts_TDTM extends npsp.TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description  Trigger Handler on Contact that handles the logic of some fields and deletions. 
    * @param        listNew the list of Contact from trigger new. 
    * @param        listOld the list of Contact from trigger old. 
    * @param        triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param        objResult the describe for Contact
    * @return       dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
        
        //Attributes
        List<Contact> lNewCon = (List<Contact>) newlist;
        List<Contact> lOldCon = (List<Contact>) oldlist;
        Map<Id, Contact> mOldCon = new Map<Id, Contact>();
        if(lOldCon != null){            
            mOldCon.putAll(lOldCon);
        }
        
        List<Account> lAccountsToDelete = new List<Account>();
        List<Contact> lContactsToUpdate = new List<Contact>();
        List<Contact> lContactsToDelete = new List<Contact>();   
        List<Opportunity> lOpportunitiesToUpdate = new List<Opportunity>();  
        
        List<Contact> lOrgContacts = new List<Contact>();
        
        Id IdOrgRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId(); 
        
        //Actions
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate){
            lOrgContacts.addAll(organizationContacts(lNewCon, IdOrgRT)); 
            
            for(Contact c : lOrgContacts){
                if(mOldCon.get(c.Id).AccountId != null){
                    if(c.AccountId == null){
                        c.AccountId = mOldCon.get(c.Id).AccountId;      
                    }    
                }   
            } 
        }        
        else if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate){            
            List<Contact> contactsChangeAccount = new List<Contact>();
            List<Contact> oldContactsAccount = new List<Contact>();
            
            lOrgContacts.addAll(organizationContacts(lNewCon, IdOrgRT)); 

            for(Contact c : lOrgContacts){
                if(mOldCon.get(c.Id).AccountId != null && c.AccountId != mOldCon.get(c.Id).AccountId){
                    contactsChangeAccount.add(c);  
                    oldContactsAccount.add(mOldCon.get(c.Id));
                } 
            }
            
            lContactsToUpdate.addAll(moveContacts(contactsChangeAccount));                  // If account is changed in a org contact, all data contact are moved to new account. 
            lOpportunitiesToUpdate.addAll(moveOpportunities(contactsChangeAccount));        // If account is changed in a org contact, all opportunities are moved to new account.
            lAccountsToDelete.addAll(checkDeleteAccounts(oldContactsAccount, IdOrgRT));     // Check if the old account must be deleted.             
        }
        else if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete){
            lOrgContacts.addAll(organizationContacts(lOldCon, IdOrgRT));
            lAccountsToDelete.addAll(checkDeleteAccounts(lOrgContacts, IdOrgRT));           // Check if the related account must be deleted. 
            lContactsToDelete.addAll(deleteContacts(lAccountsToDelete,lOrgContacts));       // Delete the contact data of the organizations that are going to be deleted.
        }
        
        //DML Operations
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        dmlWrapper.objectsToUpdate.addAll((List<Contact>)lContactsToUpdate);
        dmlWrapper.objectsToUpdate.addAll((List<Opportunity>)lOpportunitiesToUpdate);
        dmlWrapper.objectsToDelete.addAll((List<Contact>)lContactsToDelete);
        dmlWrapper.objectsToDelete.addAll((List<Account>)lAccountsToDelete);

        if(lAccountsToDelete.isEmpty() && lContactsToUpdate.isEmpty()&& lOpportunitiesToUpdate.isEmpty() && lContactsToDelete.isEmpty()){
            return null;
        }
        
        return dmlWrapper;
    }
    
    
    //PRIVATE METHODS
    
    /*******************************************************************************************************
    * @description  Gets a list of organization-type contacts.
    * @param        lContacts is the list of the updated contacts.
    * @param        orgRT is the id of the record type Organization.
    * @return       List<Contact>
    ********************************************************************************************************/ 
    private List<Contact> organizationContacts (List<Contact> lContacts, ID orgRT){
        
        List<Contact> lOrgCon = new List<Contact>();        
        
        for (Contact c : lContacts){
            if(c.RecordTypeId == orgRT){
                lOrgCon.add(c);    
            } 
        }
        
        return lOrgCon;
    } 
    
    /*******************************************************************************************************
    * @description  Updates donations from the organization when the organization moves to another 
    * 				business group.
    * @param        lNewContacts is a list of organizations whose business group has been changed.
    * @return       List<Opportunity> 
    ********************************************************************************************************/ 
    private List<Opportunity> moveOpportunities (List<Contact> lNewContacts){
        
        Map<ID,Contact> mConOrg = new Map<Id, Contact>(lNewContacts);
        List<Opportunity> lUpdateOpportunities = new List<Opportunity>();
        
        for (Opportunity o : [SELECT Id, AccountId, npsp__Primary_Contact__c FROM Opportunity WHERE npsp__Primary_Contact__c IN: mConOrg.keySet() ]){
            o.AccountId = mConOrg.get(o.npsp__Primary_Contact__c).AccountId;
            lUpdateOpportunities.add(o);                
        }
        
        return lUpdateOpportunities;
    } 
    
    /*******************************************************************************************************
    * @description  Updates organization contacts from the organization when the organization moves to 
    * 				another business group.
    * @param        lNewContacts is a list of organizations whose business group has been changed.
    * @return       List<Contact>
    ********************************************************************************************************/ 
    private List<Contact> moveContacts (List<Contact> lNewContacts){

        Map<ID,Contact> mConOrg = new Map<Id, Contact>(lNewContacts);
        List<Contact> lUpdateContacts = new List<Contact>();

        for (Contact c : [SELECT Id, AccountId, msf_Organization__c FROM Contact WHERE RecordType.DeveloperName = 'Organization_Contact' AND msf_Organization__c IN: mConOrg.keySet()]){
            c.AccountId = mConOrg.get(c.msf_Organization__c).AccountId;
            lUpdateContacts.add(c);             
        }

        return lUpdateContacts;
    } 
    
    /*******************************************************************************************************
    * @description  Check if a business group doesn't have more organizations and deletes it.
    * @param        lContacts is a list of organization whose have been changed of business group or have 
    * 				been deletes.
    * @param        orgRT is the id of the record type Organization.
    * @return       List<Account>
    ********************************************************************************************************/ 
    private List<Account> checkDeleteAccounts (List<Contact> lContacts, ID orgRT){
        
        List<Account> lDelAccounts = new List<Account>();
        
        Set<ID> sCheckAcc = new Set<ID>();
        for(Contact c : lContacts){
            if(c.AccountId != null) sCheckAcc.add(c.AccountId);
        }        
        
        if(!sCheckAcc.isEmpty()){
            for(Account a : [SELECT Id, (SELECT Id FROM Contacts WHERE RecordTypeId =: orgRT LIMIT 1 ) FROM Account WHERE Id IN: sCheckAcc]){
                if(a.Contacts.isEmpty()){
                    lDelAccounts.add(a);  
                }
            }
        }
        
        return lDelAccounts;
    }  
    
    /*******************************************************************************************************
    * @description  Remove contacts from a specific business group or organization.
    * @param        lAcc is a list of business groups.
    * @param        lCon is a list of organizations.
    * @return       List<Contact> is a list of contacts to delete.
    ********************************************************************************************************/ 
    private List<Contact> deleteContacts (List<Account> lAcc, List<Contact> lCon){
        
        Set<Contact> sDelContacts = new Set<Contact>();

        if(!lCon.isEmpty()){
            Set<ID> sConIds = new Map<Id, Contact>(lCon).keySet();
            sDelContacts.addAll([SELECT Id FROM Contact WHERE msf_Organization__c IN: sConIds AND RecordType.DeveloperName = 'Organization_Contact']);
            
            if(!lAcc.isEmpty()){
                Set<ID> sAccIds = new Map<Id, Account>(lAcc).keySet(); 
                sDelContacts.addAll([SELECT Id FROM Contact WHERE AccountId IN: sAccIds AND AccountId != null AND ID NOT IN: sConIds]);
            }
        }

        return new List<Contact>(sDelContacts);
    }
}