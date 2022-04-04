@isTest
public class MSF_ModificacionMasivaTareasCtl_Test {
    @TestSetup
    static void testSetup(){
        Task tarea = new Task();
        tarea.Subject = 'Task Subject';
        tarea.Status = 'Pendiente';
        tarea.Priority='Normal';
        tarea.OwnerId = UserInfo.getUserId();
        insert tarea;
    }

    @isTest 
    static void getTaskTest(){
        Id idTask = [SELECT Id FROM Task WHERE Subject = 'Task Subject' LIMIT 1].Id;
        MSF_ModificacionMasivaTareasController.DataTableWrapper result = new MSF_ModificacionMasivaTareasController.DataTableWrapper();
        test.startTest();
        result = MSF_ModificacionMasivaTareasController.getTask(idTask);
        test.stopTest();
        system.assertNotEquals(null, result);
    }
}