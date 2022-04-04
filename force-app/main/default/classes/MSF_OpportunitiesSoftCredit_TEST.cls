/**
* @author       Deloitte
* @date         02-2019
* @group        Opportunities, Contact.
* @description  test class for the MSF_OpportunitiesSoftCredit_CTRL class.
*/
@isTest
private class MSF_OpportunitiesSoftCredit_TEST {
    static Integer nOpps = 50;
    @testSetup static void setup(){
        nOpps = MSF_OpportunitiesSoftCredit_TEST.nOpps;
        Contact newC = new Contact(LastName='MSF_OpportunitiesSoftCredit_TEST_LastName1');
        insert newC;
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < nOpps; i++){
            Opportunity opp = new Opportunity(Name='MSFOpportunitiesSoftCreditTESTName'+i,
                                              StageName='Propuesta',
                                              CloseDate=date.today());
            oppList.add(opp);
        }
        
        for(Integer i = 0; i < nOpps*2; i++){
            Opportunity opp = new Opportunity(Name='MSFOpportunitiesSoftCreditTESTNamePages'+i,
                                              StageName='Propuesta',
                                              CloseDate=date.today());
            oppList.add(opp);
        }
        insert oppList;
        
        List<Opportunity> oppListData = [SELECT Id FROM Opportunity WHERE Name like 'MSFOpportunitiesSoftCreditTEST%'];
		List<OpportunityContactRole> oppContRoleList = new List<OpportunityContactRole>();
        for(Integer i = 0; i < oppListData.size(); i++){
            oppContRoleList.add(new OpportunityContactRole(ContactId=newC.Id,OpportunityId=oppListData[i].Id,Role='Dummy Role'));
        }
        insert oppContRoleList;
    }
    @isTest static void testGetAll(){
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'MSF_OpportunitiesSoftCredit_TEST_LastName1' LIMIT 1];
		Map<String, Object> returnData = (Map<String, Object>)MSF_OpportunitiesSoftCredit_CTRL.getSoftCreditOpportunities(c.Id, 0,  0);
        System.assert(!(Boolean)returnData.get('moreThanReturned'));
    }
    @isTest static void testGetAPage(){
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'MSF_OpportunitiesSoftCredit_TEST_LastName1' LIMIT 1];
		Map<String, Object> returnData = (Map<String, Object>)MSF_OpportunitiesSoftCredit_CTRL.getSoftCreditOpportunities(c.Id, 1,  MSF_OpportunitiesSoftCredit_TEST.nOpps);
        System.assert((Boolean)returnData.get('moreThanReturned'));
    }
    @isTest static void testGetLastPage(){
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'MSF_OpportunitiesSoftCredit_TEST_LastName1' LIMIT 1];
		Map<String, Object> returnData = (Map<String, Object>)MSF_OpportunitiesSoftCredit_CTRL.getSoftCreditOpportunities(c.Id, 3,  MSF_OpportunitiesSoftCredit_TEST.nOpps);
        System.assert(!(Boolean)returnData.get('moreThanReturned'));
    }
    @isTest static void testGetSoftCreditContactName(){
        Contact c = [SELECT Id,Name FROM Contact WHERE LastName = 'MSF_OpportunitiesSoftCredit_TEST_LastName1' LIMIT 1];
		Contact returnData = (Contact) MSF_OpportunitiesSoftCredit_CTRL.getSoftCreditContactName(c.Id);
        System.assertEquals(c.Name, returnData.Name);        
    }
}