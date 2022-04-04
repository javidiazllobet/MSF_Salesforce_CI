/**
* @author 		Deloitte
* @date 		11-2020
* @description	Test class for the MSF_ActualizarFlagsMCContacto_SCHED class
*/
@isTest
public class MSF_ActualizarFlagsMCContacto_SCHED_TEST {
	
    @isTest
	static void testScheduleBatch(){
	    
		Test.startTest();
        	
        	MSF_ActualizarFlagsMCContacto_SCHED scheduleBatch = new MSF_ActualizarFlagsMCContacto_SCHED(); 
			String sch ='0 0 0 * * ?'; 
			String jobId = System.schedule('Schedule batch', sch, scheduleBatch);
			
        	// Get the information from the CronTrigger API object
     		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        	//Assertions
        	System.assertEquals('0 0 0 * * ?', ct.CronExpression); 
		    System.assertEquals(0, ct.TimesTriggered);
        	DateTime dtInstance = dateTime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0));
        	DateTime tomorrow = dtInstance.addDays(1);
        	String fechaString = tomorrow.format('yyyy-MM-dd 00:00:00');
        	System.debug('Fecha: '+fechaString);
       		System.assertEquals(fechaString, String.valueOf(ct.NextFireTime));
        
		Test.stopTest();

	}	
    
}