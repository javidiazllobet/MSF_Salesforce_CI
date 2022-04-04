/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MSF_ListViewTareasController {

    @AuraEnabled
    public static Wrapper getListView(){
       final String value = '000000000000000000';
       final String label = '--none--';

       String usuario = UserInfo.getUserId();
       List<Task> listTask = new List<Task>();
       WrapperGetDataListView dataListView = new WrapperGetDataListView();
       Wrapper listView = new Wrapper();
       List<MSF_DefaultUserListView__c> listViewDefault = [SELECT msf_ListViewName__c, msf_ListViewId__c, msf_User__c FROM MSF_DefaultUserListView__c WHERE msf_User__c = :usuario LIMIT 1];
       if (listViewDefault.size() == 0){
            List<ListView> listListViewUser = [SELECT id, name FROM listview WHERE SobjectType = 'Task' AND DeveloperName = 'CompletedTasks'];
            dataListView = getDataListView(listListViewUser[0].id);
            listView.label = listListViewUser[0].name;
            listView.value = listListViewUser[0].id;
       } else {
           dataListView = getDataListView(listViewDefault[0].msf_ListViewId__c);
           listView.label = listViewDefault[0].msf_ListViewName__c;
           listView.value = listViewDefault[0].msf_ListViewId__c;
       }

       List<ListView> listListView = [SELECT id, name FROM listview WHERE SobjectType = 'Task'];

       //String helpText = System.Label.msf_HelpTextListView;
       String itemsLabel = System.Label.MSF_Items;
       //String listViewLabel = System.Label.MSF_ListView;
       Integer numeroRegistros = numeroRegistros();
       
       Integer numRegistros = Integer.valueOf(numeroRegistros);

       //listView.helpText = helpText;
       listView.numRegistros = numRegistros;
       listView.itemsLabel = itemsLabel;
       //listView.listViewLabel = listViewLabel;
       listView.listTask = dataListView.listTask;
       listView.hayMasRegistros = dataListView.hayMasRegistros;
       listView.listListView = listListView;
       return listView;
    }

    @AuraEnabled
    public static WrapperGetDataListView getDataListView (Id Identificador){
       system.debug('identificador: ' + Identificador);
       
       if (Identificador == '000000000000000000'){
           //List<Task> listTask = [SELECT Id, ActivityDate, Status, Subject, OwnerId, Owner.name, WhatId, WhoId FROM Task  LIMIT 200];
           WrapperGetDataListView dataListView = new WrapperGetDataListView();
           dataListView.listTask = null;
           dataListView.hayMasRegistros = false;
           return dataListView;
       } else {

           String sessionId = null;
           if(Test.isRunningTest()){
               sessionId = 'SESSION_ID_REMOVED';
           }else {
               sessionId = fetchUserSessionId();
           }
           
           Integer numeroRegistrosOriginal = numeroRegistros();
           Integer numeroRegistros = numeroRegistrosOriginal + 1;

           HTTP h = new HTTP();
           String ep = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v53.0/sobjects/Task/listviews/' + Identificador + '/results?limit=500';
           HttpRequest req = new HttpRequest();
           req.setMethod('GET');
           //req.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
           req.setHeader('Authorization','Bearer '+sessionId);
           req.setEndpoint(ep);
           HttpResponse res = new Http().send(req);
           
           JSONParser parser = JSON.createParser(res.getBody());
           Map<Integer, String> mapText = new Map<Integer, String>();
           Integer count = 0;
           List<Integer> listId = new List<Integer>();
           List<Integer> listSubject = new List<Integer>();
           List<Integer> listStatus = new List<Integer>();
           List<Integer> listActivityDate = new List<Integer>();
           List<Integer> listOwnerId = new List<Integer>();
           while (parser.nextToken() != null) {
               mapText.put(count, parser.getText());
               if (parser.getText() == 'Id') {
                   listId.add(count);
               }
               count = count + 1;
           }
           
           Boolean hayMasRegistros = false;
           Set<Id> setId = new Set<Id>();
           for (Integer i = 0; i < listId.size(); i++){
               Integer count1 = listId[i];
               Integer count2 = count1 + 2;
               String field = mapText.get(count2);
               if (field.length() == 18){
                   if (setId.size() == numeroRegistrosOriginal){
                       hayMasRegistros = true;
                       break;
                   } else {
                       setId.add(field);
                   }
               }
           }

           List<Task> listTask = [SELECT id, Subject, Status, ActivityDate, Who.Name, OwnerId, Owner.name FROM Task WHERE Id = :setId ORDER BY Id, ActivityDate ASC NULLS LAST];

           final String value = '000000000000000000';
           Map<Id, String> mapListView = new Map<Id,String>();
           List<ListView> listListView = [SELECT id, name FROM listview WHERE SobjectType = 'Task'];
           for (ListView lv: listListView){
               ListView listView = new listView();
               Id idListView = lv.Id;
               String name = lv.Name;
               mapListView.put(idListView, name);
           }
           String usuario = UserInfo.getUserId();
           MSF_DefaultUserListView__c defaultUser = new MSF_DefaultUserListView__c();
           List<MSF_DefaultUserListView__c> listViewDefault = [SELECT name, msf_ListViewName__c, msf_ListViewId__c, msf_User__c FROM MSF_DefaultUserListView__c WHERE msf_User__c = :usuario LIMIT 1];
           if (listViewDefault.size() == 0){
               String nameListView = mapListView.get(Identificador);
               String name = nameListView + usuario;
               if (name.length() > 81){
                   defaultUser.name = name.subString(80);
               }
               defaultUser.msf_ListViewName__c = nameListView;
               defaultUser.msf_ListViewId__c = Identificador;
               defaultUser.msf_User__c = usuario;
               insert defaultUser;                
           } else {
               String nameListView = mapListView.get(Identificador);
               if (listViewDefault[0].msf_ListViewId__c != Identificador){
                   String name = nameListView + usuario;
                   if (name.length() > 81){
                       listViewDefault[0].name = name.subString(80);
                   }
                   listViewDefault[0].msf_ListViewName__c = nameListView;
                   listViewDefault[0].msf_ListViewId__c = Identificador;
                   listViewDefault[0].msf_User__c = usuario;
                   update listViewDefault;
               }
           }
           WrapperGetDataListView dataListView = new WrapperGetDataListView();
           dataListView.listTask = listTask;
           dataListView.hayMasRegistros = hayMasRegistros;
           return dataListView;
       }
   }

   private static Integer numeroRegistros(){
       Integer numeroRegistros = 0;
       List<msf_ModificacionMasivaTareas__mdt> modTareasCMT = msf_ModificacionMasivaTareas__mdt.getAll().values();
       for (msf_ModificacionMasivaTareas__mdt mmt: modTareasCMT){
           Boolean hasCustomPermission = FeatureManagement.checkPermission(mmt.msf_CustomPermission__c);
           if (hasCustomPermission) {
               numeroRegistros = Integer.valueOf(mmt.msf_NumeroRegistros__c);
           }
       }
       return numeroRegistros;
   }

   public static String fetchUserSessionId(){
       String sessionId = '';
       // Refer to the Page
       PageReference reportPage = Page.GetSessionIdVF;
       // Get the content of the VF page
       String vfContent = reportPage.getContent().toString();
       // Find the position of Start_Of_Session_Id and End_Of_Session_Id
       Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
       endP = vfContent.indexOf('End_Of_Session_Id');
       // Get the Session Id
       sessionId = vfContent.substring(startP, endP);
       System.debug('sessionId '+sessionId);
       // Return Session Id
       return sessionId;
       }

   public class Wrapper{
       @AuraEnabled
       public List<Task> listTask {get; set;}
       @AuraEnabled
       public List<ListView> listListView {get; set;}
       @AuraEnabled
       public String value {get; set;}
       @AuraEnabled
       public String label {get; set;}
       //@AuraEnabled
       //public String helpText {get; set;}
       @AuraEnabled
       public Integer numRegistros {get; set;}
       @AuraEnabled
       public String itemsLabel {get; set;}
       //@AuraEnabled
       //public String listViewLabel {get; set;}
       @AuraEnabled
       public Boolean hayMasRegistros {get; set;}
   } 

   public class WrapperGetDataListView{
       @AuraEnabled
       public List<Task> listTask {get; set;}
       @AuraEnabled
       public Boolean hayMasRegistros {get; set;}
   } 
}