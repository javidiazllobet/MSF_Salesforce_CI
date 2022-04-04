public class Modelo182Launcher {
    @future (callout=true)
    public static void calloutLauncher(Id idModelo182){
        try{
        msf_Modelo182__c m182 = [select Id,msf_Estado__c,msf_Resultado__c from msf_Modelo182__c where Id = :idModelo182 limit 1];
       	Modelo182Callouts m182Callouts = new Modelo182Callouts();
       	HttpResponse resultado = m182Callouts.sendWebHook(idModelo182);
       	m182.msf_Resultado__c = resultado.getStatus() + ' - Status ' +  resultado.getStatusCode();
       	if (resultado.getStatusCode()!=200){
           	m182.msf_Estado__c = 'Finalizado Error';
           }
        update m182; 
        } catch(CalloutException e){
            ErrorException(idModelo182,e.getMessage());
           }
    }
    
    public static void ErrorException(Id idModelo182, String error){
         msf_Modelo182__c m182 = [select Id,msf_Estado__c,msf_Resultado__c from msf_Modelo182__c where Id = :idModelo182 limit 1];
         m182.msf_Resultado__c = error;
         m182.msf_Estado__c = 'Finalizado Error';
         update m182;
    }
}