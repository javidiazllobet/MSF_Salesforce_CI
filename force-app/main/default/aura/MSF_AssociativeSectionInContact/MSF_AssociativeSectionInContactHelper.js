({    
    getAssociativeInfo : function(component, objectId) {
        
        var action = component.get("c.getAssociativeInformation");        
        action.setParams({
            contactId : objectId
        });
        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue();
                if(data.associative != null){
                	component.set("v.associativeInfo",data.associative);   
                    component.set("v.haveAssociaitiveRecord",true);   
                }                           
            }
            else{
                this.showToast("ERROR",$A.get("$Label.c.MSF_UNKNOWN_ERROR"),"error");
            }
            component.set("v.loadInfo",false);
        })
        $A.enqueueAction(action);
    },
    
    showToast : function(title, msg, type) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type,
            "mode" : "dismissible"
        });
        toastEvent.fire();
    },	    
    
})