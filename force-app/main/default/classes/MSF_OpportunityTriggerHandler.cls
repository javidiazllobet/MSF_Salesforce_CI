/**
 * @description       :
 * @author            : avargas@omegacrmconsulting.com
 * @group             :
 * @last modified on  : 26-10-2021
 * @last modified by  : avargas@omegacrmconsulting.com
 * Modifications Log
 * Ver   Date         Author                            Modification
 * 1.0   26-10-2021   avargas@omegacrmconsulting.com   Initial Version
 **/
public without sharing class MSF_OpportunityTriggerHandler {
    public static void beforeInsert(List<Opportunity> oldOpp, List<Opportunity> newOpp, Map<Id, Opportunity> oldMapOpp, map<Id, Opportunity> newMapOpp){
        MSF_OpportunityTriggerHelper.saveOldQuota(oldOpp, newOpp, oldMapOpp, newMapOpp);
        
    }
}