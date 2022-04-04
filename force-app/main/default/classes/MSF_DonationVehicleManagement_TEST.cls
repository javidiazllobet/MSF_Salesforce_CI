/**
* @author       Deloitte
* @date         11-2018
* @group        Opportunity
* @description  test class for the MSF_DonationVehicleManagement_TDTM class.
*/
@isTest
private class MSF_DonationVehicleManagement_TEST {

    @testSetup static void setup(){
        
        List<Contact> lConInsert = new List<Contact>();

        Id RTIdIndividuals = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();
        
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        //Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c thAff = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestDonationVehicleManagement',
            npsp__Class__c = 'MSF_DonationVehicleManagement_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 6,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        triggerHandlers.add(thAff);        
        upsert triggerHandlers;
        
        //Create contacts
        Contact c1 = new Contact(
            FirstName = 'FNX',
            LastName = 'LNX',
            RecordTypeId = RTIdIndividuals
        );
        lConInsert.add(c1);
        
        Contact c2 = new Contact(            
            FirstName = 'FNY',
            LastName = 'LNY',
            RecordTypeId = RTIdIndividuals
        );
        lConInsert.add(c2);
        
        insert lConInsert;
    }
    
    @isTest static void DonationVehicleManagement_Individual(){
        String roleString = 'Donor by donation vehicle';
        Id RTDonation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId(); 
        Id RTIdIndividuals = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();   
        
        List<Contact> lCon = [SELECT Id, Name, AccountId FROM Contact WHERE RecordTypeId =: RTIdIndividuals ORDER BY Name];

        Opportunity o = new Opportunity(
            Name = 'Opportunity X',
            npsp__Primary_Contact__c = lCon[0].Id,
            AccountId = lCon[0].AccountId,
            Amount = 200,
            CloseDate = Date.today(),
            StageName = 'Propuesta'
        );   
        Opportunity o2 = new Opportunity(
            Name = 'Opportunity X',
            npsp__Primary_Contact__c = null,
            AccountId = lCon[1].AccountId,
            Amount = 201,
            CloseDate = Date.today(),
            StageName = 'Propuesta',
            msf_DonationVehicleContact__c = lCon[0].Id
        );   
        
        Test.startTest();        
            insert o;
            o = [SELECT Id, Name, AccountId, npsp__Primary_Contact__c, msf_DonationVehicleContact__c FROM Opportunity WHERE Id =: o.Id LIMIT 1];
            System.assertEquals(o.npsp__Primary_Contact__c, o.msf_DonationVehicleContact__c);       
        
            o.msf_DonationVehicleContact__c = lCon[1].Id;
            update o;
            o = [SELECT Id, Name, AccountId, npsp__Primary_Contact__c, msf_DonationVehicleContact__c FROM Opportunity WHERE Id =: o.Id LIMIT 1];
            List<OpportunityContactRole> lOcr = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId =: o.Id AND Role = :roleString];
            System.assertEquals(lOcr.size(), 1, 'The number of the opportunity contact role records is: '+lOcr.size());
        
            o.msf_DonationVehicleContact__c = lCon[0].Id;
            update o;
            o = [SELECT Id, Name, AccountId, npsp__Primary_Contact__c, msf_DonationVehicleContact__c FROM Opportunity WHERE Id =: o.Id LIMIT 1];
            lOcr = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole WHERE OpportunityId =: o.Id AND Role = :roleString]);
            System.assertEquals(lOcr.size(), 0, 'The number of the opportunity contact role records is: '+lOcr.size());
        
            o.npsp__Primary_Contact__c = null;
            update o;
            o = [SELECT Id, Name, AccountId, npsp__Primary_Contact__c, msf_DonationVehicleContact__c FROM Opportunity WHERE Id =: o.Id LIMIT 1];
            System.assertEquals(o.msf_DonationVehicleContact__c, null, 'The number of the opportunity contact role records is: '+lOcr.size());
        
            insert o2;
            lOcr = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole WHERE OpportunityId =: o2.Id AND Role = :roleString]);
            System.assertEquals(lOcr.size(), 1, 'The number of the opportunity contact role records is: '+lOcr.size());
        Test.stopTest();
    }
}