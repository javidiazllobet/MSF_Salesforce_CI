/**
* @author       Deloitte
* @date         02-2019
* @group        Opportunities.
* @description  Controller for the lightning component MSF_OpportunitiesSoftCredit
*/
public without sharing class MSF_OpportunitiesSoftCredit_CTRL {
    
    @AuraEnabled
    public static Object getSoftCreditOpportunities(String Id, Integer page,  Integer nrows){
        Integer totalRowsReturned = nrows*page;
        Integer offset = nrows*(page-1);
        
        List<Opportunity> Opportunities = null;
        
        Map<String,Object> returnData = new Map<String,Object>();
        returnData.put('moreThanReturned', false);
        
        if(page == 0 && nrows == 0){
            Opportunities = [SELECT Id, Name, Amount, StageName, RecordType.DeveloperName, npe01__Payments_Made__c, CloseDate 
                             FROM Opportunity
                             WHERE Id in (SELECT OpportunityId FROM OpportunityContactRole WHERE Role != 'Donor' AND ContactId = :Id)
                            ];
        }else{
            Opportunities = [SELECT Id, Name, Amount, StageName, RecordType.DeveloperName, npe01__Payments_Made__c, CloseDate 
                             FROM Opportunity
                             WHERE Id in (SELECT OpportunityId FROM OpportunityContactRole WHERE Role != 'Donor' AND ContactId = :Id)
                             LIMIT :nrows OFFSET :offset
                            ];   
            Integer totalRows = getTotalRows(Id);
            returnData.put('moreThanReturned', totalRows > totalRowsReturned);
        }
        returnData.put('data', Opportunities);
        
        return returnData;
    }
    
    @AuraEnabled
    public static Object getSoftCreditContactName(String ids){
        Contact returndata = [SELECT Id,Name FROM Contact WHERE Id = :ids LIMIT 1];        
        return returndata;
    }
    
    private static Integer getTotalRows(String Id){
        Integer numRows = [SELECT count() 
                           FROM Opportunity
                           WHERE Id in (SELECT OpportunityId FROM OpportunityContactRole WHERE Role != 'Donor' AND ContactId = :Id)
                          ];
        return numRows;
    }   
}