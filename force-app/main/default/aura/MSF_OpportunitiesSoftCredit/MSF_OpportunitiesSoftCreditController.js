({
    doInit : function(component, event, helper) {     
        var isSimple = component.get('v.simpleViewMode');
        if(isSimple){
            var navService = component.find("navService");
            // Sets the route to /lightning/o/Account/home
            var pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__MSF_OpportunitiesSoftCredit',
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
            var myPageRef = component.get("v.pageReference");
            var recordId = myPageRef.state.c__recordId;
            component.set("v.recordId", recordId);
        }
        if(isSimple){
            component.set('v.columns', [
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_1"), fieldName: 'OppName', type: 'url', typeAttributes:{label: { fieldName: 'Name' }}},
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_2"), fieldName: 'StageName', type: 'text'},
                {
                    label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_3"),
                    fieldName: 'Amount',
                    type: 'currency',
                    typeAttributes: { currencyCode: 'EUR'},
                    cellAttributes: { alignment: 'left' }
                },
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_4"), fieldName: 'RecordTypeName', type: 'text'},
                { type: 'action', typeAttributes: { rowActions: [
                    { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_ACTION_EDIT"), name: 'edit' }
                    //,{ label: $A.get("$Label.c.MSF_OPP_S_CREDIT_ACTION_DELETE"), name: 'delete' }
                ] } }
            ]);            
        }else{
            component.set('v.columns', [
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_1"), fieldName: 'OppName', type: 'url', typeAttributes:{label: { fieldName: 'Name' }},sortable:true},
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_2"), fieldName: 'StageName', type: 'text', sortable:true, cellAttributes: { alignment: 'left' } },
                {
                    label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_3"),
                    fieldName: 'Amount',
                    type: 'currency',
                    typeAttributes: { currencyCode: 'EUR'}, 
                    sortable:true, 
                    cellAttributes: { alignment: 'left' }
                },
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_4"), fieldName: 'RecordTypeName', type: 'text', sortable:true},
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_5"), cellAttributes: { alignment: 'left' },  fieldName: 'npe01__Payments_Made__c', type: 'currency', typeAttributes: { currencyCode: 'EUR'}, sortable:true },
                { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_COLUMN_6"), fieldName: 'CloseDate', type: 'date',
                 typeAttributes:{
                     day: '2-digit', 
                     month: '2-digit',   
                     year: 'numeric',   
                 }, 
                 sortable:true},
                { type: 'action', cellAttributes: { alignment: 'left' }, typeAttributes: { rowActions: [
                    { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_ACTION_EDIT"), name: 'edit' },
                    { label: $A.get("$Label.c.MSF_OPP_S_CREDIT_ACTION_DELETE"), name: 'delete' }
                ] } }
            ]);
            var recordId = component.get("v.recordId");
            console.log(recordId);
            helper.getName(component, recordId);
        }
        var ordermessage = component.get("v.orderByMessage");
        component.set("v.orderByMessage", 'Sin Ordenar');
        var recordId = component.get("v.recordId");
        var page = component.get("v.page");
        var nrows = component.get("v.nrows");        
        
        helper.getData(component,recordId,page,nrows);
        
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
        switch (action.name) {
            case 'edit':
                cmp.set('v.idToDelete',row.Id);
                cmp.find("recordHandler").reloadRecord();
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": row.Id
                });     
                editRecordEvent.fire();
                //cmp.set('v.arrayPosToUpdate',null);
                break;
            /*case 'delete':
                helper.openModal(cmp,row.Id);
                break;*/
        }
    },     
   /* deleteItem: function (cmp,event,helper){
        var isSimple = cmp.get('v.simpleViewMode');
        var cmpTarget = cmp.find('forceModalSpinner');
        cmp.set("v.isLoading", true);
        helper.closeModal(cmp);
        cmp.find("recordHandler").deleteRecord($A.getCallback(function(deleteResult) {
            // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful
            // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                // record is deleted
                helper.unrenderLoading(cmp);
                if(!isSimple){
                    var returnedLength = cmp.get('v.totalElem');
                    if(returnedLength[returnedLength.length-1] == '+'){
                        var returnedLength = returnedLength.substring(0,returnedLength.length-1);
                        returnedLength--;
                    	cmp.set('v.totalElem',returnedLength+'+');
                    }else{
                    	cmp.set('v.totalElem',returnedLength-1);
                    }
                    
                }
            } else if (deleteResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
                helper.unrenderLoading(cmp);
            } else if (deleteResult.state === "ERROR") {
                console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
                helper.unrenderLoading(cmp);
            } else {
                console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
                helper.unrenderLoading(cmp);
            }
        }));
        
    },*/
    handleRecordUpdated: function (cmp, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            var isSimple = cmp.get('v.simpleViewMode');
            if(isSimple){
                //Case when it's a simple record
                var recordId = cmp.get("v.recordId");
                var page = cmp.get("v.page");
                var nrows = cmp.get("v.nrows");
                
                var orderName = cmp.get('v.orderByName');
                var orderDir = cmp.get('v.sortedDirection');
                helper.getData(cmp,recordId,page,nrows);
            }else{
                var data = cmp.get('v.data');
                var idUpdate = cmp.get('v.idToDelete');
                cmp.set('v.data',helper.updateRow(data,idUpdate,eventParams.changedFields));
                cmp.set('v.idToDelete',null);
                cmp.find("recordHandler").reloadRecord();
            }
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
        } else if(eventParams.changeType === "REMOVED") {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                message: $A.get("$Label.c.MSF_OPP_S_CREDIT_DELETE_SUCCESS") + ' \"'+cmp.get('v.simpleRecord.Name')+'\"',
                type: 'success'
            });
            resultsToast.fire();
            
            var isSimple = cmp.get('v.simpleViewMode');
            if(isSimple){
                //Case when it's a simple record
                var recordId = cmp.get("v.recordId");
                var page = cmp.get("v.page");
                var nrows = cmp.get("v.nrows");
                helper.getData(cmp,recordId,page,nrows);
            }else{
                //Case when it's a complex record
                var data = cmp.get("v.data");
                var idDelete = cmp.get("v.idToDelete");
                var deleted = false;
                for (var i = 0; i < data.length && !deleted; i++) {
                    if(data[i].Id == idDelete) {
                        data.splice(i,1); 
                        deleted = true;
                    }
                }
                cmp.set("v.data", data);
            }
        } else {
            // there’s an error while loading, saving, or deleting the record
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    message: $A.get("$Label.c.MSF_OPP_S_CREDIT_DELETE_ERROR"),
                    type: 'Error'
                });
                resultsToast.fire();
        }
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
            var pages = cmp.get("v.page")+1;
            var nrows = cmp.get("v.nrows");
            var orderName = cmp.get('v.orderName');
            var orderDir = cmp.get('v.orderDir');
            cmp.set("v.page",pages);
            helper.getData(cmp, recordId,pages,nrows);
        }
    }
})