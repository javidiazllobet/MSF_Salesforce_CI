/**
* @author       Deloitte
* @date         01-2019
* @group        Contact
* @description  test class for the MSF_SummarySection_CONTROLLER class.
*/
@isTest
private class MSF_SummarySection_TEST {
    static Integer s_num = 1;
    @testSetup static void setup(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().Get('Organization').getRecordTypeId();
        Id RecordTypeIdOrg = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Id RecordTypeIdContOrg = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization_Contact').getRecordTypeId();
        List<Opportunity> listOpportunityTest1 = new List<Opportunity>(); 
        
        Account a = new Account();
        a.name='Silver&Gold';
        a.RecordTypeId=RecordTypeIdAccount;
        //a.msf_CRMExternalId__c='0120O000000kNMEQA2';
        insert a;
        
        Contact co = new Contact();
        co.LastName= 'Medina';
        co.RecordTypeId = RecordTypeIdOrg;
        co.npe01__HomeEmail__c = 'm@m.com';
        co.msf_NIF__c='B52296126';
        co.msf_IsAssosiative__c =true;
        co.msf_IsPublicPerson__c = true;
        co.npsp__Primary_Affiliation__c= a.Id;
        co.msf_MemberType__c ='Nada';
        co.msf_ContactInformationSummary__c = 'Nada';
        co.msf_PercomsSummary__c = 'Varios';
        insert co;
        
        Contact co2 = new Contact();
        co2.LastName= 'Medina S.L.';
        co2.RecordTypeId = RecordTypeIdOrg;
        co2.npe01__HomeEmail__c = 'm@org.com';
        co2.msf_NIF__c='12345678D';
        co2.msf_IsAssosiative__c =true;
        co2.msf_IsPublicPerson__c = true;
        co2.npsp__Primary_Affiliation__c= a.Id;
        co2.msf_MemberType__c ='Nada';
        co2.msf_ContactInformationSummary__c = 'Nada';
        co2.msf_PercomsSummary__c = 'Varios';
        insert co2;
        
        Contact orgCont = new Contact();
        orgCont.FirstName= 'Manolo';
        orgCont.LastName= 'Medina';
        orgCont.RecordTypeId = RecordTypeIdContOrg;
        orgCont.npe01__HomeEmail__c = 'm@morg.com';
        orgCont.msf_NIF__c='12345678Z';
        orgCont.msf_IsAssosiative__c =true;
        orgCont.msf_IsPublicPerson__c = true;
        orgCont.npsp__Primary_Affiliation__c= a.Id;
        orgCont.msf_MemberType__c ='Nada';
        orgCont.msf_ContactInformationSummary__c = 'Nada';
        orgCont.msf_PercomsSummary__c = 'Varios';
        insert orgCont;
        
        Contact c2 = new Contact();
        c2.RecordTypeId = RecordTypeIdOrg;
        c2.LastName= 'Medina';
        c2.npe01__HomeEmail__c = null;
        c2.msf_NIF__c='12345678P';
        c2.msf_IsAssosiative__c =false;
        c2.msf_IsPublicPerson__c = false;
        c2.npsp__Primary_Affiliation__c= null;
        c2.msf_MemberType__c ='Nada';
        c2.msf_ContactInformationSummary__c = 'Nada';
        c2.msf_PercomsSummary__c = 'Varios';
        insert c2;
        
        Contact c3 = new Contact();
        c3.RecordTypeId = RecordTypeIdOrg;
        c3.LastName= 'Medina';
        c3.npe01__HomeEmail__c = null;
        c3.msf_NIF__c='12345678R';
        c3.msf_IsAssosiative__c =false;
        c3.msf_IsPublicPerson__c = false;
        c3.npsp__Primary_Affiliation__c= null;
        c3.msf_MemberType__c ='Nada';
        c3.msf_ContactInformationSummary__c = 'Nada';
        c3.msf_PercomsSummary__c = 'Varios';

        insert c3;
        
        Campaign camp = new Campaign();
        camp.msf_PromoterIndividual__c = co.Id;
        camp.Name = 'MSFSummarySectionTestName1';
        camp.msf_FinalCampaign__c = false;
        insert camp;
        
        Opportunity o = new Opportunity();
        o.name='Donacion puntual';
        o.type='Solidarity Wedding';
        o.npsp__Primary_Contact__c=co.Id;
        o.AccountId = a.Id;
        o.StageName = 'Propuesta';
        o.CloseDate = date.newInstance(2019, 10, 15);
        listOpportunityTest1.add(o);
        
        Opportunity o2 = new Opportunity();
        o2.name='Donacion puntual';
        o2.type='Herencia';
        o2.npsp__Primary_Contact__c=c2.Id;
        o2.AccountId = a.Id;
        o2.StageName = 'Propuesta';
        o2.CloseDate = date.newInstance(2019, 10, 15);
        listOpportunityTest1.add(o2);
        
        Opportunity o3 = new Opportunity();
        o3.name='Donacion puntual';
        o3.type='Grant';
        o3.npsp__Primary_Contact__c=c3.Id;
        o3.AccountId = a.Id;
        o3.StageName = 'Propuesta';
        o3.CloseDate = date.newInstance(2019, 10, 15);
        listOpportunityTest1.add(o3);
         
        
        Opportunity o4 = new Opportunity();
        o4.name='Donacion puntual';
        o4.type='Grant';
        o4.npsp__Primary_Contact__c=co2.Id;
        o4.AccountId = a.Id;
        o4.StageName = 'Propuesta';
        o4.CloseDate = date.newInstance(2019, 10, 15);
        o4.msf_DonationVehicleContact__c = c2.Id;
        listOpportunityTest1.add(o4);
        
        Opportunity o5 = new Opportunity();
        o5.name='Donacion puntual';
        o5.type='Grant';
        o5.npsp__Primary_Contact__c=c3.Id;
        o5.AccountId = a.Id;
        o5.StageName = 'Impagada';
        o5.CloseDate = date.today();
        listOpportunityTest1.add(o5);

        
        insert listOpportunityTest1;
        
        npe4__Relationship__c dup = new npe4__Relationship__c(npe4__Type__c = 'Duplicate', npe4__Contact__c = c2.Id, npe4__RelatedContact__c = co.Id);
        insert dup;
        
        
        Case caso = new Case(ContactId = c2.Id,
                             RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSF_Doubts').getRecordTypeId());
        insert caso;
    }
    
    @isTest static void msfContactError(){
        Contact co = new Contact(Id=getFAkeId(Contact.SObjectType));
        Map<String,Object> out = new Map<String,Object>();
        System.assertEquals(out,MSF_SummarySection_CONTROLLER.getContact(co.Id));        
    }
    @isTest static void existsOneOrMorePromotionsFromContact(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='B52296126' LIMIT 1];
        System.assert(MSF_SummarySection_CONTROLLER.getProm(c.Id,null));
    }
    
    @isTest static void notExistsOneOrMorePromotionsFromContact(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='12345678P' LIMIT 1];
        System.assert(!MSF_SummarySection_CONTROLLER.getProm(c.Id,null));
    }
    @isTest static void checkNotExistsOportunityDonationVehicle(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='12345678P' LIMIT 1];
        System.assert(!MSF_SummarySection_CONTROLLER.getVd(c.Id));
    }
    
    @isTest static void testGetContact(){
        Contact co = [SELECT RecordType.DeveloperName, toLabel(RecordType.Name),  toLabel(msf_OrganizationType__c), msf_Organization__r.Name, msf_Organization__r.msf_RelationshipLevel__r.Name, msf_OrgContactType__c, msf_RelationshipLevel__r.Name, msf_Level__r.Name, msf_PrimaryContact__c,
                      msf_Program__c, msf_MainEmail__c, msf_NIF__c, msf_IsPrimary__c,  msf_MemberType__c,
                      msf_ContactInformationSummary__c, msf_PercomsSummary__c, msf_Seniority__c, msf_IsAssosiative__c, msf_IsPublicPerson__c,
                      AccountId
                      FROM Contact
                      WHERE msf_NIF__c = 'B52296126'
                      LIMIT 1];
        Map<String,Object> out = (Map<String,Object>) MSF_SummarySection_CONTROLLER.getContact(co.Id);
        System.assertEquals(co, out.get('c'), 'Contact is not the same');
        System.assertEquals(co.msf_Organization__r.msf_RelationshipLevel__r.Name, out.get('lvl'),'Relationship Level is not the same');
        System.assertEquals([SELECT Name, msf_IsOrganizationGroup__c FROM Account WHERE id=:co.AccountId LIMIT 1], out.get('acc'), 'Organization Group is not the same');
    }
    
    @isTest static void testGetOrgContact(){
        Contact co = [SELECT RecordType.DeveloperName, toLabel(RecordType.Name),  toLabel(msf_OrganizationType__c), msf_Organization__r.Name, msf_Organization__r.msf_RelationshipLevel__r.Name, msf_OrgContactType__c, msf_RelationshipLevel__r.Name, msf_Level__r.Name, msf_PrimaryContact__c,
                      msf_Program__c, msf_MainEmail__c, msf_NIF__c, msf_IsPrimary__c,  msf_MemberType__c,
                      msf_ContactInformationSummary__c, msf_PercomsSummary__c, msf_Seniority__c, msf_IsAssosiative__c, msf_IsPublicPerson__c,
                      AccountId
                      FROM Contact
                      WHERE msf_NIF__c = '12345678Z'
                      LIMIT 1];
        Map<String,Object> out = (Map<String,Object>) MSF_SummarySection_CONTROLLER.getContact(co.Id);
        System.assertEquals(co, out.get('c'), 'Contact is not the same');
        System.assertEquals([SELECT Name, msf_IsOrganizationGroup__c FROM Account WHERE id=:co.AccountId LIMIT 1], out.get('acc'), 'Organization Group is not the same');
    }
    
    @isTest static void checkgetCasoHasOut(){
        Contact co = [SELECT Id FROM Contact WHERE msf_NIF__c = '12345678P' LIMIT 1];
        Map<String,Object> out = (Map<String,Object>)MSF_SummarySection_CONTROLLER.getCaso(co.Id);
        System.assert(((Integer)out.get('case')) > 0);
    }
    
    @isTest static void checkgetCasoHasNotOut(){
        Contact co = [SELECT Id FROM Contact WHERE msf_NIF__c = '12345678D' LIMIT 1];
        Map<String,Object> out = (Map<String,Object>)MSF_SummarySection_CONTROLLER.getCaso(co.Id);
        System.assert(((Integer)out.get('case')) == 0);
    }
    
    @isTest static void checkExistsOportunityDonationVehicle(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='12345678D' LIMIT 1];
        System.assert(MSF_SummarySection_CONTROLLER.getVd(c.Id));
    }
    
    @isTest static void checkCanNotGetDuplicate(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='12345678R' LIMIT 1];
        System.assert(!MSF_SummarySection_CONTROLLER.getDuplicate(c.Id));
    }
    
    @isTest static void checkCanGetDuplicate(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='12345678P' LIMIT 1];
        System.assert(MSF_SummarySection_CONTROLLER.getDuplicate(c.Id));
    }
    
    @isTest static void checkGetOporSolitaryWedding(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='B52296126' LIMIT 1];        
        Map<String,Object> out = (Map<String,Object>) MSF_SummarySection_CONTROLLER.getOpor(c.Id);
        System.assert((Boolean)out.get('boda'));
    }
    
    @isTest static void checkGetOporOther(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='12345678R' LIMIT 1];
        Test.setCreatedDate(c.Id, Date.today().addYears(-1));
        Test.startTest();
        update c;
        Map<String,Object> out = (Map<String,Object>) MSF_SummarySection_CONTROLLER.getOpor(c.Id);
        System.assert((Boolean)out.get('apor'));
        Test.stopTest();
    }
    
    @isTest static void checkGetOporInheritance(){
        Contact c = [SELECT Id FROM Contact WHERE msf_NIF__c='12345678P' LIMIT 1];
        Map<String,Object> out = (Map<String,Object>) MSF_SummarySection_CONTROLLER.getOpor(c.Id);
        System.assert((Boolean)out.get('her'));
    }    
    
    private static String getFakeId(Schema.SObjectType sot){
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + 
            '0'.repeat(12-result.length()) + result;
    }
}