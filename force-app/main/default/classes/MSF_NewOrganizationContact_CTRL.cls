/**
* @author       Deloitte
* @date         02-2019
* @group        Contact.
* @description  Controller for the lightning component MSF_NewOrganizationContact
*/
public without sharing class MSF_NewOrganizationContact_CTRL {
	
    /*******************************************************************************************************
    * @description  Creates a contact of type 'organizational contact' with the parameters received.
    * @param 		org is the id of the org from which the contact is created.        
    * @param 		name is a String that contains the name to the new contact.
    * @param 		surname1 is a String that contains the first surname to the new contact.
    * @param 		surname2 is a String that contains the second surname to the new contact.
    * @param 		homephone is a String that contains the homephone to the new contact.
    * @param 		mobilephone is a String that contains the mobilephone to the new contact.
    * @param 		email is a String that contains the email to the new contact.
    * @param 		role is a String that contains the role to the new contact.
    * @param 		isPrimary its a flag that indicates if the contact must be set as primary.
    * @return 		Map<String, Object> that contains the result of the method logic.        
    ********************************************************************************************************/ 
    @AuraEnabled
    public static Map<String, Object> crearContactoOrganizacion(Id org, String name, String surname1, String surname2, String homephone, 
                                                                String mobilephone, String email, String role, String gender, String languagePrf, 
                                                                Boolean isPrimary, String sLeadSource,
                                                               	Id entryCampaignId
                                                               ){
                                                                   
        Map<String, Object> out = new Map<String, Object> ();
        out.put('contactId',null);
        out.put('isSuccess', false);
        out.put('msg', '');
                                                           
        ID idRTOrgCon = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        
        Contact orgContact = [SELECT Id, AccountId FROM Contact WHERE Id =: org];
        
        Contact c = new Contact(            
            RecordTypeId = idRTOrgCon,
            msf_Organization__c = org,
            FirstName = name,
            LastName = surname1,
            Suffix = surname2,
            HomePhone = homephone,
            MobilePhone = mobilephone,
            msf_MainEmail__c = email,
            Title = role,
            msf_IsPrimary__c = isPrimary,
            AccountId = orgContact.AccountId,
            msf_EntryCampaign__c = entryCampaignId
        );

        c.Gender__c = getValue(Contact.Gender__c.getDescribe(),gender);  
        c.msf_LanguagePreferer__c = getValue(Contact.msf_LanguagePreferer__c.getDescribe(),languagePrf);
        c.LeadSource = getValue(Contact.LeadSource.getDescribe(),sLeadSource);
        
        try{
            insert c;
            out.put('contactId',c.Id);
            out.put('isSuccess', true);
        }catch(Exception ex){
            out.put('msg', ex.getmessage());
        }
        
        return out;
    }
   
    @AuraEnabled
    public static List<String> getGender(){ 
        return getOptions(Contact.Gender__c.getDescribe());
    }
    
    @AuraEnabled
    public static List<String> getPrfLanguage(){
        return getOptions(Contact.msf_LanguagePreferer__c.getDescribe());
    }
    
    @AuraEnabled
    public static List<String> getLeadSources(){
        return getOptions(Contact.LeadSource.getDescribe());
    }
        
    private static List<String> getOptions(Schema.DescribeFieldResult fieldResult){         
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();        
        List<String> options = new List<String> ();

        for(Schema.PicklistEntry p : pickListValues){
            options.add(p.getLabel());
        }        
        return options;
    }
    
    private static String getValue(Schema.DescribeFieldResult fieldResult, String label){
		String value;

        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : pickListValues){
            if(p.getLabel() == label){
                value = p.getValue();
                break;
            }
        }

		return value;          
    }
}