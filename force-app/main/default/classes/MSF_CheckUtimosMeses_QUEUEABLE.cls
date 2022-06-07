/**
* @author 		Omega
* @date 		01/07/2021
* @group 		Opportunity
* @description	Job to check and update the field msf_IsFromLastMonthsBool__c ZenIT#25762
*/
public class MSF_CheckUtimosMeses_QUEUEABLE implements Queueable {
    
    Boolean process;

    public MSF_CheckUtimosMeses_QUEUEABLE(){
        this.process = true;
    }
    
    public void execute(QueueableContext context) {
		date lastTwoYears = date.today()-365*2;      
        date lastFiveYears = date.today()-365*5;   
        List<Opportunity> listOppToCheck = [ SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Opportunity where msf_IsFromLastMonthsBool__c = false and (
                                            (msf_TypeFundraisingContribution__c = 'D' AND CloseDate >=:lastFiveYears) OR
                                            (CloseDate >=:lastFiveYears AND CloseDate <= :lastTwoYears AND Type != 'Recurrent Donation' AND Type != 'Historical' AND Type != 'Membership'))Limit 100];      
        
        integer limite = 0;
        integer errors = 0;
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        
        for(Opportunity iOpp: listOppToCheck){
            
            limite++;            
           	
            if(iOpp.msf_IsFromLastMonths__c == true && iOpp.msf_IsFromLastMonthsBool__c == false ){
                iOpp.msf_IsFromLastMonthsBool__c = true;            
            	listOppToUpdate.add(iOpp);                
            }
            
            if(listOppToUpdate.size() > 0 && limite >= 10){ 
                limite = 0;
                try{
        			update listOppToUpdate;//Esta operación esta dentro de un bucle lo cual no es lo indicado, pero si lanzamos el update con todos las opp de golpe da CPU time limit, es una manera sencilla de hacerlo por bloques
                }catch(exception exc){
                    errors++;
                    System.debug('Exception: ' + exc);
                }
                listOppToUpdate.clear();
        	}
            
        }//END FOR     
        
        if(errors < 10){//si aún hay opp que no originen error
            List<Opportunity> listCheckIfThereIsMoreOpp = [ SELECT Id, msf_IsFromLastMonthsBool__c, msf_IsFromLastMonths__c From Opportunity where msf_IsFromLastMonthsBool__c = false and (
                                            (msf_TypeFundraisingContribution__c = 'D' AND CloseDate >=:lastFiveYears) OR
                                            (CloseDate >=:lastFiveYears AND CloseDate <= :lastTwoYears AND Type != 'Recurrent Donation' AND Type != 'Historical' AND Type != 'Membership'))Limit 100];   
            if(listCheckIfThereIsMoreOpp.size() >= 100){//si aún quedan opp que comprobar
                System.enqueueJob(new MSF_CheckUtimosMeses_QUEUEABLE());
            }
        }
    }
}