/**
 * @description       : 
 * @author            : arubio@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 11-04-2022
 * @last modified by  : arubio@omegacrmconsulting.com
**/
@isTest
public class MSF_UncheckUtimosMeses_BATCH_TEST {

    @testSetup static void setup(){
        Date dateSixYearsAgo = Date.today() - 365*6;
        Date dateFourYearsAgo = Date.today() - 365*4;
        Date dateOneYearsAgo = Date.today() - 365*1;
        List<Opportunity> listOppToInsert = new List<Opportunity>();
        Opportunity oppD = new Opportunity(Name='ChkUltimosMeses D');
        oppD.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD.StageName = 'Legacy';
        oppD.CloseDate = dateSixYearsAgo;
        oppD.msf_IsFromLastMonthsBool__c = true;
        oppD.Type = 'SMS Donor';
        oppD.msf_UncheckUtimosMeses__c = 'true';
        listOppToInsert.add(oppD);

        Opportunity oppD2 = new Opportunity(Name='ChkUltimosMeses RD');
        oppD2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD2.StageName = 'Legacy';
        oppD2.CloseDate = dateFourYearsAgo;
        oppD2.msf_IsFromLastMonthsBool__c = true;
        oppD2.Type = 'Recurrent Donation';
        oppD2.msf_UncheckUtimosMeses__c = 'true';
        listOppToInsert.add(oppD2);
        
        Opportunity opp = new Opportunity(Name='ChkUltimosMeses');
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp.StageName = 'Legacy';
        opp.CloseDate = dateSixYearsAgo;
        opp.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp);
        
        Opportunity opp2 = new Opportunity(Name='ChkUltimosMeses');
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp2.StageName = 'Legacy';
        opp2.CloseDate = dateSixYearsAgo;
        opp2.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp2);
        
        Opportunity opp3 = new Opportunity(Name='ChkUltimosMeses');
        opp3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp3.StageName = 'Legacy';
        opp3.CloseDate = dateSixYearsAgo;
        opp3.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp3);
        
        Opportunity opp4 = new Opportunity(Name='ChkUltimosMeses');
        opp4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp4.StageName = 'Legacy';
        opp4.CloseDate = dateSixYearsAgo;
        opp4.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp4);
        
        Opportunity opp5 = new Opportunity(Name='ChkUltimosMeses');
        opp5.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp5.StageName = 'Legacy';
        opp5.CloseDate = dateSixYearsAgo;
        opp5.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp5);
        
        Opportunity opp6 = new Opportunity(Name='ChkUltimosMeses');
        opp6.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp6.StageName = 'Legacy';
        opp6.CloseDate = dateSixYearsAgo;
        opp6.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp6);
        
        Opportunity opp7 = new Opportunity(Name='ChkUltimosMeses');
        opp7.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp7.StageName = 'Legacy';
        opp7.CloseDate = dateSixYearsAgo;
        opp7.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp7);
        
        Opportunity opp8 = new Opportunity(Name='ChkUltimosMeses');
        opp8.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp8.StageName = 'Legacy';
        opp8.CloseDate = dateSixYearsAgo;
        opp8.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp8);
        
        Opportunity opp9 = new Opportunity(Name='ChkUltimosMeses');
        opp9.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp9.StageName = 'Legacy';
        opp9.CloseDate = dateSixYearsAgo;
        opp9.msf_IsFromLastMonthsBool__c = true;
        listOppToInsert.add(opp9);
        
        insert listOppToInsert;
        
 	}
    
    /*@isTest static void Test_UncheckUltimosMeses_QUEUEABLE(){
        
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new MSF_UncheckUtimosMeses_SCHED(50, 10));
    	Test.stopTest();    
    }*/

    @isTest
    static void Test_UncheckUltimosMeses(){
        
        Test.startTest();
        MSF_UncheckUtimosMeses_BATCH myBatchObject = new MSF_UncheckUtimosMeses_BATCH();
        Database.executeBatch(myBatchObject);
    	Test.stopTest();    

        Opportunity opp = [SELECT id, msf_IsFromLastMonthsBool__c FROM Opportunity WHERE Name = 'ChkUltimosMeses D'];
        system.assertEquals(false, opp.msf_IsFromLastMonthsBool__c);
    }
    
}