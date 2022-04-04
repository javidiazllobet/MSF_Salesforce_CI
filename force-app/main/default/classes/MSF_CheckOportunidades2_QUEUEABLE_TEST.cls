/**
* @author 		Omega
* @date 		01/07/2021
* @group 		Opportunity
* @description	Test ZenIT#25762
*/
@isTest
public class MSF_CheckOportunidades2_QUEUEABLE_TEST {
    
	@testSetup static void setup(){
        List<Opportunity> listOppToInsert = new List<Opportunity>();
        Opportunity oppD = new Opportunity(Name='ChkUltimosMeses D');
        oppD.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD.StageName = 'Legacy';
        oppD.CloseDate = date.today()-365*3;
        oppD.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD);
        
        Opportunity oppD2 = new Opportunity(Name='ChkUltimosMeses D');
        oppD2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD2.StageName = 'Legacy';
        oppD2.CloseDate = date.today()-365*3;
        oppD2.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD2);
        
        Opportunity oppD3 = new Opportunity(Name='ChkUltimosMeses D');
        oppD3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD3.StageName = 'Legacy';
        oppD3.CloseDate = date.today()-365*3;
        oppD3.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD3);
        
        Opportunity oppD4 = new Opportunity(Name='ChkUltimosMeses D');
        oppD4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD4.StageName = 'Legacy';
        oppD4.CloseDate = date.today()-365*3;
        oppD4.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD4);
        
        Opportunity oppD5 = new Opportunity(Name='ChkUltimosMeses D');
        oppD5.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD5.StageName = 'Legacy';
        oppD5.CloseDate = date.today()-365*3;
        oppD5.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD5);
        
        Opportunity oppD6 = new Opportunity(Name='ChkUltimosMeses D');
        oppD6.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD6.StageName = 'Legacy';
        oppD6.CloseDate = date.today()-365*3;
        oppD6.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD6);
        
        Opportunity oppD7 = new Opportunity(Name='ChkUltimosMeses D');
        oppD7.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD7.StageName = 'Legacy';
        oppD7.CloseDate = date.today()-365*3;
        oppD7.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD7);
        
        Opportunity oppD8 = new Opportunity(Name='ChkUltimosMeses D');
        oppD8.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD8.StageName = 'Legacy';
        oppD8.CloseDate = date.today()-365*3;
        oppD8.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD8);
        
        Opportunity oppD9 = new Opportunity(Name='ChkUltimosMeses D');
        oppD9.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD9.StageName = 'Legacy';
        oppD9.CloseDate = date.today()-365*3;
        oppD9.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD9);
        
        Opportunity oppD10 = new Opportunity(Name='ChkUltimosMeses D');
        oppD10.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        oppD10.StageName = 'Legacy';
        oppD10.CloseDate = date.today()-365*3;
        oppD10.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(oppD10);
        
        Opportunity opp = new Opportunity(Name='ChkUltimosMeses');
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Legacy').getRecordTypeId();
        opp.StageName = 'Legacy';
        opp.CloseDate = date.today()-365*3;
        opp.msf_IsFromLastMonthsBool__c = false;
        listOppToInsert.add(opp);
        
        insert listOppToInsert;
        
 	}
    
    @isTest static void Test_CheckUltimosMeses_SCHED(){
        
        Test.startTest();
        System.enqueueJob(new MSF_CheckOportunidades2_QUEUEABLE());
    	Test.stopTest();        
     
    }
}