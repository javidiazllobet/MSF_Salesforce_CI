@isTest
public class Modelo182HttpCalloutsMock_OK implements HttpCalloutMock{
     public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/plain');
        response.setBody('Respuesta OK');
        response.setStatus('OK');
        response.setStatusCode(200);
        return response; 
    }

}