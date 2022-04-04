/**
* @author       Deloitte
* @date         10-2019
* @group        Historical Opportunities
* @description  Controller for the lightning component MSF_ReassignOpportunity
*/
public without sharing class MSF_ReassignOpportunity_CTRL {
	
	@TestVisible private static msf_opportunity_h__x mockedSingleRequest = new msf_opportunity_h__x();
    @TestVisible private static List<msf_opportunity_h__x> mockedListRequests = new List<msf_opportunity_h__x>();
    
    /*******************************************************************************************************
	* @description	Get the contact information of the opportunity.
    * @param		hoppId is Id of the msf_opportunity_h__x to reassign.				
    * @return		Map<String, Object>	that contains the associated contact to reallocate and the historical 
    * 				opportunity to recalculate.
	********************************************************************************************************/    
    @AuraEnabled
    public static Object getInformation(ID hoppId){
        
        Map<String,Object> outputMap = new Map<String,Object>();
        outputMap.put('success',true);
        
        msf_opportunity_h__x ohs = new msf_opportunity_h__x();
        Opportunity o = new Opportunity();
        Contact c = new Contact();

        if(Test.isRunningTest()){
            outputMap.put('record',mockedSingleRequest);    
            ohs = mockedSingleRequest;
        }else{
            ohs = [SELECT npsp_primary_contact_c__c, closedate__c, msf_entrydate_c__c, amount__c
                   FROM msf_opportunity_h__x 
                   WHERE ID =: hoppId 
                   LIMIT 1];
            
            outputMap.put('record',ohs);
        }
        
        try{
            c = [SELECT Id, msf_CRMExternalId__c, Name, msf_NIF__c, AccountId
                 FROM Contact 
                 WHERE msf_CRMExternalId__c =: ohs.npsp_primary_contact_c__c 
                 LIMIT 1];
            
            outputMap.put('contact',c);

            try{
                Integer sAnno = ohs.closedate__c.year();
                
                o = [SELECT Id, Amount, msf_SmallestHistoricalGift__c, msf_LargestHistoricalGift__c, msf_TotalNumberHistoricalGifts__c, msf_FirstDateHistoricalGift__c, CloseDate 
                     FROM Opportunity 
                     WHERE npsp__primary_contact__c =: c.Id 
                     AND RecordType.DeveloperName = 'Historical' 
                     AND CALENDAR_YEAR(CloseDate) =: sAnno
                     LIMIT 1]; 
                
                outputMap.put('opp',o);    
            }catch(Exception e){
                System.debug('>> No se ha encontrado o no tiene una oportunidad historica el contacto en el año indicado <<');    
            }  
        }catch(Exception e){
            outputMap.put('success',false);
            outputMap.put('msg',System.label.MSF_REASSIGN_CONTACT_NOT_FOUND);
            return outputMap;    
        }
		        
        return outputMap;        
    }
    
    /*******************************************************************************************************
	* @description	Get the contact information to reassign.
    * @param		numMember is the member number of the contact to reassign.	
    * @param		dCloseDate is the close date of the opportunity to reassign.	
    * @return		Map<String, Object>	that contains the associated contact to reallocate and the historical 
    * 				opportunity to recalculate.
	********************************************************************************************************/    
    @AuraEnabled
    public static Object getTargetInformation(String numMember, Date dCloseDate){
        
        Map<String,Object> outputMap = new Map<String,Object>();
        outputMap.put('success',true);
        outputMap.put('msg','');
        
        Opportunity o = new Opportunity();
        Contact c = new Contact();
        
        if(String.isNotBlank(numMember)) {      
            try{
                c = [SELECT Id, msf_CRMExternalId__c, Name, msf_NIF__c, AccountId, Account.msf_CustomExternalId__c
                     FROM Contact 
                     WHERE msf_CRMExternalId__c =: numMember 
                     LIMIT 1];
                
                outputMap.put('contact',c);
                
                try{
                    Integer sAnno = dCloseDate.year();
                    
                    o = [SELECT Id, Amount, msf_SmallestHistoricalGift__c, msf_LargestHistoricalGift__c, msf_TotalNumberHistoricalGifts__c, msf_FirstDateHistoricalGift__c, CloseDate 
                         FROM Opportunity 
                         WHERE npsp__primary_contact__c =: c.Id
                         AND RecordType.DeveloperName = 'Historical' 
                         AND CALENDAR_YEAR(CloseDate) =: sAnno
                         LIMIT 1]; 
                    
                    outputMap.put('opp',o);    
                }catch(Exception e){
                    System.debug('>> No se ha encontrado o no tiene una oportunidad historica el contacto en el año indicado <<');    
                }  
            }catch(Exception e){
                outputMap.put('success',false);
                outputMap.put('msg',System.label.MSF_REASSIGN_CONTACT_NOT_FOUND);
                return outputMap;    
            }
        }else{
            outputMap.put('success',false);
            outputMap.put('msg',System.label.MSF_REASSIGN_REQUIRED);      
        }
		        
        return outputMap;        
    }
    
    /*******************************************************************************************************
	* @description	The process of reassign of historical opportunity.
    * @param		cOrigin	is the contact owner of the opportunity to reassign.
    * @param		cTarget is the target contact of the opportunity to reassign.
    * @param		exOppHis is the opportunity to reassign.
    * @param		oOrigin is the historical opportunity of the currente contact to recalculate.
    * @param		oTarget is the historical opportunity of the target contact to recalculate.
    * @return		Map<String, Object>	that contains the result of the reassign process.
	********************************************************************************************************/    
    @AuraEnabled
    public static Object reassignProcess (Contact cOrigin, Contact cTarget, msf_opportunity_h__x exOppHis, Opportunity oOrigin, Opportunity oTarget){
        
        Map<String,Object> outputMap = new Map<String,Object>();
        outputMap.put('success',true);    
        
        Integer sAnno = exOppHis.closedate__c.year();
        
        Double maxAmout = 0, minAmount = 0, totalAmount = 0;
        Date dFirstDate = null, dLastDate = null;
        Integer totalDonations = 0;
        
        List<Opportunity> lOpp = new List<Opportunity>();
        
        try{
            // ReassignOpportunityHistory
            exOppHis.npsp_primary_contact_c__c = cTarget.msf_CRMExternalId__c;
            exOppHis.accountid__c = cTarget.Account.msf_CustomExternalId__c;

            
            Database.SaveResult sr = Database.updateImmediate(exOppHis); 
            if(!sr.isSuccess()){
                outputMap.put('msg','# Error al actualizar oportunidad en DM #');    
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }                
            }
            
            // ReassignOrigin
            oOrigin = getOpportunity(cOrigin, oOrigin, sAnno);
            if(oOrigin != null){
                lOpp.add(oOrigin);
            }
            
            // ReassignTarget
            oTarget = getOpportunity(cTarget, oTarget, sAnno);
            if(oTarget != null){
                lOpp.add(oTarget);
            }     
            
            try{
                upsert lOpp;
            }catch(Exception e){
                outputMap.put('msg','# Error al crear/actualizar oportunidades historicas #');    
            }            
        }catch(Exception ex){
         	System.debug('# Error reasignación #');   
            outputMap.put('msg','# Error reasignación #');
        }
             
        return outputMap;
    }
    
	/*******************************************************************************************************
	* @description	Recalculate historical opportunity.
    * @param		c is the contact to recalculate opportunity.
    * @param		o is the opportunity to recalculate(if exist).
    * @param		iYear is the number that represents the year of the historical opportunity.
    * @return		Opportunity that has been recalculated.
	********************************************************************************************************/
    private static Opportunity getOpportunity (Contact c, Opportunity o, Integer iYear){
        
    	Opportunity tempOpp = new Opportunity();
        
        Double maxAmout = 0, minAmount = 0, totalAmount = 0;
        Date dFirstDate = null, dLastDate = null;
        Integer totalDonations = 0;
        
        Date minDate = Date.newInstance(iYear, 01, 01);
        Date maxDate = Date.newInstance(iYear, 12, 31);
        
        ID rtId = [SELECT Id FROM RecordType WHERE DeveloperName='Historical' AND SObjectType = 'Opportunity'].Id;
        
        List<msf_opportunity_h__x> lOhsx = new List<msf_opportunity_h__x>();
        if(Test.isRunningTest()){      
            lOhsx = mockedListRequests;
        }else{
            lOhsx = [SELECT amount__c, closedate__c FROM msf_opportunity_h__x 
                     WHERE npsp_primary_contact_c__c =: c.msf_CRMExternalId__c
                     AND closedate__c >=: minDate 
                     AND closedate__c <=: maxDate];	   
        }
            
        for(msf_opportunity_h__x oHistory : lOhsx)
        {
            maxAmout = (maxAmout == 0 || maxAmout < oHistory.amount__c) ? oHistory.amount__c : maxAmout;
            minAmount = (minAmount == 0 || minAmount > oHistory.amount__c) ? oHistory.amount__c : minAmount;
            totalAmount += oHistory.amount__c;
            dFirstDate = (dFirstDate == null || dFirstDate < oHistory.closedate__c) ? oHistory.closedate__c : dFirstDate;
            dLastDate = (dLastDate == null || dLastDate > oHistory.closedate__c) ? oHistory.closedate__c : dLastDate;
            totalDonations += 1;    
        }
        
        if(totalDonations == 0 && o != null){
            //delete o;  
            return null;
        }else if(totalDonations > 0){            
            if(o != null){
                tempOpp = o;
            }else{
                tempOpp.npsp__Primary_Contact__c = c.Id;
                tempOpp.AccountId = c.AccountId;
                tempOpp.Type = 'Historical';   
                tempOpp.msf_CustomExternalId__c = c.msf_CRMExternalId__c+'_'+dFirstDate.year();
                tempOpp.RecordTypeId = rtId;
                tempOpp.StageName = 'Cobrada';
                tempOpp.Type = 'Historical';
            }            
            
            tempOpp.Amount = totalAmount;
            tempOpp.msf_SmallestHistoricalGift__c = minAmount;
            tempOpp.msf_LargestHistoricalGift__c = maxAmout;
            tempOpp.msf_TotalNumberHistoricalGifts__c = totalDonations;
            tempOpp.msf_FirstDateHistoricalGift__c = dFirstDate;
            tempOpp.msf_EntryDate__c = dFirstDate;
            tempOpp.CloseDate = dLastDate;            
        }
        
        return tempOpp;
    }
}