/**
* @author 		Omega CRM
* @date 		11-2021
* @group 		Contacts
* @description	ContactInformationSummary and PercomsSummary fields management.
*/
global without sharing class MSF_CopyLevelAndProgramContact_TDTM extends npsp.TDTM_Runnable {
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        //Attributes
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Contact> lNewCon = (List<Contact>) newlist;
        system.debug('lNewCon: ' + lNewCon);
        List<Contact> lOldCon = (List<Contact>) oldlist;
        system.debug('lOldCon: ' + lOldCon);
        Map<Id, Contact> mOldCon = new Map<Id, Contact>();
        if(lOldCon != null){            
            mOldCon.putAll(lOldCon);
        }

        //BEFORE INSERT
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
            //Map<Id, Contact> mapOrganizationContact = new Map<Id, Contact>();
            List<Contact> listOrganizationContact = new List<Contact>();
            Set<Id> setOrganization = new Set<Id>();
            for(Contact c : lNewCon){
                if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId()){
                    //mapOrganizationContact.put(c.Id, c);
                    listOrganizationContact.add(c);
                    setOrganization.add(c.msf_Organization__c);
                }
            }
            Map<Id, Contact> mapOrganization = new Map<Id, Contact>();
            mapOrganization = organization(setOrganization);
        
            List<Contact> listOrganizationContactInsert = new List<Contact>();
            updateOrganizationContact(listOrganizationContact, mapOrganization);
        }

        //BEFORE UPDATE
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            List<Contact> listOrganizationContact = new List<Contact>();
            Set<Id> setOrganization = new Set<Id>();
            for(Contact c : lNewCon){
                if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId()){
                    Contact oldContact = new Contact();
                    oldContact = mOldCon.get(c.Id);
                    if (c.msf_Organization__c != oldContact.msf_Organization__c){
                        listOrganizationContact.add(c);
                        setOrganization.add(c.msf_Organization__c);
                    }
                }
            }

            Map<Id, Contact> mapOrganization = new Map<Id, Contact>();
            mapOrganization = organization(setOrganization);

            List<Contact> listOrganizationContactInsert = new List<Contact>();
            updateOrganizationContact(listOrganizationContact, mapOrganization);
        }

         //AFTER UPDATE
         if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id,Contact> mapOrganization = new Map<Id,Contact>();
            Set<Id> setOrganization = new Set<Id>();
            system.debug('lNewCon: ' + lNewCon);
            for(Contact c : lNewCon){
                if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId()){
                    Contact oldContact = new Contact();
                    oldContact = mOldCon.get(c.Id);
                    if (c.msf_RelationshipLevel__c != oldContact.msf_RelationshipLevel__c || c.msf_Program__c != oldContact.msf_Program__c 
                        || c.msf_LevelRelationshipScore__c != oldContact.msf_LevelRelationshipScore__c){
                        mapOrganization.put(c.Id, c);
                        setOrganization.add(c.Id);
                    }
                }
            }

            system.debug('setOrganization:' + setOrganization);
            List<Contact> listOrganizationContact = [SELECT Id, msf_Organization__c, msf_RelationshipLevel__c, msf_Program__c,msf_LevelRelationshipScore__c
                                                    FROM Contact WHERE msf_Organization__c = :setOrganization];
            system.debug('listOrganizationContact: ' + listOrganizationContact);

            List<Contact> listOrganizationContactUpdate = new List<Contact>();
            for (Contact c: listOrganizationContact){
               Contact organization = new Contact();
               Contact organizationContact = new Contact();
               organization = mapOrganization.get(c.msf_Organization__c);
               organizationContact = c;
               organizationContact.msf_RelationshipLevel__c = organization.msf_RelationshipLevel__c;
               organizationContact.msf_Program__c = organization.msf_Program__c;
               organizationContact.msf_LevelRelationshipScore__c = organization.msf_LevelRelationshipScore__c;
               listOrganizationContactUpdate.add(organizationContact);
            } 
            system.debug('listOrganizationContactUpdate: ' + listOrganizationContactUpdate);
            dmlWrapper.objectsToUpdate.addAll(listOrganizationContactUpdate);
            
         }
         system.debug('dmlWrapper: ' + dmlWrapper);
         if (dmlWrapper != null){
            return dmlWrapper;
         } else {
             return null;
         }
    }

    // PRIVATE METHODS

    private Map<Id, Contact> organization (Set<Id> setOrganization){
        Map<Id, Contact> mapOrganization = new Map<Id, Contact>();
        for (Contact c : [SELECT Id, msf_RelationshipLevel__c, msf_Program__c, msf_LevelRelationshipScore__c FROM Contact WHERE Id = :setOrganization]){
            mapOrganization.put(c.Id, c);
        }
        return mapOrganization;   
    }


    private void updateOrganizationContact (List<Contact> listOrganizationContact, Map<Id, Contact> mapOrganization){
        List<Contact> listOrganizationContactInsert = new List<Contact>();
        for (Contact c: listOrganizationContact){
            Contact organizationContact = new contact();
            Contact organization = new contact();
            organization = mapOrganization.get(c.msf_Organization__c);
            c.msf_RelationshipLevel__c = organization.msf_RelationshipLevel__c;
            c.msf_Program__c = organization.msf_Program__c;
            c.msf_LevelRelationshipScore__c = organization.msf_LevelRelationshipScore__c;
        }
    }
}