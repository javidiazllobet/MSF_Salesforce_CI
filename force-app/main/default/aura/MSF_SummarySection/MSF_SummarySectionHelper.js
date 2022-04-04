({
    getContact : function(component, idContact){
        var action = component.get("c.getContact");
        action.setParams({ idContact : idContact });
        
        action.setCallback(this, function(actionResult) {
            if (actionResult.getState() == "SUCCESS") {
                var stateReturnValue = actionResult.getReturnValue();
					if(stateReturnValue != null){ 
                        component.set("v.icons", true); 
                        component.set("v.contact", stateReturnValue.c);
                        component.set("v.account", stateReturnValue.acc);
                        if(stateReturnValue.c.msf_Seniority__c == null){
                            component.set("v.ant", "0");
                        }else{
                            component.set("v.ant", stateReturnValue.c.msf_Seniority__c.toString());
                        }
                        if(stateReturnValue.lvl != null){
                            component.set("v.lvl",stateReturnValue.lvl);
                        }
                        if(stateReturnValue.program != null){
                            component.set("v.program",stateReturnValue.program);
                        }
                    }
            }
        });
        
        $A.enqueueAction(action);
        
    },

    getProm : function(component, idContact){
        var action = component.get("c.getProm");
        action.setParams({ idContact : idContact,
                           rtDevName : component.get('v.contact.RecordType.DeveloperName')
                         });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.icons", true);
                component.set("v.iconProm", response.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
    },
    
    getCaso : function(component, idContact){
        var action = component.get("c.getCaso");
        action.setParams({ idContact : idContact });
        
        action.setCallback(this, function(actionResult) {
 			if (actionResult.getState() == "SUCCESS") {
                var stateReturnValue = actionResult.getReturnValue();
					if(stateReturnValue != null){ 
                        component.set("v.icons", true); 
                        component.set("v.case", stateReturnValue.case);
                        component.set("v.iconCasoName",$A.get("$Label.c.MSF_SUM_SECTION_CASE")+" ("+stateReturnValue.case+")");
               		  }            
         	}
        });
        $A.enqueueAction(action);
    },  
    
    getVD : function(component, idContact){
        var action = component.get("c.getVD");
        action.setParams({ idContact : idContact });
        
        action.setCallback(this, function(actionResult) {
            if (actionResult.getState() == "SUCCESS") {
                var stateReturnValue = actionResult.getReturnValue();
                if(stateReturnValue != null){ 
                    component.set("v.icons", true);
                    component.set("v.iconVD", stateReturnValue);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getOpor : function(component, idContact) {
        var action = component.get("c.getOpor");
        action.setParams({ idContact : idContact });
        
        action.setCallback(this, function(actionResult) {
            if (actionResult.getState() == "SUCCESS") {
                var stateReturnValue = actionResult.getReturnValue();
                if(stateReturnValue != null){ 
                    component.set("v.icons", true); 
                    component.set("v.iconApor", stateReturnValue.apor);
                    component.set("v.iconTest", stateReturnValue.her);
                    component.set("v.legacyStage", stateReturnValue.herStage);
                    component.set("v.iconBoda", stateReturnValue.boda);
                }            
            }
        });
        $A.enqueueAction(action);
    },
    
    getDuplicate : function(component, idContact){
        var action = component.get("c.getDuplicate");
        action.setParams({ idContact : idContact });
        
        action.setCallback(this, function(actionResult) {
            if (actionResult.getState() == "SUCCESS") {
                var stateReturnValue = actionResult.getReturnValue();
                if(stateReturnValue != null){ 
                    component.set("v.icons", true); 
                    component.set("v.iconDuplicate", stateReturnValue);
                }            
            }
        });
        $A.enqueueAction(action);
    },
    
    limpiarGet : function(component){
    	component.set("v.icons", false); 
    	component.set("v.iconLvl", false); 
        component.set("v.iconLPur", false); 
        component.set("v.iconEst" , false); 
        component.set("v.iconProg", false);
        component.set("v.iconTipo", false); 
        component.set("v.iconAnt" , false);  
        component.set("v.iconProm" , false); 
        component.set("v.iconCaso" , false); 
        component.set("v.iconApor" , false); 
        component.set("v.iconEmail" , false); 
        component.set("v.iconCif" , false); 
        component.set("v.iconCont", false); 
        component.set("v.iconData" , false); 
        component.set("v.iconPerc", false); 
	}
})