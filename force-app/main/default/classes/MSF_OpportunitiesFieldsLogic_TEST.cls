/**
* @author 		Deloitte
* @date 		03-2019
* @group 		Opportunity
* @description	test class for the MSF_OpportunitiesFieldsLogic_TDTM class.
*/
@isTest
private class MSF_OpportunitiesFieldsLogic_TEST {
    @testSetup static void setup(){
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestOpportunitiesFieldsLogic',
            npsp__Class__c = 'MSF_OpportunitiesFieldsLogic_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 6,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        upsert thCon; 
               
        Id idRDAssc = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Associate').getRecordTypeId();
        Id IdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        List<npe03__Recurring_Donation__c> lRecDon = new List<npe03__Recurring_Donation__c>();
        List<Contact> lcon = new List<Contact>();
        List<cpm__Payment_Profile__c> lppInsert = new List<cpm__Payment_Profile__c>();
        Map<String,Schema.RecordTypeInfo> mRtPaymentProfileInfo = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName();
        
        List<msf_LeadSourceMasterData__c> lLeadSourceMD = new List<msf_LeadSourceMasterData__c>();
        List<String> leadSource = leadSource1Desc();
        List<String> leadSource2 = leadSource2Desc();
        List<String> leadSource3 = leadSource3Desc();
        
        for(Integer x = 0; x < leadSource.size(); x ++){
            msf_LeadSourceMasterData__c data = new msf_LeadSourceMasterData__c(
                msf_LeadSource1__c = leadSource[x], 
                msf_LeadSource2__c = LeadSource2[math.mod(x, leadSource2.size())], 
                msf_LeadSource3__c = LeadSource3[math.mod(x, leadSource3.size())]
            );
            lLeadSourceMD.add(data);
        }
        insert lLeadSourceMD;
        
        //Campaign
        Campaign c = new Campaign(Name='MSFOpportunitiesFieldsLogicTESTName1', msf_FinalCampaign__c = false, msf_BetterNowExternalId__c = 'TEST01OFL', msf_CustomExternalId__c = 'TEST02OFL');
        insert c;
        Campaign camp1 = new Campaign(Name='CampaignRatingOppTemplado',msf_FinalCampaign__c = false, msf_BetterNowExternalId__c = 'TEST01Rating', msf_CustomExternalId__c = 'TEST02Rating');
        insert camp1;
        
        //Recurring Donation
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c(
            Name='MSF_OpportunitiesFieldsLogic_TEST_Name1',
            npsp4hub__Payment_Method__c = 'Direct Debit',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
        );
        lRecDon.add(recDon);
        
        npe03__Recurring_Donation__c recDon2 = new npe03__Recurring_Donation__c(
            Name='MSF_OpportunitiesFieldsLogic_TEST_Name2',
            RecordTypeId=idRDAssc,
            npsp4hub__Payment_Method__c = 'Direct Debit',
            npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
            npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
        );
        lRecDon.add(recDon2);        
        insert lRecDon;
        
        //Contacts
        lcon.add(new Contact(LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1', msf_BeginDateMSF__c=date.today()));
        lcon.add(new Contact(LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2',msf_BeginDateMSF__c=date.today()));
        lcon.add(new Contact(LastName='contact1',msf_BeginDateMSF__c=date.today().addMonths(-2)));
        insert lcon;
        
        //Opportunities
        Opportunity o = new Opportunity (
            Name ='RatingOpportunity1',
            RecordTypeId = IdRecType,
            CampaignId = c.Id,
            LeadSource = leadSource[0],
            CloseDate = date.today(),
            Type= 'One off Donation',
            npsp__Primary_Contact__c = lcon[2].Id,
            Amount = 10,
            StageName='Cobrada',
            npsp4hub__Payment_Method__c = 'EFECTIVO S.C.',
            npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA',
            npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA'
        );
        insert o;                    
        
        //Create Payment Profile
        cpm.TestService.createIbanRegex();
        cpm.TestService.initTestPSPExtension();
        cpm.TestService.initTestSourceExtension();

        cpm__IbanValidation__c ibanValidation = new cpm__IbanValidation__c(
            Name = 'ES',
            cpm__RegEx__c = '^(?=[0-9A-Z]{24}$)ES\\d{22}$' 
        );
        insert ibanValidation;
        
       cpm__PaymentHub_Settings__c ps = new cpm__PaymentHub_Settings__c (
            cpm__Auto_Create_Mandate_Recurring_Payment_DD__c = false,	
            cpm__Re_use_existing_mandate__c	= false,
            cpm__Store_Informal_Logs__c	= true,
            Name = 'main'        
       );
        insert ps;
        
        cpm__Payment_Profile__c p1 = new cpm__Payment_Profile__c(
            cpm__IBAN__c ='ES8920631786117012691524',
            msf_HolderFirstName__c = 'contact1',
            msf_HolderLastName1__c = 'contact1',
            cpm__Holder_Name__c = 'contact1 contact1',
            msf_NIF__c = '12707968P',
            cpm__Active__c = true,
            RecordTypeId = mRtPaymentProfileInfo.get('IBAN').getRecordTypeId()     
        );
        insert p1;
    }
    
    @isTest static void insertLeadSourceDependencies(){
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        
        Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTEST_insertLeadSourceDependenciesLastName1');
        o.CampaignId = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        o.LeadSource = values[0].msf_LeadSource1__c;
        o.StageName = 'Propuesta';
        o.CloseDate = date.today();
        o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                          WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name1' LIMIT 1].Id;
        insert o;
        o = [SELECT msf_LeadSource2Level__c, msf_LeadSource3Level__c FROM Opportunity WHERE Id = :o.Id LIMIT 1];        
        System.assertNotEquals(null, o.msf_LeadSource2Level__c, 'Result is not null for msf_LeadSource2Level__c');
        System.assertNotEquals(null, o.msf_LeadSource3Level__c, 'Result is not null for msf_LeadSource3Level__c');
    }
    
    @isTest static void RatingOppTemplado(){
        Id IdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        Contact ct = [SELECT id FROM Contact WHERE Name ='contact1'];
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        
        List<Campaign> lCamp = [SELECT Id FROM Campaign WHERE Name = 'CampaignRatingOppTemplado' LIMIT 1];
        
        //Oportunity
        Opportunity o = new Opportunity(Name='RatingOpportunity2');
        o.RecordTypeId = IdRecType;
        o.CampaignId = lCamp[0].Id;
        o.LeadSource = values[0].msf_LeadSource1__c;
        o.CloseDate = date.today();
        o.Type= 'Herencia';
        o.npsp__Primary_Contact__c = ct.Id;
        o.Amount = 10;
        o.StageName='Cobrada';
        o.npsp4hub__Payment_Method__c = 'HERENCIAS Y LEGADOS';
        o.npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA';
        o.npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA';
        insert o;
        
        //installment
        cpm__Installment__c i = new cpm__Installment__c(
        	cpm__Contact__c=ct.Id,
            npsp4hub__Opportunity__c=o.Id
        );
        Insert i;

        Opportunity o2 = [SELECT id, StageName, msf_LastReasonCodeReceived__c FROM Opportunity WHERE id =:o.Id LIMIT 1];
        o2.StageName='Devuelta';
        o2.msf_LastReasonCodeReceived__c='AM04';
        Update o2;
        
        //******* ASSERT *************************************
        /*Opportunity oppAssert = [SELECT Id, StageName, msf_LastReasonCodeReceived__c FROM Opportunity WHERE id =:o.Id]; 
        System.assertEquals('AM04', oppAssert.msf_LastReasonCodeReceived__c, 'msf_LastReasonCodeReceived__c is not AM04');
        System.assertEquals('Devuelta', oppAssert.StageName, 'Stage is not Devuelta');*/
    	//****************************************************
    }
    
    @isTest static void testImpagada(){
        Contact ct = [SELECT id FROM Contact WHERE Name ='contact1'];
        Opportunity o = [SELECT Id, Name, StageName, msf_Rating__c FROM Opportunity WHERE npsp__Primary_Contact__c =:ct.Id AND Amount = 10 AND StageName='Cobrada' LIMIT 1];
		
        o.StageName='Devuelta';
        o.msf_LastReasonCodeReceived__c='xx';
        o.npsp4hub__Payment_Method__c ='Direct Debit';
        Update o;
        
        //******* ASSERT *************************************
        /*Opportunity oppAssert = [SELECT Id, StageName, msf_LastReasonCodeReceived__c FROM Opportunity WHERE id =:o.Id]; 
        System.assertNotEquals('AM04', oppAssert.msf_LastReasonCodeReceived__c, 'msf_LastReasonCodeReceived__c is AM04');
        System.assertEquals('Impagada', oppAssert.StageName, 'Stage is not Impagada');*/
        //****************************************************
    }
    
    @isTest static void testPrimaryContactChanged(){
        Contact ct = [SELECT id FROM Contact WHERE Name ='contact1'];
        Opportunity o = [SELECT Id, npsp__Primary_Contact__c, msf_EntryDate__c FROM Opportunity WHERE npsp__Primary_Contact__c =:ct.Id LIMIT 1];
		
        Contact ct2 = new Contact(
            LastName='contact2',
            msf_BeginDateMSF__c=date.today()
        );
        insert ct2;
        
        o.npsp__Primary_Contact__c = (ct2.Id);
        o.msf_EntryDate__c = date.today().addDays(-5);
        Update o;
        
        //******* ASSERT *************************************
        Opportunity oppAssert = [SELECT Id, npsp__Primary_Contact__c FROM Opportunity WHERE id =:o.Id]; 
        System.assertNotEquals(ct.Id, oppAssert.npsp__Primary_Contact__c, 'Primary contact is not changed');
        //****************************************************
    }
    
    @isTest static void insertOpportunityRecurrentDonation(){
        Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1');
        o.CampaignId = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        o.StageName = 'Propuesta';
        o.CloseDate = date.today();
        o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                          WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name1' LIMIT 1].Id;
        insert o;
        System.assertEquals('Recurrent Donation', [SELECT Type FROM Opportunity WHERE Id = :o.Id LIMIT 1].Type);
    }
    @isTest static void insertOpportunityMembership(){
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        
        Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1');
        o.CampaignId = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        o.LeadSource = values[0].msf_LeadSource1__c;
        o.StageName = 'Propuesta';
        o.CloseDate = date.today();
        o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                          WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name2' LIMIT 1].Id;
        insert o;   
        
        o = [SELECT Type FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        
        System.assertEquals('Membership', o.Type);
    }
    @isTest static void insertOpportunityContact(){
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        
        Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1');
        o.CampaignId = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        o.LeadSource = values[0].msf_LeadSource1__c;
        o.StageName = 'Propuesta';
        o.CloseDate = date.today();
        o.msf_EntryDate__c = date.today();
        o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                          WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name2' LIMIT 1].Id;
        o.npsp__Primary_Contact__c = [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1].Id;
        insert o;   
        
        o = [SELECT msf_EntryDate__c FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        Contact c = [SELECT msf_BeginDateMSF__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1];
        System.assertEquals(c.msf_BeginDateMSF__c, o.msf_EntryDate__c);
    }
    
    @isTest static void insertOpportunityContactWon(){
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        cpm__Payment_Profile__c p1 = [SELECT Id FROM cpm__Payment_Profile__c WHERE msf_NIF__c = '12707968P' LIMIT 1];
        
        p1.cpm__Contact__c= [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1].Id;
        Update p1;
        
        Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1');
        o.CampaignId = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        o.LeadSource = values[0].msf_LeadSource1__c;
        o.Amount = 10;
        o.CloseDate = date.today();
        o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                          WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name2' LIMIT 1].Id;
        o.npsp__Primary_Contact__c = [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1].Id;
        o.StageName='Cobrada';
        o.npsp4hub__Payment_Method__c = 'Direct Debit';
        o.npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA';
        o.npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA';
        o.npsp4hub__Payment_Profile__c=p1.Id;
        insert o;   
        
        o = [SELECT CampaignId, LeadSource FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        Contact c = [SELECT msf_FirstCampaingColaboration__c, msf_FirstCampaignColaborationChannel__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1];
        
        System.assertEquals(c.msf_FirstCampaingColaboration__c, o.CampaignId);
        System.assertEquals(c.msf_FirstCampaignColaborationChannel__c, o.LeadSource);
    }
    
    @isTest static void insertOpportunityContactWithDate(){
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        cpm__Payment_Profile__c p1 = [SELECT Id FROM cpm__Payment_Profile__c WHERE msf_NIF__c = '12707968P' LIMIT 1];
        
        p1.cpm__Contact__c= [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2' LIMIT 1].Id;
        Update p1;
        
        Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1');
        o.CampaignId = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        o.LeadSource = values[0].msf_LeadSource1__c;
        o.CloseDate = date.today();
        o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                          WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name2' LIMIT 1].Id;
        o.npsp__Primary_Contact__c = [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2' LIMIT 1].Id;
        o.StageName='Cobrada';
        o.Amount = 10;
        o.npsp4hub__Payment_Method__c = 'Direct Debit';
        o.npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA';
        o.npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA';
        o.npsp4hub__Payment_Profile__c=p1.Id;
        insert o;   
        
        o = [SELECT CampaignId, LeadSource FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        Contact c = [SELECT msf_FirstCampaingColaboration__c, msf_FirstCampaignColaborationChannel__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2' LIMIT 1];
        
        System.assertEquals(c.msf_FirstCampaingColaboration__c, o.CampaignId);
        System.assertEquals(c.msf_FirstCampaignColaborationChannel__c, o.LeadSource);
    }
    @isTest static void insertOpportunityContactDonationDate(){
        Id IdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                    FROM msf_LeadSourceMasterData__c 
                                                    WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
        
        Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTEST_insertLeadSourceDependenciesLastName1');
        Contact cont = [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2' LIMIT 1];
        cont.msf_FirstCampaingColaboration__c = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        update cont;
        
        cpm__Payment_Profile__c p1 = [SELECT Id FROM cpm__Payment_Profile__c WHERE msf_NIF__c = '12707968P' LIMIT 1];
        p1.cpm__Contact__c= cont.Id;
        Update p1;
        
        o.RecordTypeId = IdRecType;
        o.CampaignId = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        o.LeadSource = values[0].msf_LeadSource1__c;
        o.CloseDate = date.today();
        o.Type= 'One off Donation';
        o.npsp__Primary_Contact__c = cont.Id;
        o.Amount = 10;
        o.StageName='Cobrada';
        o.npsp4hub__Payment_Method__c = 'Direct Debit';
        o.npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA';
        o.npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA';
        o.npsp4hub__Payment_Profile__c=p1.Id;
        insert o;   
        o = [SELECT CloseDate FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        
        Contact c = [SELECT msf_DateFirstDonation__c, msf_DateLastDonation__c FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2' LIMIT 1];
        
        System.assertEquals(c.msf_DateFirstDonation__c, o.CloseDate);
        System.assertEquals(c.msf_DateLastDonation__c, o.CloseDate);
    }
    
    @isTest static void insertOpportunityErrorNoCampaign(){
        try{
            List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                        FROM msf_LeadSourceMasterData__c 
                                                        WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
            
            Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1');
            o.LeadSource = values[0].msf_LeadSource1__c;
            o.StageName = 'Propuesta';
            o.CloseDate = date.today();
            o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                              WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name2' LIMIT 1].Id;
            insert o;  
            
        }catch(DmlException ex){
            System.assert(false);            
        }        
    }
    @isTest static void insertOpportunityErrorCampaignNotFound(){
        try{
            List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                        FROM msf_LeadSourceMasterData__c 
                                                        WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
            
            Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1');
            o.LeadSource = values[0].msf_LeadSource1__c;
            o.StageName = 'Propuesta';
            o.CloseDate = date.today();
            o.CampaignId = (Id)getFakeId(Campaign.SObjectType);
            o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                              WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name2' LIMIT 1].Id;
            insert o;  
            System.assert(false);
        }catch(DmlException ex){
            System.assert(true);            
        }        
    }
    @isTest static void insertOpportunityContactDonationDateErrorCampaignNotFound(){
        try{
            Id IdRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
            List<msf_LeadSourceMasterData__c> values = [SELECT msf_LeadSource1__c, msf_LeadSource2__c, msf_LeadSource3__c 
                                                        FROM msf_LeadSourceMasterData__c 
                                                        WHERE msf_LeadSource1__c = :leadSource1Desc()[0] LIMIT 1];
            
            Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTESTinsertLeadSourceDependenciesLastName1');
            Contact cont = [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName2' LIMIT 1];
            cont.msf_FirstCampaingColaboration__c = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
            update cont;
            
            o.RecordTypeId = IdRecType;
            o.CampaignId = (Id)getFakeId(Campaign.SObjectType);
            o.LeadSource = values[0].msf_LeadSource1__c;
            o.CloseDate = date.today();
            o.Type= 'One off Donation';
            o.npsp__Primary_Contact__c = cont.Id;
            o.StageName='Cobrada'; 
            insert o;   
            System.assert(false);
        }catch(DmlException ex){
            System.assert(true);            
        }        
    }
    @isTest static void deleteOppWithContact(){
        Opportunity o = new Opportunity(Name='MSFOpportunitiesFieldsLogicTEST_insertLeadSourceDependenciesLastName1DeletePrimary');
        o.CampaignId = [SELECT Id FROM Campaign WHERE Name='MSFOpportunitiesFieldsLogicTESTName1' LIMIT 1].Id;
        o.StageName = 'Propuesta';
        o.CloseDate = date.today();
        o.npe03__Recurring_Donation__c = [SELECT Id FROM npe03__Recurring_Donation__c 
                                          WHERE Name='MSF_OpportunitiesFieldsLogic_TEST_Name1' LIMIT 1].Id;
        o.npsp__Primary_Contact__c = [SELECT Id FROM Contact WHERE LastName='MSF_OpportunitiesFieldsLogic_TEST_LastName1' LIMIT 1].Id;
        insert o;
        
        Opportunity opp = [SELECT Id,Name,npsp__Primary_Contact__c FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        delete opp;
        
        Contact result = [SELECT Id, msf_RecalculateMemberType__c FROM Contact 
                          WHERE Id = :opp.npsp__Primary_Contact__c and msf_RecalculateMemberType__c=TRUE LIMIT 1];
        System.assertEquals(opp.npsp__Primary_Contact__c, result.Id);
        System.assert(result.msf_RecalculateMemberType__c, 'RecalculateMemberType is false, must be true in this test');
    }
   
    //Private methods
    static Integer s_num = 1;
    private static String getFakeId(Schema.SObjectType sot){
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + 
            '0'.repeat(12-result.length()) + result;
    }
    
    private static List<String> leadSource1Desc(){
        Schema.DescribeFieldResult fieldResult = Opportunity.LeadSource.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    
    private static List<String> leadSource2Desc(){
        Schema.DescribeFieldResult fieldResult = Opportunity.msf_LeadSource2Level__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
    
    private static List<String> leadSource3Desc(){
        Schema.DescribeFieldResult fieldResult = Opportunity.msf_LeadSource3Level__c.getDescribe(); 
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        List<String> options = new List<String>();
        
        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }
        return options;
    }
}