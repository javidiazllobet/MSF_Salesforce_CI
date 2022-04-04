({
    getMemberInfo : function(cmp, event, helper){        
        if(cmp.isValid()){
            cmp.set("v.spinnerLoading",true);
            
            var action = cmp.get("c.getMemberInfo");
            action.setParams({ 
                recordId : cmp.get("v.recordId")
            });
            action.setCallback(this, function(actionResult) { 
                if(actionResult.getState() == "SUCCESS"){
                    var rv = actionResult.getReturnValue();

                    if(rv.existContact){                        
                        cmp.set("v.hasPrimaryContact", rv.hasPrimaryContact);
                        cmp.set("v.member", rv.contact);
                        cmp.set("v.lanSelected", rv.contact.msf_LanguagePreferer__c); 
                        if(rv.isOrg){
                        	cmp.set("v.type", "O");
                            cmp.set("v.cif", rv.contact.msf_NIF__c);      
                            cmp.set("v.orgTypeSelected", rv.contact.msf_OrganizationType__c);
                            cmp.set("v.funTypeSelected", rv.contact.msf_FundationType__c); 
                            cmp.set("v.primaryContact", rv.primaryContact);
                        }else{
                            cmp.set("v.type", "P");
                            cmp.set("v.nif", rv.contact.msf_NIF__c);
                        	cmp.set("v.genSelected", rv.contact.Gender__c);    
                        }
                   
                        this.setFieldsVisibility(cmp);
                    }
                }
                
                cmp.set("v.spinnerLoading",false); 
            });
            $A.enqueueAction(action);   
        }   
    },
    
    initializeSobjects : function(cmp){
    	 if(cmp.isValid()){
             cmp.set("v.spinnerLoading",true);
            
            var action = cmp.get("c.initializeSobjects");
            action.setCallback(this, function(actionResult) { 
                if(actionResult.getState() == "SUCCESS"){
                    var rv = actionResult.getReturnValue();
                    cmp.set("v.member", rv.newContact);
                    cmp.set("v.primaryContact", rv.newPrimaryContact);  
                    cmp.set("v.PPSelectedInfo", rv.newPayProf);
                }

                cmp.set("v.spinnerLoading",false); 
            });
            $A.enqueueAction(action);   
        }      
    },
        
    setFieldsVisibility : function(cmp,event){
        
        if(!this.isNotEmpty(cmp.get("v.recordId"))){ //clean objects when is new insert
            var value = event.getSource().get("v.name");
            if(value == 'membertype' ){
                cmp.set("v.nif","");
                cmp.set("v.cif","");
                this.initializeSobjects(cmp);
            }
            $A.util.addClass(cmp.find("modificationSection"),"slds-hide"); 
        }else{            
            $A.util.removeClass(cmp.find("modificationSection"),"slds-hide");
        }
        
        if(cmp.get("v.type") == "O"){          
            $A.util.removeClass(cmp.find("cifS"),"slds-hide");
            $A.util.removeClass(cmp.find("organizationContact"),"slds-hide");
            $A.util.removeClass(cmp.find("cifImput"),"slds-hide");
            $A.util.removeClass(cmp.find("orgTypeSelection"),"slds-hide");
            if(cmp.get("v.orgTypeSelected") == "Foundation"){
            	$A.util.removeClass(cmp.find("foundationTypeSelection"),"slds-hide");    
            }else{
                $A.util.addClass(cmp.find("foundationTypeSelection"),"slds-hide");
            }      
            $A.util.addClass(cmp.find("nifS"),"slds-hide"); 
            cmp.find("lastName").set("v.label",$A.get("$Label.c.MSF_FORM_F2F_ORGANIZATION_NAME"));
            for(var i=0;i<=cmp.find("contactInputs").length;i++){ 
                $A.util.addClass(cmp.find("contactInputs")[i],"slds-hide");
            }
        }
        if(cmp.get("v.type") == "P"){
            $A.util.addClass(cmp.find("cifS"),"slds-hide");
            $A.util.addClass(cmp.find("cifImput"),"slds-hide");
            $A.util.addClass(cmp.find("organizationContact"),"slds-hide");
            $A.util.addClass(cmp.find("orgTypeSelection"),"slds-hide");
            $A.util.addClass(cmp.find("foundationTypeSelection"),"slds-hide");
            $A.util.removeClass(cmp.find("nifS"),"slds-hide");
            cmp.find("lastName").set("v.label",$A.get("$Label.c.MSF_FORM_F2F_SURNAME"));
            for(var i=0;i<=cmp.find("contactInputs").length;i++){
                $A.util.removeClass(cmp.find("contactInputs")[i],"slds-hide");
            }
        }
    },
    
    getPPInfo : function (cmp, event, helper){
        if(cmp.isValid()){
            cmp.set("v.holderValue","member");
            
            if(this.isNotEmpty(cmp.get("v.PPSelected")) && cmp.get("v.PPSelected") != "disabled" && cmp.get("v.PPSelected") != "noCC"){
                
                var action = cmp.get("c.getPaymentProfileInfo");
                action.setParams({ 
                    ppId : cmp.get("v.PPSelected")
                }); 
                
                action.setCallback(this, function(actionResult) {
                    this.manageIBAN(cmp, false);
                    
                    if(actionResult.getState() == "SUCCESS"){
                        var stateReturnValue = actionResult.getReturnValue();
                        cmp.set("v.PPSelectedInfo", stateReturnValue);
                        
                        if(cmp.get("v.PPSelected") != "new"){
                            if(stateReturnValue != null){
                                if(stateReturnValue.msf_NIF__c != cmp.get("v.cif") && stateReturnValue.msf_NIF__c != cmp.get("v.nif") && stateReturnValue.msf_NIF__c != cmp.get("v.primaryContact.msf_fiscalNif__c")){
                                    cmp.set("v.holderValue","other");
                                }
                                if (stateReturnValue.cpm__IBAN__c != null) { 
                                    this.manageIBAN(cmp, true);
                                }
                            }
                        }else{
                            this.manageIBAN(cmp, false);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                this.manageIBAN(cmp, false);
            } 
        }
    },
    
    manageIBAN : function(cmp, split) {
        if(split){            
            var iban = cmp.get("v.PPSelectedInfo").cpm__IBAN__c;
            
            cmp.set("v.iban", iban.substring(0,24));
            //cmp.set("v.iban1", iban.substring(0,4));
            //cmp.set("v.iban2", iban.substring(4,8));
            //cmp.set("v.iban3", iban.substring(8,12));
            //cmp.set("v.iban4", iban.substring(12,14));
            //cmp.set("v.iban5", iban.substring(14,iban.length));
        }else{
            cmp.set("v.iban", null);
            //cmp.set("v.iban1", null);
            //cmp.set("v.iban2", null);
            //cmp.set("v.iban3", null);
            //cmp.set("v.iban4", null);
            //cmp.set("v.iban5", null);    
        }
    },
    
    setDefaultOppDate : function(cmp, event, helper){
        if(cmp.get("v.donationTypeSelected") == 'Membership' || cmp.get("v.donationTypeSelected") == 'Recurrent Donation Membership'){
            cmp.set("v.amount","10");
        }
        if(cmp.get("v.donationTypeSelected") == "Recurrent Donation"){
        	this.getRecurringDate(cmp, event, helper);    
        }else{
            this.getToday(cmp, event, helper);
        }
    },
    
    getToday : function(cmp, event, helper){
    	var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	cmp.set('v.dateSelected', today);    
    },
    
    getRecurringDate : function(cmp, event, helper){
        if(cmp.isValid()){
            
            var action = cmp.get("c.nextRecurringDate");
            action.setCallback(this, function(actionResult) { 
                if(actionResult.getState() == "SUCCESS"){
                    var rv = actionResult.getReturnValue();
                    cmp.set('v.dateSelected', rv);    
                }
            });
            $A.enqueueAction(action);   
        } 	    
    },
    
    setDenyFieldEditing : function (cmp){
    	cmp.find("membertype").set("v.disabled",true);
        cmp.find("orgType").set("v.disabled",true);
        cmp.find("funType").set("v.disabled",true);
    },
    
    showToast : function(title,msg,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type,
            "mode" : "dismissible"
        });
        toastEvent.fire();
    },
    ///////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////// ---SET PICKLIST VALUES--- ///////////////////////////////////////////////////////       
    getLanguage : function(cmp, event, helper) {
		var action = cmp.get("c.getLanguage");
        this.getPickListValues(cmp, action, "v.language", "v.lanSelected", false, 0); //#25849 - OMEGA - Estaba, no sabemos la razón, indicado el 1 en lugar de 0, de todas formas como en la linea de debajo se indica el valor por defecto como none tiene poca importancia
        cmp.set("v.lanSelected", 'none'); //#25849 - OMEGA - Se indica none como valor por defecto
    },
    
    getGender : function(cmp, event, helper) {
        var action = cmp.get("c.getGender");
        this.getPickListValues(cmp, action, "v.gender", "v.genSelected", false, 0);
    },
    
    getOrgType : function(cmp, event, helper) {
        var action = cmp.get("c.getOrganizationType");
        this.getPickListValues(cmp, action, "v.orgType", "v.orgTypeSelected", false, 0);
    },
    
    getFunType : function(cmp, event, helper) {
        var action = cmp.get("c.getFundationType");
        this.getPickListValues(cmp, action, "v.funType", "v.funTypeSelected", false, 0);
    },
    
    getPayMethod : function(cmp, event, helper) {
        var action = cmp.get("c.getPayMethod");
        this.getPickListValues(cmp, action, "v.opPaymentMethods", "v.payMethodSelected", false, 0);
    },
    
    getLeadSource : function(cmp, event, helper) {
        var action = cmp.get("c.getLeadSource");
        this.getPickListValues(cmp, action, "v.opLeadSources", "v.leadSourceSelected", false, 0);
    },
    
    getFrequencies : function(cmp, event, helper) {
        var action = cmp.get("c.getFrequencies");
        this.getPickListValues(cmp, action, "v.rdFrequencies", "v.frequencySelected", false, 0);
    },
    
    getModificationChannels : function(cmp, event, helper) {
        var action = cmp.get("c.getModificationChannels");
        this.getPickListValues(cmp, action, "v.modChannels", "v.modChannelSelected", false, 0);
    },
    
    getPaymentProfiles : function(cmp, event, helper){
    	if(this.isNotEmpty(cmp.get("v.payMethodSelected"))){
            var action = cmp.get("c.getPayProf");
            action.setParams({ 
                payMethodSelected : cmp.get("v.payMethodSelected"),
                recordId : cmp.get("v.recordId")
            }); 
            this.getPickListValues(cmp, action, "v.opPP", "v.PPSelected", true, 0);
        }	    
    },
    
    getOppType : function(cmp, event, helper) {        
        if(this.isNotEmpty(cmp.get("v.payMethodSelected"))){
            var action = cmp.get("c.getOppType");
            action.setParams({ 
                payMethodSelected : cmp.get("v.payMethodSelected")
            }); 
            this.getPickListValues(cmp, action, "v.opDonationTypes", "v.donationTypeSelected", true, 0);
            
            cmp.set("v.holderValue","member");
        }
    },
    
    getInKindTypes : function(cmp, event, helper){     
        if(cmp.get("v.payMethodSelected") == "EN ESPECIE-SERVICIOS" || cmp.get("v.payMethodSelected") == "EN ESPECIE-INMOVILIZADO"){    
            var action = cmp.get("c.getInKindTypes");            
            if(cmp.get("v.payMethodSelected") == "EN ESPECIE-INMOVILIZADO"){
                action.setParams({ 
                    isImmobilized : "true"
                });     
            }
            if(cmp.get("v.payMethodSelected") == "EN ESPECIE-SERVICIOS"){
                action.setParams({ 
                    isImmobilized : "false"
                });     
            }             
            this.getPickListValues(cmp, action, "v.inKindTypes", "v.inKindSelected", true, 0);
        }else{
        	cmp.set("v.inKindTypes", null);
            cmp.set("v.inKindSelected", null);
        }   
    },

    getTarget : function(cmp, event, helper){        
        var action = cmp.get("c.getTarget");            
        if(cmp.get("v.payMethodSelected") == "TRANSFERENCIA BANCARIA"){
            action.setParams({ 
                isTransfer : "true"
            });     
        }else{
            action.setParams({ 
                isTransfer : "false"
            });     
        }             
        this.getPickListValues(cmp, action, "v.opTargets", "v.targetSelected", true, 0);        
    },
    
    getPickListValues : function(cmp, action, list, selected, setdefault, posDefault){
        if(cmp.isValid()){
            action.setCallback(this, function(actionResult) {
                if(actionResult.getState() == "SUCCESS"){
                    var stateReturnValue = actionResult.getReturnValue();
                    if(stateReturnValue != null){
                        let values = JSON.parse(stateReturnValue);
                        cmp.set(list, values);       
                        if(values.length > 0) {
                            if (!this.isNotEmpty(cmp.get(selected)) || setdefault){
                            	cmp.set(selected, values[posDefault].value);
                            }
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }    
    },
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////// ---VALIDATIONS FUNCTIONS--- ////////////////////////////////////////////////////////
    birthdateChange: function(cmp, event, helper) {
        var dateA = new Date();
        var dateB = new Date(cmp.find("birthdate").get("v.value"));

        if(this.isNotEmpty(cmp.find("birthdate").get("v.value"))){ 
            if(dateB<dateA){
                this.showToast($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_GREATER_THAN_TODAY"), 'ERROR'); 
                cmp.find("birthdate").set("v.value","");
            } 
        }
    },
 
    convDateString: function(value){
        value=value.split("/");
        var value2 = value[2]+"-"+value[1]+"-"+value[0];
        return value2;
    },
    
    checkNif : function(value) {
        var validChars = "TRWAGMYFPDXBNJZSQVHLCKET";
        var nifRexp = /^[0-9]{8}[TRWAGMYFPDXBNJZSQVHLCKET]$/i;
        var nieRexp = /^[XYZ][0-9]{7}[TRWAGMYFPDXBNJZSQVHLCKET]$/i;
        var str = value.toString().toUpperCase();
        
        if (!nifRexp.test(str) && !nieRexp.test(str)) return false;
        
        var nie = str
        .replace(/^[X]/, "0")
        .replace(/^[Y]/, "1")
        .replace(/^[Z]/, "2");
        
        var letter = str.substr(-1);
        var charIndex = parseInt(nie.substr(0, 8)) % 23;
        
        if (validChars.charAt(charIndex) === letter) return true;
        
        return false;
    },
    
    checkCif : function (cif) {
        var aux = cif.substring(0, 8);
        aux = this.calculaCif(aux);
        return cif == aux;
    },
    
    calculaCif : function(cif) 
    {
        return cif + this.calculaDigitoControl(cif);
    },
    
    posicionImpar : function (str) 
    {
        var value;
        var value2;
        var aux = parseInt(str);
        aux = aux * 2;
        if(aux.toString().length>1){
            value = aux.toString().substring(0,1);
            value2 = aux.toString().substring(1);
            aux = parseInt(value) + aux;
        }
        return parseInt(aux);
    },
    
    calculaDigitoControl : function (cif) 
    {
        var DIGITO_CONTORL_CIF = "JABCDEFGHI";
        var CIF_CON_LETRA_FINAL = "KNPQRSW";
        var str = cif.substring(1, 8);
        var cabecera = cif.substring(0, 1);
        var sumaPar = 0;
        var sumaImpar = 0;
        var sumaTotal;
        //Calcular A
        for (var i = 1; i < str.length; i += 2) 
        {
            var aux = parseInt("" + str.charAt(i));
            sumaPar += aux;
        }
        //Calcular B
        for (var i = 0; i < str.length; i += 2) 
        {
            sumaImpar += this.posicionImpar("" + str.charAt(i));
        }
        // A + B = C
        sumaTotal = sumaPar + sumaImpar;
        
        var resto = sumaTotal % 10;
        if(resto == 0){
            sumaTotal = 0; 
        } 
        else {
            sumaTotal = 10 - resto;
        }
        if (CIF_CON_LETRA_FINAL.includes(cabecera)) 
        {
            str = "" + DIGITO_CONTORL_CIF.charAt(sumaTotal);
        } 
        else 
        {
            str = "" + sumaTotal;
        }
        
        return str;
    },
    
    checkIban : function(cmp) {
        var iban;
        if(!this.isNotEmpty(cmp.get("v.PPSelectedInfo.cpm__IBAN__c"))){
            if(cmp.get("v.PPSelected") == 'new'){
                if(this.isNotEmpty(cmp.get("v.iban")))   
                { 	
                    iban = cmp.get("v.iban");
                    if(this.ValidateIban(iban)){
                        cmp.set("v.PPSelectedInfo.cpm__IBAN__c",iban.toUpperCase());
                        return true;
                    }
                }
                return false;
            }
        }
        return true;
    },
    
    ValidateIban : function(IBAN) {
        if(this.isNotEmpty(IBAN)){
            IBAN = IBAN.toUpperCase();
            IBAN = IBAN.trim();
            IBAN = IBAN.replace(/\s/g, "");
            
            var letra1,letra2,num1,num2;
            var isbanaux;
            var numeroSustitucion;
            if (IBAN.length != 24) {
                return false;
            }
            letra1 = IBAN.substring(0, 1);
            letra2 = IBAN.substring(1, 2);
            num1 = this.getnumIBAN(letra1);
            num2 = this.getnumIBAN(letra2);
            isbanaux = String(num1) + String(num2) + IBAN.substring(2);
            isbanaux = isbanaux.substring(6) + isbanaux.substring(0,6);
            var resto = this.modulo97(isbanaux);
            if (resto == 1){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    },
    
    modulo97 : function(iban) {
        var parts = Math.ceil(iban.length/7);
        var remainer = "";        
        for (var i = 1; i <= parts; i++) {
            remainer = String(parseFloat(remainer+iban.substr((i-1)*7, 7))%97);
        }
        return remainer;
    },
    
    getnumIBAN : function (letra) {
        var ls_letras = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        return ls_letras.search(letra) + 10;
    },
    
    isNotEmpty : function (value){
        if(value != null && value != undefined && value != "" ){
            return true;
        }else{
            return false;
        }
    },
    
    /*checkAddres : function(cmp,id){
        if((this.isNotEmpty(cmp.find("street"+id).get("v.value")) || this.isNotEmpty(cmp.find("city"+id).get("v.value")) || this.isNotEmpty(cmp.find("zipCode"+id).get("v.value")) || 
           this.isNotEmpty(cmp.find("province"+id).get("v.value")) || this.isNotEmpty(cmp.find("country"+id).get("v.value")) || cmp.find("zipCode"+id).get('v.validity').valid ) )
        {
            return true;
        }
        else{
            return false;
        }
    },*/
    
    validFields : function(value, cmp){
        if(value == 'basicFields'){
            var id = cmp.get("v.hasPrimaryContact") ? 'PC' : '';

            cmp.find("lastName").showHelpMessageIfInvalid();
            cmp.find("amount").showHelpMessageIfInvalid();
            cmp.find("phone"+id).showHelpMessageIfInvalid();
            cmp.find("email"+id).showHelpMessageIfInvalid();
            cmp.find("zipCode"+id).showHelpMessageIfInvalid();
            cmp.find("modificationChannel").showHelpMessageIfInvalid();
            cmp.find("leadSource").showHelpMessageIfInvalid();
            
            if(cmp.get("v.type") =='P'){
                cmp.find("firstName").showHelpMessageIfInvalid();
                cmp.find("nif").showHelpMessageIfInvalid();
                cmp.find("mobile"+id).showHelpMessageIfInvalid();
                var nif = false;
                
                if(this.isNotEmpty(cmp.get("v.nif"))){
                    if(this.checkNif(cmp.get("v.nif"))){
                        nif = true;
                    }else{
                        cmp.find("nif").setCustomValidity($A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_NIE_INCORRECT"));
                        cmp.find("nif").reportValidity();
                    }
                }else{
                	nif = true;
                }
                
                /*if(cmp.find("lastName").get('v.validity').valid && cmp.find("amount").get('v.validity').valid &&
                   cmp.find("firstName").get('v.validity').valid && cmp.find("mobile"+id).get('v.validity').valid && 
                   cmp.find("phone"+id).get('v.validity').valid && cmp.find("email"+id).get('v.validity').valid && cmp.find("zipCode"+id).get('v.validity').valid && nif ){*/
                
                if(cmp.find("lastName").get('v.validity').valid && cmp.find("amount").get('v.validity').valid &&
                   cmp.find("firstName").get('v.validity').valid && cmp.find("mobile"+id).get('v.validity').valid && 
                   cmp.find("phone"+id).get('v.validity').valid && cmp.find("email"+id).get('v.validity').valid && 
                   nif && cmp.find("leadSource").get('v.validity').valid)
                {    
                    return true;
                }
            }else{
                cmp.find("cif").showHelpMessageIfInvalid();
                cmp.find("firstNameAux").showHelpMessageIfInvalid();
                cmp.find("lastNameAux").showHelpMessageIfInvalid();
                cmp.find("nifAux").showHelpMessageIfInvalid();
                var cif = false;
                var nifAux = false;
                
                if(this.isNotEmpty(cmp.get("v.cif"))){
                    if(this.checkCif(cmp.get("v.cif"))){
                        cif = true;                        
                    }else{
                        cmp.find("cif").setCustomValidity($A.get("$Label.c.MSF_FORM_F2F_ERROR_CIF_INCORRECT"));
                        cmp.find("cif").reportValidity();
                    }
                }else{
                    cif = !this.isNotEmpty(cmp.get("v.cif"));
                    
                }
                
                if(this.isNotEmpty(cmp.get("v.primaryContact.msf_fiscalNif__c"))){
                    if(this.checkNif(cmp.get("v.primaryContact.msf_fiscalNif__c"))){
                        nifAux = true;
                    }else{
                        cmp.find("nifAux").setCustomValidity($A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_NIE_INCORRECT"));
                        cmp.find("nifAux").reportValidity();
                    }                    
                }else{
                    nifAux = !this.isNotEmpty(cmp.get("v.primaryContact.msf_fiscalNif__c")); 
                }
                
                if(cmp.find("lastName").get('v.validity').valid && cmp.find("amount").get('v.validity').valid &&
                   cmp.find("phone"+id).get('v.validity').valid && cmp.find("firstNameAux").get('v.validity').valid && 
                   cmp.find("lastNameAux").get('v.validity').valid && cmp.find("email"+id).get('v.validity').valid &&
                   cif && nifAux)
                {
                    return true;
                }
            }
            
            return false;
        }
        
        if(value == 'economicFields'){
            
            if(cmp.get("v.donationTypeSelected") == 'Membership' || cmp.get("v.donationTypeSelected") == 'Recurrent Donation Membership'){
                if(!this.isNotEmpty(cmp.get("v.recordId")) || !cmp.get("v.member.msf_IsAssosiative__c")){
                    this.showToast($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_DE_ERROR_IS_NOT_ASSOCIATIVE"),"ERROR");
                    return false;
                }
            }
            
            if(this.isNotEmpty(cmp.get("v.dateSelected"))){
                if(cmp.get("v.payMethodSelected") == 'Direct Debit' || cmp.get("v.payMethodSelected") == 'PAGARÉS' || cmp.get("v.payMethodSelected") == 'TALÓN BANCARIO ESTÁNDAR'){
                    if(this.checkIban(cmp)){
                        if(cmp.get("v.holderValue") == 'other'){
                            cmp.find("firstNameHolder").showHelpMessageIfInvalid();
                            cmp.find("lastNameHolder").showHelpMessageIfInvalid();
                            cmp.find("suffixHolder").showHelpMessageIfInvalid();
                            cmp.find("nifHolder").showHelpMessageIfInvalid(); 
                            var nif = false;
                            
                            if(this.isNotEmpty(cmp.get("v.PPSelectedInfo.msf_NIF__c"))){
                                if(this.checkNif(cmp.get("v.PPSelectedInfo.msf_NIF__c"))){
                                    nif = true;
                                    cmp.find("nifHolder").setCustomValidity('');
                                    cmp.find("nifHolder").reportValidity();
                                }else{
                                    cmp.find("nifHolder").setCustomValidity($A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_NIE_INCORRECT"));
                                    cmp.find("nifHolder").reportValidity();
                                }
                            }
                            
                            if(cmp.find("firstNameHolder").get('v.validity').valid && cmp.find("lastNameHolder").get('v.validity').valid &&
                               cmp.find("suffixHolder").get('v.validity').valid && nif){
                                return true;
                            }
                            return false;
                        }
                        
                        if(cmp.get("v.payMethodSelected") == 'TALÓN BANCARIO ESTÁNDAR' || cmp.get("v.payMethodSelected") == 'PAGARÉS'){
                            
                            cmp.find("numTalon1").showHelpMessageIfInvalid();
                            cmp.find("numTalon2").showHelpMessageIfInvalid();
                            
                            if(!cmp.find("numTalon1").get('v.validity').valid || !cmp.find("numTalon2").get('v.validity').valid)
                            {
                                return false;
                            }  
                        }
                        
                        return true;                        
                    }else{
                        this.showToast($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_INCORRECT_IBAN"),"ERROR");
                        return false;
                    }
                }else if(cmp.get("v.payMethodSelected") == 'CreditCard'){
                    if(cmp.get("v.PPSelected") == "noCC"){
                        this.showToast($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_DE_HAS_NOT_CREDIT_CARD"),"ERROR");
                        return false;
                    } 
                    return true;
                }else if(cmp.get("v.payMethodSelected") == 'TC ONLINE' || cmp.get("v.payMethodSelected") == 'TRUSTLY - TR ONLINE' || cmp.get("v.payMethodSelected") == 'PAYPAL' 
                          || cmp.get("v.payMethodSelected") == 'INICIATIVA SOLIDARIA ONLINE'){
                    
                    cmp.find("orderId").showHelpMessageIfInvalid();
                    cmp.find("autCode").showHelpMessageIfInvalid();
                    
                    if(cmp.find("orderId").get('v.validity').valid && cmp.find("autCode").get('v.validity').valid){
                        return true;
                    }  
                }else{
                    return true; //the rest
                }                
            }else{
                cmp.find("firstDonation").setCustomValidity($A.get("$Label.c.MSF_FORM_DE_ERROR_INVALID_DATE"));
                cmp.find("firstDonation").reportValidity();
                return false;
            }
        }   
    },
    ////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    
    generalValidationFields : function(cmp, event, helper){        
        if(this.validFields('basicFields',cmp)){ //minimun fields
            if(this.isNotEmpty(cmp.get("v.campaignSelected"))){
                if(this.validFields('economicFields',cmp)){
                    this.save(cmp, event);
                }
            }else{
                this.showToast($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_DE_ERROR_INVALID_CAMPAIGN"),"ERROR");
                cmp.set("v.error", true); //show campaign field red
            }            
        }else{
            this.showToast($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_BASIC_INFO_INCOMPLETE"),"ERROR"); //informacion basica incompleta o erronea
        }
    },
        
    save : function(cmp, event, helper){    	
        if(cmp.isValid()){
            cmp.set("v.spinnerLoading",true);
            
            var isInd = cmp.get("v.type") == "P";
            var isNew = !this.isNotEmpty(cmp.get("v.recordId"));
            
            cmp.set("v.member.msf_LanguagePreferer__c", cmp.get("v.lanSelected"));    
            
            if(isInd){
            	cmp.set("v.member.msf_NIF__c", cmp.get("v.nif"));
                cmp.set("v.member.Gender__c", cmp.get("v.genSelected"));
            }else{
            	cmp.set("v.member.msf_NIF__c", cmp.get("v.cif")); 
                cmp.set("v.member.msf_OrganizationType__c", cmp.get("v.orgTypeSelected")); 
                cmp.set("v.member.msf_FundationType__c", cmp.get("v.orgTypeSelected") == 'Foundation' ? cmp.get("v.funTypeSelected") : null);
            }
            
            var action = cmp.get("c.saveProcess");
            action.setParams({               
                isNewContact : isNew,
                isIndividual : isInd,
                hasPriCont : cmp.get("v.hasPrimaryContact"),
                checkPriCont : cmp.get("v.checkPrimaryContact"),
                contactInfo	: cmp.get("v.member"),
                priCont : cmp.get("v.primaryContact"),
                payProf : cmp.get("v.PPSelectedInfo"),        
                payProfHolder : cmp.get("v.holderValue"),                
                amount : cmp.get("v.amount"),
                payReference : cmp.get("v.paymentReference"),
                trancode : cmp.get("v.trancode"),
                orderId : cmp.get("v.orderId"),
                autCode : cmp.get("v.autCode"),
                oppType : cmp.get("v.donationTypeSelected"),
                inkindType : cmp.get("v.inKindSelected"),
                donationDate : cmp.get("v.dateSelected"),
                rdFrequency : cmp.get("v.frequencySelected"),
                gau : cmp.get("v.GAUSelected"),                
                payMethod : cmp.get("v.payMethodSelected"),
                target : cmp.get("v.targetSelected"),                
                entryLeadSource : cmp.get("v.leadSourceSelected"),
                entryCampaign : cmp.get("v.campaignSelected"),
                modChannel : cmp.get("v.modChannelSelected"),
                oppDescription : cmp.get("v.opDescription")
            });            
            
            action.setCallback(this, function(actionResult) { 
            	var stateReturnValue = actionResult.getReturnValue();
                cmp.set("v.spinnerLoading",false);
                if(actionResult.getState() == "SUCCESS"){
                    if(stateReturnValue.type != 'ERROR'){
                       this.refresh(cmp, event, stateReturnValue.contactId);
                    }
                }
                this.showToast(stateReturnValue.title,stateReturnValue.msg,stateReturnValue.type);                 
            });
            $A.enqueueAction(action);   
        }         
	},
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////// ---NAVIGATE FUNCTIONS--- ///////////////////////////////////////////////////////////
    
    refreshPage: function(cmp, event, idObj){
        $A.get('e.force:refreshView').fire(); 
    },
    
    refresh : function(cmp, event, idObj){
        
        if(cmp.get("v.setIsConsoleNavigation")){
            if(this.isNotEmpty(cmp.get("v.recordId"))){
               this.closeFocusedTab(cmp, event);
            }else{
                this.refreshNavigationItem(cmp, event);
                this.navigateToObject(idObj);
            }
        }
        else{
            var id = this.isNotEmpty(cmp.get("v.recordId")) ? cmp.get("v.recordId") : idObj;
            this.navigateToObject(id);
            $A.get('e.force:refreshView').fire();  
        }  
    },
    
    navigateToObject : function(idObj){
        var navContact = $A.get("e.force:navigateToSObject");
        navContact.setParams({
            "recordId": idObj
        });
        navContact.fire();
    },
    
    setIsConsoleNavigation : function(cmp){
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            cmp.set("v.setIsConsoleNavigation",response);
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    refreshNavigationItem : function(cmp, event, helper) {
        var navigationItemAPI = cmp.find("navigationItemAPI");
        navigationItemAPI.refreshNavigationItem().then(function(response) {
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
})