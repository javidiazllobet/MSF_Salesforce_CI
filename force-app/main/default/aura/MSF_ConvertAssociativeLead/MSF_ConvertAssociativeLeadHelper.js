({
    getData : function(component, event) {       
        
        var action = component.get("c.getLeadInformation");
        
        action.setParams({
            leadId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue(); 
                
                component.set("v.currentLead",data.lead);
                component.set("v.duplicateContacts",data.contacts);               
                component.set("v.spinnerContacts",false);
                component.set("v.hasContacts",data.contacts.length > 0);                
            }else{
                this.showToast("ERROR",$A.get("$Label.c.MSF_UNKNOWN_ERROR"),"error");
            }
            
            component.set("v.spinnerConvert",false);
        })
        $A.enqueueAction(action);
    },
    
    setNewAssociativeContact : function(component, event) {
        component.set("v.spinnerConvert",true);
        
        var action = component.get("c.setNewAssociativePerson");        
        action.setParams({
            leadId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue(); 
                
                this.showToast(data.title, data.msg, data.type);
                this.goToSObject(data.goToSobject);
            }else{
                this.showToast("ERROR",$A.get("$Label.c.MSF_UNKNOWN_ERROR"),"error");                
            }            
            component.set("v.spinnerConvert",true);
        })
        $A.enqueueAction(action);
    },
    
    setMemberAsAssociativeContact : function(component, event) {
        component.set("v.spinnerConvert",true);
        
        var ev = event.getSource().get("v.value");
        var selectedContact = JSON.parse(JSON.stringify(ev));
        
        var action = component.get("c.setMemberAsAssociativePerson");        
        action.setParams({
            leadId : component.get("v.recordId"),
            selectedContactId : selectedContact.Id
        });
        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue(); 
                
                this.showToast(data.title, data.msg, data.type);
                this.goToSObject(data.goToSobject);
            }else{
                this.showToast("ERROR",$A.get("$Label.c.MSF_UNKNOWN_ERROR"),"error");                
            }            
            component.set("v.spinnerConvert",true);
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