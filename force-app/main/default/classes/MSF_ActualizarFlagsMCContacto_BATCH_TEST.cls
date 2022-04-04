/**
* @author       Deloitte
* @date         11-2020
* @group        Contacts
* @description  test class for the MSF_ActualizarFlagsMCContacto_BATCH class.
*/
@isTest
public class MSF_ActualizarFlagsMCContacto_BATCH_TEST {
     
 	@testSetup static void setup(){
        
        List<Contact> lConInsert = new List<Contact>();
        
        Id RTIdHH = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();    
        Id RTIdIndividuals = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();        
        
        //Create account
        Account acc = new Account(
            Name = 'HH Account Test',
            RecordTypeId = RTIdHH
        );
        insert acc;
        
		//Create campaign
		Campaign camp = new Campaign(
            Name='MSFMemberTypeTESTCampName1', 
            msf_FinalCampaign__c = false
        );
        insert camp;
        
        //Create contacts
        Integer numCon = 10;
        for (Integer x=0;x<numCon;x++){
            Contact c = new Contact(
                FirstName = 'FN'+x,
                LastName = 'LN'+x,
                RecordTypeId = RTIdIndividuals,
                AccountId = acc.Id,
                msf_RecalculateMemberType__c = FALSE,
                msf_BeginDateMSF__c=date.today()
            );
            lConInsert.add(c);
       
        }
        insert lConInsert;
 	}
    /*
    @isTest static void Test_FlagsMC_BATCH (){
        List<Contact> contacts = [SELECT Id FROM Contact];
        Integer numTasks = 8;
        List<Task> tareas = new List<Task>();
        for(Integer x=0;x<numTasks;x++){
            if(math.mod(x,2) == 0){
                Task tarea1 = new Task(
                	Subject ='Se Queja Presión en Captación Fondos',
                    WhoId = contacts.get(x).Id
            	);
                tareas.add(tarea1);
            }
            Task tarea2 = new Task(
            	Subject = 'Solicita Confidencialidad Herencias',
                WhoId = contacts.get(x).Id
            );
            tareas.add(tarea2);
        }
        
        insert tareas;
        
        Test.startTest();
        MSF_ActualizarFlagsMCContacto_BATCH batch = new MSF_ActualizarFlagsMCContacto_BATCH();
		Database.executeBatch(batch, 50);
        Test.stopTest();
        
        List<Contact> contactsPressure = [SELECT Id, msf_PressureComplaint__c, msf_LegacyConfidentiality__c FROM Contact WHERE msf_PressureComplaint__c = TRUE];
        List<Contact> contactsConfidentiality = [SELECT Id, msf_PressureComplaint__c, msf_LegacyConfidentiality__c FROM Contact WHERE msf_LegacyConfidentiality__c = TRUE];
        
        System.assertEquals(4, contactsPressure.size());
		System.assertEquals(8, contactsConfidentiality.size());
    }
    
     @isTest static void Test2_FlagsMC_BATCH (){
        List<Contact> contacts = [SELECT Id FROM Contact];
        Integer numTasks = 2;
        List<Task> tareas = new List<Task>();
        for(Integer x=0;x<numTasks;x++){
            Task tarea = new Task(
            	Subject = 'Solicita Confidencialidad Herencias',
                Status ='Cancelada',
                WhoId = contacts.get(0).Id
            );
            tareas.add(tarea);
        }        
        insert tareas;
        
        Test.startTest();
        MSF_ActualizarFlagsMCContacto_BATCH batch = new MSF_ActualizarFlagsMCContacto_BATCH();
		Database.executeBatch(batch, 50);
        Test.stopTest();
        
        List<Contact> contactsConfidentiality = [SELECT Id, msf_PressureComplaint__c, msf_LegacyConfidentiality__c FROM Contact WHERE msf_LegacyConfidentiality__c = TRUE];
        
		System.assertEquals(0, contactsConfidentiality.size());
    }
    */
    @isTest static void Test3_FlagsMC_BATCH (){
        List<Contact> contacts = [SELECT Id FROM Contact];
        
        List<Task> tareas = new List<Task>();
        Task tareaCancelled = new Task(
            	Subject = 'Solicita Confidencialidad Herencias',
                Status ='Cancelada',
                WhoId = contacts.get(0).Id
        );
        tareas.add(tareaCancelled);
        Task tareaNotCancelled = new Task(
            	Subject = 'Solicita Confidencialidad Herencias',
                WhoId = contacts.get(0).Id
        );
        tareas.add(tareaNotCancelled);  
        insert tareas;
        
        Test.startTest();
        MSF_ActualizarFlagsMCContacto_BATCH batch = new MSF_ActualizarFlagsMCContacto_BATCH();
		Database.executeBatch(batch, 50);
        Test.stopTest();
        
        List<Contact> contactsConfidentiality = [SELECT Id, msf_PressureComplaint__c, msf_LegacyConfidentiality__c FROM Contact WHERE msf_LegacyConfidentiality__c = TRUE];
		System.assertEquals(1, contactsConfidentiality.size());
        
    }
    
    @isTest static void Test4_FlagsMC_BATCH (){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Contact contacto = new Contact(
        	FirstName = 'FN',
            LastName = 'LN',
            AccountId = acc.Id,
            msf_LegacyConfidentiality__c = TRUE
        );
        insert contacto;
        
        Task tareaCancelled = new Task(
            	Subject = 'Solicita Confidencialidad Herencias',
                Status ='Cancelada',
                WhoId = contacto.Id
        );

        insert tareaCancelled;
        
        Test.startTest();
        MSF_ActualizarFlagsMCContacto_BATCH batch = new MSF_ActualizarFlagsMCContacto_BATCH();
		Database.executeBatch(batch, 50);
        Test.stopTest();
        
        List<Contact> contactsConfidentiality = [SELECT Id, msf_PressureComplaint__c, msf_LegacyConfidentiality__c FROM Contact WHERE msf_LegacyConfidentiality__c = TRUE];
		System.assertEquals(0, contactsConfidentiality.size());
     
    }
}