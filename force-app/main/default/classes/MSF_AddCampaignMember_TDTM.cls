/*
	Copyright (c) 2015 Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/

/**
* @author Deloitte
* @date 05-2019
* @group Contacts
* @description Creates or updates campaign members to the main contact of the opportunity.
*/

global without sharing class MSF_AddCampaignMember_TDTM extends npsp.TDTM_Runnable {
	  
    /*@description Map containing existing Campaign Members*/
    private static map<string, CampaignMember> MAPCampaignMembers;

    /*@description Map containing existing Campaign Member Statuses*/
    private static map<id, list<CampaignMemberStatus>> MAPcampaignMemberStatuses;    
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        
        //Attributes
        List<Opportunity> lNewOpp = (List<Opportunity>) newlist;        
        List<Opportunity> lOldOpp = (List<Opportunity>) oldlist;
        Map<Id, Opportunity> mOldOpp = new Map<Id, Opportunity>();
        if(lOldOpp != null){            
            mOldOpp.putAll(lOldOpp);
        }
        
        List<ID> sContactsIds = new List<ID>();
        List<ID> sCampaignsIds = new List<ID>();
        List<String> sStatuses = new List<String>();
        
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){ 
            for(Opportunity opp :lNewOpp){
                if (opp.npsp__Primary_Contact__c != null && opp.msf_CurrentCampaign__c != null && opp.CampaignId != opp.msf_CurrentCampaign__c) { 
                    sContactsIds.add(opp.npsp__Primary_Contact__c);
                    sCampaignsIds.add(opp.msf_CurrentCampaign__c);
                    sStatuses.add(getStatus(opp)); 
                } 
                if (opp.npsp__Primary_Contact__c != null && opp.msf_ModificationCampaign__c != null && opp.CampaignId != opp.msf_ModificationCampaign__c) { 
                    sContactsIds.add(opp.npsp__Primary_Contact__c);
                    sCampaignsIds.add(opp.msf_ModificationCampaign__c);
                    sStatuses.add(getStatus(opp)); 
                }                
            }   
            dmlWrapper = CreateCampaignMembers(sContactsIds, sCampaignsIds, sStatuses);
        }

        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate){     
            for(Opportunity opp :lNewOpp){
                if (opp.npsp__Primary_Contact__c != null && opp.msf_CurrentCampaign__c != null && opp.CampaignId != opp.msf_CurrentCampaign__c && opp.msf_CurrentCampaign__c != mOldOpp.get(opp.Id).msf_CurrentCampaign__c) { 
                    sContactsIds.add(opp.npsp__Primary_Contact__c);
                    sCampaignsIds.add(opp.msf_CurrentCampaign__c);
                    sStatuses.add(getStatus(opp)); 
                } 
                if (opp.npsp__Primary_Contact__c != null && opp.msf_ModificationCampaign__c != null && opp.CampaignId != opp.msf_ModificationCampaign__c && opp.msf_ModificationCampaign__c != mOldOpp.get(opp.Id).msf_ModificationCampaign__c && opp.msf_ModificationCampaign__c != opp.msf_CurrentCampaign__c) { 
                    sContactsIds.add(opp.npsp__Primary_Contact__c);
                    sCampaignsIds.add(opp.msf_ModificationCampaign__c);
                    sStatuses.add(getStatus(opp)); 
                }                
            }   
            
            dmlWrapper = CreateCampaignMembers(sContactsIds, sCampaignsIds, sStatuses);
        }    
                
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
    * @description Get the correct Status. If the opportunity has a status it is used, otherwise a default 
    * is used based on if the opportunity is closed/won or not.
    * @param Opp The current opportunity.
    * @return String of the status to use.
    ********************************************************************************************************/
    private String getStatus(Opportunity opp) {
        
        String sStatus = null;

        //if no status is provided, default to a responded status if the opp is closed/won
        //otherwise default to a non-responded status
        if (String.isBlank(opp.npsp__Primary_Contact_Campaign_Member_Status__c)) {
            if (opp.isClosed && opp.isWon) {
                sStatus = Label.npsp.campaignMemberStatusResponded;
            } else {
                sStatus = Label.npsp.campaignMemberStatusNonResponded;
            }
        } else {
            sStatus = opp.npsp__Primary_Contact_Campaign_Member_Status__c;
        }
        
        return sStatus;
    }
    
    /*******************************************************************************************************
    * @description This method creates or updates campaign members based on three lists of equal size that
    * contain contact ids, campaign ids, and statuses. It creates statuses first, and parses out special
    * statuses to allow the selection of the default status, the first non responded status, or the first
    * responded status.
    * @param Contacts the list of Contact IDs.
    * @param Campaigns the list of Campaign IDs.
    * @param Statuses the list of Status strings.
    * @return dmlWrapper Campaign members for insert or update.
    ********************************************************************************************************/
    private static npsp.TDTM_Runnable.DmlWrapper CreateCampaignMembers(list<id> Contacts, list<id> Campaigns, list<String> Statuses) {

        //instantiating the static parameters at the start of the routine in case this method called more than once in a transaction 
        MAPCampaignMembers = new map<string, CampaignMember>();
        MAPcampaignMemberStatuses = new map<id, list<CampaignMemberStatus>>();
        
        //iterate the list of CampaignMembers, placing into map using the combo key of contactid:campaignid
        for(CampaignMember cm : [SELECT Id, ContactId, CampaignId, Status FROM CampaignMember WHERE ContactId IN :Contacts and CampaignId in :Campaigns]) {
            MAPCampaignMembers.put(cm.contactid + ':' + cm.campaignid, cm);
        }
        
        createNewCampaignMemberStatuses(Campaigns, Statuses);
        
        npsp.TDTM_Runnable.DmlWrapper dml = getCampaignMembers(Contacts, Campaigns, Statuses);
        
        return dml;
    }   
    
    /*******************************************************************************************************
    * @description For all provided campaigns, this method first queries for campaign member statuses and 
    * adds them to the map, then creates statuses that were provided in the list and don't yet exist.
    * @param Campaigns the list of Campaign IDs.
    * @param Statuses the list of Status strings.
    * @return void This method inserts statuses directly, as they're needed before inserting campaign members.
    ********************************************************************************************************/
    private static void createNewCampaignMemberStatuses(list<id> Campaigns, list<String> Statuses) {
                                                                  
        map<id, list<string>> MAPcampaignMemberStatusesCompare = new map<id, list<string>>();
        
        //a list to hold any statuses which do not exist already
        list<CampaignMemberStatus> listStatusForInsert = new list<CampaignMemberStatus>();
        
        //iterate the list of campaign member statuses while building a map of campaign id and list of statuses
        for(CampaignMemberStatus cms : [SELECT Id, CampaignId, Label, SortOrder, HasResponded, IsDefault FROM CampaignMemberStatus WHERE CampaignId IN :Campaigns ORDER BY SortOrder]) {
            
            if (MAPcampaignMemberStatuses.containsKey(cms.CampaignId)) {
                MAPcampaignMemberStatuses.get(cms.CampaignId).add(cms);
            } else {
                MAPcampaignMemberStatuses.put(cms.CampaignId, new list<CampaignMemberStatus>{cms});
            }
        }
        
        //iterate the list of provided statuses while building a map of campaign id and list of string statuses
        for(integer i = 0; i < Campaigns.size(); i ++) {
            
            if(MAPcampaignMemberStatusesCompare.containsKey(Campaigns[i])) {
                MAPcampaignMemberStatusesCompare.get(Campaigns[i]).add(Statuses[i]);
            } else {
                MAPcampaignMemberStatusesCompare.put(Campaigns[i], new list<string>{Statuses[i]});
            }
        }
        
        //iterate through both maps comparing the values against each other and adding new campaign member values where necessary
        for(Id cIdCompare : MAPcampaignMemberStatusesCompare.keyset()) {
            
            integer sortOrderMax = 3;
            
            for(string cmsCompare : MAPcampaignMemberStatusesCompare.get(cIdCompare)) {
                
                boolean match = false;
                
                if(MAPcampaignMemberStatuses.containsKey(cIdCompare)) {
                    for(CampaignMemberStatus cms : MAPcampaignMemberStatuses.get(cIdCompare)) {
                        
                        if(sortOrderMax < cms.SortOrder)
                            sortOrderMax = cms.SortOrder;
                        
                        if(getStatusReplacementFromSetting(cmsCompare) == cms.Label) {
                            match = true;
                            break;
                        }
                    }
                }
                //create a campaign member status
                //if this is a special status, only create a status if we have a setting
                if(!match && (!isSpecialStatus(cmsCompare) || hasStatusReplacement(cmsCompare))) {
                    sortOrderMax ++;
                    //use a responded status only if this is a special responded status, otherwise default to non-responded
                    boolean isResponded = cmsCompare == Label.npsp.campaignMemberStatusResponded;
                    
                    listStatusForInsert.add(
                        new CampaignMemberStatus(
                            campaignId = cIdCompare,
                            Label = getStatusReplacementFromSetting(cmsCompare),
                            HasResponded = isResponded,
                            SortOrder = sortOrderMax
                        )
                    );
                }
            }
        }

        Database.insert(listStatusForInsert, true);
    }
        
    /*******************************************************************************************************
    * @description With all the associated processing complete, this method creates and updates campaign members
    * @param Contacts the list of Contact IDs.
    * @param Campaigns the list of Campaign IDs.
    * @param Statuses the list of Status strings.
    * @return void This method adds campaign members to dmlWrapper and returns nothing.
    ********************************************************************************************************/
    private static npsp.TDTM_Runnable.DmlWrapper getCampaignMembers(list<id> Contacts, list<id> Campaigns, list<String> Statuses) {

        npsp.TDTM_Runnable.DmlWrapper dml = new npsp.TDTM_Runnable.DmlWrapper();

        //iterate the list of Contacts passed in and check for matches in  Campaign Members and if found update Campaign Member Status
        for(integer i = 0; i < Contacts.size(); i++) {
            string comboKey = Contacts[i] + ':' + Campaigns[i];
	
            //if we have an existing campaign member, update the status
            if(MAPCampaignMembers.containsKey(comboKey)) {
                CampaignMember cmForUpdate = MAPCampaignMembers.get(comboKey);
                cmForUpdate.status = getStatus(Campaigns[i], Statuses[i]);
                dml.objectsToUpdate.add(cmForUpdate);
            //otherwise create a new one
            } else {
                CampaignMember cmForInsert = new CampaignMember(ContactId = Contacts[i], CampaignId = Campaigns[i]);
                cmForInsert.Status = getStatus(Campaigns[i], Statuses[i]);
                dml.objectsToInsert.add(cmForInsert);
            }
        }
        return dml;
    }
    
    /*******************************************************************************************************
    * @description Given a campaign id and a status string, verifies if the string is a special status, and
    * replaces it with the appropriate status from the given campaign. Otherwise, the unmodified status is
    * returned.
    * @param CampaignId The ID of the campaign.
    * @param Status The status.
    * @return string The return status.
    ********************************************************************************************************/
    private static string getStatus(id CampaignId, string status) {
        
        if (isSpecialStatus(status)) {
            //if we have a setting for a special status, use that
            if (hasStatusReplacement(status))
                return getStatusReplacementFromSetting(status);
            
            //if this is a special status but our campaign doesn't have any statuses, return a blank status
            if(!MAPcampaignMemberStatuses.containsKey(CampaignId))
                return null;
            
            //return the appropriate value for the special status key
            for(CampaignMemberStatus cms : MAPcampaignMemberStatuses.get(CampaignId)) {
                if ((status == Label.npsp.campaignMemberStatusDefault && cms.IsDefault) ||
                    (status == Label.npsp.campaignMemberStatusNonResponded && !cms.HasResponded) ||
                    (status == Label.npsp.campaignMemberStatusResponded && cms.HasResponded)) {
                        
                        return cms.Label;
                    }
            }
        }
        return status;
    }

    /*******************************************************************************************************
    * @description Gets the replacement setting for a status if one exists, otherwise returns the status.
    * @param Status The status.
    * @return string The replacement status from the setting, or the given status if no replacement is found.
    ********************************************************************************************************/
    private static string getStatusReplacementFromSetting(string status) {
        
        npe01__Contacts_And_Orgs_Settings__c contactsSettings = new npe01__Contacts_And_Orgs_Settings__c(); 
        contactsSettings = npe01__Contacts_And_Orgs_Settings__c.getInstance();
        if (contactsSettings == null) {              
            if(contactsSettings.Id == null) 
                contactsSettings = npe01__Contacts_And_Orgs_Settings__c.getOrgDefaults();
        } 
        
        if (status == Label.npsp.campaignMemberStatusResponded && !string.isBlank(contactsSettings.npsp__Campaign_Member_Responded_Status__c)){
            return contactsSettings.npsp__Campaign_Member_Responded_Status__c;  
        }
            
        if (status == Label.npsp.campaignMemberStatusNonResponded && !string.isBlank(contactsSettings.npsp__Campaign_Member_Non_Responded_Status__c)){
        	return contactsSettings.npsp__Campaign_Member_Non_Responded_Status__c;    
        }            
        
        return status;
    }

    /*******************************************************************************************************
    * @description Checks if this status has a setting to replace it.
    * @param Status The status.
    * @return Boolean Whether this status has a replacement setting.
    ********************************************************************************************************/
    private static boolean hasStatusReplacement(string status) {
        return (status != getStatusReplacementFromSetting(status));
    }

    /*******************************************************************************************************
    * @description Checks if a status is a special status key.
    * @param Status The status.
    * @return string Whether this status is a special status key.
    ********************************************************************************************************/
    private static boolean isSpecialStatus(string status) {
        return (status == Label.npsp.campaignMemberStatusResponded ||
                status == Label.npsp.campaignMemberStatusNonResponded ||
                status == Label.npsp.campaignMemberStatusDefault);
    }
}