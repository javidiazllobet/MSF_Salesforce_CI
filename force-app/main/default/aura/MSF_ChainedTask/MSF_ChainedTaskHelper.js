({
	getData : function(component, recordId) {
		var action = component.get("c.getChainedTasks");
        action.setParams({
            "parentId"    : recordId
        });
        action.setCallback(this, function(response) {    
            let state = response.getState();
            let returnedData = response.getReturnValue();
            
            if (state === "SUCCESS") {
                returnedData = returnedData.data;
                for(let i = 0; i < returnedData.length; i++){
                    returnedData[i].Id = '/' + returnedData[i].Id;
                }
                component.set('v.data', returnedData);
            }
            else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
	}
})