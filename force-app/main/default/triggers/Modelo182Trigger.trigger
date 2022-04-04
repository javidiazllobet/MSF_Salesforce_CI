trigger Modelo182Trigger on msf_Modelo182__c (after insert) {
	List<msf_Modelo182__c> lista = [select Id from msf_Modelo182__c where msf_Estado__c = 'Iniciando proceso' order by CreatedDate desc];
    if (lista.size()>=1){
        Modelo182Launcher.calloutLauncher(lista[0].Id);
    } 
}