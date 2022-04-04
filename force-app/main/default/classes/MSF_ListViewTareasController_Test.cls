/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class MSF_ListViewTareasController_Test {
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
    static void getListViewTest(){
        Test.setMock(HttpCalloutMock.class, new MSF_ListViewTareasController_Mock());
        test.startTest();
        MSF_ListViewTareasController.Wrapper listListView = MSF_ListViewTareasController.getListView();
        test.stopTest();

        system.assertNotEquals(null, listListView);
    }

    @isTest 
    static void getDataListViewTest2(){
        ListView lista = [SELECT id FROM listview WHERE SobjectType = 'Task' LIMIT 1];
        Id identificador = lista.Id;
        Test.setMock(HttpCalloutMock.class, new MSF_ListViewTareasController_Mock());  
        test.startTest();
        MSF_ListViewTareasController.WrapperGetDataListView listTask = MSF_ListViewTareasController.getDataListView(identificador);
        test.stopTest();

        system.assertNotEquals(null, listTask);
    }

}