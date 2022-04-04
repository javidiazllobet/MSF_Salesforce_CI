@isTest
public class MSF_DefaultMerge_TEST {
	@testSetup static void setup(){
        Id IdOrgCont = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Contact cont = new Contact(LastName='MasterRecord',RecordTypeId=IdOrgCont, msf_CRMHistoryIds__c = '3');
        insert cont;
        
        Contact cont2 = new Contact(LastName='MergeRecord', RecordTypeId=IdOrgCont, msf_CRMHistoryIds__c = '6');
        insert cont2;
    }
    
    @isTest static void test() {
        MSF_DefaultMerge_CTRL t = new MSF_DefaultMerge_CTRL();
        Contact masterRecord = [SELECT Id, msf_CRMExternalId__c, msf_CRMHistoryIds__c  FROM Contact WHERE LastName = 'MasterRecord'];
        Contact mergeRecord = [SELECT ID, msf_CRMExternalId__c, msf_CRMHistoryIds__c FROM Contact WHERE LastName = 'MergeRecord'];
        
        List<Contact> lConts = new List<Contact>(); 
        lConts.add(mergeRecord);
        Set<Id> sConts = new Set<Id>(); 
        sConts.add(mergeRecord.Id);
        
        t.beforeMerge('003', masterRecord, lConts);    
        t.afterMerge('003', masterRecord, sConts);
        t.mergeFailed('003', masterRecord, sConts, null);
    }
    
}