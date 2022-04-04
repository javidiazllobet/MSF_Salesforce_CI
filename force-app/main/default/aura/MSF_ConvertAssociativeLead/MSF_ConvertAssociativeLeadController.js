({
	doInit : function(component, event, helper) {
        helper.getData(component, event);
	},
    
    newContact : function(component, event, helper) {        
        helper.setNewAssociativeContact(component, event);
	},
    
    existingContact : function(component, event, helper) {
        helper.setMemberAsAssociativeContact(component, event);
	},  
    
    existingAssociativeContact : function(component, event, helper) {
        var ev = event.getSource().get("v.value");
        var selectedContact = JSON.parse(JSON.stringify(ev));
        
        helper.goToSObject(selectedContact.Id);
	},
})