({
    doInit : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        component.set('v.columns', [
            { label: '', fieldName: 'Id',fixedWidth: 45, type: 'url', typeAttributes: {label: $A.get("$Label.c.MSF_FORM_VIEW")}},
            { label: 'Asunto', fieldName: 'Subject', type: 'text', },
            { label: 'Estado', fieldName: 'Status',  type: 'text'},
            { label: 'Comentario', fieldName: 'Description',  type: 'text'},
            { type: 'action', cellAttributes: { alignment: 'left' }, typeAttributes: { 
                rowActions: [
                	{ label: $A.get("$Label.c.MSF_OPP_S_CREDIT_ACTION_EDIT"), name: 'edit' }
            	] 
            }}
            ]);
        helper.getData(component, recordId);
        component.set('v.isLoading', false);
    },
    
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        let rowId = row.Id.substring(1, row.Id.length); //Remove the / 
        switch (action.name) {
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": rowId
                });     
                editRecordEvent.fire();
                break;
        }       
    },
    
    toastHandler : function(component, event, helper) {
        //Reload the data; 
        let recordId = component.get("v.recordId");
        component.set('v.isLoading', true);
        helper.getData(component, recordId);
        component.set('v.isLoading', false);
    },
    
    loadMoreData : function(component, event, helper){
        /*var isLoading = component.get('v.isLoading');
        if(!isLoading) {
            component.set('v.isLoading',true);
            var recordId = component.get("v.recordId");
            var pages = component.get("v.page") + 1;
            var nrows = component.get("v.nrows");
            var orderName = component.get('v.orderName');
            var orderDir = component.get('v.orderDir');
            component.set("v.page",pages);
            helper.getData(component, recordId, pages,nrows);
        }*/
    }
})