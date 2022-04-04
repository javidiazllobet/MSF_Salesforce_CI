({
    doInit : function(component, event, helper) {
        var objectId = component.get("v.recordId");
        helper.getAssociativeInfo(component, objectId);
    },    
    
    expandSection : function(component){
        var section = component.find('seccionAsociativo').getElement();
        
        if(component.get('v.expand')){
            component.set('v.expand',false);
            $A.util.addClass(section,"slds-is-open");
        }else{
            component.set('v.expand',true);            
            $A.util.removeClass(section,"slds-is-open");
        }        
    },
    
})