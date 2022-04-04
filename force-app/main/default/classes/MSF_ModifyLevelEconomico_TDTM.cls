/**
* @author 		Omega CRM
* @date 		11-2021
* @group 		Contacts
* @description	ContactInformationSummary and PercomsSummary fields management.
*/
global without sharing class MSF_ModifyLevelEconomico_TDTM extends npsp.TDTM_Runnable {
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){

        //npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Contact> lNewCon = (List<Contact>) newlist;
        system.debug('lNewCon: ' + lNewCon);
        List<Contact> lOldCon = (List<Contact>) oldlist;
        system.debug('lOldCon: ' + lOldCon);
        Map<Id, Contact> mOldCon = new Map<Id, Contact>();
        if(lOldCon != null){            
            mOldCon.putAll(lOldCon);
        }

        //BEFORE UPDATE
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            List<Contact> listOrganizationContact = new List<Contact>();
            Set<Id> setOrganization = new Set<Id>();
            
            List<npsp__Level__c> levels = [SELECT Id, Name, npsp__Minimum_Amount__c FROM npsp__Level__c WHERE name = 'One to few+' OR name = 'One to one'];
            Id idLevelEcoFew = null;
            Id idLevelEcoOnetoOne = null;
            Decimal scoreFew = 0.0;
            Decimal scoreOneToOne = 0.0;

            for (npsp__Level__c level : levels){
                if (level.Name == 'One to few+'){
                    idLevelEcoFew = level.Id;
                    scoreFew = level.npsp__Minimum_Amount__c;
                }else if (level.Name == 'One to one'){
                    idLevelEcoOnetoOne = level.Id;
                    scoreOneToOne = level.npsp__Minimum_Amount__c;
                }
            }

            for(Contact c : lNewCon){
                if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId()){
                    Contact oldContact = new Contact();
                    oldContact = mOldCon.get(c.Id);
                    if (c.msf_Forced__c != oldContact.msf_Forced__c && c.msf_Forced__c == '12Few'){
                        c.msf_RelationshipLevel__c = idLevelEcoFew;
                        c.msf_LevelRelationshipScore__c = scoreFew;
                        c.msf_Program__c = 'Mid+ Donors';
                    } else if (c.msf_Forced__c != oldContact.msf_Forced__c && c.msf_Forced__c == '121'){
                        c.msf_RelationshipLevel__c = idLevelEcoOnetoOne;
                        c.msf_LevelRelationshipScore__c = scoreOneToOne;
                        c.msf_Program__c = 'Major Donors';
                    }
                }
            } 
        }

        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
            List<Contact> listOrganizationContact = new List<Contact>();
            Set<Id> setOrganization = new Set<Id>();
            
            List<npsp__Level__c> levels = [SELECT Id, Name, npsp__Minimum_Amount__c FROM npsp__Level__c WHERE name = 'One to few+' OR name = 'One to one'];
            Id idLevelEcoFew = null;
            Id idLevelEcoOnetoOne = null;
            Decimal scoreFew = 0.0;
            Decimal scoreOneToOne = 0.0;

            for (npsp__Level__c level : levels){
                if (level.Name == 'One to few+'){
                    idLevelEcoFew = level.Id;
                    scoreFew = level.npsp__Minimum_Amount__c;
                }else if (level.Name == 'One to one'){
                    idLevelEcoOnetoOne = level.Id;
                    scoreOneToOne = level.npsp__Minimum_Amount__c;
                }
            }

            for(Contact c : lNewCon){
                if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId()){
                    if (c.msf_Forced__c == '12Few'){
                        c.msf_RelationshipLevel__c = idLevelEcoFew;
                        c.msf_LevelRelationshipScore__c = scoreFew;
                        c.msf_Program__c = 'Mid+ Donors';
                    } else if (c.msf_Forced__c == '121'){
                        c.msf_RelationshipLevel__c = idLevelEcoOnetoOne;
                        c.msf_LevelRelationshipScore__c = scoreOneToOne;
                        c.msf_Program__c = 'Major Donors';
                    }
                }
            } 
        }
        
        return null;
    }
}