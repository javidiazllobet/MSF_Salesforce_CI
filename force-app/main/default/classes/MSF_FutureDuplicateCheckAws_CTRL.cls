public class MSF_FutureDuplicateCheckAws_CTRL {

    @future
    public static void processRecords(Set<Id> mergedRecordIds, Id master_id) {

        Contact master_contact = [SELECT Id, msf_CRMExternalId__c, msf_CRMHistoryIds__c FROM Contact WHERE Id = :master_id];
        String id_miembro_master = (String) master_contact.get('msf_CRMExternalId__c');
        
        String history_ids = (String) master_contact.get('msf_CRMHistoryIds__c');
        List<String> history_id_list = history_ids.split(',');

        for (String history_id: history_id_list) {

            List<msf_opportunity_h__x> opportunities = [SELECT Id, npsp_primary_contact_c__c FROM msf_opportunity_h__x WHERE npsp_primary_contact_c__c = :history_id];

            for (msf_opportunity_h__x opp: opportunities) {
                opp.npsp_primary_contact_c__c = id_miembro_master;
            }

            database.updateAsync(opportunities);
        }
    }
}