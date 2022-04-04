global class MSF_DefaultMerge_CTRL implements dupcheck.dc3Plugin.InterfaceMerge {

    /**
     * Duplicate Check plugin for storing msf_CRMExternalId__c in msf_CRMHistoryIds__c field.
     */
    global void beforeMerge(String objectPrefix, sObject masterRecord, List<sObject> mergedRecordList) {

        // Contact.
        if (objectPrefix.equals('003')) {
			String master_historic_ids = [SELECT msf_CRMHistoryIds__c FROM Contact WHERE Id = :masterRecord.Id].msf_CRMHistoryIds__c;
            
            for (sObject obj: mergedRecordList) {
                String object_external_id = (String) obj.get('msf_CRMExternalId__c');
                String object_external_historic_ids = (String) obj.get('msf_CRMHistoryIds__c');
                
                String new_value = '';
                if (!String.isBlank(object_external_id)) {
                    new_value = object_external_id;
                }
                if (!String.isBlank(master_historic_ids)) {
                    if (String.isBlank(new_value)) {
                        new_value = master_historic_ids;
                    }
                    else {
                        new_value = master_historic_ids + ',' + new_value;
                    }
                }
                if (!String.isBlank(object_external_historic_ids)) {
                    if (String.isBlank(new_value)) {
                        new_value = object_external_historic_ids;
                    }
                    else {
                        new_value = object_external_historic_ids + ',' + new_value;
                    }
                }

                masterRecord.put('msf_CRMHistoryIds__c', new_value);
            }
        }
    }

    /**
     * Duplicate Check plugin for Amazon Redshift (AWS) integration.
     */
    global void afterMerge(String objectPrefix, Sobject masterRecord, Set<id> mergedRecordIds) {

        // Contact.
        if (objectPrefix.equals('003')) {
            MSF_FutureDuplicateCheckAws_CTRL.processRecords(mergedRecordIds, masterRecord.Id);
        }
    }

    /**
     * Dumb method implementation (all methods need to be implemented).
     */
    global void mergeFailed(String objectPrefix, Sobject masterRecord, Set<id> mergedRecordsIds, dupcheck.dc3Exception.MergeException exceptionData) {

        return;
    }
}