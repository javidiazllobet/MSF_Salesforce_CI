({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var isSimple = component.get('v.simpleViewMode');
        if(isSimple){
            var navService = component.find("navService");
            var pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Task',
                    actionName: 'list'
                },
                state: {
                    "c__recordId": component.get('v.recordId'),
                }
            };
            component.set("v.pageReference", pageReference);
            // Set the URL on the link or use the default if there's an error
            var defaultUrl = "#";
            navService.generateUrl(pageReference).then($A.getCallback(function(url) {
                component.set("v.seeAllUrl", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.seeAllUrl", defaultUrl);
            }));
        }else{
            var cmpTarget = component.find('lightingCardBody');
            $A.util.addClass(cmpTarget,'slds-page-header');
        }
      
        component.set('v.columns', [
            { label: '', fieldName: 'Id',fixedWidth: 45, type: 'url', typeAttributes: {label: $A.get("$Label.c.MSF_FORM_VIEW")}},
            { label: 'Asunto', fieldName: 'Subject', type: 'text'},
            { label: 'Estado', fieldName: 'Status',  type: 'text'},
            { label: 'Comentario', fieldName: 'Description',  type: 'text'},
            { type: 'action', cellAttributes: { alignment: 'left' }, typeAttributes: { rowActions: [
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_ACTION_EDIT"), name: 'edit' },
            ] } }
        ]);            
        
        var page = component.get("v.page");
        var nrows = component.get("v.nrows");        
        helper.getData(component, recordId, page, nrows);
	},
             
     updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var showName = event.getParam('fieldName')
        var rows = cmp.get('v.columns');
        var found = false;
        for(var i = 0; i < rows.length && found != true; i++){
            if(rows[i].fieldName == fieldName){
                found = true;
                showName = rows[i].label;
            }
        }
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
        cmp.set("v.orderByMessage", $A.get("$Label.c.MSF_OPP_S_CREDIT_SORTED_BY") + ' ' + showName);
    },    
             
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        let rowId = row.Id.substring(1, row.Id.length); //Remove the / 
        switch (action.name) {
            case 'edit':
                cmp.find("recordHandler").reloadRecord();
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": rowId
                });     
                editRecordEvent.fire();
                break;
        }
    },     
             
    handleRecordUpdated: function (cmp, event, helper) {
        
        var recordId = cmp.get("v.recordId");
        var page = cmp.get("v.page");
        var nrows = cmp.get("v.nrows");
        
        var orderName = cmp.get('v.orderByName');
        var orderDir = cmp.get('v.sortedDirection');
        helper.getData(cmp, recordId, page, nrows);
    },
             
    closeModal: function(cmp,event,helper){
        helper.closeModal(cmp);
        helper.unrenderLoading(cmp);
    },
             
    loadMoreData: function(cmp, event,helper){
        var isLoading = cmp.get('v.isLoading');
        if(!isLoading) {
            cmp.set('v.isLoading',true);
            var recordId = cmp.get("v.recordId");
            var pages = cmp.get("v.page") + 1;
            var nrows = cmp.get("v.nrows");
            var orderName = cmp.get('v.orderName');
            var orderDir = cmp.get('v.orderDir');
            cmp.set("v.page",pages);
            helper.getData(cmp, recordId,pages,nrows);
        }
    },
             
     toastHandler : function(component, event, helper) {
        //Reload the data; 
        let recordId = component.get("v.recordId");
        component.set('v.isLoading', true);
        helper.getData(component, recordId);
        component.set('v.isLoading', false);
    }         
})