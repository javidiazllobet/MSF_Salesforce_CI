({
    objectType : function(component, objectId) {
        component.set("v.spinnerLoadInfoOne",true);
        component.set("v.spinnerLoadInfoTwo",true);
        
        var action = component.get("c.getObjectType");        
        action.setParams({
            objectId : objectId
        });        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue();                 
                component.set("v.isContact",data.isContact);                 
                if(data.isContact){
                    this.getContactInfo(component, objectId); 
                    this.getAssociativeInfo(component, objectId);                    
                }else{
                    this.getLeadInfo(component, objectId);     
                }                
            }else{
                this.showToast("ERROR","Error desconocio al recuperar la información de las etiquetas de asociativo.","error");
                component.set("v.spinnerLoadInfoOne",false);
        		component.set("v.spinnerLoadInfoTwo",false);
            }
        })
        $A.enqueueAction(action);        
    },
    
    getContactInfo : function(component, objectId) {
        
        var action = component.get("c.getContactInformation");        
        action.setParams({
            contactId : objectId
        });        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue();                 
                component.set("v.endorsedNumber",data.numEndorsements.toString()); 
                component.set("v.hasEndorses", data.numEndorsements > 0);
                component.set("v.isAssociative",data.contact.msf_IsAssosiative__c);
            }else{
                this.showToast("ERROR","No se ha podido recuperar la información relacionada del contacto.","error");
            }
            component.set("v.spinnerLoadInfoOne",false);
        })
        $A.enqueueAction(action);
    },
    
    getAssociativeInfo : function(component, objectId) {

        var action = component.get("c.getAssociativeInformation");        
        action.setParams({
            contactId : objectId
        });        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue(); 
                if(data.associative != null){
                    //component.set("v.display",true);
                	component.set("v.hasFieldExperience", data.associative.msf_StaffType__c == 'Nacional' || data.associative.msf_IsFieldSAP__c == true);
                    component.set("v.isSanitary",data.associative.msf_IsSanitary__c);
                    component.set("v.hasAssemblyExperience",data.associative.msf_MemberMeetingStartDate__c != null);   
                    component.set("v.isHeadquartersStaff",data.associative.msf_SalariedSAP__c  == true);   
                }else{
                	//component.set("v.display",true);
                	component.set("v.hasFieldExperience",false);
                    component.set("v.isSanitary",false);
                    component.set("v.hasAssemblyExperience",false);   
                    component.set("v.isHeadquartersStaff",false);     
                }
            }else{
                this.showToast("ERROR","No se ha podido recuperar la información relacionada del asociativo.","error");                
            }
            component.set("v.spinnerLoadInfoTwo",false);            
        })
        $A.enqueueAction(action);
    },
    
    getLeadInfo : function(component, objectId) {
        
        var action = component.get("c.getLeadInformation");        
        action.setParams({
            leadId : objectId
        });        
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var data = response.getReturnValue();
                //component.set("v.display",data.ld.RecordType.DeveloperName == 'Associative');
                component.set("v.isSanitary",data.ld.msf_isSanitary__c); 
                component.set("v.hasFieldExperience",data.ld.msf_StaffType__c == 'Nacional' || data.ld.msf_StaffType__c == 'Internacional');
                component.set("v.isHeadquartersStaff",data.ld.msf_StaffType__c == 'Voluntario' || data.ld.msf_StaffType__c == 'Sede o delegaciones');                
            }else{
                this.showToast("ERROR","No se ha podido recuperar la información relacionada del lead.","error");
            }
            component.set("v.spinnerLoadInfoOne",false);
        	component.set("v.spinnerLoadInfoTwo",false);
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
    
})