({
    getData : function(component, event) {      
        
        var action = component.get("c.getInformation");        
        action.setParams({
            hoppId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue(); 
                
                if(data.success){
                	component.set("v.currentRecord",data.record);
                	component.set("v.currentContact",data.contact);               
                	component.set("v.currentOppHistorical",data.opp);    
                }else{
                	console.log('Error');    
                }                
                
            }else{
                this.showToast("ERROR",$A.get("$Label.c.MSF_UNKNOWN_ERROR"),"error");
            }
            
            component.set("v.loadingCurrent",false);
        })
        $A.enqueueAction(action);
    },
    
    getTargetData : function(component, event) {  
        component.set("v.loadingTarget",true);
        
        var action = component.get("c.getTargetInformation");        
        action.setParams({
            numMember : component.get("v.searchId"),
            dCloseDate : component.get("v.currentRecord").closedate__c
        });
        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue(); 
                
                if(data.success){
                	component.set("v.targetContact",data.contact);               
                	component.set("v.targetOppHistorical",data.opp);    
                    component.set("v.message",null);  
                }else{                	 
                    component.set("v.targetContact",null);               
                	component.set("v.targetOppHistorical",null);  
                    component.set("v.message",data.msg); 
                } 
            }else{
                this.showToast("ERROR",$A.get("$Label.c.MSF_UNKNOWN_ERROR"),"error");
            }
            
            component.set("v.loadingTarget",false);
        })
        $A.enqueueAction(action);
    },
    
    reassignProcess : function(component, event) {
        component.set("v.reassignProcess",true);
        
        var action = component.get("c.reassignProcess");        
        action.setParams({            
            cOrigin : component.get("v.currentContact"),
            cTarget : component.get("v.targetContact"),
            exOppHis : component.get("v.currentRecord"),
            oOrigin : component.get("v.currentOppHistorical"),
            oTarget : component.get("v.targetOppHistorical")            
        });
        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue(); 

                if(data.success){
                    $A.get("e.force:closeQuickAction").fire();	
                    $A.get('e.force:refreshView').fire();
                    this.showToast(null,$A.get("$Label.c.MSF_REASSIGN_SUCCESS"),"success");
                }else{       
                	this.showToast("ERROR",data.msg,"error");  
                } 
            }else{
                this.showToast("ERROR",$A.get("$Label.c.MSF_UNKNOWN_ERROR"),"error");
            }
            
            component.set("v.reassignProcess",false);
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
    
    goToSObject : function (SObjectId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": SObjectId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})