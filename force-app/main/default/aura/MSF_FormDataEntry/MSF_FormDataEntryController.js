({
	inicializacion : function(component, event, helper) {	
        var myPageRef = component.get("v.pageReference");

        if(helper.isNotEmpty(myPageRef.state.c__recordId)){
            var recordId = myPageRef.state.c__recordId;
            component.set("v.recordId", recordId);
           	
            helper.setDenyFieldEditing(component);
            helper.getMemberInfo(component, event, helper);
        }else{
            helper.initializeSobjects(component);
        } 
        helper.setIsConsoleNavigation(component, event, helper);
        helper.getLanguage(component, event, helper);
        helper.getGender(component, event, helper);
        helper.getOrgType(component, event, helper);
        helper.getFunType(component, event, helper);
        helper.getPayMethod(component, event, helper);
        helper.getLeadSource(component, event, helper);
        helper.getModificationChannels(component, event, helper);
        helper.getFrequencies(component, event, helper);
        helper.getToday(component, event, helper);    		
	},
    
    setFieldsVisibility : function(component, event, helper) {
        helper.setFieldsVisibility(component, event, helper);
    },

    payMethodChanged : function(component, event, helper) {
        helper.getOppType(component, event, helper);
        helper.getTarget(component, event, helper);
        helper.getInKindTypes(component, event, helper);
        helper.getPaymentProfiles(component, event, helper);
    },
    
    oppTypeChanged : function(component, event, helper) {
        helper.setDefaultOppDate(component, event, helper);
    },
    
    payProfileChanged : function(component, event, helper) {
        helper.getPPInfo(component, event, helper);
    },
    
    save : function(component, event, helper){
        helper.generalValidationFields(component, event, helper);
    },
    
    toBack : function(component, event, helper) {
        helper.toBack(component, event);
    }, 
    
    clearCustomValidity : function(component, event, helper){
        var value = event.getSource().get("v.name");
        component.find(value).setCustomValidity('');
        component.find(value).reportValidity();
    },
    
    refresh : function(component, event, helper){
        helper.refreshPage(component);
    },
    
    toBack : function(component, event, helper) {
        helper.navigateToObject(component.get("v.recordId"));
    }, 
    
    togglePrimaryContact : function(component, event, helper) {
        if(event.getSource().get("v.checked")){
            $A.util.removeClass(component.find("organizationContact"),"slds-hide");
            component.find("firstNameAux").set("v.required",true);
            component.find("lastNameAux").set("v.required",true);
        }else{
            $A.util.addClass(component.find("organizationContact"),"slds-hide");
            component.find("firstNameAux").set("v.required",false);
            component.find("lastNameAux").set("v.required",false);
        }
        
	},
})