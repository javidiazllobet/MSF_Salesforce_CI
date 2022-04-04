/**
* @author       Deloitte
* @date         12-2018
* @group        Associative.
* @description  Controller for the lightning component MSF_SummarySectionAssociative
*/
public without sharing class MSF_SummarySectionAssociative_CTRL {
   	
    @AuraEnabled
    public static Object getObjectType(ID objectId){
        
        Map<String,Object> outputMap = new Map<String,Object>();   
        
        if(Schema.Contact.SObjectType == objectId.getSobjectType()){
        	outputMap.put('isContact',true);    
        }
        else if (Schema.Lead.SObjectType == objectId.getSobjectType()){
        	outputMap.put('isContact',false);    
        }
        
        return outputMap;     
    }    
    
    @AuraEnabled
    public static Object getContactInformation(ID contactId){
        
        Map<String,Object> outputMap = new Map<String,Object>();        
		
        List<Contact> c = new List<Contact>();
        
        c = [SELECT Id, msf_IsAssosiative__c,
             (SELECT Id FROM Avales__r)
             FROM Contact 
             WHERE RecordType.DeveloperName = 'Individual_Contact'
             AND Id =: contactId
             LIMIT 1
            ];
 
        if(!c.IsEmpty()){
            outputMap.put('contact',c[0]);
            outputMap.put('numEndorsements',c[0].Avales__r.size()); 
        }else{
        	outputMap.put('contact',new Contact());
            outputMap.put('numEndorsements',0);     
        }
        
        return outputMap;        
    }
    
    @AuraEnabled
    public static Object getAssociativeInformation(ID contactId){
        
        Map<String,Object> outputMap = new Map<String,Object>();        
		
        List<msf_Associative__c> asso = new List<msf_Associative__c>();
        
        asso = [SELECT Id, msf_IsSanitary__c, msf_FieldExperienceSAP__c, msf_MemberMeetingStartDate__c, msf_IsFieldSAP__c, msf_SalariedSAP__c, msf_StaffType__c
                FROM msf_Associative__c 
                WHERE msf_ContactId__c =: contactId
                ORDER BY CreatedDate DESC
                LIMIT 1
               ];
        
        if(!asso.isEmpty()){
        	outputMap.put('associative',asso[0]);     
        }else{
            outputMap.put('associative',null);    
        }             
        
        return outputMap;        
    }
    
    @AuraEnabled
    public static Object getLeadInformation(ID leadId){
        
        Map<String,Object> outputMap = new Map<String,Object>();        
		
        Lead ld = new Lead();
        
        ld = [SELECT Id, Name, msf_isSanitary__c, msf_StaffType__c, RecordType.DeveloperName
              FROM Lead 
              WHERE Id =: leadId
              LIMIT 1
             ];
        
        outputMap.put('ld',ld);      
        
        return outputMap;        
    }
}