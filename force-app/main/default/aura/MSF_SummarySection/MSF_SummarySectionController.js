({
	inicializacion : function(component, event, helper) {
        var idContact = component.get("v.recordId");
        helper.getContact(component, idContact);
        helper.getProm(component, idContact);
        helper.getCaso(component, idContact);
        helper.getVD(component, idContact);
        helper.getOpor(component, idContact);
        helper.getDuplicate(component,idContact);
        
	},
    
})