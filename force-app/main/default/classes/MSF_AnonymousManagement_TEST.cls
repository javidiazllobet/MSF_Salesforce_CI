/**
* @author 		Deloitte
* @date 		10-2018
* @group 		Accounts
* @description	test class for the MSF_AnonymousManagement_BATCH class.
*/
@isTest
private class MSF_AnonymousManagement_TEST {
    public static String CRON_EXP = '0 0 0 L * ? *';
    public static String months = (String.valueOf(Date.today().addMonths(1).month()));
    
    public static String ACCNAME = 'Anónimos_'+Date.today().addMonths(1).year()+'_';
    
    static testmethod void testScheduledJob() {
        if(months.length()==1){
            months='0'+months;
        }
        Test.startTest();        	
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP, new MSF_AnonymousManagement_BATCH());          
        Test.stopTest();
        
        List<Account> lt = [SELECT Id FROM Account WHERE Name =: ACCNAME+months];
        System.assertEquals(1, lt.size(), 'New account haven\'t been created.');
    }
    
    static testmethod void testScheduledJob2() {        
        Id RTAnonymous = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Anonymous').getRecordTypeId();  
        if(months.length()==1){
            months='0'+months;
        }
        
        Account a = new Account(
            Name = ACCNAME+months,
            RecordTypeId = RTAnonymous,
            Type = 'Anonymous'
        );
        insert a;
        
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP, new MSF_AnonymousManagement_BATCH());                 
        Test.stopTest();
        
        List<Account> lt = [SELECT Id, Name FROM Account];
        System.assertEquals(1, lt.size(), 'New account haven\'t been created.');        
    }
    
    static testmethod void testScheduledJob3() {  
        Id RTAnonymousCt = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Anonymous').getRecordTypeId(); 
        
        if(months.length()==1){
            months='0'+months;
        }
        
        Contact c = new Contact(
            LastName = ACCNAME+months,
            RecordTypeId = RTAnonymousCt
        );
        insert c;
        
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP, new MSF_AnonymousManagement_BATCH());                 
        Test.stopTest();
        
        List<Contact> lt = [SELECT Id, Name FROM Contact];
        System.assertEquals(1, lt.size(), 'New account haven\'t been created.');        
    }
}