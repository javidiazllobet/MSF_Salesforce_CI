({
    
    init : function(component, event, helper) {
        component.set("v.spinner",true);       
        
        this.closeQuickAction();
        
        component.set("v.spinner",false);  
    },   
    
    closeQuickAction : function(){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
    
})