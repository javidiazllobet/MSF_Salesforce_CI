/**
* @author       Deloitte
* @date         01-2019
* @group        Lead
* @description  test class for the MSF_IncompleteManagement_CTRL class.
*/
@isTest
private class MSF_IncompleteManagement_TEST {
    @testSetup static void setup(){
        Lead l = new Lead(LastName='MSF_IncompleteManagement_TEST_LastName1');
        l.Company = 'MSF_IncompleteManagement_TEST_Company1';        
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();  
        l.LeadSource = 'Web';
        insert l;
    }
    @isTest static void testGetIncompletes(){
        Map<String,Object> incompleteLeads = (Map<String,Object>)MSF_IncompleteManagement_CTRL.getMyIncompletes();
        System.assert(incompleteLeads.size() > 0);
    }
    @isTest static void testRemoveIncompletes(){
        Lead l = [SELECT Id FROM Lead WHERE LastName = 'MSF_IncompleteManagement_TEST_LastName1' LIMIT 1];
        Map<String,Object> content = (Map<String,Object>)MSF_IncompleteManagement_CTRL.removeIncomplete(l.Id);
        Boolean result = (Boolean)content.get('eliminado');
        System.assert(result);
    }
    @isTest static void testRemoveIncompletesError(){
        Lead l = [SELECT Id FROM Lead WHERE LastName = 'MSF_IncompleteManagement_TEST_LastName1' LIMIT 1];
        Map<String,Object> content = (Map<String,Object>)MSF_IncompleteManagement_CTRL.removeIncomplete((Id)getFakeId(Lead.SObjectType));
        Boolean result = (Boolean)content.get('eliminado');
        System.assert(!result);
    }
   static Integer s_num = 1;
   private static String getFakeId(Schema.SObjectType sot){
      String result = String.valueOf(s_num++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
   }
}