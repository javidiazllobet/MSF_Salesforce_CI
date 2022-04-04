/**
* @author       Deloitte
* @date         12-2018
* @group        Associative.
* @description  Controller for the lightning component MSF_IncompleteManagement
*/
public with sharing class MSF_IncompleteManagement_CTRL {
	
    @AuraEnabled
    public static Object getMyIncompletes(){
    	
        Map<String,Object> mOutValues = new Map<String,Object>();
        mOutValues.put('lIncompletes',null);
        
        List<Lead> lIncompleteIndividuals = new List<Lead>();        
        lIncompleteIndividuals = [SELECT Id, msf_esOrganizacion__c, OwnerId, createdDate,
                                  msf_Canvasser__c, msf_CityCanvasser__c, msf_CanvasserCampaign__c, msf_PlaceCanvasser__c,								// Canvasser information
                                  Name, FirstName, LastName, Suffix, msf_NIF__c, msf_Birthdate__c, msf_Gender__c, MobilePhone,								// Specific individual information
                                  Company,			 																									// Specific organization information
                                  Description, Email, Phone, msf_LanguagePreferer__c, 																	// General information shared (infividual/organization)
                                  Country, State, PostalCode, City, Street, msf_StreetNumber__c	, msf_Floor__c, msf_DoorNumber__c,						// General information shared (infividual/organization)	
                                  msf_AuxFirstName__c, msf_AuxLastName__c, msf_AuxSuffix__c, msf_AuxNIF__c,												// Information of (tutor/representative)
                                  msf_AuxMobilePhone__c, msf_AuxRole__c, 																				// Specific representative information
                                  msf_IBANCode__c, msf_IBANEntity__c, msf_IBANOffice__c, msf_IBANDC__c, msf_IBANAccountNumber__c,						// Payment profile information
                                  msf_HolderFirstName__c, msf_HolderLastName__c, msf_HolderSuffixName__c, msf_HolderNIF__c,	msf_AccountHolderOption__c,	// Payment profile holder's information
                                  msf_Opp_npe03_Amount__c, msf_RecDon_npe03_Installment_Period__c, msf_RecDona_npe03_Next_Payment_Date__c,				// Payment details
                                  msf_FirmaDonante__c, msf_FirmaRepresentante__c, msf_FirmaTitular__c,													// Signatures
                                  msf_ContactDate__c, msf_NotInformedAmount__c																		// Contact date and NotInformedAmount
                                  FROM Lead 
                                  WHERE RecordType.DeveloperName = 'Individual' 
                                  AND LeadSource = 'Persona a Persona'
                                  ORDER BY msf_ContactDate__c];
        
        if(!lIncompleteIndividuals.isEmpty()){
        	mOutValues.put('lIncompleteIndividuals',lIncompleteIndividuals);    
        }
        
    	return mOutValues; 
    }
    
    @AuraEnabled
    public static Object removeIncomplete(Id incompleteId){

        List<Lead> lIncompletos = new List<Lead>();
        
        Map<String,Object> mResult = new Map<String,Object>();
        mResult.put('title',System.Label.MSF_FORM_F2F_INCOMPLETE_DELETE_INCOMPLETE);
        mResult.put('type','warning');
        mResult.put('eliminado',false);        
        
        if(incompleteId != null){            
            lIncompletos.add(new Lead(ID=incompleteId));

            try{
                delete lIncompletos;   
                mResult.put('type','success');
                mResult.put('msg',System.Label.MSF_FORM_F2F_INCOMPLETE_DELETE_INCOMPLETE_CORRECTLY);
                mResult.put('eliminado',true);
            }catch(Exception ex){
                System.debug('ERROR: '+ex.getMessage());
                mResult.put('type','error');
            	mResult.put('msg',ex.getMessage());
            }
        }
        
    	return mResult;
    }    
}