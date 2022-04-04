@isTest 
public class MSF_CustomLookupController_Test {
    @TestSetup
    static void testSetup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testCustomLookup@testorg.com');
        insert u;
    }

    @isTest 
    static void searchTest(){
        String searchTerm = 'test';
        String myObject = 'User';
        String filter = null;
        test.startTest();
        List<sObject> listSObject = MSF_CustomLookupController.search(searchTerm, myObject, filter);
        test.stopTest();

        system.assertNotEquals(null, listSObject);
    }
}