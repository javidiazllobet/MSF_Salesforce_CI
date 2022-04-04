/**
* @author       Deloitte
* @date         01-2019
* @group        MSF_Signature_CTRL
* @description  test class for the MSF_Signature_CTRL clases.
*/
@isTest
private class MSF_Signature_TEST {
    @testSetup static void setup(){
        Contact a = new Contact(LastName='MSF_Signature_TEST_LastName1');
        insert a;
    }
    //saveSignature(String signatureBody, String signatureName, ID signatureIdMember)
    @isTest static void testIdSignatureNull(){
        System.assert(!MSF_Signature_CTRL.saveSignature('a','b',null));
    }
    @isTest static void testBodyNull(){
        Id idInsert = (Id)getFakeId(Account.SObjectType);
        System.assert(!MSF_Signature_CTRL.saveSignature(null,'asd',idInsert));
    }
    @isTest static void testErrorKeyGen(){
        Id idInsert = (Id)getFakeId(Account.SObjectType);
        System.assert(!MSF_Signature_CTRL.saveSignature('         ','asd',idInsert));
    }
    @isTest static void testInsertGenError(){
        Id idInsert = (Id)getFakeId(Account.SObjectType);
        System.assert(!MSF_Signature_CTRL.saveSignature('aaa','asd',idInsert));
    }
    @isTest static void testInsertGen(){
        Contact cont = [SELECT Id FROM Contact WHERE LastName='MSF_Signature_TEST_LastName1'];
        Id idInsert = cont.Id;
        System.assert(MSF_Signature_CTRL.saveSignature('aaa','asd',idInsert));
    }
    @isTest static void testInsertGenNullSigName(){
        Contact cont = [SELECT Id FROM Contact WHERE LastName='MSF_Signature_TEST_LastName1'];
        Id idInsert = cont.Id;
        System.assert(MSF_Signature_CTRL.saveSignature('aaa',null,idInsert));
    }
   static Integer s_num = 1;
   private static String getFakeId(Schema.SObjectType sot){
      String result = String.valueOf(s_num++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
   }
}