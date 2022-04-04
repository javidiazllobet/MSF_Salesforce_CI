/**
* @author 		Deloitte
* @date 		02-2019
* @group 		Lead
* @description	test class for the MSF_LeadFieldsLogic_TDTM class.
*/
@isTest
private class MSF_LeadFieldsLogic_TEST {
    @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestLeadFieldsLogic',
            npsp__Class__c = 'MSF_LeadFieldsLogic_TDTM',
            npsp__Object__c = 'Lead',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 3,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
        //Initialize values
        Lead newLead = new Lead(LastName='MSF_LeadFieldsLogic_TEST_Name1',
                                Company='MSF_LeadFieldsLogic_TEST_DummyCompany');
        insert newLead;        
        
        List<msf_LeadSourceMasterData__c> lLeadSourceMD = new List<msf_LeadSourceMasterData__c>();
        List<String> leadSource = leadSource1Desc();
        List<String> leadSource2 = leadSource2Desc();
        List<String> leadSource3 = leadSource3Desc();
        for(Integer x = 0; x < leadSource.size(); x ++){
            msf_LeadSourceMasterData__c data = new msf_LeadSourceMasterData__c(msf_LeadSource1__c = leadSource[x], 
                                                                               msf_LeadSource2__c = LeadSource2[math.mod(x, leadSource2.size())], 
                                                                               msf_LeadSource3__c = LeadSource3[math.mod(x, leadSource3.size())]);
            lLeadSourceMD.add(data);
        }
        insert lLeadSourceMD;        
    }
    
    @isTest static void testInsertNif(){
        Lead l = new Lead(LastName='MSF_LeadFieldsLogic_TEST_LastName',
                          Company='MSF_LeadFieldsLogic_TEST_DummyCompany',
                          Street='Street',
                          msf_NIF__c='62796843N',
                          msf_AuxNIF__c='62796843N',
                          msf_HolderNIF__c='62796843N');
        insert l;
        l = [SELECt Id FROM Lead WHERE msf_NIF__c='62796843N' LIMIT 1];
        System.assertNotEquals(null,l,'Lead has not been created, probably DNI error');
    }
    
    @isTest static void testInsertCif(){
        Lead l = new Lead(LastName='MSF_LeadFieldsLogic_TEST_LastName',
                          Company='MSF_LeadFieldsLogic_TEST_DummyCompany',
                          msf_NIF__c='B52296126',
                          msf_AuxNIF__c='B52296126',
                          msf_HolderNIF__c='B52296126');
        insert l;
        l = [SELECt Id FROM Lead WHERE msf_NIF__c='B52296126' LIMIT 1];
        System.assertNotEquals(null,l,'Lead has not been created, probably DNI error');
    }
    
    @isTest static void testInsertOldCif(){
        Lead l = new Lead(LastName='MSF_LeadFieldsLogic_TEST_LastName',
                          Company='MSF_LeadFieldsLogic_TEST_DummyCompany',
                          msf_NIF__c='K4585653A',
                          msf_AuxNIF__c='K4585653A',
                          msf_HolderNIF__c='K4585653A');
        insert l;
        l = [SELECt Id FROM Lead WHERE msf_NIF__c='K4585653A' LIMIT 1];
        System.assertNotEquals(null,l,'Lead has not been created, probably DNI error');
    }
    
    @isTest static void testInsertNifCifNotValid(){
        try{
            Lead l = new Lead(LastName='MSF_LeadFieldsLogic_TEST_LastName',
                              Company='MSF_LeadFieldsLogic_TEST_DummyCompany',
                              msf_NIF__c='62796143T',
                              msf_AuxNIF__c='62796143T',
                              msf_HolderNIF__c='62796143T');
            insert l;
            System.assert(false, 'Record with an invalid DNI inserted.');
        }catch(DmlException ex){
            System.assert(true);            
        }
    }
    
    @isTest static void testInsertNifCifBadFormated(){
        try{
            Lead l = new Lead(LastName='MSF_LeadFieldsLogic_TEST_LastName',
                              Company='MSF_LeadFieldsLogic_TEST_DummyCompany',
                              msf_NIF__c='62796143*',
                              msf_AuxNIF__c='62796143*',
                              msf_HolderNIF__c='62796143*');
            insert l;
            System.assert(false, 'Record with a DNI with incorrect format inserted.');
        }catch(DmlException ex){
            System.assert(true);            
        }
    }
    
    @isTest static void testInsertIBAN(){
        Lead l = new Lead(LastName='MSF_LeadFieldsLogic_TEST_LastName',
                          Company='MSF_LeadFieldsLogic_TEST_DummyCompany',
                          msf_PaymentMethod__c = 'Domiciliación bancaria',
                          msf_IBANCode__c='ES83',
                          msf_IBANEntity__c='0138', 
                          msf_IBANOffice__c='8772', 
                          msf_IBANDC__c = '71',
                          msf_IBANAccountNumber__c = '8584470812');
        insert l;
        /*l = [SELECt Id FROM Lead WHERE LastName='MSF_LeadFieldsLogic_TEST_LastName' AND msf_IBANDC__c='71' LIMIT 1];
        System.assertNotEquals(null,l,'Lead has not been created, probably DNI error');*/
    }  
    
    @isTest static void testInsertBadIBAN(){
        try{            
            Lead l = new Lead(LastName='MSF_LeadFieldsLogic_TEST_LastName',
                              Company='MSF_LeadFieldsLogic_TEST_DummyCompany',
                              msf_PaymentMethod__c = 'Domiciliación bancaria',
                              msf_IBANCode__c='ES73',
                              msf_IBANEntity__c='0138', 
                              msf_IBANOffice__c='8772',
                              msf_IBANDC__c = '75',
                              msf_IBANAccountNumber__c = '8584478808');
            insert l;
            System.assert(false, 'Record with a IBAN with incorrect format inserted.');
        }catch(DmlException ex){
            System.debug('ex: '+ex);
            System.assert(true);
        }
    }
    
    @isTest static void testLeadsource(){
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        Lead l = [SELECT Id,LeadSource FROM Lead WHERE LastName = 'MSF_LeadFieldsLogic_TEST_Name1' LIMIT 1];
        l.LeadSource = values[0].msf_LeadSource1__c;
        update l;
        
        Lead l2 = [SELECT Id,LeadSource,msf_LeadSource2Level__c,msf_LeadSource3Level__c FROM Lead WHERE Id = :l.Id LIMIT 1];
        
        System.assertNotEquals(null, l2.msf_LeadSource2Level__c, 'Result is not null for msf_LeadSource2Level__c');
        System.assertNotEquals(null, l2.msf_LeadSource3Level__c, 'Result is not null for msf_LeadSource3Level__c');
    }
    
    private static List<String> leadSource1Desc(){
        Schema.DescribeFieldResult fieldResult = Lead.LeadSource.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    
    private static List<String> leadSource2Desc(){
        Schema.DescribeFieldResult fieldResult = Lead.msf_LeadSource2Level__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    
    private static List<String> leadSource3Desc(){
        Schema.DescribeFieldResult fieldResult = Lead.msf_LeadSource3Level__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
}