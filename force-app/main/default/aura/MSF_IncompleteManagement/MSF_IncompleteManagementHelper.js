({
	
    getIncompletes : function(component, event) {                 
        var action = component.get("c.getMyIncompletes");

        action.setCallback(this, function(actionResult) {
            if(actionResult.getState() == "SUCCESS"){
                var dataValues = actionResult.getReturnValue();
                if(dataValues != null){ 
                    component.set("v.data", dataValues.lIncompleteIndividuals);
                }
            }else{
                this.showToast($A.get('$Label.c.MSF_FORM_F2F_ERROR_TITLE'),$A.get('$Label.c.MSF_UNKNOWN_ERROR'),'error');
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    removeIncomplete: function (component, row) { 
        var removeConfirm = confirm($A.get('$Label.c.MSF_FORM_F2F_INCOMPLETE_CONFIRMATION_MESSAGE_REMOVE_LEAD'));
        if(removeConfirm){
            component.set('v.spinnerDelete', true); 
            var rows = component.get('v.data');
            var rowIndex = rows.indexOf(row);		
            
            var action = component.get("c.removeIncomplete");
            action.setParams({ 
                incompleteId : JSON.parse(JSON.stringify(row)).Id
            });
            
            action.setCallback(this, function(actionResult) {
                if(actionResult.getState() == "SUCCESS"){
                    var dataValues = actionResult.getReturnValue();
                    this.showToast(dataValues.title,dataValues.msg,dataValues.type);                 
                    if(dataValues.eliminado){
                        rows.splice(rowIndex, 1);
                        component.set('v.data', rows); 
                    }            
                }
                else{
                    this.showToast($A.get('$Label.c.MSF_FORM_F2F_ERROR_TITLE'),$A.get('$Label.c.MSF_UNKNOWN_ERROR'),'error');
                }            
                component.set('v.spinnerDelete', false);  
            });    
            
            $A.enqueueAction(action);  
        }
    },
    
    goToForm : function(component, event,  row) {        
        console.log('Data sent: ',JSON.parse(JSON.stringify(row)));
        
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c:MSF_FormF2F',
                "incomplete": JSON.parse(JSON.stringify(row))
            },
            state: {
                "incomplete": JSON.parse(JSON.stringify(row))
            }
        };

        var navService = component.find("navService");
        event.preventDefault();
        navService.navigate(pageReference,true);
        
        /*var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:MSF_FormF2F", //****** Cambiar por el componente del formulario que toque *******
            componentAttributes: {
                //recordId : '0036E00000SwWARQA3',
                incomplete: JSON.parse(JSON.stringify(row))
            }//,
            //isredirect : true        
        });
        evt.fire();*/
    },
    
    showToast : function(title, msg, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type,
            "mode" : 'dismissible'
        });
        toastEvent.fire();
    },	
    
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';

        data = Object.assign(
            [],
            data.sort(
                this.sortBy(fieldName, reverse ? -1 : 1)
            )
        );
        component.set("v.data", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ? function(x) { return primer(x[field]) } : function(x) { return x[field] };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
    
})