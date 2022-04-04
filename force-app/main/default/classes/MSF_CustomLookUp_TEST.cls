/**
* @author       Deloitte
* @date         03-2019
* @group        sObject
* @description  test class for the MSF_CustomLookUp_CTRL class.
*/
@isTest
public class MSF_CustomLookUp_TEST {
	
    @testSetup static void setup(){
        List<Contact> lCon = new List<Contact>();
        List<Campaign> lCam = new List<Campaign>();
        Id RTIdIndividuals = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Individual_Contact').getRecordTypeId();    
        
        for(Integer x = 0; x < 3; x++){
            Contact c = new Contact(
                FirstName = 'FN'+x,
                LastName = 'LN'+x,
                RecordTypeId = RTIdIndividuals,
                msf_RecalculateMemberType__c = FALSE
            );
            lCon.add(c);
        }
        Contact c = new Contact(
            FirstName = 'XX',
            LastName = 'XX',
            Email = 'FN@FM.com',
            RecordTypeId = RTIdIndividuals,
            msf_RecalculateMemberType__c = FALSE
        );
        lCon.add(c);
        insert lCon;
        
         for(Integer x = 0; x < 4; x++){
            Campaign cam = new Campaign(
                Name = 'CAM'+x,
                isActive = TRUE,
                msf_FinalCampaign__c = false
            );
            lCam.add(cam);
        }
        Campaign cam = new Campaign(
                Name = 'CAM',
                isActive = FALSE,
            	msf_FinalCampaign__c = false
            );
            lCam.add(cam);
        insert lCam;
    }
    
    @isTest static void correctTestSecondFilter(){
        List<sObject> lObjects = MSF_CustomLookUp_CTRL.fetchLookUpValues('FN', 'Email', '', 'Contact');
        System.assertEquals(4,lObjects.size());
    }
    
    @isTest static void correctTestFilterActive(){
        List<sObject> lObjects = MSF_CustomLookUp_CTRL.fetchLookUpValues('CAM', '', 'isActive', 'Campaign');
        System.assertEquals(4,lObjects.size());
    }
}