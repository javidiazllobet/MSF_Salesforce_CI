public with sharing class MSF_SummarySection_CONTROLLER {
    
    @AuraEnabled
    public static Object getContact(Id idContact){
        Contact c;
        Account acc;
        String lvl;
        String program;
        Map<String,Object> out = new Map<String,Object>();
        try{
    	c = [SELECT RecordType.DeveloperName, toLabel(RecordType.Name),  toLabel(msf_OrganizationType__c), 
             msf_OrgContactType__c, msf_RelationshipLevel__r.Name, msf_Level__r.Name, msf_PrimaryContact__c,
             msf_Program__c, msf_MainEmail__c, msf_NIF__c, msf_IsPrimary__c,  msf_MemberType__c,
             msf_ContactInformationSummary__c, msf_PercomsSummary__c, msf_Seniority__c, msf_IsAssosiative__c, msf_IsPublicPerson__c,             
             msf_Organization__r.Name, msf_Organization__r.msf_RelationshipLevel__r.Name, msf_Organization__r.msf_Program__c,
             AccountId
             FROM Contact 
             WHERE Id =: idContact
             LIMIT 1];

            lvl = c.msf_RelationshipLevel__r.Name;
            program = c.msf_Program__c;
            
            if(c.RecordType.DeveloperName == 'Organization_Contact'){          
                lvl = (c.msf_Organization__r.msf_RelationshipLevel__r.Name != null ? c.msf_Organization__r.msf_RelationshipLevel__r.Name : '') ; 
                program = (c.msf_Organization__r.msf_Program__c != null ? c.msf_Organization__r.msf_Program__c : '');
            }
            
            if(c.AccountId != null){
                acc = [SELECT Name, msf_IsOrganizationGroup__c FROM Account WHERE id=:c.AccountId LIMIT 1];
            }
            out.put('c',c);   
 			out.put('lvl',lvl);
            out.put('program',program);
            out.put('acc',acc);
            
        }catch(exception e){
            System.debug('ERROR');
        }
        return out;
    }

    @AuraEnabled
    public static Boolean getProm(Id idContact, String rtDevName){
        List<Campaign> result = [SELECT Id FROM Campaign  WHERE msf_PromoterIndividual__c =: idContact LIMIT 1];
        if(result.size()>0){
            return true; 
        }else{
            return false;
        }    
    }
    
    @AuraEnabled
    public static Object getCaso(Id idContact){
        Map<String,Object> out = new Map<String,Object>();
        List<Case> cases = [SELECT id FROM Case WHERE ContactId=: idContact AND IsClosed = false];
        out.put('case',cases.size());
        return out;
    }
    
    @AuraEnabled
    public static Object getOpor(Id idContact){
        Map<String,Object> out = new Map<String,Object>();
        out.put('boda',false);
        out.put('apor',false);
        out.put('her',false);
        out.put('herStage','');
        for(Opportunity o : [SELECT Type, StageName FROM Opportunity WHERE npsp__Primary_Contact__c =: idContact  AND ((CreatedDate = LAST_90_DAYS AND isWon = false AND StageName IN ('Impagada','Devuelta') ) OR (Type IN ('Solidarity Wedding','Herencia') AND StageName != 'Cancelada' ))]){  //#31790
            if(o.Type == 'Solidarity Wedding'){ 
                out.put('boda',true);
            }else if(o.Type == 'Herencia'){ 
                out.put('her',true);
                out.put('herStage', o.StageName);
            }else{ 
                out.put('apor',true);
            }
		}
        return out;
    }
    
    @AuraEnabled
    public static Boolean getVD(Id idContact){
        List<Opportunity> result = [SELECT id , name FROM Opportunity WHERE npsp__Primary_Contact__c =: idContact AND msf_IsDonationVehicle__c = true LIMIT 1];
        if(result.isEmpty()){
            return false;    
        }else{
        	return true;    
        }            
    }
    
    @AuraEnabled
    public static Boolean getDuplicate(Id idContact){
        List<npe4__Relationship__c> result = [SELECT id FROM npe4__Relationship__c WHERE npe4__Type__c = 'Duplicate' AND npe4__Contact__c =: idContact LIMIT 1];
        if(result.isEmpty()){
            return false;    
        }else{
        	return true;    
        } 
    }
}