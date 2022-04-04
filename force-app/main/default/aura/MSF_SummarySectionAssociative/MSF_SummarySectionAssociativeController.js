({
	doInit : function(component, event, helper) {
        var objectId = component.get("v.recordId");
        
        helper.objectType(component, objectId);         
	},
})