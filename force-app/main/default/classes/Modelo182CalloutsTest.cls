@isTest
public class Modelo182CalloutsTest {
    @isTest 
    static  void testMakeGetCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new Modelo182HttpCalloutsMock_OK());
        Modelo182Callouts m182Callouts = new Modelo182Callouts();
        HttpResponse response = m182Callouts.makeGetCallout();
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
    	System.assert(contentType == 'text/plain');
    	String actualValue = response.getBody();
    	System.debug(response.getBody());
      	System.assertEquals(actualValue, 'Respuesta OK');
    	System.assertEquals(200, response.getStatusCode());

    }
    @isTest 
    static  void testsendWebHook() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new Modelo182HttpCalloutsMock_OK());
        Modelo182Callouts m182Callouts = new Modelo182Callouts();
        HttpResponse response = m182Callouts.sendWebHook('a3i1X000000UxFKQA0');
        // Verify that the response received contains fake values
        String contentType2 = response.getHeader('Content-Type');
    	System.assert(contentType2 == 'text/plain');
    	String actualValue2 = response.getBody();
    	System.debug(response.getBody());
      	System.assertEquals(actualValue2, 'Respuesta OK');
    	System.assertEquals(200, response.getStatusCode());
    }
}