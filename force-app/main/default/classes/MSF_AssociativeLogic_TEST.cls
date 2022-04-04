/**
* @author       Deloitte
* @date         02-2019
* @group        Associative
* @description  test class for the MSF_AssociativeLogic_TDTM class.
*/
@isTest
private class MSF_AssociativeLogic_TEST {
    
    @testSetup static void setup(){
        
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestAssociativeLogic',
            npsp__Class__c = 'MSF_AssociativeLogic_TDTM',
            npsp__Object__c = 'msf_Associative__c',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate',
            npsp__Active__c = true, 
            npsp__Load_Order__c = 1,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );
        upsert thCon;
        
        //Initialize values
        //Contact
        Contact cont = new Contact(LastName='MSF_AssociativeLogic_TEST_LastName1');
        insert cont;
        
        //Donation
        npe03__Recurring_Donation__c don = new npe03__Recurring_Donation__c();
        don.npe03__Contact__c = cont.Id;
        don.npe03__Open_Ended_Status__c = 'Open';
        don.npsp4hub__Payment_Method__c = 'Direct Debit';
        don.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        don.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        don.RecordTypeId = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Associate').getRecordTypeId();
        insert don;
        
        //Associative
        msf_Associative__c assoLogic = new msf_Associative__c();
        assoLogic.msf_Status__c = 'Activo';
        assoLogic.msf_ContactId__c = cont.Id;
        insert assoLogic;
    }
    
    @isTest static void testUpdateStatusBaja(){
        msf_Associative__c assoLogic = [SELECT Id FROM msf_Associative__c  LIMIT 1];
        assoLogic.msf_Status__c = 'Baja';
        assoLogic.msf_CancellationReason__c = 'Fallecido';
        update assoLogic;
     
        assoLogic = [SELECT msf_receiveEmailCommunications__c FROM msf_Associative__c LIMIT 1];
        System.assert(!assoLogic.msf_receiveEmailCommunications__c);
    }
    
    @isTest static void testInsertStatusAlta(){
        Contact cont = new Contact(LastName='MSF_AssociativeLogic_TEST_LastName2');
        insert cont;
        
        //Donation
        npe03__Recurring_Donation__c don = new npe03__Recurring_Donation__c();
        don.npe03__Contact__c = cont.Id;
        don.npe03__Open_Ended_Status__c = 'Open';
         don.npsp4hub__Payment_Method__c = 'Direct Debit';
        don.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        don.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        don.RecordTypeId = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Associate').getRecordTypeId();
        insert don;
        
        //Associative
        msf_Associative__c assoLogic = new msf_Associative__c();
        assoLogic.msf_Status__c = 'Activo';
        assoLogic.msf_ContactId__c = cont.Id;
        insert assoLogic;
                
        cont = [SELECT Id,msf_IsAssosiative__c FROM Contact WHERE LastName='MSF_AssociativeLogic_TEST_LastName2'];    
        System.assert(cont.msf_IsAssosiative__c);
    }

}