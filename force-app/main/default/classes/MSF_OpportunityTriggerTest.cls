@isTest
public class MSF_OpportunityTriggerTest {
    @TestSetup
    static void setup(){
        List<List<String>> str = new List<List<String>>();
        str.add(new List<String>{'Payment Method','npsp4hub__Payment_Method__c','npsp4hub__Payment_Method__c'});
        str.add(new List<String>{'Payment Processor' ,'npsp4hub__Payment_Processor__c','npsp4hub__Payment_Processor__c'});
        str.add(new List<String>{'Target','npsp4hub__Target__c','npsp4hub__Target__c'});
        str.add(new List<String>{'Mandate'  ,'npsp4hub__Mandate__c' ,'npsp4hub__Mandate__c'});
        str.add(new List<String>{'Payment Profile','npsp4hub__Payment_Profile__c','npsp4hub__Payment_Profile__c'});

        List<npe03__Custom_Field_Mapping__c> record = new List<npe03__Custom_Field_Mapping__c>();
        for(List<String> cv:str){
            record.add(new npe03__Custom_Field_Mapping__c(Name=cv[0],npe03__Opportunity_Field__c=cv[1],npe03__Recurring_Donation_Field__c=cv[2]));
        }
        insert record;
        Id RTIDDonation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        Contact cont = new Contact(LastName='Test',FirstName='Contact',Phone='+573004197578');
        insert cont;
        Id recordTypeIdA =Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByDeveloperName()
            .get('Associate').getRecordTypeId();
            
        cpm__Payment_Profile__c pay = new cpm__Payment_Profile__c(
            cpm__Holder_Name__c='Omega',
            cpm__Contact__c=cont.Id,cpm__IBAN__c='ES3320990020587042742992',msf_NIF__c='123124615'
        );
        cpm__IbanValidation__c iban = new cpm__IbanValidation__c(Name='ES',cpm__RegEx__c='^(?=[0-9A-Z]{24}$)ES\\d{22}$');
        System.debug(iban.cpm__RegEx__c);
        insert iban;
        insert pay;
        npe03__Recurring_Donation__c donation = new npe03__Recurring_Donation__c(
            RecordTypeId=recordTypeIdA,
            npe03__Contact__c=cont.Id,npsp4hub__Payment_Method__c='CreditCard',
            npe03__Installment_Period__c='Monthly',
            npsp4hub__Payment_Profile__c=pay.Id,npsp4hub__Payment_Processor__c='PaymentHub-Redsys',
            npsp4hub__Target__c='LA CAIXA CCC OPERATIVA',
            npe03__Amount__c=30
        );
        insert donation;
        List<msf_QuotaModification__c> quota = new List<msf_QuotaModification__c>();
        List<Decimal> amounts = new List<Decimal>{80,85,30,15,10,100};
        for(Decimal de:amounts){
            quota.add(new msf_QuotaModification__c(msf_NewAmount__c=de,msf_RecurringDonation__c=donation.Id));
        }
        insert quota;
    }

    @isTest
    static void testbeforeInsert(){
        Id RTIDDonation = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId();
        List<msf_QuotaModification__c> quota = new List<msf_QuotaModification__c>();
        quota = [select Id from msf_QuotaModification__c];
        System.debug(quota.size());
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer a=0;a<2;a++){
            opps.add(new Opportunity(
                RecordTypeId=RTIDDonation,
                Name = 'Opp Test '+String.valueOf(a),
                CloseDate=Date.today().addDays(1),
                ForecastCategoryName='Commit',
                StageName='Devuelta',
                msf_CurrentQuotaModification__c=quota[a].Id,
                msf_OldQuotaModification__c=quota[a+2].Id,
                npsp4hub__Payment_Method__c='CreditCard',
                Amount=150,npsp4hub__Payment_Processor__c='PaymentHub-Redsys',
                npsp4hub__Target__c='LA CAIXA CCC OPERATIVA'
            ));
        }
        opps.add(new Opportunity(
            RecordTypeId=RTIDDonation,
            Name = 'Opp Test 3',
            CloseDate=Date.today().addDays(1),
            ForecastCategoryName='Commit',
            StageName='Devuelta',
            msf_CurrentQuotaModification__c=quota[0].Id,
            msf_OldQuotaModification__c=quota[3].Id,Amount=20,
            npsp4hub__Payment_Method__c='CreditCard',npsp4hub__Payment_Processor__c='PaymentHub-Redsys',
            npsp4hub__Target__c='LA CAIXA CCC OPERATIVA'
        ));
        Test.startTest();
        insert opps;
        opps[0].msf_CurrentQuotaModification__c=quota[5].Id;
        opps[0].Amount=20;
        opps[2].Amount=20;
        update opps;
        Test.stopTest();
    }
}