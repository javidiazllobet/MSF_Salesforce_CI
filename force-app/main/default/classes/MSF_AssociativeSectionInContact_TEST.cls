@isTest
private class MSF_AssociativeSectionInContact_TEST {
    @testSetup static void setup(){
        //Initialize values
        Contact cont = new Contact(LastName='MSF_AssociativeSectionInContact_TEST_LastName1');
        insert cont;
        msf_Associative__c obj = new msf_Associative__c(msf_Status__c='Activo', msf_contactId__c=cont.Id);
        insert obj; 
    }
    
    @isTest static void getMsf_Associative_c(){
        Contact cont = [SELECT Id,LastName FROM Contact Where LastName = 'MSF_AssociativeSectionInContact_TEST_LastName1' LIMIT 1];
        Object obj = MSF_AssociativeSectionInContact_CTRL.getAssociativeInformation(cont.Id);        
        Map<String, Object> msfa = (Map<String, Object>)obj;
        System.assertNotEquals(null,msfa.get('associative'));
    }
    @isTest static void getNull(){
        Contact cont = new Contact(LastName='MSF_AssociativeSectionInContact_TEST_LastName2');
        Object obj = MSF_AssociativeSectionInContact_CTRL.getAssociativeInformation(cont.Id);        
        Map<String, Object> msfa = (Map<String, Object>)obj;
        System.assertEquals(null,msfa.get('associative'));
    }

}