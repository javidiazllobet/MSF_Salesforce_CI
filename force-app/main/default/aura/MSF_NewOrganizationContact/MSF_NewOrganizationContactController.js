({     
    doInit: function(component, event, helper) {        
        helper.getGender(component,event, helper);
        helper.getPrfLang(component,event, helper);
        helper.getLeadSources(component,event, helper); 
    },
    
    newOrganizationContact : function(component, event, helper) {        
        helper.createOrganizationContact(component, event, helper);
    },
    
    closeQuickAction : function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }   
})