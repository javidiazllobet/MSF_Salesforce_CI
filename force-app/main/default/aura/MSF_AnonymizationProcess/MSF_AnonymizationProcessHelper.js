({
	anonymization : function(component, event) {
		component.set("v.spinner",true);        
 
        var action = component.get("c.anonymizationRecord");
        action.setParams({ 
            recordId : component.get("v.recordId"),
        });
        
        action.setCallback(this, function(actionResult) {                
            if(actionResult.getState() == "SUCCESS"){                    
                var data = actionResult.getReturnValue();                    
                
                if(data.anonymizationSuccess){                   
                    this.showToast(null, data.msg, 'SUCCESS');    
                }else{
                	this.showToast(null, data.msg, 'ERROR');     
                }
            }else{
            	this.showToast(null, $A.get("$Label.c.MSF_UNKNOWN_ERROR"), 'ERROR'); 	  
            }
            
            component.set("v.spinner",false); 
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();             
        });
        
        $A.enqueueAction(action);                  	
	},
    
    showToast : function(title, msg, type) {        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type
        });
        toastEvent.fire();
    },
})