/**
* @author       Deloitte
* @date         12-2018
* @group        Associative.
* @description  Controller for the lightning component MSF_AssociativeSectionInContact
*/
public without sharing class MSF_AssociativeSectionInContact_CTRL {
    
    @AuraEnabled
    public static Object getAssociativeInformation(ID contactId){
        
        Map<String,Object> outputMap = new Map<String,Object>();        
        
        List<msf_Associative__c> lAsso = new List<msf_Associative__c>();
        
        lAsso = [SELECT Id, Name, msf_ExemptOfPayment__c, msf_Status__c, msf_CancellationReason__c, 
                 msf_FirstNameSAP__c, msf_LastNameSAP__c, msf_SecondNameSAP__c, msf_AssociativePhone__c,
                 msf_FirstAssociativeEmail__c, msf_SecondAssociativeEmail__c,
                 msf_NationalitySAP__c, msf_LanguagePreferer__c, 
                 msf_IsSanitary__c, msf_SalariedSAP__c, msf_IsFieldSAP__c, msf_PaymentMethod__c,
                 msf_StaffType__c, msf_StartDateAssociativeSAP__c
                 FROM msf_Associative__c 
                 WHERE msf_contactId__c =: contactId
                 LIMIT 1
                ];
        
        if(lAsso.isEmpty()){
        	outputMap.put('associative',null);     
        }else{
        	outputMap.put('associative',lAsso[0]);      
        }           
        
        return outputMap;        
    }    
}