/**
* @author       Deloitte
* @date         01-2019
* @group        Contact
* @description  Calculation of member level.
*/
global without sharing class MSF_LevelFieldsChanges_TDTM extends npsp.TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description  Trigger Handler on Contact that handles the changes in the fields involved in the 
    *               calculation of levels
    * @param        listNew the list of Contacts from trigger new. 
    * @param        listOld the list of Contacts from trigger old. 
    * @param        triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param        objResult the describe for Contacts.
    * @return       dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        //Attributes
        List<Contact> lNewCon = (List<Contact>) newlist;
        List<Contact> lOldCon = (List<Contact>) oldlist;
        Map<Id, Contact> mOldCon = new Map<Id, Contact>();
        if(lOldCon != null){            
            mOldCon.putAll(lOldCon);
        }
        
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {            
            for(Contact c : lNewCon){
                if(!c.msf_RecalculateLevel__c){
                	c.msf_RecalculateLevel__c = recalculateLevel(c, mOldCon.get(c.Id));     
                } 
                setLevelDates(c, mOldCon.get(c.Id));
            }
        }
        
        return null;        
    }
    
    
    //PRIVATE METHODS
    
    /*******************************************************************************************************
    * @description  The helper method for Trigger Handler that compare if there is a difference in certain 
    * 				fields between two contacts and set a flag if have some difference.
    * @param        newC is the new Contact to be saved.
    * @param        oldC is the old Contact to compare.
    ********************************************************************************************************/ 
    private boolean recalculateLevel(Contact newC, Contact oldC){
        boolean bRecalculate = false;
        if(newC.msf_Forced__c != oldC.msf_Forced__c ||
           newC.msf_PotentialAccordingOfficer__c != oldC.msf_PotentialAccordingOfficer__c ||
           newC.msf_IsStrategic__c != oldC.msf_IsStrategic__c ||
           newC.msf_ContactInformationSummary__c != oldC.msf_ContactInformationSummary__c ||
           newC.msf_PercomsSummary__c != oldC.msf_PercomsSummary__c ||
           newC.msf_RelationshipMidDonorsProgram__c != oldC.msf_RelationshipMidDonorsProgram__c ||
           newC.msf_RelationshipMajorDonorsProgram__c != oldC.msf_RelationshipMajorDonorsProgram__c ||
           newC.msf_IsAssosiative__c != oldC.msf_IsAssosiative__c ||
           newC.msf_IsPublicPerson__c != oldC.msf_IsPublicPerson__c ||
           newC.msf_IsInfluencer__c != oldC.msf_IsInfluencer__c ||
           newC.msf_BigDonorContact__c != oldC.msf_BigDonorContact__c ||
           // Economic level fields
           newC.msf_LevelHCLifetime__c != oldC.msf_LevelHCLifetime__c ||
           newC.msf_LevelHCLifetimeVD__c != oldC.msf_LevelHCLifetimeVD__c ||                    
           newC.msf_LevelHCNextFiscalYear__c != oldC.msf_LevelHCNextFiscalYear__c ||
           newC.msf_LevelSCNextFiscalYear__c != oldC.msf_LevelSCNextFiscalYear__c ||
           newC.msf_LevelHCCurrentFiscalYear__c != oldC.msf_LevelHCCurrentFiscalYear__c ||
           newC.msf_LevelSCCurrentFiscalYear__c != oldC.msf_LevelSCCurrentFiscalYear__c ||
           newC.msf_LevelHCOneFiscalYearAgo__c != oldC.msf_LevelHCOneFiscalYearAgo__c ||
           newC.msf_LevelSCOneFiscalYearAgo__c != oldC.msf_LevelSCOneFiscalYearAgo__c ||
           newC.msf_LevelHCTwoFiscalYearsAgo__c != oldC.msf_LevelHCTwoFiscalYearsAgo__c ||  
           newC.msf_LevelSCTwoFiscalYearsAgo__c != oldC.msf_LevelSCTwoFiscalYearsAgo__c
          )
        {
            bRecalculate = true;    
        } 
        
        return bRecalculate;
    }  
    
    /*******************************************************************************************************
    * @description  The helper method for Trigger Handler that compare if there is a difference in levels fields 
    *               between two contacts and set a date of change.
    * @param        c is the new Contact to be saved.
    * @param        cOld is the old Contact to compare.
    ********************************************************************************************************/ 
    private void setLevelDates (Contact c, Contact cOld){
        if(c.msf_Level__c != cOld.msf_Level__c){
            c.msf_FechaCambioLevelEconomico__c = date.today();
        }
        if(c.msf_RelationshipLevel__c != cOld.msf_RelationshipLevel__c){
            c.msf_FechaCambioLevelRelacion__c = date.today();
        }
    }
}