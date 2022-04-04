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
public without sharing class MSF_OpportunityTriggerHelper {
    public static void saveOldQuota(List<Opportunity> oldOpp, List<Opportunity> newOpp, Map<Id, Opportunity> oldMapOpp, map<Id, Opportunity> newMapOpp){
        List<Opportunity> oppToUpdate = New List<Opportunity>();
        List<Id> quotaIdToSearch = New List<Id>();
        

        for(Integer i = 0; i < newOpp.size(); i++){
            Id RTIDDonation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
            if(newOpp[i].RecordTypeId == RTIDDonation && newOpp[i].StageName == 'Devuelta'){
                if(newOpp[i].msf_CurrentQuotaModification__c != oldOpp[i].msf_CurrentQuotaModification__c && newOpp[i].msf_CurrentQuotaModification__c != null){
                    newOpp[i].msf_OldQuotaModification__c = oldOpp[i].msf_CurrentQuotaModification__c;
                    System.debug('Guardado de Quota');

                    System.debug('Cambio de Current to Old');
                    newOpp[i].msf_CurrentQuotaModification__c = newOpp[i].msf_OldQuotaModification__c;
                    oppToUpdate.add(newOpp[i]);
                    quotaIdToSearch.add(newOpp[i].msf_OldQuotaModification__c);
                    
                }

                System.debug('Amount: ' + newOpp[i].Amount + ' Viejo: ' + oldOpp[i].Amount);
                if( ((newOpp[i].Amount != oldOpp[i].Amount && newOpp[i].Amount != null) || (newOpp[i].msf_RecurringPeriod__c != oldOpp[i].msf_RecurringPeriod__c) ) && newOpp[i].msf_OldQuotaModification__c != null){
                    System.debug('Cambio de Current to Old');
                    newOpp[i].msf_CurrentQuotaModification__c = newOpp[i].msf_OldQuotaModification__c;
                    
                    
                    oppToUpdate.add(newOpp[i]);
                    quotaIdToSearch.add(newOpp[i].msf_OldQuotaModification__c);

                }

            }
        }

        Map<Id, msf_QuotaModification__c> quotaToSearch = new Map<Id, msf_QuotaModification__c>([select Id,  msf_NewAmount__c, msf_NewRecurringPeriod__c
                                                                                                from msf_QuotaModification__c
                                                                                                where Id in :quotaIdToSearch]);

        for(Opportunity opp: oppToUpdate){
            System.debug('Remodificación de Amount. Nuevo Amount: ' + quotaToSearch.get(opp.msf_OldQuotaModification__c).msf_NewAmount__c );
            newMapOpp.get(opp.Id).Amount                 = quotaToSearch.get(opp.msf_OldQuotaModification__c).msf_NewAmount__c;
            newMapOpp.get(opp.Id).msf_RecurringPeriod__c = quotaToSearch.get(opp.msf_OldQuotaModification__c).msf_NewRecurringPeriod__c;
        }
        
    }
}