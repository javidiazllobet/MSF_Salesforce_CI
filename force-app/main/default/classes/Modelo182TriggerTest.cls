@isTest
private class Modelo182TriggerTest {
	@IsTest
    private static void testCalloutOK(){
        msf_Modelo182__c m182new = new msf_Modelo182__c(
        	Name='Test',
            msf_Anterior__c = '0000',
            msf_Anyo_fiscal__c=String.valueOf(Date.today().year()),
            msf_Justificante__c='0000',
            msf_caracter__c='Complementaria',
            msf_Estado__c = 'Iniciando proceso'
        );
        Test.setMock(HttpCalloutMock.class, new Modelo182HttpCalloutsMock_OK());
    	Test.startTest();
        insert m182new;
    	Test.stopTest();
        msf_Modelo182__c m182 = [select Id,msf_Estado__c,msf_Resultado__c from msf_Modelo182__c where Id = :m182new.Id limit 1];
        System.assertNotEquals(null, m182);
        System.assertEquals('OK - Status 200', m182.msf_Resultado__c);
        System.assertNotEquals('Finalizado Error', m182.msf_Estado__c);
    }
    
    @IsTest 
    private static void testCalloutKO(){
        msf_Modelo182__c m182new = new msf_Modelo182__c(
        	Name='Test',
            msf_Anterior__c = '0000',
            msf_Anyo_fiscal__c=String.valueOf(Date.today().year()),
            msf_Justificante__c='0000',
            msf_caracter__c='Complementaria',
            msf_Estado__c = 'Iniciando proceso'
        );
        Test.setMock(HttpCalloutMock.class, new Modelo182HttpCalloutsMock_400());
    	Test.startTest();
        insert m182new;
    	Test.stopTest();
        msf_Modelo182__c m182 = [select Id,msf_Estado__c,msf_Resultado__c from msf_Modelo182__c where Id = :m182new.Id limit 1];
        System.assertNotEquals(null, m182);
        System.assertEquals('Error - Status 400', m182.msf_Resultado__c);
        System.assertEquals('Finalizado Error', m182.msf_Estado__c);
    }
}