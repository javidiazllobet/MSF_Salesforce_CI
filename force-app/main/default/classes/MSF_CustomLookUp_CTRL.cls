public class MSF_CustomLookUp_CTRL {
    
	@AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyWord, String secondFilter, String filterActive, String ObjectName) {
        String searchKey = '%'+ searchKeyWord	 +'%';

        List <sObject> returnList = new List <sObject>();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'SELECT Id, Name';
        sQuery += secondFilter != '' ? ', ' + secondFilter : '';
        sQuery += ' FROM ' + ObjectName + ' WHERE Name LIKE: searchKey';
        sQuery += secondFilter != '' ? ' OR ' + secondFilter + ' LIKE: searchKey' : '';
        sQuery += filterActive != '' ? ' AND '+ filterActive + ' = true' : '';
        if(ObjectName != 'Campaign' || secondFilter == null ||  secondFilter == ''){ 
            sQuery += ' order by createdDate DESC limit 15';
        } else{
            sQuery += ' order by '+ secondFilter +' ASC limit 15';
        }

        List <sObject> lstOfRecords = Database.query(sQuery);        
        
        for (sObject obj: lstOfRecords){
            returnList.add(obj);
        }
        return returnList;
    }
}