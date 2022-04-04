({
	getData:function(component, recordId,page,nrows){
        var isSimple = component.get('v.simpleViewMode');
		var action = component.get("c.getChildTasks");
        action.setParams({
            "parentId"    : recordId,
            "page"  : page,
            "nrows" : nrows
        });
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataAdded = component.get('v.data');
                var returndata = response.getReturnValue();
                var totalElemCount = component.get('v.totalElemCount');

                if(isSimple){
                    totalElemCount = returndata.data.length;
                }else{
                    totalElemCount += returndata.data.length;
                }
                component.set('v.totalElemCount',totalElemCount);

                var returnedLength = returndata.moreThanReturned ? totalElemCount+'+': totalElemCount;
                component.set('v.totalElem',returnedLength);

                component.set('v.enableInfiniteLoading', returndata.moreThanReturned);
                returndata = returndata.data;
                for(var i=0; i < returndata.length; i++){
                    returndata[i].Id = '/' + returndata[i].Id;
                }
                if(dataAdded != null && !isSimple){
                    dataAdded = dataAdded.concat(returndata);
                }else{ 
                    dataAdded = returndata;
                }
                component.set('v.data', dataAdded);
                component.set("v.isLoading",false);
            } else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
	}
})