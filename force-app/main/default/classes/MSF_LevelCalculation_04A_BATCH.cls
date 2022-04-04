/**
* @author       Deloitte
* @date         01-2019
* @group        Contact
* @description  Calculation of member level for organizations.
*/
global without sharing class MSF_LevelCalculation_04A_BATCH implements Database.Batchable<sObject>{
    
    global final String query;  
    
    global MSF_LevelCalculation_04A_BATCH (){
        String queryStep = '';
        queryStep  = 'SELECT Id, msf_OrganizationType__c, msf_ContactDeleteReason__c, ';        
        queryStep += 'msf_LevelScore__c, msf_LevelRelationshipScore__c, msf_Program__c, ';																					// Level & Programs fields 
        queryStep += 'msf_Forced__c, msf_PotentialAccordingOfficer__c, msf_IsStrategic__c, ';																				// Estrategic fields
        queryStep += 'msf_LevelAmountNextFiscalYear__c, msf_LevelAmountCurrentFiscalYear__c, msf_LevelAmountOneFiscalYearAgo__c, msf_LevelAmountTwoFiscalYearsAgo__c, ';	// Amount fields
        queryStep += 'msf_LevelAmountLifetime__c, msf_LevelHCLifetimeVD__c ';																								// Amount lifetime fields
        queryStep += 'FROM Contact ';
        queryStep += 'WHERE RecordType.DeveloperName = \'Organization\' ';
        queryStep += 'AND (msf_RecalculateLevel__c = TRUE ';
        queryStep += 'OR msf_Level__c = null ';
        queryStep += 'OR msf_RelationshipLevel__c = null) ';
        query = queryStep; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){

        List<Contact> lConToUpdate = new List<Contact>();
        
        //Define level of member
        for(Contact c : scope){
            
            if(levelCondition(c,10000))
            {   
                c.msf_LevelScore__c = 100; //BIG
                c.msf_LevelRelationshipScore__c = setRelationshipLevel(c,50); //One to one               
            }
            else if(levelCondition(c,8000))
            {   
                c.msf_LevelScore__c = 80; //MID+
                c.msf_LevelRelationshipScore__c = setRelationshipLevel(c,30); //One to few
            }
            else if(levelCondition(c,1500))
            {   
                c.msf_LevelScore__c = 60; //MID
                c.msf_LevelRelationshipScore__c = setRelationshipLevel(c,30); //One to few     
            }
            else if(levelCondition(c,0) || c.msf_LevelAmountLifetime__c > 0)
            {                 
                c.msf_LevelScore__c = 40; //MASS
                c.msf_LevelRelationshipScore__c = setRelationshipLevel(c,20); //One to many
            }
            else if(c.msf_LevelAmountLifetime__c == 0 && c.msf_LevelHCLifetimeVD__c != null && c.msf_LevelHCLifetimeVD__c > 0) 
            {                 
                c.msf_LevelScore__c = 1; //NONE 
                c.msf_LevelRelationshipScore__c = setRelationshipLevel(c,10); //None
            }
            else if(c.msf_LevelAmountLifetime__c == 0)
            {       
                c.msf_LevelScore__c = 20; //PROSPECTOS
                c.msf_LevelRelationshipScore__c = setRelationshipLevel(c,20); //One to many
            }

            if(String.isNotBlank(c.msf_ContactDeleteReason__c)){
            	c.msf_LevelRelationshipScore__c = 10; //None    
            }            
            
            c.msf_Program__c = setOrganizationProgram(c);
            
            c.msf_RecalculateLevel__c = FALSE;
            
            lConToUpdate.add(c);                        
        }

        if(!lConToUpdate.isEmpty()){
            // DML statement
            Database.SaveResult[] srList = Database.update(lConToUpdate, false);
            
            //*
            List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
            
            for (Database.SaveResult sr : srList) { // Iterate through each returned result
                if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                    for(Database.Error err : sr.getErrors()) {
                        msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_LevelCalculation_04A', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
                        lAPE.add(tempAPE);
                    }
                }            
            }  
            
            if(!lAPE.isEmpty()){
                insert lAPE;
            }//*/
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('END BATCH - MSF_LevelCalculation_04A_BATCH');
    } 
    
    
    //PRIVATE METHODS
    
    private boolean levelCondition (Contact c, Integer iLimit){        
        
        if(iLimit == 0){
            return (c.msf_LevelAmountNextFiscalYear__c > iLimit || 
                    c.msf_LevelAmountCurrentFiscalYear__c > iLimit || 
                    c.msf_LevelAmountOneFiscalYearAgo__c > iLimit);              
        }
        
        return (c.msf_LevelAmountNextFiscalYear__c >= iLimit || 
                c.msf_LevelAmountCurrentFiscalYear__c >= iLimit || 
                c.msf_LevelAmountOneFiscalYearAgo__c >= iLimit);       
    }
    
    private Integer setRelationshipLevel (Contact c, Integer iDefault){
        
        if(c.msf_Forced__c == '121' || c.msf_PotentialAccordingOfficer__c == '121' || c.msf_IsStrategic__c){
            return 50; //One to one
        }
        
        return iDefault;
    }
          
    private String setOrganizationProgram (Contact c){
        
        String sProgram = '';    
         
        if(c.msf_LevelRelationshipScore__c == 50){
            if(c.msf_OrganizationType__c == 'Foundation'){
                sProgram = 'Fundaciones Estratégicas';    
            }else if(c.msf_OrganizationType__c == 'Public Entity'){
                sProgram = 'Instituciones Públicas Estratégicas';                    
            }else if(c.msf_OrganizationType__c == 'Company' || c.msf_OrganizationType__c == 'Collective'){
                sProgram = 'Empresas y Colectivos Estratégicas';    
            }              
        } 
        else if(c.msf_LevelRelationshipScore__c == 30){
            if(c.msf_OrganizationType__c == 'Foundation'){
                sProgram = 'Fundaciones Mid, Mid +';    
            }else if(c.msf_OrganizationType__c == 'Public Entity'){
                sProgram = 'Instituciones Públicas Mid y Mid +';      
            }else if(c.msf_OrganizationType__c == 'Company' || c.msf_OrganizationType__c == 'Collective'){
                sProgram = 'Empresas y Colectivos Mid, Mid +';    
            }          
        } 
        else if(c.msf_LevelRelationshipScore__c == 20){
            if(c.msf_OrganizationType__c == 'Foundation'){
                if(c.msf_LevelScore__c == 40){
                    sProgram = 'Fundaciones Mass';
                }else if(c.msf_LevelScore__c == 20){
                    sProgram = 'Prospectos Fundaciones Mass';    
                }                    
            }else if(c.msf_OrganizationType__c == 'Public Entity'){
                if(c.msf_LevelScore__c == 40){
                    sProgram = 'Instituciones Públicas Mass';
                }else if(c.msf_LevelScore__c == 20){
                    sProgram = null;  
                }       
            }else if(c.msf_OrganizationType__c == 'Company' || c.msf_OrganizationType__c == 'Collective'){
                if(c.msf_LevelScore__c == 40){
                    sProgram = 'Empresas y Colectivos Mass';
                }else if(c.msf_LevelScore__c == 20){
                    sProgram = 'Prospectos Empresas & Colectivos Mass';    
                }    
            }      
        } 
        else if(c.msf_LevelRelationshipScore__c == 10){
            sProgram = 'Vehículo donación de Gran Donante = YES';    
        }
        
        return sProgram;
    }    
}