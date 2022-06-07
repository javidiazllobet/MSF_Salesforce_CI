/**
* @author 		Deloitte
* @date 		01-2019
* @group 		Contacts
* @description	test class for the MSP_LevelCalculation_01_BATCH, MSP_LevelCalculation_02_BATCH, MSP_LevelCalculation_03_BATCH,
*				MSP_LevelCalculation_04A_BATCH, MSP_LevelCalculation_04B_BATCH clases. 
*/
@isTest
private class MSF_LevelCalculation_TEST {
    
    @testSetup static void setup(){
        List<Contact> lConInsert = new List<Contact>();
        List<Opportunity> lOppInsert = new List<Opportunity>();
        List<Campaign> lCampInsert = new List<Campaign>();
        Id RTIdIndividuals = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();        
        Id RTIdOrg = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();        
        Id RTIdHH = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();    
        String[] orgTypes = new String[]{'Foundation', 'Public Entity', 'Company', 'Collective'};
            
        //Create account
        Account acc = new Account(
        	Name = 'HH Account Test',
        	RecordTypeId = RTIdHH
        );
        insert acc;
        
        //Create contact
        Integer numCon = 10;
        for (Integer x=0;x<numCon/2;x++){
            Contact c = new Contact(
                FirstName = 'FN'+x,
                LastName = 'LN'+x,
                RecordTypeId = RTIdIndividuals,
                AccountId = acc.Id,
                msf_RecalculateLevel__c = FALSE,
                msf_LevelHCLifetimeVD__c = 1
            );
            lConInsert.add(c);
        }
        for (Integer x=numCon/2;x<numCon;x++){
            Contact c = new Contact(
                LastName = 'LN'+x,
                RecordTypeId = RTIdOrg,
                AccountId = acc.Id,
                msf_RecalculateLevel__c = FALSE,
                msf_LevelHCLifetimeVD__c = 1,
                msf_Forced__c = '121',
                msf_OrganizationType__c = orgTypes[math.mod(x, orgTypes.size())]
            );
            lConInsert.add(c);
        }
        Contact contactRecord = new Contact(
            LastName = 'ContactLN',
            RecordTypeId = RTIdOrg,
            AccountId = acc.Id,
            msf_RecalculateLevel__c = FALSE
        );
        lConInsert.add(contactRecord);
        insert lConInsert;
              
        //Creatre campaigns
        for (Integer x=0;x<numCon;x++){
            List<Contact> cont = [SELECT Id FROM Contact WHERE LastName like 'LN%'];
            Campaign c = new Campaign(Name = 'FN'+x);
            c.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
            c.msf_PromoterIndividual__c = cont[x].Id;
            c.msf_FinalCampaign__c = false;
            
            lCampInsert.add(c);
        }
        insert lCampInsert;
        
        List<Campaign> camp = [SELECT Id,Name,msf_PromoterIndividual__c,LastModifiedDate,CreatedDate FROM Campaign WHERE Name like 'FN%'];
        update camp;    
        
        //Objetos 4A
        Id[] contactTypes = new Id[]{RTIdOrg,RTIdIndividuals};
        Integer[] levels = new Integer[]{10000,8000,1500,500,1};
        List<Contact> con4aList = new List<Contact>();
        Integer size = levels.size();
        
        for(Integer z=0; z<contactTypes.size(); z++){
            for(Integer y=0; y<orgTypes.size(); y++){
                for(Integer x=0; x<size; x++){
                    Contact con4a = new Contact(LastName='4ALN'+x+''+y+''+z);
                    if(contactTypes[z] != RTIdOrg){
                        con4a.FirstName='4AFN'+x+''+y+''+z;
                    }
                    con4a.RecordTypeId = contactTypes[z];
                    con4a.msf_RecalculateLevel__c = TRUE;
                    con4a.msf_LevelHCOneFiscalYearAgo__c = levels[x];
                    con4a.msf_OrganizationType__c = orgTypes[y];
                    con4a.msf_LevelHCLifetime__c  = 1;
                    con4aList.add(con4a);
                }
                Contact con4a = new Contact(LastName='4ALN'+y+''+z);
                if(contactTypes[z] != RTIdOrg){
                    con4a.FirstName='4AFN'+y+''+z;
                }
                con4a.RecordTypeId = contactTypes[z];
                con4a.msf_RecalculateLevel__c = TRUE;
                con4a.msf_LevelScore__c = 20;
                con4a.msf_OrganizationType__c = orgTypes[y];
                con4aList.add(con4a);
            }
        }
        Contact con4a = new Contact(LastName='4ALNRelScore10');
        con4a.RecordTypeId = RTIdOrg;
        con4a.msf_RecalculateLevel__c = TRUE;
        con4a.msf_LevelHCLifetimeVD__c = 1;
        con4a.msf_OrganizationType__c = orgTypes[0];
        con4aList.add(con4a);
        
        //Objetos 4B
        Contact con4b = new Contact(FirstName='4AFNRelScore50NoData',LastName='4ALNRelScore50NoData');
        con4b.RecordTypeId = RTIdIndividuals;
        con4b.msf_RecalculateLevel__c = TRUE;
        con4b.msf_LevelHCLifetimeVD__c = 1;
        con4b.msf_LevelHCOneFiscalYearAgo__c = 10000;
        con4b.msf_ContactInformationSummary__c = 'No data';
        con4b.msf_OrganizationType__c = orgTypes[1];
        con4aList.add(con4b);
        
        String[] potentialValues = new String[]{'121','12Few'};
            for(Integer x=0; x<potentialValues.size(); x++){
                con4b = new Contact(FirstName='4AFNRelScore50Data-'+x,LastName='4ALNRelScore50Data-'+x);
                con4b.RecordTypeId = RTIdIndividuals;
                con4b.msf_RecalculateLevel__c = TRUE;
                con4b.msf_LevelHCLifetimeVD__c = 1;
                con4b.msf_LevelHCOneFiscalYearAgo__c = 1000;
                con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
                con4b.msf_PotentialAccordingOfficer__c = potentialValues[x];
                con4b.msf_IsStrategic__c = math.mod(x,2) == 0 ? false : true;
                con4b.msf_ContactInformationSummary__c = 'Data';
                con4b.msf_PercomsSummary__c = 'Algo';
                con4b.msf_RelationshipMajorDonorsProgram__c = 'Upgrade';
                con4b.msf_OrganizationType__c = orgTypes[1];
                con4aList.add(con4b);            
            }
        
        Contact con4b2 = new Contact(FirstName='4AFNRelScore40NoData',LastName='4ALNRelScore40NoData');
        con4b2.RecordTypeId = RTIdIndividuals;
        con4b2.msf_RecalculateLevel__c = TRUE;
        con4b2.msf_LevelHCLifetimeVD__c = 1;
        con4b2.msf_LevelHCOneFiscalYearAgo__c = 2000;
        con4b2.msf_LevelHCTwoFiscalYearsAgo__c = 0;
        con4b2.msf_ContactInformationSummary__c = 'No Data';
        con4b2.msf_OrganizationType__c = orgTypes[1];
        con4aList.add(con4b2);
        
        con4b2 = new Contact(FirstName='4AFNRelScore40NoData',LastName='4ALNRelScore40NoData');
        con4b2.RecordTypeId = RTIdIndividuals;
        con4b2.msf_RecalculateLevel__c = TRUE;
        con4b2.msf_LevelHCLifetimeVD__c = 1;
        con4b2.msf_LevelHCOneFiscalYearAgo__c = 1000;
        con4b2.msf_LevelHCTwoFiscalYearsAgo__c = 0;
        con4b2.msf_ProgramaHerencias__c = false;
        con4b2.msf_ContactInformationSummary__c = 'Data';
        con4b2.msf_OrganizationType__c = orgTypes[1];
        con4aList.add(con4b2);
        
        con4b = new Contact(FirstName='4AFNRelScore40NoProgramaHerenciasNoData',LastName='4ALNRelScore40NoProgramaHerenciasNoData');
        con4b.RecordTypeId = RTIdIndividuals;
        con4b.msf_RecalculateLevel__c = TRUE;
        con4b.msf_LevelHCLifetimeVD__c = 1;
        con4b.msf_LevelHCOneFiscalYearAgo__c = 600;
        con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
        con4b.msf_ProgramaHerencias__c = false;
        con4b.msf_ContactInformationSummary__c = 'Data';
        con4b.msf_PercomsSummary__c = 'Algo';
        con4b.msf_RelationshipMajorDonorsProgram__c = 'Upgrade';
        con4b.msf_OrganizationType__c = orgTypes[1];
        con4b.msf_Forced__c = con4b.msf_PotentialAccordingOfficer__c = '121';
        con4aList.add(con4b);

        con4b = new Contact(FirstName='4AFNRelScore40Mid+DonorsAllFalse',LastName='4AFNRelScore40Mid+DonorsAllFalse');
        con4b.RecordTypeId = RTIdIndividuals;
        con4b.msf_RecalculateLevel__c = TRUE;
        con4b.msf_LevelHCLifetimeVD__c = 1;
        con4b.msf_LevelHCOneFiscalYearAgo__c = 600;
        con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
        con4b.msf_ProgramaHerencias__c = false;
        con4b.msf_ContactInformationSummary__c = 'Data';
        con4b.msf_PercomsSummary__c = 'Algo';
        con4b.msf_RelationshipMajorDonorsProgram__c = 'Upgrade';
        con4b.msf_OrganizationType__c = orgTypes[1];
        con4b.msf_Forced__c = con4b.msf_PotentialAccordingOfficer__c = '121';
        con4b.msf_ContactInformationSummary__c = con4b.msf_PercomsSummary__c ='DummyData*1' ;
        con4b.msf_RelationshipMajorDonorsProgram__c = 'Upgrade';
        
        con4aList.add(con4b);
        
        //Score 30
        Integer[] lowLevels = new Integer[]{600,5};
            for(Integer x =0; x<lowLevels.size();x++){
                con4b = new Contact(FirstName='4AFNRelScore40Associative',LastName='4ALNRelScore40Associative');
                con4b.RecordTypeId = RTIdIndividuals;
                con4b.msf_RecalculateLevel__c = TRUE;
                con4b.msf_LevelHCLifetimeVD__c = 1;
                con4b.msf_LevelHCOneFiscalYearAgo__c = lowLevels[x];
                con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
                con4b.msf_IsAssosiative__c = true;
                con4b.msf_IsActiveRecurringDonor__c = 'Socio';
                con4b.msf_OrganizationType__c = orgTypes[1];
                con4aList.add(con4b);
                
            }
        
        for(Integer x = 0; x<2; x++){
            con4b = new Contact(FirstName='4AFNRelScore40RecurringDonorSocio'+x,LastName='4AFNRelScore40RecurringDonorSocio'+x);
            con4b.RecordTypeId = RTIdIndividuals;
            con4b.msf_RecalculateLevel__c = TRUE;
            con4b.msf_LevelHCLifetimeVD__c = 1;
            con4b.msf_LevelHCOneFiscalYearAgo__c = 600;
            con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
            con4b.msf_IsAssosiative__c = false;
            con4b.msf_IsActiveRecurringDonor__c = 'Socio';
            con4b.msf_OrganizationType__c = orgTypes[1];
            con4aList.add(con4b);
        }
        //Score 30
        for(Integer x = 0; x<2; x++){
            con4b = new Contact(FirstName='4AFNRelScore30RecurringDonorSocio'+x,LastName='4AFNRelScore30RecurringDonorSocio'+x);
            con4b.RecordTypeId = RTIdIndividuals;
            con4b.msf_RecalculateLevel__c = TRUE;
            con4b.msf_LevelHCLifetimeVD__c = 1;
            con4b.msf_LevelHCOneFiscalYearAgo__c = 50;
            con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
            con4b.msf_IsAssosiative__c = con4b.msf_ProgramaHerencias__c = con4b.msf_IsPublicPerson__c = false;
            con4b.msf_IsActiveRecurringDonor__c = 'Socio';
            con4b.msf_OrganizationType__c = orgTypes[1];
            con4aList.add(con4b);
        }
        
        String[] activeDonorList = new String[]{'Donante','Exdonante'};
            for(Integer y=0; y<lowLevels.size(); y++){            
                for(Integer x=0; x<activeDonorList.size(); x++){
                    con4b = new Contact(FirstName='4AFNRelScore40RecurringDonorSocio'+y+''+x,LastName='4AFNRelScore40RecurringDonorSocio'+y+''+x);
                    con4b.RecordTypeId = RTIdIndividuals;
                    con4b.msf_RecalculateLevel__c = TRUE;
                    con4b.msf_LevelHCLifetimeVD__c = 1;
                    con4b.msf_LevelHCOneFiscalYearAgo__c = lowLevels[y];
                    con4b.msf_IsActiveRecurringDonor__c = 'Nunca';
                    con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
                    con4b.msf_IsAssosiative__c = false;
                    con4b.msf_IsActiveDonor__c = activeDonorList[x];
                    con4b.msf_OrganizationType__c = orgTypes[1];
                    con4aList.add(con4b);
                }
            }
        for(Integer y=0; y<lowLevels.size();y++){       
            con4b = new Contact(FirstName='4AFNRelScore40BajaRecurringDonor'+y,LastName='4AFNRelScore40BajaRecurringDonor'+y);
            con4b.RecordTypeId = RTIdIndividuals;
            con4b.msf_RecalculateLevel__c = TRUE;
            con4b.msf_LevelHCLifetimeVD__c = 1;
            con4b.msf_LevelHCOneFiscalYearAgo__c = lowLevels[y];
            con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
            con4b.msf_IsAssosiative__c = false;
            con4b.msf_IsActiveRecurringDonor__c = 'Baja';
            con4b.msf_OrganizationType__c = orgTypes[1];
            con4aList.add(con4b);
        }
        //Score 20        
        
        String[] IsActiveRecurringDonorValues = new String[]{'Socio','Nunca', 'Baja'};
            for(Integer x = 0; x < IsActiveRecurringDonorValues.size(); x++){
                for(Integer y = 0; y < activeDonorList.size(); y++){
                    con4b = new Contact(FirstName='4AFNRelScore20'+x+''+y,LastName='4ALNRelScore20'+x+''+y);
                    con4b.RecordTypeId = RTIdIndividuals;
                    con4b.msf_RecalculateLevel__c = TRUE;
                    con4b.msf_LevelHCLifetimeVD__c = 0;
                    con4b.msf_LevelHCOneFiscalYearAgo__c = 0;
                    con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
                    con4b.msf_IsAssosiative__c = false;
                    con4b.msf_LevelHCLifetime__c = con4b.msf_LevelHCLifetimeVD__c = 0;
                    con4b.msf_IsActiveRecurringDonor__c = IsActiveRecurringDonorValues[x];
                    con4b.msf_IsActiveDonor__c = activeDonorList[y];
                    con4b.msf_OrganizationType__c = orgTypes[1];
                    con4aList.add(con4b);
                }
            }
        
        con4b = new Contact(FirstName='4AFNRelScore20SocioLastYear',LastName='4AFNRelScore20SocioLastYear');
        con4b.RecordTypeId = RTIdIndividuals;
        con4b.msf_RecalculateLevel__c = TRUE;
        con4b.msf_LevelHCLifetimeVD__c = 0;
        con4b.msf_LevelHCOneFiscalYearAgo__c = 0;
        con4b.msf_LevelHCTwoFiscalYearsAgo__c = 0;
        con4b.msf_IsAssosiative__c = false;
        con4b.msf_LevelHCLifetime__c = con4b.msf_LevelHCLifetimeVD__c = 0;
        con4b.msf_IsActiveRecurringDonor__c = 'Socio';
        con4b.msf_OrganizationType__c = orgTypes[1];
        con4aList.add(con4b);
        insert con4aList;
        
        //Create opportunities
        for (Integer x=0;x<numCon;x++){
            List<Contact> cont = [SELECT Id FROM Contact WHERE LastName like 'LN%'];
            Opportunity opp = new Opportunity(Name='LevelCalculationOpportunity'+x);
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
            opp.StageName = 'Legacy';
            opp.CloseDate = Date.today();
            opp.npsp__Primary_Contact__c = cont[x].Id;
            lOppInsert.add(opp);
        }
        
        Contact contOrg = [SELECT Id FROM Contact WHERE LastName = 'ContactLN' LIMIT 1];
        Opportunity opportunityInsert = new Opportunity(Name='LevelCalculationOpportunity');
        opportunityInsert.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        opportunityInsert.StageName = 'Legacy';
        opportunityInsert.Type='Recurrent Donation';
        opportunityInsert.CloseDate = Date.today();
        opportunityInsert.npsp__Primary_Contact__c = contOrg.Id;
        lOppInsert.add(opportunityInsert);
        
        opportunityInsert = new Opportunity(Name='Opportunity4B');
        opportunityInsert.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opportunityInsert.StageName= 'Testamento a favor';
        opportunityInsert.CloseDate = Date.today();
        opportunityInsert.npsp__Primary_Contact__c = [SELECT Id From Contact Where FirstName like 'FN%' LIMIT 1].Id;
        lOppInsert.add(opportunityInsert);
        
        insert lOppInsert;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Name like 'LevelCalculationOpportunity%'];
        update opp;
        
        List<npe03__Recurring_Donation__c> lDonations = new List<npe03__Recurring_Donation__c>();
        
        npe03__Recurring_Donation__c recDonation = new npe03__Recurring_Donation__c(Name='npe03__Open_Ended_Status__c_TEST_Name1');
        recDonation.npe03__Date_Established__c = Date.today();
        recDonation.npe03__Contact__c = [SELECT Id From Contact Where FirstName like 'FN%' LIMIT 1].Id;
        recDonation.npe03__Open_Ended_Status__c = 'Open';
        recDonation.npsp4hub__Payment_Method__c = 'Direct Debit';
        recDonation.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        recDonation.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        recDonation.RecordTypeId = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Recurring_donation').getRecordTypeId();
        lDonations.add(recDonation);
        
        recDonation = new npe03__Recurring_Donation__c(Name='npe03__Open_Ended_Status__c_TEST_SocioLastYear');
        recDonation.npe03__Date_Established__c = Date.today();
        recDonation.npe03__Contact__c = [SELECT Id From Contact Where LastName like '4AFNRelScore20SocioLastYear' LIMIT 1].Id;
        recDonation.npe03__Open_Ended_Status__c = 'Open';
        recDonation.npsp4hub__Payment_Method__c = 'Direct Debit';
        recDonation.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
        recDonation.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
        recDonation.RecordTypeId = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Recurring_donation').getRecordTypeId();
        lDonations.add(recDonation);
        
        String[] searchQuery = new String[]{'4AFNRelScore40RecurringDonorSocio%', '4AFNRelScore30RecurringDonorSocio%'};
            
            for(Integer x=0; x<searchQuery.size(); x++){
                recDonation = new npe03__Recurring_Donation__c(Name='npe03__Open_Ended_Status__c_TEST_Name2'+x);
                recDonation.npe03__Date_Established__c = Date.today();
                recDonation.npe03__Contact__c = [SELECT Id From Contact Where FirstName like :searchQuery[x] LIMIT 1].Id;
                recDonation.npe03__Open_Ended_Status__c = 'Open';
                recDonation.npsp4hub__Payment_Method__c = 'Direct Debit';
                recDonation.npsp4hub__Payment_Processor__c  = 'PaymentHub-SEPA';
                recDonation.npsp4hub__Target__c  = 'LA CAIXA CCC OPERATIVA';
                recDonation.RecordTypeId = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName().get('Recurring_donation').getRecordTypeId();        
                lDonations.add(recDonation);
            }
        insert lDonations; 

        String queryStep = '';
        queryStep = 'SELECT Id ';
        queryStep += 'FROM Contact ';
        queryStep += 'WHERE RecordType.DeveloperName = \'Individual_Contact\' AND msf_RecalculateLevel__c = FALSE '; 
        queryStep += 'AND Id IN (SELECT msf_PromoterIndividual__c FROM Campaign WHERE Recordtype.DeveloperName = \'Default\' AND msf_PromoterIndividual__c != null) ';

        System.debug('Test setup query ---------------------> ' + Database.query(queryStep));
    }
    
    @isTest static void LevelCalculation_BatchTest(){
        Test.startTest();
        MSF_LevelCalculation_01_BATCH mta = new MSF_LevelCalculation_01_BATCH();
        MSF_LevelCalculation_01_BATCH mta1 = new MSF_LevelCalculation_01_BATCH(0);
        MSF_LevelCalculation_01_BATCH mta2 = new MSF_LevelCalculation_01_BATCH(1);
        Id batchId = Database.executeBatch(mta);
        Test.stopTest();
        
        List<Contact> lCon = [SELECT Id, msf_LevelScore__c, msf_LevelRelationshipScore__c, msf_RecalculateLevel__c,
                              msf_ProgramaIS__c,msf_ProgramaHerencias__c, msf_Program__c
                              FROM Contact WHERE FirstName like '%FN%' AND LastName like '%LN%'];
        for(Integer i = 0; i<lCon.size(); i++){
            System.assertNotEquals(null,lCon[i].msf_LevelRelationshipScore__c);
            System.assertNotEquals(null,lCon[i].msf_LevelScore__c);
            System.assertNotEquals(null,lCon[i].msf_RecalculateLevel__c);
            System.assertNotEquals(null,lCon[i].msf_ProgramaIS__c);
            System.assertNotEquals(null,lCon[i].msf_ProgramaHerencias__c);
            System.assertEquals(false, lCon[i].msf_RecalculateLevel__c);
        }
    }
    
    @isTest static void MemberType_01_SchedulerTest (){
        Test.startTest();           
        String CRON_EXP = '0 0 0 * * ? *';
        String jobId = System.schedule('MSF - MemberTypeTest',CRON_EXP, new MSF_LevelCalculation_01_BATCH());
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];       
        System.assert(ct != null, 'Job is not exist.');
        System.assert(ct.NextFireTime != null, 'Job is not schedule.');
    }

    @isTest static void testBatch02(){
        MSF_LevelCalculation_02_BATCH batch = new MSF_LevelCalculation_02_BATCH();
        Id batchId = Database.executeBatch(batch);
    }
}