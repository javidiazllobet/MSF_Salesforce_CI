/**
* @author       Deloitte
* @date         03-2019
* @group        SObjects
* @description  test class for the MSF_SharedMethods_UTIL class.
*/
@isTest
private class MSF_SharedMethods_TEST {
    @testSetup static void setup(){
        msf_LeadSourceMasterData__c data = new msf_LeadSourceMasterData__c(msf_LeadSource1__c = leadSource1Desc()[0],
                                                                           msf_LeadSource2__c = leadSource2Desc()[0], 
                                                                           msf_LeadSource3__c = leadSource3Desc()[0]);
        insert data;   
        
        Contact c = new Contact(LastName='Testin', msf_BeginDateMSF__c=date.today());
        insert c; 
    }
        
    @isTest static void testCreateLog() {
        Contact con = [SELECT Id, FirstName, LastName, Suffix, msf_LastModificationChannel__c, msf_CRMExternalId__c FROM Contact WHERE LastName = 'Testin' LIMIT 1];
        MSF_SharedMethods_UTIL shared = new MSF_SharedMethods_UTIL();
        Set<String> sfields = new Set<String>{'FirstName','LastName'};
        Map<String,Schema.sObjectField> mObjectFields = Contact.sObjectType.getDescribe().fields.getMap();
        shared.createLog(con, null, UserInfo.getUserId(), con.Id, null, true, false, sfields, mObjectFields); 
        shared.createLog(con, null, UserInfo.getUserId(), con.Id, null, false, true, sfields, mObjectFields);
        
        Contact con2 = con; 
        con2.FirstName = 'Test';
        upsert con2; 
        
        shared.createLog(con2, con , UserInfo.getUserId(), con.Id, null, false, false, sfields, mObjectFields); 
    }
    
    @isTest static void testGetLeadSourceDependence(){
        MSF_SharedMethods_UTIL shared = new MSF_SharedMethods_UTIL();
        Map<String,String> stringReturned = shared.getLeadSourceDependence(leadSource1Desc()[0]);
        System.assertEquals(leadSource2Desc()[0],stringReturned.get('LS2'), 'Dependence not found');
        System.assertEquals(leadSource3Desc()[0],stringReturned.get('LS3'), 'Dependence not found');
    }
    
    @isTest static void testGetLeadSourceDependencies(){
        MSF_SharedMethods_UTIL shared = new MSF_SharedMethods_UTIL();
        Map<String,msf_LeadSourceMasterData__c> mapReturned = shared.getLeadSourceDependencies();
        msf_LeadSourceMasterData__c leadSource = mapReturned.get(leadSource1Desc()[0]);
        msf_LeadSourceMasterData__c leadSourceExpected = [SELECT msf_LeadSource1__c,
                                                          msf_LeadSource2__c, 
                                                          msf_LeadSource3__c 
                                                          FROM msf_LeadSourceMasterData__c
                                                          WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        System.assertEquals(leadSourceExpected, leadSource);
        
    }
    
    private static List<String> leadSource1Desc(){
        Schema.DescribeFieldResult fieldResult = msf_LeadSourceMasterData__c.msf_LeadSource1__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    
    private static List<String> leadSource2Desc(){
        Schema.DescribeFieldResult fieldResult = msf_LeadSourceMasterData__c.msf_LeadSource2__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    
    private static List<String> leadSource3Desc(){
        Schema.DescribeFieldResult fieldResult = msf_LeadSourceMasterData__c.msf_LeadSource3__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
}