({
	doInit : function(component, event, helper) {
        helper.getData(component, event);
	},
    
    getTarget : function(component, event, helper) {
        helper.getTargetData(component, event);
	},
    
    reassignOpp : function(component, event, helper) {        
        helper.reassignProcess(component, event);
	},
   
})