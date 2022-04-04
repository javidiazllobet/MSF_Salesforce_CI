({    
    createOrganizationContact : function(component, event, helper) {
        component.set("v.spinner",true);
        
        if(this.validityFields(component)){    
            var action = component.get("c.crearContactoOrganizacion");
            action.setParams({ 
                org : component.get("v.recordId"),
                name : component.find("name").get("v.value"),
                surname1 : component.find("surname1").get("v.value"),
                surname2 : component.find("surname2").get("v.value"),
                homephone : component.find("phone").get("v.value"),
                mobilephone : component.find("mobile").get("v.value"),
                email : component.find("email").get("v.value"),
                role : component.find("role").get("v.value"),
                isPrimary : component.find("maincontact").get("v.checked"),
                gender: component.find("gender").get("v.value"),
                languagePrf: component.find("languagePrf").get("v.value"),
                sLeadSource: component.find("leadSource").get("v.value"),
                entryCampaignId: component.find('entryCampaign').get('v.selectedRecord').Id
            });

            action.setCallback(this, function(actionResult) {                
                if(actionResult.getState() == "SUCCESS"){                    
                    var data = actionResult.getReturnValue();                    
                    if(data.isSuccess){                           
                        // Close the action panel
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        
                        // Navigate to new Organization Contact
                        var pageReference = {
                            type: "standard__recordPage",
                            attributes: {
                                recordId: data.contactId,
                                objectApiName: "Contact",
                                actionName: "view"                        
                            }
                        };
                        
                        var navService = component.find("navService");
                        event.preventDefault();
                        navService.navigate(pageReference); 
                    }else{                        
                        // Close the action panel
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();                        
                        //Error produced in apex when create contact
                        this.showToast('ERROR',data.msg,'error');  
                    }   
                }else{
                    // Close the action panel
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();                    
                    this.showToast("ERROR",$A.get("$Label.c.MSF_UNKNOWN_ERROR"),"error");
                }
            });
            
            $A.enqueueAction(action);  
        }else{
            component.set("v.spinner",false);    
        }
    },
    
    getGender : function(component, event, helper) {
        this.setPicklist(component, "c.getGender", "v.gender", "v.genSelected");        
    },
    
    getPrfLang : function(component, event, helper) {
        this.setPicklist(component, "c.getPrfLanguage", "v.prfLang", "v.prfLanSelected");
    },  
    
    getLeadSources : function(component, event, helper) {
        this.setPicklist(component, "c.getLeadSources", "v.leadSources", "v.lsSelected");
    },
    
    setPicklist : function(component, method, attribute, selected){
    	if(component.isValid()){
            var action = component.get(method);
            action.setCallback(this, function(actionResult) {
                if(actionResult.getState() == "SUCCESS"){
                    var stateReturnValue = actionResult.getReturnValue();
                    if(stateReturnValue != null){
                        component.set(attribute, stateReturnValue);
                        if(attribute == "v.prfLang"){
                            component.set(selected, stateReturnValue[1]); 
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }    
    },
    
    
    validityFields : function(component){
        console.log("validity: ",component.find("leadSource").checkValidity());
        if(component.find("name").get("v.validity").valid &&
           component.find("surname1").get("v.validity").valid &&
           component.find("surname2").get("v.validity").valid &&
           component.find("phone").get("v.validity").valid &&
           component.find("mobile").get("v.validity").valid &&
           component.find("email").get("v.validity").valid &&
           component.find("maincontact").get("v.validity").valid &&
           component.find("role").get("v.validity").valid &&
           component.find("leadSource").checkValidity() &&
           component.find('entryCampaign').get('v.selectedRecord').Id != null
          ) 
        {
            return true;
        }
        else{
            component.find("name").reportValidity();
            component.find("surname1").reportValidity();
            component.find("surname2").reportValidity();
            component.find("phone").reportValidity();
            component.find("mobile").reportValidity();
            component.find("email").reportValidity();
            component.find("maincontact").reportValidity();
            component.find("role").reportValidity();
			component.find("leadSource").showHelpMessageIfInvalid();
            component.find('entryCampaign').set('v.error', true);
        }
        
        return false;
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