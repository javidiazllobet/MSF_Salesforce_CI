@isTest
public class Modelo182HttpCalloutsMock_400 implements HttpCalloutMock{
     public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/plain');
        response.setBody('Respuesta 400');
        response.setStatus('Error');
        response.setStatusCode(400);
        return response; 
    }
}