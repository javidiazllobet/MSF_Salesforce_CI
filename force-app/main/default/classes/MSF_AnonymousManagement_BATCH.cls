/**
* @author 		Deloitte
* @date 		10-2018
* @group 		Accounts
* @description	Monthly anonymous management. This class creates a monthly account to group all anonymous donations.
*/
global without sharing class MSF_AnonymousManagement_BATCH implements Schedulable {
    
    global void execute(SchedulableContext SC) {

        List<Account> laccNew = new List<Account>();
        List<Contact> lcontNew = new List<Contact>();
        Savepoint sp = Database.setSavepoint();
        
        try{
            Date DateNextMonth = date.today().addMonths(1);
            String nextMonth = String.valueOf(DateNextMonth.month());
            if(nextMonth.length()==1){
                nextMonth = '0'+nextMonth;
            }
            String NameRecord = 'Anónimos_'+DateNextMonth.year()+'_'+nextMonth;
            
            List<Account> aAnonymous = [SELECT Id, Name FROM Account WHERE Name=: NameRecord AND RecordType.DeveloperName = 'Anonymous'];
            
            if(aAnonymous.isEmpty()){
                
                List<Contact> cAnonymous = [SELECT Id, Name FROM Contact WHERE Name=: NameRecord AND RecordType.DeveloperName = 'Anonymous'];
                
                if(cAnonymous.isEmpty()){
                    RecordType accRt =[SELECT Id FROM RecordType WHERE DeveloperName = 'Anonymous' AND SobjectType = 'Account'];
                    RecordType contRt =[SELECT Id FROM RecordType WHERE DeveloperName = 'Anonymous' AND SobjectType = 'Contact'];
                    
                    Account accNew = new Account(
                        Name = NameRecord,
                        RecordTypeId = accRt.Id,
                        Type = 'Anonymous'
                    );

                    laccNew.add(accNew);                      

                    Database.SaveResult[] srList = Database.insert(laccNew, false);            
                    
                    
                    List<msf_AutomatedProcessErrors__c> lAPE = new List<msf_AutomatedProcessErrors__c>(); 
                    
                    for (Database.SaveResult sr : srList) { // Iterate through each returned result
                        if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                            for(Database.Error err : sr.getErrors()) {
                                msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_AnonymousManagement_BATCH', msf_RecordId__c = laccNew.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = err.getMessage());
                                lAPE.add(tempAPE);
                            }
                        }            
                    }
                    
                    if(lAPE.isEmpty()){
                        Contact contNew = new Contact(
                            LastName = NameRecord+' - Transferencias',
                            RecordTypeId = contRt.Id,
                            AccountId = accNew.Id
                        );
                        lcontNew.add(contNew);
                        
                        Contact contNew2 = new Contact(
                            LastName = NameRecord+' - Otras formas de pago',
                            RecordTypeId = contRt.Id,
                            AccountId = accNew.Id
                        );
                        lcontNew.add(contNew2);

                        Database.SaveResult[] srListaCont = Database.insert(lcontNew, false);                
                        
                        for (Database.SaveResult sr : srList) { // Iterate through each returned result
                            if (!sr.isSuccess()) {  // Operation failed, so get all errors                                   
                                for(Database.Error err : sr.getErrors()) {
                                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_AnonymousManagement_BATCH', msf_RecordId__c = lcontNew.get(srList.indexOf(sr)).Id, msf_StatusCode__c = String.valueOf(err.getStatusCode()), msf_FieldsErrors__c = String.valueOf(err.getFields()), msf_ErrorMessage__c = err.getMessage());
                                    lAPE.add(tempAPE);
                                }
                            } 
                        }
                    }
                    
                    if(!lAPE.isEmpty()){
                        insert lAPE;
                    }
                }
                else{
                    msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_AnonymousManagement_BATCH', msf_ErrorMessage__c = 'El contacto '+NameRecord+' ya existe en el sistema.');              
                    insert tempAPE;
                    
                }
            } 
            else{
                msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c(msf_Process__c = 'MSF_AnonymousManagement_BATCH', msf_ErrorMessage__c = 'La cuenta '+NameRecord+' ya existe en el sistema.'); 
                insert tempAPE;
                
            }
        }catch(exception e){
            Database.rollback(sp);
            msf_AutomatedProcessErrors__c tempAPE = new msf_AutomatedProcessErrors__c( msf_Process__c = 'MSF_AnonymousManagement_BATCH', msf_ErrorMessage__c = e.getMessage());
            insert tempAPE;          
        }
    }
}