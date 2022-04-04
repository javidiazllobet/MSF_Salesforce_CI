/**
* @author 		Omega
* @date 		01/07/2021
* @group 		Task
* @description	Job to check and update the field msf_IsFromLastMonthsBool__c ZenIT#25762
*/
public class MSF_UncheckUtimosMesesTask_QUEUEABLE implements Queueable {
    
    public void execute(QueueableContext context) {
        
        List<Task> listTaskToCheck = [ SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Task where msf_IsFromLastMonthsBool__c = true and msf_IsFromLastMonths__c = false Limit 400];      
        
        integer limite = 0;
        integer errors = 0;
        List<Task> listTaskToUpdate = new List<Task>();
        
        for(Task iTask: listTaskToCheck){
            
            limite++;            
           	
            if(iTask.msf_IsFromLastMonths__c == false && iTask.msf_IsFromLastMonthsBool__c == true ){
                iTask.msf_IsFromLastMonthsBool__c = false;            
            	listTaskToUpdate.add(iTask);                
            }
            
            if(listTaskToUpdate.size() > 0 && limite >= 10){ 
                limite = 0;
                try{
        			update listTaskToUpdate;//Esta operación esta dentro de un bucle lo cual no es lo indicado, pero si lanzamos el update con todos las task de golpe da CPU time limit, es una manera sencilla de hacerlo por bloques
                }catch(exception exc){
                    errors++;
                    System.debug('Exception: ' + exc);
                }
                listTaskToUpdate.clear();
        	}
            
        }//END FOR     
        
        if(errors < 40){//si aún hay task que no originen error
            List<Task> listCheckIfThereIsMoreTask = [ SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Task where msf_IsFromLastMonthsBool__c = true and msf_IsFromLastMonths__c = false Limit 400];   
            if(listCheckIfThereIsMoreTask.size() >= 400){//si aún quedan task que comprobar
                System.enqueueJob(new MSF_UncheckUtimosMesesTask_QUEUEABLE());
            }
        }
    }
}