/**
* @author 		Deloitte
* @date 		12-2018
* @group 		Lead
* @description	test class for the MSF_IncompleteLeadManagement_BATCH class.
*/
@isTest
public class MSF_IncompleteLeadManagement_TEST {
    
    @testSetup static void setup(){
        
        List<Lead> lLeadsInsert = new List<Lead>();       
        
        Id RTIdLeadAssociative = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Associative').getRecordTypeId();        
        Id RTIdLeadIndividual = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Individual').getRecordTypeId();        
        
        Integer numLD = 3;
        
        //Create associative leads        
        for (Integer x=0;x<numLD;x++){
            Lead ld = new Lead (
                LastName = 'LD_Name_'+x,
                Company = 'Comp_'+x,
                recordTypeId = RTIdLeadAssociative,
                LeadSource = ''
            );
            lLeadsInsert.add(ld);
        }
        
        //Create individual SMS leads
        for (Integer x=0;x<numLD;x++){
            Lead ld = new Lead (
                LastName = 'LD_Name_SMS_'+x,
                Company = 'Comp_SMS_'+x,
                recordTypeId = RTIdLeadIndividual,
                LeadSource = 'SMS'
            );
            lLeadsInsert.add(ld);
        }
        
        //Create individual F2F leads
        for (Integer x=0;x<numLD;x++){
            Lead ld = new Lead (
                LastName = 'LD_Name_F2F_'+x,
                Company = 'Comp_F2F_'+x,
                recordTypeId = RTIdLeadIndividual,
                LeadSource = 'F2F'
            );
            lLeadsInsert.add(ld);
        } 
        
        insert lLeadsInsert;
    }
    
    @isTest static void IncompleteLeadManagementBatchTest (){
        
        List<Lead> lLead = new List<Lead>();
        
        lLead = [SELECT Id FROM Lead];
        System.assertEquals(9, lLead.size(), 'Leads have not been created correctly for the test.');
        
        Test.startTest();
            MSF_IncompleteLeadManagement_BATCH ilm = new MSF_IncompleteLeadManagement_BATCH();
            Id batchId = Database.executeBatch(ilm);
        Test.stopTest();
        
        lLead = [SELECT Id FROM Lead];
        System.assertEquals(6, lLead.size(), 'The leads that must be eliminated have not been eliminated.');
    }
    
    @isTest static void IncompleteLeadManagementSchedulerTest (){
        Test.startTest();			
        	String CRON_EXP = '0 0 0 * * ? *';
        	String jobId = System.schedule('MSF - IncompleteLeadManagementTest',CRON_EXP, new MSF_IncompleteLeadManagement_BATCH());  
        Test.stopTest();
        
     	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];       
		System.assert(ct != null, 'Job is not exist.');
		System.assert(ct.NextFireTime != null, 'Job is not schedule.');
    }
}