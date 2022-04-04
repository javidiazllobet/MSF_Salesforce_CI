@isTest
public class MSF_ModificacionTareasController_Test {
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
    static void getPickListValuesStatusTest(){
        test.startTest();
        List<String> listValues = MSF_ModificacionTareasController.getPickListValuesStatus();
        test.stopTest();

        system.assertNotEquals(null, listValues);
    }

    @isTest 
    static void getPickListValuesSubjectTest(){
        test.startTest();
        List<String> listValues = MSF_ModificacionTareasController.getPickListValuesSubject();
        test.stopTest();

        system.assertNotEquals(null, listValues);
    }

    @isTest 
    static void submitDateTest(){
        Task tarea = [SELECT Id, ActivityDate, Status, Subject, OwnerId, Owner.name FROM Task WHERE Subject = 'Task Subject'];
        List<String> listId = new List<String>();
        listId.add(tarea.Id);
        String Subject = tarea.Subject;
        String Status = tarea.Status;
        Date dueDate = tarea.ActivityDate;
        String OwnerId = tarea.OwnerId;
        

        test.startTest();
        string valor = MSF_ModificacionTareasController.submitDate(listId, Subject, Status, dueDate, OwnerId);
        test.stopTest();

        system.assertNotEquals(null, valor);
    }
}