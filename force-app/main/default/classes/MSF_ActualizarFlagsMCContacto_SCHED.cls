/**
* @author 		Deloitte
* @date 		11-2020
* @description	Class to program the execution of MSF_ActualizarFlagsMCContacto_BATCH
*/
global without sharing class MSF_ActualizarFlagsMCContacto_SCHED implements Schedulable {

   global void execute(SchedulableContext sc) {
		MSF_ActualizarFlagsMCContacto_BATCH batchFlagMC = new MSF_ActualizarFlagsMCContacto_BATCH();
		Database.executeBatch(batchFlagMC, 50);
   }
}