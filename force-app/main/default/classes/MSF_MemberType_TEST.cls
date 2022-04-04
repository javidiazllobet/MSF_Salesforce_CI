/**
* @author       Deloitte
* @date         01-2019
* @group        Accounts
* @description  test class for the MSF_MemberType_01_BATCH, MSF_MemberType_02_BATCH and MSF_MemberType_03_BATCH classes.
*/
@isTest
private class MSF_MemberType_TEST {

    @testSetup static void setup(){
        
        List<Contact> lConInsert = new List<Contact>();
        List<npe03__Recurring_Donation__c> lRDInsert = new List<npe03__Recurring_Donation__c>();
        List<Opportunity> lOppInsert = new List<Opportunity>();  
        List<cpm__Payment_Profile__c> lppInsert = new List<cpm__Payment_Profile__c>();  
        
        Map<String,Schema.RecordTypeInfo> mRtPaymentProfileInfo = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByDeveloperName();
        Id RTIdHH = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();    
        Id RTIdIndividuals = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();        
        Id RTIdDonation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        Id RTIdRecurrentDonation = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Recurring_donation').getRecordTypeId();
        

        //Opportunities RecordType assigment
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'TriggerTestMemberType',
            npsp__Class__c = 'MSF_OpportunitiesFieldsLogic_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__Load_Order__c = 6,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );
        triggerHandlers.add(thCon);
        upsert triggerHandlers;
        
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
        
        //Create contact
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
        
        //Payment profile
        Integer numPp = 10;
        for (Integer x=0;x<numPp;x++){
            cpm__Payment_Profile__c p = new cpm__Payment_Profile__c(
                cpm__IBAN__c ='ES8920631786117012691524',
                msf_HolderFirstName__c = 'contact1',
                msf_HolderLastName1__c = 'contact1',
                cpm__Holder_Name__c = 'contact1 contact1',
                msf_NIF__c = '12707968P',
                cpm__Active__c = true,
                cpm__Contact__c = lConInsert[x].Id,
                RecordTypeId = mRtPaymentProfileInfo.get('IBAN').getRecordTypeId()     
            );
            lppInsert.add(p);
        }
        insert lppInsert;
        
        //Create recurring donation
        Integer numRD = 3;
        for (Integer x=0;x<numRD;x++){
            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c (
                Name = 'DR'+x,
                recordTypeId = RTIdRecurrentDonation,
                npe03__Open_Ended_Status__c = 'Open',
                npe03__Installment_Period__c = 'Yearly',
                npe03__Contact__c = lConInsert[x].Id,
                npe03__Date_Established__c = date.today().addDays(1),
                npe03__Amount__c = 50,
                npe03__Installments__c = null,
                npsp4hub__Payment_Method__c = 'Direct Debit',
                npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
            );
            lRDInsert.add(rd);
        }
        
        for (Integer x=0;x<numRD;x++){
            npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c (
                Name = 'DR'+(x+numRD),
                recordTypeId = RTIdRecurrentDonation,
                npe03__Open_Ended_Status__c = 'Closed',
                npe03__Installment_Period__c = 'Yearly',
                npe03__Contact__c = lConInsert[x+numRD].Id,
                npe03__Date_Established__c = date.today(),
                npe03__Amount__c = 50,
                npe03__Installments__c = null,
                msf_CancelationReason__c = 'Unpaid',
                npsp4hub__Payment_Method__c = 'Direct Debit',
                npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA',
                npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA'
            );
            lRDInsert.add(rd);
        }
        insert lRDInsert;
        
        //Create opportunities
        Integer numOpp = 3;
        for (Integer x=0;x<numOpp;x++){
            Opportunity opp = new Opportunity(
                Name = 'Opp'+(x*3),
                recordTypeId = RTIdDonation,
                AccountId = acc.Id,
                npsp__Primary_Contact__c = lConInsert[(x*3)].Id,
                CloseDate = date.today().addDays(-7),
                StageName = 'Cobrada',
	        	Amount = 10.0,
                CampaignId = camp.Id,
                npsp4hub__Payment_Method__c = 'TRANSFERENCIA BANCARIA',
                npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA',
                npsp4hub__Target__c = 'BBVA',
                npsp4hub__Payment_Profile__c = lppInsert[(x*3)].Id,
                Type = 'One off Donation'           
            );
            lOppInsert.add(opp);
        }
        for (Integer x=0;x<numOpp;x++){
            Opportunity opp = new Opportunity(
                Name = 'Opp'+(x*3+1),
                recordTypeId = RTIdDonation,
                AccountId = acc.Id,
                npsp__Primary_Contact__c = lConInsert[(x*3+1)].Id,
                CloseDate = date.today().addYears(-7),
                StageName = 'Cobrada',
	        	Amount = 10.0,
                CampaignId = camp.Id,
                npsp4hub__Payment_Method__c = 'TRANSFERENCIA BANCARIA',
                npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA',
                npsp4hub__Target__c = 'BBVA',
                npsp4hub__Payment_Profile__c = lppInsert[(x*3+1)].id,
                Type = 'One off Donation'           
            );
            lOppInsert.add(opp);
        }
        Opportunity oppSMS = new Opportunity(
            Name = 'OppSMS',
            recordTypeId = RTIdDonation,
            AccountId = acc.Id,
            npsp__Primary_Contact__c = lConInsert[9].Id,
            CloseDate = date.today().addYears(1),
            StageName = 'SMS Donor cerrada',
	        Amount = 10.0,
            CampaignId = camp.Id,
            npsp4hub__Payment_Method__c = 'TRANSFERENCIA BANCARIA',
            npsp4hub__Payment_Processor__c = 'PaymentHub-SEPA',
            npsp4hub__Target__c = 'LA CAIXA CCC OPERATIVA',
            npsp4hub__Payment_Profile__c = lppInsert[9].id,
            Type = 'SMS Donor'
        );
        lOppInsert.add(oppSMS);
        insert lOppInsert;
    }
    
    @isTest static void MemberType_BatchTest (){
        Test.startTest();
            MSF_MemberType_01_BATCH mta = new MSF_MemberType_01_BATCH();
            Id batchId = Database.executeBatch(mta);
        Test.stopTest();
        
        List<Contact> lCon = [SELECT Id, Name, msf_MemberType__c, 
                              (SELECT Id, CloseDate, msf_TypeFundraisingContribution__c, StageName 
                               FROM Opportunities 
                               ORDER BY CloseDate DESC
                               LIMIT 1) 
                              FROM Contact ORDER BY Name ASC];
        
        
        System.assertEquals('Socio + Donante', lCon[0].msf_MemberType__c);
        System.assertEquals('Socio + Exdonante', lCon[1].msf_MemberType__c);
        System.assertEquals('Socio', lCon[2].msf_MemberType__c);        
        System.assertEquals('Baja + Donante', lCon[3].msf_MemberType__c);
        System.assertEquals('Baja + Exdonante', lCon[4].msf_MemberType__c);
        System.assertEquals('Baja', lCon[5].msf_MemberType__c);
        System.assertEquals('Donante',lCon[6].msf_MemberType__c);
        System.assertEquals('Exdonante',lCon[7].msf_MemberType__c);
        System.assertEquals('Nada', lCon[8].msf_MemberType__c);
        System.assertEquals('Nada (Donante SMS)', lCon[9].msf_MemberType__c);
    }
    
    @isTest static void MemberType_01_SchedulerTest (){
        Test.startTest();           
            String CRON_EXP = '0 0 0 * * ? *';
            String jobId = System.schedule('MSF - MemberTypeTest',CRON_EXP, new MSF_MemberType_01_BATCH());  
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];       
        System.assert(ct != null, 'Job is not exist.');
        System.assert(ct.NextFireTime != null, 'Job is not schedule.');
    }
}