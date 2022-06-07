/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 04-04-2022
 * @last modified by  : sheredia@omegacrmconsulting.com
**/
@isTest
public with sharing class MSF_ReassignOpportunity_CTRL_TEST {

    @TestSetup
    static void makeData(){
    }

    @isTest static void testGetInformationNoContact() {
        try {
            MSF_ReassignOpportunity_CTRL.getInformation(null);   
        } catch (Exception e) {
            System.assert(false, 'Error: ' + e);
        }
    }

    @isTest static void testGetInformationContactTry() { 
        //TODO Hacer que con.msf_CRMExternalId__c = msf_opportunity_h__x.npsp_primary_contact_c__c 
        try {
            Contact con = new Contact(LastName='Test');
            insert con;
    
            MSF_ReassignOpportunity_CTRL.getInformation(null); 
        } catch (Exception e) {
            System.assert(false, 'Error: ' + e);
        }
    }

    @isTest static void testGetInformationContactCatch() {
        try {
            Contact con = new Contact(LastName='Test');
            insert con;
    
            MSF_ReassignOpportunity_CTRL.getInformation(null); 
        } catch (Exception e) {
            System.assert(false, 'Error: ' + e);
        }
    }

    @isTest static void testGetTargetInformation() {
        try {
            Contact con = new Contact(LastName='Test');
            insert con;

            Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Prospecting' , npsp__primary_contact__c = con.Id, CloseDate = System.today(), RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Historical'].ID );
            insert opp;

            con = [SELECT ID, msf_CRMExternalId__c FROM Contact LIMIT 1];

            MSF_ReassignOpportunity_CTRL.getTargetInformation(con.msf_CRMExternalId__c, System.today());
        } catch (Exception e) {
            System.assert(false, 'Error: ' + e);
        }
    }

    @isTest static void testGetTargetInformationCatch() {
        try {
            Contact con = new Contact(LastName='Test');
            insert con;

            MSF_ReassignOpportunity_CTRL.getTargetInformation(null, System.today());
            
            MSF_ReassignOpportunity_CTRL.getTargetInformation('1234', System.today());
        } catch (Exception e) {
            System.assert(false, 'Error: ' + e);
        }
    }

    @isTest static void testReassignProcess() {
        try {
            Contact con = new Contact(LastName='Test');
            insert con;

            Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Prospecting' , npsp__primary_contact__c = con.Id, CloseDate = System.today(), RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Historical'].ID );
            insert opp;

            msf_opportunity_h__x exOppHis = new msf_opportunity_h__x(closedate__c = System.today(), amount__c = 0);

            MSF_ReassignOpportunity_CTRL.mockedListRequests.add(exOppHis);
            MSF_ReassignOpportunity_CTRL.reassignProcess (con, con, exOppHis, opp, opp);
            
        } catch (Exception e) {
            System.assert(false, 'Error: ' + e);
        }
    }

    @isTest static void testReassignProcessTargetNull() {
        try {
            Contact con = new Contact(LastName='Test');
            insert con;

            Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Prospecting' , npsp__primary_contact__c = con.Id, CloseDate = System.today(), RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Historical'].ID );
            insert opp;

            msf_opportunity_h__x exOppHis = new msf_opportunity_h__x(closedate__c = System.today(), amount__c = 0);

            MSF_ReassignOpportunity_CTRL.mockedListRequests.add(exOppHis);
            MSF_ReassignOpportunity_CTRL.reassignProcess (con, con, exOppHis, opp, null);
            
        } catch (Exception e) {
            System.assert(false, 'Error: ' + e);
        }
    }

}