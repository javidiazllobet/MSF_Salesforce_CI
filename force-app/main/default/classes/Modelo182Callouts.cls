public class Modelo182Callouts {
    public Map<String,String> datosConexion;
    public Modelo182Callouts(){
        datosConexion = getDatosConexion();
    }
    private Map<String,String> getDatosConexion(){
        Map<String,msf_Master_Admin__c> datosMaestros = new Map<String,msf_Master_Admin__c>([select msf_RecordId__c, msf_Value__c from msf_Master_Admin__c where msf_FamilyId__c = 'REST']);
        Map<String,String> datosConexion0 = new Map<String,String>();
        for (String datoMaestro : datosMaestros.keySet()) {
            msf_Master_Admin__c maestro = datosMaestros.get(datoMaestro);
            datosConexion0.put(maestro.msf_RecordId__c, maestro.msf_Value__c);
            System.debug('registro = ' + maestro.msf_RecordId__c + ' - valor = ' + maestro.msf_Value__c);
        }
        //System.debug('host: ' + datosConexion0.get('host'));
        return datosConexion0;
    }
    
    
    public HttpResponse sendWebHook(Id idModelo182){
        String body = '{"id":"'+ idModelo182 + '" }';
        HttpResponse response = makePostCallout(body);
        Return response;
    }
    
    public HttpResponse makeGetCallout() {
        //System.debug('host: ' + datosConexion.get('host'));
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(datosConexion.get('host') + '/' + datosConexion.get('getResource'));
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return response;
    }
    public HttpResponse makePostCallout(String body) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(datosConexion.get('host') + '/' + datosConexion.get('postResource'));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        //request.setHeader('accept-encoding','gzip, deflate, br');
        //request.setHeader('accept','*/*');
        Blob headerValue = Blob.valueOf(datosConexion.get('user') + ':' + datosConexion.get('pass'));
        String authorizationHeader ='Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setBody(body);
        HttpResponse response = http.send(request);
        return response;
   }
}