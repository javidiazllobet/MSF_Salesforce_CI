/**
* @author       Deloitte
* @date         01-2019
* @group        Contact
* @description  Calculation of member level for Individuals.
*/
global without sharing class MSF_LevelCalculation_04B_BATCH implements Database.Batchable<sObject>{
    
    global final String query; 
    
    global MSF_LevelCalculation_04B_BATCH (){              
        String queryStep = '';
        queryStep  = 'SELECT Id, msf_NextLevelCheck__c, msf_ContactDeleteReason__c, ';         
        queryStep += 'msf_LevelScore__c, msf_LevelRelationshipScore__c, msf_Program__c, ';                                                                          			// Level & Programs fields  
        queryStep += 'msf_Forced__c, msf_PotentialAccordingOfficer__c, msf_IsStrategic__c, ';                                                                       			// Estrategic fields        
        queryStep += 'msf_LevelAmountNextFiscalYear__c, msf_LevelAmountCurrentFiscalYear__c, msf_LevelAmountOneFiscalYearAgo__c, msf_LevelAmountTwoFiscalYearsAgo__c, ';		// Amount fields
        queryStep += 'msf_LevelAmountLifetime__c, msf_LevelHCLifetimeVD__c, ';																									// Amount lifetime fields
        queryStep += 'msf_RelationshipMidDonorsProgram__c, msf_RelationshipMajorDonorsProgram__c, msf_IsAssosiative__c, ';                                          			// Other fields to set program logic
        queryStep += 'msf_ContactInformationSummary__c, msf_PercomsSummary__c, msf_FirstEntryDateRecurringDonor__c, ';                                                          // Other fields to set program logic
        queryStep += 'msf_IsActiveDonor__c, msf_IsActiveRecurringDonor__c, msf_IsPublicPerson__c, msf_IsInfluencer__c, msf_BigDonorContact__c ';                    			// Other fields to set program logic
        queryStep += 'FROM Contact ';
        queryStep += 'WHERE RecordType.DeveloperName = \'Individual_Contact\' ';
        queryStep += 'AND (msf_RecalculateLevel__c = TRUE ';
        queryStep += 'OR msf_RelationshipLevel__c = null ';
        queryStep += 'OR msf_Level__c = null ';
        queryStep += 'OR (msf_NextLevelCheck__c != null AND msf_NextLevelCheck__c < TOMORROW)) ';
        query = queryStep; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){

        List<Contact> lConToUpdate = new List<Contact>();
        Set<ID> sContactsWithLegacyOpp = new Set<ID>();        
        Set<ID> sContactsLessOneYear = new Set<ID>();  
        Set<ID> sIsTestamentariProgram = new Set<ID>();
        Set<ID> sIsISProgram = new Set<ID>();
        Map<ID, Contact> mCon = new Map<ID, Contact>(scope); 
        
        if(!scope.isEmpty()){
            Set<ID> sConId = new Map<ID, Contact>(scope).keyset(); 
            
            for(Opportunity opp : [SELECT npsp__Primary_Contact__c FROM Opportunity WHERE npsp__Primary_Contact__c IN: sConId AND RecordType.DeveloperName = 'Legacy' AND StageName = 'Testamento a favor']){
                sContactsWithLegacyOpp.add(opp.npsp__Primary_Contact__c);
            }
            for(Opportunity opp : [SELECT npsp__Primary_Contact__c FROM Opportunity WHERE npsp__Primary_Contact__c IN: sConId AND Type = 'Herencia']){
                sIsTestamentariProgram.add(opp.npsp__Primary_Contact__c);
            }
            for(Campaign cam : [SELECT Id, msf_PromoterIndividual__c, (SELECT Id FROM Opportunities WHERE CloseDate = LAST_N_DAYS:730 AND IsWon = true LIMIT 1) FROM Campaign WHERE msf_PromoterIndividual__c IN: sConId]){
                if(cam.Opportunities != null && !cam.Opportunities.isEmpty()){
                    sIsISProgram.add(cam.msf_PromoterIndividual__c);   
                }
            }
            for(npe03__Recurring_Donation__c rd : [SELECT npe03__Contact__c, npe03__Date_Established__c FROM npe03__Recurring_Donation__c WHERE npe03__Contact__c IN: sConId AND npe03__Open_Ended_Status__c = 'Open' AND RecordType.DeveloperName = 'Recurring_donation' AND npe03__Date_Established__c = LAST_N_DAYS:365]){
                sContactsLessOneYear.add(rd.npe03__Contact__c); 
                Date tempDate = mCon.get(rd.npe03__Contact__c).msf_NextLevelCheck__c;
                Date nextDateCheck = rd.npe03__Date_Established__c.addYears(1); 
                
                if((tempDate == null && nextDateCheck > date.today()) || (tempDate != null && nextDateCheck > date.today() && nextDateCheck < tempDate)){
                    mCon.get(rd.npe03__Contact__c).msf_NextLevelCheck__c = nextDateCheck;   
                }
            }  
        }              
        
        for(Contact con : scope){
            if(levelCondition(con,10000) || (con.msf_LevelAmountTwoFiscalYearsAgo__c) >= 10000)
            {   
                con.msf_LevelScore__c = 100; //BIG
                con.msf_LevelRelationshipScore__c = setRelationshipLevel(con,50,sContactsWithLegacyOpp); //'One to one'
            }
            else if(levelCondition(con,1000))
            {   
                con.msf_LevelScore__c = 80; //MID+
                con.msf_LevelRelationshipScore__c = setRelationshipLevel(con,40,sContactsWithLegacyOpp); //'One to few+'
            }
            else if(levelCondition(con,500))
            {   
                con.msf_LevelScore__c = 60; //MID
                con.msf_LevelRelationshipScore__c = setRelationshipLevel(con,30,sContactsWithLegacyOpp); //'One to few'
            }
            else if(con.msf_LevelAmountLifetime__c > 0)
            {                 
                con.msf_LevelScore__c = 40; //MASS
                con.msf_LevelRelationshipScore__c = setRelationshipLevel(con,20,sContactsWithLegacyOpp); //'One to many'
            }
            else
            {
                con.msf_LevelScore__c = 1; //NONE
                con.msf_LevelRelationshipScore__c = setRelationshipLevel(con,20,sContactsWithLegacyOpp); //'One to many'
            }
            
            if(String.isNotBlank(con.msf_ContactDeleteReason__c)){
            	con.msf_LevelRelationshipScore__c = 10; //None    
            }

            con.msf_ProgramaIS__c = sIsISProgram.contains(con.Id);
            con.msf_ProgramaHerencias__c = sIsTestamentariProgram.contains(con.Id);       
            
            con.msf_Program__c = setIndividualProgram(con, sContactsLessOneYear);
            
            con.msf_RecalculateLevel__c = FALSE;
            
            if(sContactsLessOneYear.contains(con.Id)){
                con.msf_NextLevelCheck__c = mCon.get(con.Id).msf_NextLevelCheck__c;    
            }else{
                con.msf_NextLevelCheck__c = null;    
            }
            
            lConToUpdate.add(con);
        }
    
        if(!lConToUpdate.isEmpty()){
            // DML statement
            Database.SaveResult[] srList = Database.update(lConToUpdate, false);
            
            //*
            List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
            
            for (Database.SaveResult sr : srList) { // Iterate through each returned result
                if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                    for(Database.Error err : sr.getErrors()) {
                        msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_LevelCalculation_04B', msf_RecordId__c = scope.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = String.valueOf(err.getMessage()).abbreviate(255));
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
        System.debug('END BATCH - MSF_LevelCalculation_04B_BATCH');
    }
    
    
    //PRIVATE METHODS
    
    private boolean levelCondition (Contact c, Integer iLimit){ 
        
        return (c.msf_LevelAmountNextFiscalYear__c >= iLimit || c.msf_LevelAmountCurrentFiscalYear__c >= iLimit || c.msf_LevelAmountOneFiscalYearAgo__c >= iLimit);  
    }
    
    private Integer setRelationshipLevel (Contact con, Integer iDefault, Set<ID> sContactsWithLegacyOpp){
        
        if(con.msf_Forced__c == '121' || con.msf_PotentialAccordingOfficer__c == '121' || con.msf_IsStrategic__c || (iDefault == 50 && con.msf_Forced__c != '12Few') ){
            return 50; //One to one
        }
        else if(con.msf_Forced__c == '12Few' || con.msf_PotentialAccordingOfficer__c == '12Few' || sContactsWithLegacyOpp.contains(con.Id)){
            return 40; //One to few+    
        }
        
        return iDefault;
    } 

    private String setIndividualProgram (Contact con, Set<ID> sLessOneYearOldMember){
        
        String sProgram = ''; 
        
        if(con.msf_LevelRelationshipScore__c == 50){
            if(con.msf_ContactInformationSummary__c == 'No data' 
               || con.msf_PercomsSummary__c == 'Nada' || con.msf_PercomsSummary__c == 'Sólo certificado fiscal' 
               || con.msf_RelationshipMajorDonorsProgram__c == 'Sin Mantenimiento' || con.msf_RelationshipMajorDonorsProgram__c == 'IS Sin Mantenimiento')
            {
                sProgram = 'Otros 121';    
            }
            else if(con.msf_LevelScore__c == 100 || con.msf_Forced__c == '121'){
                sProgram = 'Major Donors';
            }
            else if(con.msf_LevelScore__c != 100){
                if(con.msf_PotentialAccordingOfficer__c == '121'){
                    sProgram = 'Potenciales a Major Donors';   
                }
                else if(con.msf_IsStrategic__c){
                    sProgram = 'Públicos Especiales';    
                }   
            }                 
        } 
        else if(con.msf_LevelRelationshipScore__c == 40){
            if(con.msf_ContactInformationSummary__c == 'No data' 
               || con.msf_PercomsSummary__c == 'Nada' || con.msf_PercomsSummary__c == 'Sólo certificado fiscal' 
               || con.msf_RelationshipMidDonorsProgram__c == 'Sin Mantenimiento' || con.msf_RelationshipMidDonorsProgram__c == 'IS Sin Mantenimiento')
            {
                sProgram = 'Otros 12Few+';    
            }
            else if(con.msf_Forced__c == '12Few' || con.msf_PotentialAccordingOfficer__c == '12Few' || con.msf_LevelScore__c == 80){
                sProgram = 'Mid+ Donors';    
            }
            else if(con.msf_ProgramaHerencias__c){
                sProgram = 'Testamentarios';     
            }
            else{
                sProgram = 'Mid+ Donors';    
            }
        }
        else if(con.msf_LevelRelationshipScore__c == 30){
            if(con.msf_IsAssosiative__c){
                sProgram = 'Otros programas transversales';    
            }
            else{
                if(con.msf_IsActiveRecurringDonor__c == 'Socio'){
                    if(sLessOneYearOldMember.contains(con.Id) && con.msf_FirstEntryDateRecurringDonor__c != null && con.msf_FirstEntryDateRecurringDonor__c >= Date.today().addDays(-365)){
                        sProgram = 'Retención 1r año MID';     
                    }
                    else{
                        sProgram = 'Cultivación socios MID';     
                    }    
                }
                else{
                    if(con.msf_IsActiveDonor__c == 'Donante'){
                        sProgram = 'Cultivación/conversión Donantes MID';     
                    }
                    else{
                        if(con.msf_IsActiveDonor__c == 'Exdonante' && (con.msf_IsActiveRecurringDonor__c == 'Nunca' || con.msf_IsActiveRecurringDonor__c == null)){
                            sProgram = 'Reactivación/conversión EXDonantes MID';            
                        }else if(con.msf_IsActiveRecurringDonor__c == 'Baja'){
                            sProgram = 'Reactivación bajas MID';                              
                        }
                    }    
                }
            }    
        }
        else if(con.msf_LevelRelationshipScore__c == 20){
            if(con.msf_IsAssosiative__c || con.msf_LevelScore__c == 1 && (con.msf_ProgramaHerencias__c || con.msf_IsPublicPerson__c || con.msf_IsInfluencer__c || con.msf_BigDonorContact__c || (con.msf_LevelHCLifetimeVD__c != null && con.msf_LevelHCLifetimeVD__c > 0))){
                sProgram = 'Otros programas transversales';    
            }
            else{
                if(con.msf_IsActiveRecurringDonor__c == 'Socio'){
                    if(sLessOneYearOldMember.contains(con.Id) && con.msf_FirstEntryDateRecurringDonor__c != null && con.msf_FirstEntryDateRecurringDonor__c >= Date.today().addDays(-365)){
                        sProgram = 'Retención 1r año MASS';     
                    }
                    else{
                        sProgram = 'Cultivación socios MASS';     
                    }    
                }
                else{
                    if(con.msf_IsActiveDonor__c == 'Donante'){
                        sProgram = 'Cultivación/conversión Donantes MASS';     
                    }
                    else{
                        if((con.msf_IsActiveDonor__c == 'Nunca' || con.msf_IsActiveDonor__c == null) && (con.msf_IsActiveRecurringDonor__c == 'Nunca' || con.msf_IsActiveRecurringDonor__c == null)){
                            sProgram = 'Conversión prospectos';             
                        }
                        else if(con.msf_IsActiveDonor__c == 'Exdonante' && con.msf_IsActiveRecurringDonor__c == 'Nunca'){
                            sProgram = 'Reactivación/conversión EXDonantes MASS';           
                        }
                        else if(con.msf_IsActiveRecurringDonor__c == 'Baja'){
                            sProgram = 'Reactivación bajas MASS';                             
                        }
                    }    
                }
            }               
        }

        return sProgram;
    }      
}