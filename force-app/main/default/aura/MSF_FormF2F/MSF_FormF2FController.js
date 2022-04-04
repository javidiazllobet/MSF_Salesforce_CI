({
    inicializacion : function(component, event, helper) {
        helper.getNumConvertation(component, event, helper, false);
        helper.getLanguage(component,event, helper);
        helper.getGender(component,event, helper);
        helper.getPeriod(component,event, helper,true,false);
        
        var incomplete = JSON.parse(JSON.stringify(component.get("v.pageReference.type")));
        if( incomplete == "standard__component"){
            var myPageRef = component.get("v.pageReference");
            component.set("v.incomplete", JSON.parse(JSON.stringify(myPageRef.attributes.incomplete)));
            helper.incompleteLeadInit(component,event, helper);
        }else{
            helper.getDate(component,event, helper);
            helper.tipoRegistro(component,event, helper);
            helper.getCanvasser(component, event, helper);
        } 
    },
     
    addConversation : function(component, event, helper){
        helper.getNumConvertation(component, event, helper, true);
    },
    
    refresh : function(component, event, helper){
       $A.get('e.force:refreshView').fire();  
    },
    
    amountChanged : function(component, event, helper) {
        helper.amountChanged(component, event);
    },
    
    tipoRegistro : function(component, event, helper) {
        helper.tipoRegistro(component, event, helper);
    },
    
    holderChange : function(component, event, helper) {
        helper.holderChange(component, event);
    },
    
    birthdateChange: function(component, event, helper) {
        helper.birthdateChange(component, event, helper);
    },
    
    search : function(component, event, helper){
        if(component.get("v.type") == 'P'){
            if(component.find("nifS").get("v.value")!=null){
                component.set("v.nif",component.get("v.nif").toUpperCase());
                if(helper.comprobarNIF(component.find("nifS").get("v.value"))){
                    helper.getSocio(component, event, helper, false);
                }else{
                    helper.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_NIE_INCORRECT"));
                }
            }else{
                helper.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_NIE_INCORRECT"));
            }
        }else{
            if(component.find("cifS").get('v.validity').valid){
                component.set("v.cif",component.get("v.cif").toUpperCase());
                if(helper.isCifValid(component.find("cifS").get('v.value'))){
                    helper.getSocio(component, event, helper, true);
                }
                else{
                    helper.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_CIF_INCORRECT"));
                }
            }else{
                helper.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_CIF_INCORRECT"));
            }
        }
    },
    
    save : function(component, event, helper){
        helper.typeCase(component, event, helper);
    },
    
    //---- increase methods-----
    frequencyChanged : function(component, event, helper) {
        component.set("v.frequencyChanged",true);        
        var selected = component.find("periodSocio").get("v.value");
        var actualFrequency = component.get("v.recurringDonation").npe03__Installment_Period__c;
        var defaultDate;
        if(selected == actualFrequency){
            defaultDate = component.get("v.recurringDonation").npe03__Next_Payment_Date__c;
        }else{
            defaultDate = component.get("v.opDate")[0];
        }
        component.set("v.newNextQuotaDate", defaultDate);
        component.set("v.newFrequency",selected);
        
    },
    
    saveNewQuota: function(component, event, helper) {
        helper.saveNewQuota(component, event);
    },    
    
    increaseQuota : function(component, event, helper) {
        helper.increaseQuota(component, event, helper);
    },
    
    loadForm : function(component, event, helper) {
        helper.loadForm(component, event, helper);
    },
    
    toBack : function(component, event, helper) {
        helper.toBack(component, event);
    }, 
    
    notInformedAmount : function(component, event, helper){
        helper.notInformedAmount(component, event);
    },
    
    contactDateChange : function(component, event, helper){
        helper.contactDateChange(component);
    },
    
})