({
    incompleteLeadInit : function(component, event, helper) { 
        
        var sourceLead = component.get("v.incomplete");
        if(sourceLead.msf_esOrganizacion__c){
            component.set("v.type","O");
        }else{
            component.set("v.type","P");
        }
        this.setSectionsVisibility(component, false);
        this.setLeadFields(component, sourceLead);
    },
  
    setLeadFields : function(component, lead){
        // Canvasser information
        var canvasser = {
            Id : lead.OwnerId,
            Name : lead.msf_Canvasser__c,
            msf_Place__c : lead.msf_PlaceCanvasser__c,
            msf_City__c : lead.msf_CityCanvasser__c,
            msf_Campaign__c : lead.msf_CanvasserCampaign__c
        }
        component.set("v.canvasser", canvasser);
        
        if(lead.msf_esOrganizacion__c){
            // Specific organization information
            this.setCmpAttributes(component,'name',lead.Company);
            this.setCmpAttributes(component,'cif',lead.msf_NIF__c);
        }else{
            // Specific individual information
            if(component.get("v.type") == 'O'){
                this.setCmpAttributes(component,'name',lead.LastName); 
            }else{
                this.setCmpAttributes(component,'name',lead.FirstName);
                this.setCmpAttributes(component,'firstSName',lead.LastName); 
                this.setCmpAttributes(component,'secondSName',lead.Suffix);
            }
            this.isNotEmpty(lead.msf_Birthdate__c) ? this.setCmpAttributes(component,'birthdate',lead.msf_Birthdate__c) : component.set("v.isLeadMinor",true);
            this.setCmpAttributes(component,'nif',lead.msf_NIF__c);
            this.setCmpAttributes(component,'genderCmp',lead.msf_Gender__c);
            this.setCmpAttributes(component,'mobile',lead.MobilePhone);
        }
        
        // General information shared (infividual/organization)
        this.setCmpAttributes(component,'obs',lead.Description);
        this.setCmpAttributes(component,'email',lead.Email);
        this.setCmpAttributes(component,'phone',lead.Phone);
        this.setCmpAttributes(component,'language',lead.msf_LanguagePreferer__c);
        this.setCmpAttributes(component,'country',lead.Country);
        this.setCmpAttributes(component,'province',lead.State);
        this.setCmpAttributes(component,'zipCode',lead.PostalCode);
        this.setCmpAttributes(component,'city',lead.City);
        this.setCmpAttributes(component,'street',lead.Street);
        this.setCmpAttributes(component,'num',lead.msf_StreetNumber__c);
        this.setCmpAttributes(component,'floor',lead.msf_Floor__c);
        this.setCmpAttributes(component,'door',lead.msf_DoorNumber__c);
        
        // Specific representative information
        this.setCmpAttributes(component,'nameAux',lead.msf_AuxFirstName__c);
        this.setCmpAttributes(component,'firstSNameAux',lead.msf_AuxLastName__c);
        this.setCmpAttributes(component,'secondSNameAux',lead.msf_AuxSuffix__c);
        this.setCmpAttributes(component,'nifAux',lead.msf_AuxNIF__c); 
        if(lead.msf_esOrganizacion__c){    
            this.setCmpAttributes(component,'mobileAux',lead.msf_AuxMobilePhone__c);
            this.setCmpAttributes(component,'rolAux',lead.msf_AuxRole__c);
        }
        
        // Payment profile information
        this.setCmpAttributes(component,'iban1',lead.msf_IBANCode__c);
        this.setCmpAttributes(component,'iban2',lead.msf_IBANEntity__c);
        this.setCmpAttributes(component,'iban3',lead.msf_IBANOffice__c);
        this.setCmpAttributes(component,'iban4',lead.msf_IBANDC__c);
        this.setCmpAttributes(component,'iban5',lead.msf_IBANAccountNumber__c);
        
        // Payment profile holder's information
        this.setCmpAttributes(component,'nameH',lead.msf_HolderFirstName__c);
        this.setCmpAttributes(component,'firstSNameH',lead.msf_HolderLastName__c);
        this.setCmpAttributes(component,'secondSNameH',lead.msf_HolderSuffixName__c);
        this.setCmpAttributes(component,'nifH',lead.msf_HolderNIF__c);
        this.setCmpAttributes(component,'holder',lead.msf_AccountHolderOption__c);
        //component.set("v.holderValue",lead.msf_AccountHolderOption__c);
        
        // Payment details 
        this.setCmpAttributes(component,'period',lead.msf_RecDon_npe03_Installment_Period__c);//revisar el tema con este campo
        this.setCmpAttributes(component,'firstDonation',this.convDateStringReverse(lead.msf_RecDona_npe03_Next_Payment_Date__c));
        component.set("v.opDate",this.convDateStringReverse(lead.msf_RecDona_npe03_Next_Payment_Date__c));
        // Contact date
        component.find("contactDate").set("v.value",lead.msf_ContactDate__c);
        
        // Checks
        component.set("v.checkPolitics",true);
        component.set("v.checkPayment",true);
        component.find("checkPolitics").set("v.checked",true);
        component.find("checkPolitics").set("v.disabled",true);
        component.find("checkPayment").set("v.checked",true);
        component.find("checkPayment").set("v.disabled",true);
        component.find("checkAmount").set("v.checked",lead.msf_NotInformedAmount__c);
        
        //Amount
        var amountLead = lead.msf_Opp_npe03_Amount__c;
        if(!lead.msf_NotInformedAmount__c){
            component.find("checkAmount").set("v.disabled",true);

            if(amountLead == "60" || amountLead == "25" || amountLead == "15"){
                this.setCmpAttributes(component,'Amount',amountLead.toString());
            }else{
                this.setCmpAttributes(component,'Amount',"0");
                this.setCmpAttributes(component,'otherApor',amountLead);
            }
        }else{
            
            component.find("period").set("v.disabled",false);
            component.find("firstDonation").set("v.disabled",false);
            this.getDate(component,event);
            this.notInformedAmount(component, event);
        }
        
        //Signatures
        component.set("v.signatureDonorOk",lead.msf_FirmaDonante__c);
        component.set("v.signatureTutorOk",lead.msf_FirmaRepresentante__c);
        component.set("v.signatureHolderOk",lead.msf_FirmaTitular__c);
        if(lead.msf_FirmaDonante__c){
            $A.util.addClass(component.find("sigDonor"),"slds-hide");
        }
        if(lead.msf_FirmaRepresentante__c){
            $A.util.addClass(component.find("sigRep"),"slds-hide");
        }
        if(lead.msf_FirmaTitular__c){
            $A.util.addClass(component.find("sigHolder"),"slds-hide");
        }
        
        //Basic functions
        this.holderChange(component, event);
        this.setFieldsVisibility(component, component.get("v.type"));//changed position because don't show auxsection when is minor
        if(component.get("v.type") == 'P'){
            this.birthdateChange(component, event);
        }
        this.amountChanged(component, event);
    },
    
    notInformedAmount : function(component, event){
        component.find("Amount").set("v.value","60");
        this.amountChanged(component, event);
        if(component.find("checkAmount").get("v.checked")){
            component.find("Amount").set("v.class","slds-hide");
            component.find("otherApor").set("v.class","slds-hide");
            component.find("period").set("v.class","slds-hide");
            component.find("firstDonation").set("v.class","slds-hide");
        }
        else{
            component.find("Amount").set("v.class","");
            component.find("period").set("v.class","");
            component.find("firstDonation").set("v.class","");
        }
    },
    
    setCmpAttributes : function(component,id,value){
        var encryptedFields = new Set([
            'secondSName', 'birthdate', 'nif', 'cif',
            'country', 'province', 'zipCode', 'city', 'street', 'num', 'floor', 'door',
            'nameAux', 'firstSNameAux', 'secondSNameAux', 'nifAux', 'mobileAux', 'rolAux',
            'iban1', 'iban2', 'iban3', 'iban4',
            'nameH', 'firstSNameH', 'secondSNameH', 'nifH'
        ]);
        
        if(value != null && value != undefined && value != ''){
            if(id != 'nif' && id != 'cif' && id != 'obs' ){
                component.find(id).set("v.disabled",true); 
            }	        
            component.find(id).set("v.value",value);
            
            if(encryptedFields.has(id)){
                component.find(id).set("v.type",'password');
            }
        }
    },
    
    amountChanged : function(component, event){
        var id;
        if(component.get("v.incomplete") == null){
            id = event.getSource().get("v.name") == 'AmountS' ? 'otherApor2' : "otherApor";
        }else{
            id='otherApor';
        }

        if(!component.find("checkAmount").get("v.checked")){
            var valor = component.get("v.ValorAportacionRad");
            if(valor == 15 || valor == 25 || valor == 60){
                component.find(id).set("v.class","slds-hide");
                component.find(id).set("v.value","");
                component.find(id).set("v.required",false);
            }else{
                component.find(id).set("v.class","");
                component.find(id).set("v.required",true);
            }
        }
    },
    
    holderChange : function(component, event){
        var holder = component.find("holder").get("v.value");
        
        if(holder == 'other'){
            for(var i=0;i<=component.find("otherHolder").length;i++){
                $A.util.removeClass(component.find("otherHolder")[i],"slds-hide");
            }
        }else{
            for(var i=0;i<=component.find("otherHolder").length;i++){
                $A.util.addClass(component.find("otherHolder")[i],"slds-hide");
            }
        }
    },
    
    birthdateChange: function(component, event, helper) {
        var dateA = new Date();
        var dateB = new Date(component.find("birthdate").get("v.value"));
        
        $A.util.addClass(component.find("auxSection"),"slds-hide");
        $A.util.removeClass(component.find("mobileAuxInput"),"slds-hide");
        $A.util.removeClass(component.find("rolAuxInput"),"slds-hide");
        component.set("v.isMinor",false);
        
        if(this.isNotEmpty(component.find("birthdate").get("v.value"))){ 
            if(dateB<dateA){        
                dateA.setFullYear(dateA.getFullYear()-18);
                
                if(dateB<=dateA){
                    component.set("v.isMinor",false);
                }else{
                    component.set("v.isMinor",true);
                    if(this.isNotEmpty(component.get("v.incomplete")) && component.get("v.isLeadMinor")){
                        this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_TUTOR_DO_NOT_SIGN"));
                        component.find("birthdate").set("v.value","");
                    }else{
                        $A.util.removeClass(component.find("auxSection"),"slds-hide");
                        $A.util.removeClass(component.find("firmaAux"),"slds-hide");
                        if(component.get("v.incomplete.msf_FirmaRepresentante__c")){
                            $A.util.addClass(component.find("sigRep"),"slds-hide");
                        }
                        $A.util.addClass(component.find("mobileAuxInput"),"slds-hide");
                        $A.util.addClass(component.find("rolAuxInput"),"slds-hide");
                    }
                }
            }else{
                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_GREATER_THAN_TODAY")); 
                component.find("birthdate").set("v.value","");
            } 
        }
    },
    
    getCanvasser : function(component, event, helper) {
        var action = component.get("c.getCanvasser");
        
        action.setCallback(this, function(actionResult){
            if(actionResult.getState() == 'SUCCESS'){
                var infoCanvasser = actionResult.getReturnValue();
                component.set("v.canvasser", infoCanvasser);
            }
        })
        $A.enqueueAction(action);
    },
    
    tipoRegistro : function(component, event, helper) {
        var valor = component.find("option").get("v.value");
        component.set("v.type",valor);
        this.setFieldsVisibility(component, valor);
        this.clearFields(component);
    },
    
    setFieldsVisibility : function(component, type){
        if(type == 'O'){          
            $A.util.removeClass(component.find("cifS"),"slds-hide");
            $A.util.removeClass(component.find("auxSection"),"slds-hide");
            $A.util.removeClass(component.find("cifImput"),"slds-hide");
            $A.util.addClass(component.find("nifS"),"slds-hide");
            $A.util.addClass(component.find("firmaAux"),"slds-hide");  
            $A.util.addClass(component.find("sigRep"),"slds-hide"); 
            component.find("name").set("v.label",$A.get("$Label.c.MSF_FORM_F2F_ORGANIZATION_NAME"));
            for(var i=0;i<=component.find("contactInputs").length;i++){ 
                $A.util.addClass(component.find("contactInputs")[i],"slds-hide");
            }
        }
        if(type == 'P'){
            $A.util.addClass(component.find("cifS"),"slds-hide");
            $A.util.addClass(component.find("cifImput"),"slds-hide");
            $A.util.addClass(component.find("auxSection"),"slds-hide");
            $A.util.removeClass(component.find("nifS"),"slds-hide");
            $A.util.removeClass(component.find("firmaAux"),"slds-hide");
            $A.util.removeClass(component.find("sigRep"),"slds-hide"); 
            component.find("name").set("v.label","Nombre");
            for(var i=0;i<=component.find("contactInputs").length;i++){
                $A.util.removeClass(component.find("contactInputs")[i],"slds-hide");
            }
        }
    },
    
    getSocio : function(component, event, helper, isOrganization) {
        var action = component.get("c.getSocio");
        
        action.setParams({
            docId : isOrganization ? component.find("cifS").get("v.value") : component.find("nifS").get("v.value"),
            isOrg : isOrganization
        });
        
        action.setCallback(this, function(actionResult){
            if(actionResult.getState() == 'SUCCESS'){
                var infoSocio = actionResult.getReturnValue();
                if(infoSocio != null){
                    
                    component.set("v.socio", infoSocio.socio);
                    component.set("v.isSocio", true);
                    component.set("v.perSelected","");
                    
                    if(this.isNotEmpty(infoSocio.rdonation)){
                        this.getMemberInfo(component, event);  
                        this.setSectionsVisibility(component, true);                 
                        this.getPeriod(component, event, helper, false, true); 
                        component.set("v.idRD", infoSocio.rdonation.id);
                    }
                    else {
                        this.getPeriod(component, event, helper, true,false);
                        this.loadForm(component, event,helper);
                    }
                }
                else{
                    this.setSectionsVisibility(component, false);
                }
            }
        })
        $A.enqueueAction(action);
    },
    
    loadForm : function(component, event, helper){ //here have to show it general section with the values         
        this.setSectionsVisibility(component, false);
        
        if(component.get("v.type") == 'P'){
            this.assignValues("name", "v.socio.FirstName",component);
            this.assignValues("firstSName", "v.socio.LastName",component);
            this.assignValues("secondSName", "v.socio.Suffix",component);
            this.assignValues("nif", "v.socio.msf_NIF__c",component);
            this.assignValues("genderCmp", "v.socio.Gender__c",component);
            this.assignValues("language", "v.socio.msf_LanguagePreferer__c",component);
            
            if(this.isNotEmpty(component.get("v.socio.Birthdate"))){
                this.assignValues("birthdate", "v.socio.Birthdate",component);
                this.birthdateChange(component, event, helper);
            }
        }
        
        if(component.get("v.type") == 'O'){
            this.assignValues("name", "v.socio.Name", component);
            
            let legalAgent = component.get('v.socio');
            if (legalAgent.msf_PrimaryContact__r != null) {
                legalAgent = legalAgent.msf_PrimaryContact__r; 
                //Datos representante legal; 
            	component.find("nameAux").set("v.value", legalAgent.FirstName);
                component.find("firstSNameAux").set("v.value", legalAgent.LastName);
                component.find("secondSNameAux").set("v.value", legalAgent.Suffix);
                component.find("nifAux").set("v.value", legalAgent.msf_NIF__c != null ? legalAgent.msf_NIF__c : legalAgent.msf_fiscalNif__c);
                component.find("mobileAux").set("v.value", legalAgent.MobilePhone);
                component.find("rolAux").set("v.value", legalAgent.Title);
            }
            
        }        
    },
    
    setSectionsVisibility : function(component, value){
        $A.util.addClass(component.find("searchSection"),"slds-hide");
        $A.util.addClass(component.find("conversationSection"),"slds-hide");
        if(value){
            $A.util.removeClass(component.find("socioSection"),"slds-hide");
            $A.util.addClass(component.find("generalSection"),"slds-hide");
        }else{
            $A.util.addClass(component.find("socioSection"),"slds-hide");
            $A.util.removeClass(component.find("generalSection"),"slds-hide");
        }
    },
    
    convertirFecha : function(value){
        value = new Date(value);
        return this.fixDigit(value.getDate())+"-"+(this.fixDigit(value.getMonth() + 1))+"-"+value.getFullYear();
    },
    
    fixDigit : function(val){
        return val.toString().length === 1 ? "0" + val : val;
    },
    
    getDate : function(component, event, helper){
        if(component.isValid()){
            var action = component.get("c.getDate");
            action.setCallback(this, function(actionResult) {
                if(actionResult.getState() == "SUCCESS"){
                    var stateReturnValue = actionResult.getReturnValue();
                    if(stateReturnValue != null){
                        component.set("v.opDate", stateReturnValue);
                        if(!this.isNotEmpty(component.get("v.dateSelected"))){
                            component.set("v.dateSelected",stateReturnValue[0]);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    comprobarNIF : function(value) {
        var validChars = 'TRWAGMYFPDXBNJZSQVHLCKET';
        var nifRexp = /^[0-9]{8}[TRWAGMYFPDXBNJZSQVHLCKET]$/i;
        var nieRexp = /^[XYZ][0-9]{7}[TRWAGMYFPDXBNJZSQVHLCKET]$/i;
        var str = value.toString().toUpperCase();
        
        if (!nifRexp.test(str) && !nieRexp.test(str)) return false;
        
        var nie = str
        .replace(/^[X]/, '0')
        .replace(/^[Y]/, '1')
        .replace(/^[Z]/, '2');
        
        var letter = str.substr(-1);
        var charIndex = parseInt(nie.substr(0, 8)) % 23;
        
        if (validChars.charAt(charIndex) === letter) return true;
        
        return false;
    },
    
    isCifValid : function (cif)  
    {
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
    
    comprobarIban : function(component) {
        var iban;
        
        if(!component.find("iban1").get('v.validity').patternMismatch && !component.find("iban2").get('v.validity').patternMismatch && 
           !component.find("iban3").get('v.validity').patternMismatch && !component.find("iban4").get('v.validity').patternMismatch && 
           !component.find("iban5").get('v.validity').patternMismatch)
        {      
            if(this.isNotEmpty(component.get("v.iban1")) && this.isNotEmpty(component.get("v.iban2")) && 
               this.isNotEmpty(component.get("v.iban3")) && this.isNotEmpty(component.get("v.iban4")) && 
               this.isNotEmpty(component.get("v.iban5")))   
            { 	
                iban = component.get("v.iban1")+component.get("v.iban2")+component.get("v.iban3")+component.get("v.iban4")+component.get("v.iban5");
                if(this.ValidateIban(iban)){
                    component.set("v.ibanComplete",iban.toUpperCase());
                    return true;
                }
            }else if(!this.isNotEmpty(component.get("v.iban1")) && !this.isNotEmpty(component.get("v.iban2")) && 
                     !this.isNotEmpty(component.get("v.iban3")) && !this.isNotEmpty(component.get("v.iban4")) && 
                     !this.isNotEmpty(component.get("v.iban5")))
            {
                return true;
            }
        }
        
        return false;
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
        var ls_letras = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        return ls_letras.search(letra) + 10;
    },
    
    comprobarHolder : function(component, lead) {
        var holder;
        if(component.get("v.holderValue") == 'socio'){
            holder = [
                component.find("name").get("v.value"),
                component.find("firstSName").get("v.value"),
                (this.isNotEmpty(component.find("secondSName").get("v.value"))?" "+component.find("secondSName").get("v.value"):null),
                (this.isNotEmpty(component.find("nif").get("v.value"))?component.find("nif").get("v.value"):null)
            ];
        }
        if(component.get("v.holderValue") =='tutor' ){
            holder = [
                component.find("nameAux").get("v.value"),
                component.find("firstSNameAux").get("v.value"),
                (this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?" "+component.find("secondSNameAux").get("v.value"):null),
                (this.isNotEmpty(component.find("nifAux").get("v.value"))?component.find("nifAux").get("v.value"):null)
            ];
        }
        if(component.get("v.holderValue") =='other' ){
            holder = [
                component.find("nameH").get("v.value"), 
                component.find("firstSNameH").get("v.value"),
                (this.isNotEmpty(component.find("secondSNameH").get("v.value"))?" "+component.find("secondSNameH").get("v.value"):null),
                (this.isNotEmpty(component.find("nifH").get("v.value"))?component.find("nifH").get("v.value").toUpperCase():null)
            ];
        }
        
        if(lead){
            return holder;
        }else{
            var ppDetails = { 
                cpm__IBAN__c : component.get("v.ibanComplete"),
                msf_HolderFirstName__c : holder[0],
                msf_HolderLastName1__c : holder[1],
                msf_HolderLastName2__c : holder[2],
                msf_NIF__c : holder[3],
                cpm__Holder_Name__c : holder[0]+" "+holder[1]+(holder[2]!=null?" "+holder[2]:""),
                cpm__Active__c : true
            };
            return ppDetails;
        }
    },
    
    isNotEmpty : function (value){
        if(value != null && value != undefined && value != "" ){
            return true;
        }else{
            return false;
        }
    },
    
    incompleteFields : function(value, component){
        
        if(value == 'socioFields'){
            component.find("mobile").showHelpMessageIfInvalid();
            component.find("phone").showHelpMessageIfInvalid();
            component.find("otherApor").showHelpMessageIfInvalid();
            if(!component.find("mobile").get('v.validity').patternMismatch  && !component.find("phone").get('v.validity').patternMismatch && component.find("otherApor").get('v.validity').valid){
                return true;
            }else{
                return false;
            }
        }
        
        if(value == 'lead'){
            var movil = this.isNotEmpty(component.find("mobile").get("v.value")) 		? component.find("mobile").get('v.validity').patternMismatch : false;
            var movilAux = this.isNotEmpty(component.find("mobileAux").get("v.value"))	? component.find("mobileAux").get('v.validity').patternMismatch : false;
            var phone = this.isNotEmpty(component.find("phone").get("v.value"))			? component.find("phone").get('v.validity').patternMismatch : false;
            var zipCode = this.isNotEmpty(component.find("zipCode").get("v.value"))		? component.find("zipCode").get('v.validity').patternMismatch : false;
            var otherApor = component.find("Amount").get("v.value") == '0' ? (component.find("otherApor").get('v.validity').valid) : true;
           
            component.find("otherApor").reportValidity();
            
            if(!movil && !phone && !zipCode && !movilAux && otherApor){
                return true;
            }else{
                return false;
            }
        }
        
        if(value == 'tutorFields'){
            component.find("nameAux").showHelpMessageIfInvalid();
            component.find("firstSNameAux").showHelpMessageIfInvalid();
            component.find("nifAux").showHelpMessageIfInvalid();
            if(component.find("nameAux").get('v.validity').valid && component.find("firstSNameAux").get('v.validity').valid && component.find("nifAux").get('v.validity').valid ){
                return true;
            }else{
                return false;
            }
        }
        if(value == 'holderFields'){
            component.find("nameH").showHelpMessageIfInvalid();
            component.find("firstSNameH").showHelpMessageIfInvalid();
            component.find("nifH").showHelpMessageIfInvalid();
            if(component.find("nameH").get('v.validity').valid && component.find("firstSNameH").get('v.validity').valid && component.find("nifH").get('v.validity').valid){
                return true;
            }else{
                return false;
            }
        }
        if(value == 'socioFieldsOrg'){
            component.find("mobileAux").showHelpMessageIfInvalid();
            component.find("phone").showHelpMessageIfInvalid();
            component.find("otherApor").showHelpMessageIfInvalid();
            if(!component.find("mobileAux").get('v.validity').patternMismatch  && !component.find("phone").get('v.validity').patternMismatch && component.find("otherApor").get('v.validity').valid){
                return true;
            }else{
                return false;
            }
        }
        if(value == 'PCFields'){
            component.find("nameAux").showHelpMessageIfInvalid();
            component.find("firstSNameAux").showHelpMessageIfInvalid();
            if(component.find("nameAux").get('v.validity').valid && component.find("firstSNameAux").get('v.validity').valid){
                return true;
            }else{
                return false;
            }
        }
        if(value == 'basic'){
            component.find("name").showHelpMessageIfInvalid();
            component.find("firstSName").showHelpMessageIfInvalid();
            component.find("checkPolitics").showHelpMessageIfInvalid();
            component.find("checkPayment").showHelpMessageIfInvalid();
            if(component.find("name").get('v.validity').valid && component.find("firstSName").get('v.validity').valid && component.find("checkPolitics").get('v.validity').valid && component.find("checkPayment").get('v.validity').valid){
                return true;
            }else{
                return false;
            }
        }
        if(value == 'basicOrg'){
            component.find("name").showHelpMessageIfInvalid();
            component.find("checkPolitics").showHelpMessageIfInvalid();
            component.find("checkPayment").showHelpMessageIfInvalid();
            if(component.find("name").get('v.validity').valid && component.find("checkPolitics").get('v.validity').valid && component.find("checkPayment").get('v.validity').valid){
                return true;
            }else{
                return false;
            }
        }
    },
    
    checkAddres : function(component){
        if(this.isNotEmpty(component.find("street").get("v.value")) && this.isNotEmpty(component.find("num").get("v.value")) && this.isNotEmpty(component.find("floor").get("v.value")) && this.isNotEmpty(component.find("door").get("v.value")) &&
           this.isNotEmpty(component.find("city").get("v.value")) && this.isNotEmpty(component.find("zipCode").get("v.value")) && this.isNotEmpty(component.find("province").get("v.value")) && this.isNotEmpty(component.find("country").get("v.value")))
        {
            return true;
        }else{ 
            return false;
        }
    },
    
    typeCase : function(component, event, helper){        
        if(component.get("v.type") == 'P'){//es persona
            if(this.incompleteFields('basic',component) && component.get("v.signatureDonorOk") ){ //campos mínimos
                if(!component.get("v.isMinor")){//Isn't minor (case 1 y 2)
                    if(component.get("v.holderValue") == 'other') { //case 2 adult other holder
                        if(this.incompleteFields('socioFields',component) && this.incompleteFields('holderFields',component) 
                           && component.get("v.signatureHolderOk")) {
                            if(this.comprobarNIF(component.find("nifH").get("v.value"))){
                                if(this.comprobarIban(component) && this.isNotEmpty(component.get("v.ibanComplete")) && this.isNotEmpty(this.getAmount(component)) 
                                   && this.isNotEmpty(component.find("nif").get("v.value")) 
                                   && (this.isNotEmpty(component.find("mobile").get("v.value")) || this.isNotEmpty(component.find("email").get("v.value")) 
                                       /*|| this.isNotEmpty(component.find("phone").get("v.value")) || this.checkAddres(component)*/ )
                                  ) {//verificar primero si estan vacios porque puede ser lead
                                    this.saveInformation(component, event,'case2');
                                }else{
                                    this.saveInformation(component, event,'lead');
                                }
                            }else {
                                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_NIE_HOLDER_INCORRECT"));
                            }
                        }else {
                            this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_INFORMATION_INCOMPLETE_HOLDER"));
                        }
                    }else{ //case 1 adult same holder
                        if(this.comprobarIban(component) && this.isNotEmpty(component.find("nif").get("v.value")) 
                           && this.isNotEmpty(component.get("v.ibanComplete")) && this.isNotEmpty(this.getAmount(component)) 
                           && (this.isNotEmpty(component.find("mobile").get("v.value")) || this.isNotEmpty(component.find("email").get("v.value")) 
                               /*|| this.isNotEmpty(component.find("phone").get("v.value")) || this.checkAddres(component)*/)
                          ) { //verificar primero si estan vacios porque puede ser lead
                            if(this.incompleteFields('socioFields',component)){
                                this.saveInformation(component, event,'case1');
                            }else{
                                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_INCOMPLETE_FIELDS"));
                            }                            
                        }else{
                            this.saveInformation(component, event,'lead');
                        }
                    }
                }
                else{//is minor (Case 3,4,5)
                    if(this.incompleteFields('tutorFields',component) && component.get("v.signatureTutorOk")){
                        if(this.comprobarNIF(component.find("nifAux").get("v.value"))){
                            if(component.get("v.holderValue") == 'tutor'){//caso 4 menor tutor titular
                                if(this.comprobarIban(component) && this.isNotEmpty(component.get("v.ibanComplete")) && this.isNotEmpty(this.getAmount(component)) 
                                   && (this.isNotEmpty(component.find("mobile").get("v.value")) || this.isNotEmpty(component.find("email").get("v.value")) 
                                       /*|| this.isNotEmpty(component.find("phone").get("v.value")) || this.checkAddres(component) */)
                                  ) { //verificar primero si estan vacios porque puede ser lead
                                    this.saveInformation(component, event,'case4');
                                }
                                else{
                                    this.saveInformation(component, event,'lead');
                                } 
                            }else if(component.get("v.holderValue") == 'other'){//caso 5 menor otro titular
                                if(this.incompleteFields('socioFields',component) && this.incompleteFields('holderFields',component) && component.get("v.signatureHolderOk") ) {
                                    if(this.comprobarNIF(component.find("nifH").get("v.value"))){
                                        if(this.comprobarIban(component) && this.isNotEmpty(component.get("v.ibanComplete")) && this.isNotEmpty(this.getAmount(component)) 
                                           && (this.isNotEmpty(component.find("mobile").get("v.value")) || this.isNotEmpty(component.find("email").get("v.value")) 
                                               /*|| this.isNotEmpty(component.find("phone").get("v.value")) || this.checkAddres(component)*/)
                                          ) {//verificar primero si estan vacios porque puede ser lead
                                            this.saveInformation(component, event,'case5');
                                        }
                                        else{
                                            this.saveInformation(component, event,'lead');
                                        }
                                    }
                                    else {
                                        this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_NIE_HOLDER_INCORRECT"));
                                    }
                                }
                                else {
                                    this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_INFORMATION_INCOMPLETE_HOLDER"));
                                }
                            }else{//case 3 y 4 minor same holder
                                if(this.comprobarIban(component) && this.isNotEmpty(component.find("nif").get("v.value")) && this.isNotEmpty(component.get("v.ibanComplete")) 
                                   && this.isNotEmpty(this.getAmount(component)) 
                                   && (this.isNotEmpty(component.find("mobile").get("v.value")) || this.isNotEmpty(component.find("email").get("v.value")) 
                                       /*|| this.isNotEmpty(component.find("phone").get("v.value")) || this.checkAddres(component)*/)
                                  ) { //verificar primero si estan vacios porque puede ser lead
                                    if(this.incompleteFields('socioFields',component)){
                                        this.saveInformation(component, event,'case3');
                                    }
                                    else {
                                        this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_INCOMPLETE_FIELDS"));
                                    }                                    
                                }
                                else {//is lead
                                    this.saveInformation(component, event,'lead');
                                }
                            }
                        }else{
                            this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_REP_LEGAL_INCORRECT"));
                        }
                    }else {
                        this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_INFO_REP_LEGAL_INCORRECT"));
                    }
                }
            }
            else {//minimum fields
                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_BASIC_INFO_INCOMPLETE"));
            }
        }
        else if(component.get("v.type") =='O'){//----------------------------------------------------ORGANIZATION------------------------------------------------------------//            
            if(this.incompleteFields('basicOrg',component) && component.get("v.signatureDonorOk")){
                if(this.comprobarNIF(component.find("nifAux").get("v.value"))){
                    if(component.get("v.holderValue")=='other'){ //es caso 7
                        if(this.incompleteFields('PCFields',component) && this.incompleteFields('holderFields',component) && this.incompleteFields('socioFieldsOrg',component) && component.get("v.signatureHolderOk")) {
                            if(this.comprobarNIF(component.find("nifH").get("v.value"))){
                                if(this.comprobarIban(component) && this.isNotEmpty(component.get("v.ibanComplete")) && this.isNotEmpty(this.getAmount(component)) && (this.isNotEmpty(component.find("mobileAux").get("v.value")) || this.isNotEmpty(component.find("phone").get("v.value")) || this.isNotEmpty(component.find("email").get("v.value")) || this.checkAddres(component))){//check first if they are empty because it can be lead
                                    this.saveInformation(component, event,'case7');
                                }else{
                                    this.saveInformation(component, event,'lead');
                                }
                            }else {
                                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_NIE_HOLDER_INCORRECT"));
                            }
                        }else {
                            if(component.get("v.signatureHolderOk")){
                                this.saveInformation(component, event,'lead'); 
                            }else{
                                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_INFORMATION_INCOMPLETE_HOLDER"));
                            }
                        }
                    }else{//is case 6
                        if(this.comprobarIban(component) && this.isNotEmpty(component.get("v.ibanComplete")) && this.isNotEmpty(this.getAmount(component)) && (this.isNotEmpty(component.find("mobileAux").get("v.value")) || this.isNotEmpty(component.find("phone").get("v.value")) || this.isNotEmpty(component.find("email").get("v.value")) || this.checkAddres(component))){//check first if they are empty because it can be lead
                            if(this.incompleteFields('PCFields',component) && this.incompleteFields('socioFieldsOrg',component)){
                                this.saveInformation(component, event,'case6');
                            }else{//islead
                                this.saveInformation(component, event,'lead');
                            }                        
                        }else{//islead
                            this.saveInformation(component, event,'lead');
                        }
                    }
                }else{
                    this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_NIF_REP_LEGAL_INCORRECT"));
                }
            }else{
                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_BASIC_INFO_INCOMPLETE"));
            }
        }
    },
    
    getLanguage : function(component, event, helper) {
        if(component.isValid()){
            var action = component.get("c.getLanguage");
            action.setCallback(this, function(actionResult) {
                if(actionResult.getState() == "SUCCESS"){
                    var stateReturnValue = actionResult.getReturnValue();
                    if(stateReturnValue != null){
                        component.set("v.language", stateReturnValue);
                        if(!this.isNotEmpty(component.get("v.lanSelected"))){
                            component.set("v.lanSelected",stateReturnValue[1]);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getGender : function(component, event, helper) {
        if(component.isValid()){
            var action = component.get("c.getGender");
            action.setCallback(this, function(actionResult) {
                if(actionResult.getState() == "SUCCESS"){
                    var stateReturnValue = actionResult.getReturnValue();
                    if(stateReturnValue != null){
                        component.set("v.gender", stateReturnValue);
                        if(!this.isNotEmpty(component.get("v.genSelected"))){
                            component.set("v.genSelected",stateReturnValue[0]);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getPeriod : function(component, event, helper, value1,value2) {
        if(component.isValid()){
            var action = component.get("c.getPeriod");
            action.setParams({
                uniqueadd : value1,
                uniqueOnly: value2
            });
            
            action.setCallback(this, function(actionResult) {
                if(actionResult.getState() == "SUCCESS"){
                    var stateReturnValue = actionResult.getReturnValue();
                    if(stateReturnValue != null){
                        component.set("v.opPeriod", stateReturnValue);
                        if(!this.isNotEmpty(component.get("v.perSelected"))){
                            component.set("v.perSelected",stateReturnValue[0]);
                        }
                    }
                }
            });            
            $A.enqueueAction(action);
        }
    },
    
    getAmount : function(component){
        if(!component.find("checkAmount").get("v.checked")){
            if(component.get("v.ValorAportacionRad") == 0){
                if(this.isNotEmpty(component.get("v.ValorOtherAmount"))){
                    return component.get("v.ValorOtherAmount");
                }else{
                    return null;
                }
            }else{
                return component.get("v.ValorAportacionRad");   
            }
        } 
        else{
            return 0; 
        }
    },
    
    checkDate : function(value){
        var value1 = new Date(value);
        var today = new Date();
        if(value1 >= today){
            return true;
        }else{
            return false;
        }        
    },
    
    getCleanedString : function(cadena){
        var specialChars = "!@#$^&%*()+=-[]\/{}|:<>?,.´`";
        for (var i = 0; i < specialChars.length; i++) {
            cadena= cadena.replace(new RegExp("\\" + specialChars[i], 'gi'), '');
        }  
        cadena = cadena.toUpperCase();
        cadena = cadena.replace(/[áäà]/gi,"A");
        cadena = cadena.replace(/[éèë]/gi,"E");
        cadena = cadena.replace(/íìï/gi,"I");
        cadena = cadena.replace(/óòö/gi,"O");
        cadena = cadena.replace(/úùü/gi,"U");
        return cadena;
    },
    
    convDateString: function(value){
        value=value.split('/');
        var value2 = value[2]+"-"+value[1]+"-"+value[0];
        return value2;
    },
    
    convDateStringReverse: function(value){
        value=value.split('-');
        var value2 = value[1]+"/"+value[2]+"/"+value[0];
        return value2;
    },
    
    saveInformation : function(component, event, typeCase){
        component.set('v.spinnerRecurring', true);
        var showSearch = false;
        
        //Lead
        var currentLead = this.isNotEmpty(component.get("v.incomplete")) ? JSON.parse(JSON.stringify(component.get("v.incomplete"))) : null;
        
        if(typeCase == 'case1' ||typeCase == 'case2' || typeCase == 'case3'|| typeCase == 'case4'|| typeCase == 'case5' || typeCase == 'case6' || typeCase == 'case7'){
            
            // Generate PDF to new Donations
            var uniqueDonation = component.get("v.perSelected") == $A.get('$Label.c.MSF_FORM_F2F_UNIQUE_DONATION');
            var isMember = component.get("v.isSocio");

            var templatePDF = 1000;
            if(uniqueDonation){
                templatePDF = 6;  
                if(typeCase == 'case3'){
                    templatePDF = 7;
                }else if(typeCase == 'case2' || typeCase == 'case7'){
                    templatePDF = 8;    
                }else if(typeCase == 'case5'){
                    templatePDF = 9;
                }else if(typeCase == 'case4'){
                    templatePDF = 10;
                }  
            }else{
                templatePDF = 0;
                if(typeCase == 'case3'){
                    templatePDF = 1;
                }else if(typeCase == 'case2' || typeCase == 'case7'){
                    templatePDF = 2;    
                }else if(typeCase == 'case5'){
                    templatePDF = 3;
                }else if(typeCase == 'case4'){
                    templatePDF = 4;
                }  
            }            
            
            //Build Contact
            var ctDetails = { 
                FirstName: component.get("v.type") == 'P'? component.find("name").get("v.value") : null,
                LastName: component.get("v.type") == 'P'? component.find("firstSName").get("v.value") : component.find("name").get("v.value"),
                Suffix : this.isNotEmpty(component.find("secondSName").get("v.value"))?" "+component.find("secondSName").get("v.value"):null,
                msf_NIF__c : component.get("v.type") == 'P'? this.isNotEmpty(component.find("nif").get("v.value"))?component.find("nif").get("v.value"):null : this.isNotEmpty(component.find("cif").get("v.value"))?component.find("cif").get("v.value"):null,
                Birthdate : component.find("birthdate").get("v.value"),
                msf_MainEmail__c : this.isNotEmpty(component.find("email").get("v.value"))?component.find("email").get("v.value"):null,
                MailingStreet : (this.isNotEmpty(component.find("street").get("v.value"))?component.find("street").get("v.value"):"") +
                (this.isNotEmpty(component.find("num").get("v.value"))?" "+component.find("num").get("v.value"):"") +
                (this.isNotEmpty(component.find("floor").get("v.value"))?" "+component.find("floor").get("v.value"):"") + 
                (this.isNotEmpty(component.find("door").get("v.value"))?" "+component.find("door").get("v.value"):""),
                MailingPostalCode : this.isNotEmpty(component.find("zipCode").get("v.value"))?component.find("zipCode").get("v.value"):null,
                MailingCity : this.isNotEmpty(component.find("city").get("v.value"))?component.find("city").get("v.value"):null,
                MailingState : this.isNotEmpty(component.find("province").get("v.value"))?component.find("province").get("v.value"):null,
                MailingCountry : this.isNotEmpty(component.find("country").get("v.value"))?component.find("country").get("v.value"):null,
                HomePhone : this.isNotEmpty(component.find("phone").get("v.value"))?component.find("phone").get("v.value"):null,
                MobilePhone :this.isNotEmpty(component.find("mobile").get("v.value"))?component.find("mobile").get("v.value"):null,
                msf_LanguagePreferer__c : this.isNotEmpty(component.get("v.lanSelected"))?component.get("v.lanSelected"):null,
                Gender__c	 : component.get("v.type") == 'P'? (this.isNotEmpty(component.get("v.genSelected"))?component.get("v.genSelected"):null) : null,
                msf_Canvasser__c : component.get("v.canvasser.Name"),
                msf_CityCanvasser__c : component.get("v.canvasser.msf_City__c"),
                msf_PlaceCanvasser__c : component.get("v.canvasser.msf_Place__c"),
                msf_FiscalFirstName__c : component.get("v.type") == 'P'? (this.isNotEmpty(component.find("nameAux").get("v.value"))?this.getCleanedString(component.find("nameAux").get("v.value")):null) : null,
                msf_FiscalLastName1__c : component.get("v.type") == 'P'? (this.isNotEmpty(component.find("firstSNameAux").get("v.value"))?this.getCleanedString(component.find("firstSNameAux").get("v.value")):null) : null,
                msf_FiscalLastName2__c : component.get("v.type") == 'P'? (this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?this.getCleanedString(component.find("secondSNameAux").get("v.value")):null) : null,
                msf_fiscalNif__c : component.get("v.type") == 'P'? (this.isNotEmpty(component.find("nifAux").get("v.value"))?component.find("nifAux").get("v.value").toUpperCase():null) : null,
                msf_ConfirmedLanguage__c : true,
                OwnerId : component.get("v.canvasser.Id"),
                msf_F2FTemplateNumber__c : templatePDF
            };
            if(component.get("v.type") == 'O'){
                //Primary Contact when is org.
                var repDetails = { 
                    FirstName: this.isNotEmpty( component.find("nameAux").get("v.value"))?this.convCapLetter(component.find("nameAux").get("v.value")):null,
                    LastName: (this.isNotEmpty(component.find("firstSNameAux").get("v.value"))?this.convCapLetter(component.find("firstSNameAux").get("v.value")):null),
                    Suffix : (this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?this.convCapLetter(component.find("secondSNameAux").get("v.value")):null),
                    MobilePhone : (this.isNotEmpty(component.find("mobileAux").get("v.value"))?component.find("mobileAux").get("v.value"):null),
                    Title : (this.isNotEmpty(component.find("rolAux").get("v.value"))?" "+component.find("rolAux").get("v.value"):null),
                    msf_FiscalFirstName__c : this.isNotEmpty(component.find("nameAux").get("v.value"))?this.getCleanedString(component.find("nameAux").get("v.value")):null,
                    msf_FiscalLastName1__c : this.isNotEmpty(component.find("firstSNameAux").get("v.value"))?this.getCleanedString(component.find("firstSNameAux").get("v.value")):null,
                    msf_FiscalLastName2__c : this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?this.getCleanedString(component.find("secondSNameAux").get("v.value")):null,
                    msf_fiscalNif__c : this.isNotEmpty(component.find("nifAux").get("v.value"))?component.find("nifAux").get("v.value").toUpperCase():null,
                    msf_NIF__c : this.isNotEmpty(component.find("nifAux").get("v.value")) ? component.find("nifAux").get("v.value").toUpperCase() : null,
                    msf_ConfirmedLanguage__c : true,
                    OwnerId : component.get("v.canvasser.Id"),
                    
                    HomePhone : this.isNotEmpty(component.find("phone").get("v.value")) ? component.find("phone").get("v.value") : null
                };
            }
            
            //Build Opportunity
            var amount = this.getAmount(component);
            if(this.isNotEmpty(amount)){
                if(component.get("v.perSelected") == $A.get('$Label.c.MSF_FORM_F2F_UNIQUE_DONATION')){
                    var opUniqueDetails = { 
                        Name: 'Unique donation',
                        StageName: 'Propuesta',
                        CloseDate : this.convDateString(component.get("v.dateSelected")),
                        Type : 'One off Donation',
                        npsp4hub__Payment_Method__c : 'Direct Debit',
                        npsp4hub__Payment_Processor__c : 'PaymentHub-SEPA',
                        npsp4hub__Target__c : 'LA CAIXA CCC OPERATIVA',
                        msf_Canvasser__c : component.get("v.canvasser.Name"),
                        msf_CityCanvasser__c : component.get("v.canvasser.msf_City__c"),
                        msf_PlaceCanvasser__c : component.get("v.canvasser.msf_Place__c"),
                        OwnerId : component.get("v.canvasser.Id")
                    };
                }else{//if opp is recurring
                    var opDetails = {
                        Name: 'Recurring donation',
                        npe03__Open_Ended_Status__c : 'Open',
                        npe03__Date_Established__c : this.convDateString(component.get("v.dateSelected")),
                        npe03__Installment_Period__c :component.get("v.perSelected"),
                        npe03__Installments__c : 0,
                        npsp4hub__Payment_Method__c : 'Direct Debit',
                        npsp4hub__Payment_Processor__c : 'PaymentHub-SEPA',
                        npsp4hub__Target__c : 'LA CAIXA CCC OPERATIVA',
                        msf_Canvasser__c : component.get("v.canvasser.Name"),
                        msf_CityCanvasser__c : component.get("v.canvasser.msf_City__c"),
                        msf_PlaceCanvasser__c : component.get("v.canvasser.msf_Place__c"),
                        OwnerId : component.get("v.canvasser.Id")
                    };
                }
                //Build Payment Profile
                if(component.get("v.type") == 'O' && component.get("v.holderValue")=='socio'){
                    var ppDetails = { 
                        cpm__IBAN__c : component.get("v.ibanComplete"),
                        msf_HolderFirstName__c : component.find("nameAux").get("v.value"),
                        msf_HolderLastName1__c : component.find("firstSNameAux").get("v.value"),
                        msf_HolderLastName2__c : (this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?" "+component.find("secondSNameAux").get("v.value"):null),
                        msf_NIF__c : component.find("nifAux").get("v.value"),
                        cpm__Holder_Name__c : component.find("nameAux").get("v.value")+" "+component.find("firstSNameAux").get("v.value")+(this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?" "+component.find("secondSNameAux").get("v.value"):""),
                        cpm__Active__c : true
                    };
                }
                else{
                    var ppDetails = this.comprobarHolder(component,false);  
                }
                
                var action = component.get("c.setContact");
                action.setParams({ 
                    infoC : ctDetails,
                    canvasser : component.get("v.canvasser"),
                    infoO : opDetails,
                    infoOU : opUniqueDetails,
                    infoPP : ppDetails,
                    infoRep : repDetails,
                    isSocio : component.get("v.isSocio"),
                    isOrg : component.get("v.type") == 'O'?true:false,
                    amount : amount, 
                    campaignName : component.find("campañaCan").get("v.value"),
                    incompleteLead : currentLead
                });                
                action.setCallback(this, function(actionResult) {
                    
                    if (actionResult.getState() === "SUCCESS") {
                        showSearch = true;
                        var stateReturnValue = actionResult.getReturnValue();                        
                        if(stateReturnValue.idContact != null){
                            component.set("v.memberId",stateReturnValue.idContact);
                            if(!this.isNotEmpty(component.get("v.incomplete"))){
                                this.createSignatures(component);
                            } 
                            this.showToast(stateReturnValue.title,stateReturnValue.msg,stateReturnValue.type);  
                            this.generatePDF(component,false);
                        }else{
                            this.showMessage($A.get('$Label.c.MSF_FORM_F2F_ERROR_TITLE'),stateReturnValue.msg);                            
                        }
                    }else {
                        this.showMessage($A.get('$Label.c.MSF_FORM_F2F_ERROR_TITLE'),$A.get('$Label.c.MSF_UNKNOWN_ERROR'));                        
                    }
                    this.toBack(component, event);
                    component.set('v.spinnerRecurring', false);
                });
                $A.enqueueAction(action);
            } else{
                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_REPORT_AMOUNT"));
            }
        }
        
        if(typeCase == 'lead'){ //Is a lead
            if(!component.get("v.isSocio")){
                if(this.incompleteFields('lead',component)){
                    if(this.comprobarIban(component)){
                        if(this.isNotEmpty(component.find("contactDate").get("v.value")) && this.checkDate(component.find("contactDate").get("v.value"))){
                            var leadConfirm;
                            if(this.isNotEmpty(component.find("mobile").get("v.value")) || this.isNotEmpty(component.find("phone").get("v.value")) || this.isNotEmpty(component.find("mobileAux").get("v.value")) 
                               || this.isNotEmpty(component.find("email").get("v.value")) || this.checkAddres(component) ){
                                leadConfirm = confirm($A.get('$Label.c.MSF_FORM_F2F_MESSAGE_LEAD_CONFIRM_WITH_PHONE'));
                            }else{
                                leadConfirm = confirm($A.get('$Label.c.MSF_FORM_F2F_MESSAGE_LEAD_CONFIRM_WITHOUT_PHONE'));    
                            }
                            if(leadConfirm){
                                var amount = this.getAmount(component);
                                var holder;
                                if(component.get("v.type") == 'O' && component.get("v.holderValue")=='socio'){
                                    holder = { 
                                        cpm__IBAN__c : component.get("v.ibanComplete"),
                                        msf_HolderFirstName__c : component.find("nameAux").get("v.value"),
                                        msf_HolderLastName1__c : component.find("firstSNameAux").get("v.value"),
                                        msf_HolderLastName2__c : (this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?" "+component.find("secondSNameAux").get("v.value"):null),
                                        msf_NIF__c : component.find("nifAux").get("v.value"),
                                        cpm__Holder_Name__c : component.find("nameAux").get("v.value")+" "+component.find("firstSNameAux").get("v.value")+(this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?" "+component.find("secondSNameAux").get("v.value"):""),
                                        cpm__Active__c : true
                                    };
                                }
                                else{
                                    holder = this.comprobarHolder(component,true);  
                                }
                                var leadDetails = {
                                    FirstName: component.get("v.type") == 'P'? component.find("name").get("v.value") : null,
                                    LastName: component.get("v.type") == 'P'? component.find("firstSName").get("v.value") : component.find("name").get("v.value"),
                                    Suffix : component.get("v.type") == 'P'?(component.find("secondSName").get("v.value") != ""?" "+this.convCapLetter(component.find("secondSName").get("v.value")):null):null,
                                    msf_Birthdate__c : component.get("v.type") == 'P'?component.find("birthdate").get("v.value"):null,
                                    MobilePhone : component.get("v.type") == 'P'?(this.isNotEmpty(component.find("mobile").get("v.value"))?component.find("mobile").get("v.value"):null):null,
                                    msf_NIF__c : component.get("v.type") == 'P'?(this.isNotEmpty(component.find("nif").get("v.value"))?component.find("nif").get("v.value"):null):(this.isNotEmpty(component.find("cif").get("v.value"))?component.find("cif").get("v.value"):null),
                                    msf_Gender__c : component.get("v.type") == 'P'?(this.isNotEmpty(component.get("v.genSelected"))?component.get("v.genSelected"):null):null,
                                    msf_AuxFirstName__c : this.isNotEmpty(component.find("nameAux").get("v.value"))?this.getCleanedString(component.find("nameAux").get("v.value")):null,
                                    msf_AuxLastName__c : this.isNotEmpty(component.find("firstSNameAux").get("v.value"))?this.getCleanedString(component.find("firstSNameAux").get("v.value")):null,
                                    msf_AuxSuffix__c : this.isNotEmpty(component.find("secondSNameAux").get("v.value"))?this.getCleanedString(component.find("secondSNameAux").get("v.value")):null,
                                    msf_AuxNIF__c : this.isNotEmpty(component.find("nifAux").get("v.value"))?component.find("nifAux").get("v.value").toUpperCase():null,
                                    msf_AuxMobilePhone__c : component.get("v.type") == 'P'?null:(this.isNotEmpty(component.find("mobileAux").get("v.value"))?component.find("mobileAux").get("v.value"):null),
                                    msf_AuxRole__c : component.get("v.type") == 'P'?null:(this.isNotEmpty(component.find("rolAux").get("v.value"))?component.find("rolAux").get("v.value"):null),
                                    Company : component.get("v.type") == 'P'?("N/A"):component.find("name").get("v.value"),
                                    msf_esOrganizacion__c : component.get("v.type") == 'P'?false:true,
                                    Phone : this.isNotEmpty(component.find("phone").get("v.value"))?component.find("phone").get("v.value"):null,
                                    City : this.isNotEmpty(component.find("city").get("v.value"))?component.find("city").get("v.value"):null,
                                    Country : this.isNotEmpty(component.find("country").get("v.value"))?component.find("country").get("v.value"):null,
                                    Street : this.isNotEmpty(component.find("street").get("v.value"))?component.find("street").get("v.value"):null,
                                    State : this.isNotEmpty(component.find("province").get("v.value"))?component.find("province").get("v.value"):null,
                                    PostalCode : this.isNotEmpty(component.find("zipCode").get("v.value"))?component.find("zipCode").get("v.value"):null,
                                    msf_StreetNumber__c : this.isNotEmpty(component.find("num").get("v.value"))?component.find("num").get("v.value"):null,
                                    msf_Floor__c : this.isNotEmpty(component.find("floor").get("v.value"))?component.find("floor").get("v.value"):null,
                                    msf_DoorNumber__c : this.isNotEmpty(component.find("door").get("v.value"))?component.find("door").get("v.value"):null,
                                    Description : this.isNotEmpty(component.find("obs").get("v.value"))?component.find("obs").get("v.value"):null,
                                    Email : this.isNotEmpty(component.find("email").get("v.value"))?component.find("email").get("v.value"):null,
                                    msf_LanguagePreferer__c : this.isNotEmpty(component.get("v.lanSelected"))?component.get("v.lanSelected"):null,
                                    msf_RecDon_npe03_Installment_Period__c : component.get("v.perSelected"),
                                    msf_RecDona_npe03_Next_Payment_Date__c : component.get("v.dateSelected"),
                                    msf_Canvasser__c : component.get("v.canvasser.Name"),
                                    msf_CanvasserCampaign__c : component.find("campañaCan").get("v.value")/*component.get("v.canvasser.msf_Campaign__c")*/,
                                    msf_CityCanvasser__c : component.get("v.canvasser.msf_City__c"),
                                    msf_PlaceCanvasser__c : component.get("v.canvasser.msf_Place__c"),
                                    msf_IBANCode__c : this.isNotEmpty(component.get("v.iban1"))?component.get("v.iban1"):null,
                                    msf_IBANEntity__c : this.isNotEmpty(component.get("v.iban2"))?component.get("v.iban2"):null,
                                    msf_IBANOffice__c : this.isNotEmpty(component.get("v.iban3"))?component.get("v.iban3"):null,
                                    msf_IBANDC__c : this.isNotEmpty(component.get("v.iban4"))?component.get("v.iban4"):null,
                                    msf_IBANAccountNumber__c : this.isNotEmpty(component.get("v.iban5"))?component.get("v.iban5"):null,
                                    msf_HolderFirstName__c : this.isNotEmpty(holder[0])?holder[0]:null,
                                    msf_HolderLastName__c : this.isNotEmpty(holder[1])?holder[1]:null,
                                    msf_HolderSuffixName__c : this.isNotEmpty(holder[2])?holder[2]:null,
                                    msf_HolderNIF__c : this.isNotEmpty(holder[3])?holder[3]:null,
                                    msf_FirmaDonante__c : component.get("v.signatureDonorOk"),
                                    msf_FirmaTitular__c : component.get("v.signatureHolderOk"),
                                    msf_FirmaRepresentante__c : component.get("v.signatureTutorOk"),
                                    msf_AccountHolderOption__c  : component.get("v.holderValue"),
                                    msf_ContactDate__c : component.find("contactDate").get("v.value")?component.find("contactDate").get("v.value"):null,
                                    msf_NotInformedAmount__c : component.find("checkAmount").get("v.checked")
                                };
                                
                                var taskDetails = {
                                    ActivityDate : component.find("contactDate").get("v.value")?component.find("contactDate").get("v.value"):null,
                                    Subject : 'Completar Incompleto',
                                    Type : 'Call',
                                    Priority : 'Normal',
                                    Status : 'Pendiente',
                                    OwnerId : component.get("v.canvasser.Id")
                                };
                                
                                var action = component.get("c.setLead");
                                action.setParams({
                                    infoLead : leadDetails,
                                    infoTask : taskDetails,
                                    amount : amount,
                                    incompleteLead : currentLead
                                });
                                
                                action.setCallback(this, function(actionResult) {                                    
                                    if (actionResult.getState() === "SUCCESS") {
                                        showSearch = true;
                                        var stateReturnValue = actionResult.getReturnValue();
                                        if(stateReturnValue.idLead != null){
                                            component.set("v.memberId",stateReturnValue.idLead);
                                            if(!this.isNotEmpty(component.get("v.incomplete"))){
                                                this.createSignatures(component);
                                            }  
                                            this.showToast(stateReturnValue.title,stateReturnValue.msg,stateReturnValue.type);  
                                        }else{
                                            this.showMessage($A.get('$Label.c.MSF_FORM_F2F_ERROR_TITLE'),stateReturnValue.msg);                                            
                                        }
                                    }else{
                                        this.showMessage($A.get('$Label.c.MSF_FORM_F2F_ERROR_TITLE'),actionResult.getState());                                        
                                    }
                                    this.toBack(component, event);
                                    component.set('v.spinnerRecurring', false);
                                });
                                $A.enqueueAction(action);
                            }else{
                                component.set('v.spinnerRecurring', false);
                            }
                        }else{
                            component.set('v.spinnerRecurring', false);
                            this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_COMPLETE_MIN_INFORMATION"));
                        }
                    }else{
                        component.set('v.spinnerRecurring', false);
                        this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_INCORRECT_IBAN"));
                    }                    
                }else{
                    component.set('v.spinnerRecurring', false);
                    this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_BASIC_INFO_INCOMPLETE"));
                }
            }else{
                component.set('v.spinnerRecurring', false);
                this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_IS_PARTNER_COMPLETE_INFO"));
            }
        }  
        if(showSearch){
            $A.util.removeClass(component.find("searchSection"),"slds-hide");//show search section 
        }
    },
    
    generatePDF : function(component, increaseQuotaAction) {
        var action = component.get("c.GeneratePDF");
        action.setParams({ 
            idContact : component.get("v.memberId"),
            increaseQuota : increaseQuotaAction
        });
        
        action.setCallback(this, function(actionResult){
            if(actionResult.getState() == 'SUCCESS'){
            	console.log('Success PDF');    
            }else{
                console.log('Error PDF');
            }
        })
        $A.enqueueAction(action);
    },
    
    createSignatures : function(component){ 
        if(component.get("v.signatureDonorOk")){
            component.find('sigDonorCmp').saveSignature();            
        }
        if(component.get("v.signatureDonorIncQuoOk")){
            component.find('sigDonorIncQuoCmp').saveSignature();            
        }
        if(component.get("v.signatureTutorOk")){
            component.find('sigRepCmp').saveSignature();
        }
        if(component.get("v.signatureHolderOk")){
            component.find('sigHolderCmp').saveSignature();
        }
    },
  
    clearFields : function(component) {
        component.set("v.nif","");
        component.set("v.cif","");
    },
    
    showToast : function(title,msg,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type,
            "mode" : 'dismissible'
        });
        toastEvent.fire();
    },
    
    showMessage : function(title, msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : 'error',
            "mode" : 'dismissible'
        });
        toastEvent.fire();
    },
    
    convCapLetter : function(str){
        str = str.toLowerCase().split(' ');
        for (var i = 0; i < str.length; i++) {
            str[i] = str[i].charAt(0).toUpperCase() + str[i].slice(1);
        }
        str = str.join(' ');
        
        if(str.includes('.')){
            str = str.split('.');
            for (var j = 0; j < str.length; j++) {
                str[j] = str[j].charAt(0).toUpperCase() + str[j].slice(1) ;
            }
            str = str.join('.')+ '.';
        }
        return str;    
    },
    
    //---- increase methods-----
    getMemberInfo : function(component, event) {
        var action = component.get("c.getMemberInfo");
        action.setParams({
            memberId : component.get("v.socio.Id")
        });
        
        action.setCallback(this, function(actionResult){
            
            if(actionResult.getState() === 'SUCCESS'){
                var dataValues = actionResult.getReturnValue();
                
                component.set('v.isOrganization',dataValues.isOrganization);
                component.set("v.newNextQuotaDate", dataValues.quota.npe03__Next_Payment_Date__c);//set default date
                component.set('v.recurringDonation',dataValues.quota);
                
                if(dataValues.labelPeriod != null){
                    component.set('v.oldFrequency',dataValues.labelPeriod);
                    component.set('v.newFrequency',dataValues.labelPeriod);
                }
                
                if(component.get("v.type") == 'O'){
                    component.set("v.isOrganization", true);
                    component.find("nameS").set("v.label","Nombre de la empresa");
                    component.set('v.nameS',dataValues.member.Name);
                }else{
                    component.set('v.nameS',dataValues.member.FirstName);
                    component.set('v.secondSNameS',dataValues.member.LastName);
                }
            }
        })
        $A.enqueueAction(action);
    },
    
    increaseQuota : function(component, event, helper) {
        this.getPeriod(component, event, helper, false, false);
        $A.util.removeClass(component.find("increaseQuota"),"slds-hide");
        $A.util.addClass(component.find("donationButton"),"slds-hide");
    },
    
    saveNewQuota : function(component, event) {
        component.set('v.spinnerRecurring', true);

        var amount = this.getAmount(component);
        if(component.get("v.signatureDonorIncQuoOk")){
            if(this.isNotEmpty(amount) && amount >0 ){ // verificar firma del donante
                
                var action = component.get("c.createNewQuota");
                action.setParams({
                    campaignName : component.find("campañaCan").get("v.value"),
                    RD : component.get("v.recurringDonation"),
                    quotaDate : component.get("v.frequencyChanged") ? this.convDateString(component.get("v.newNextQuotaDate")) : component.get('v.recurringDonation').npe03__Next_Payment_Date__c,
                    frequency : component.get("v.newFrequency"),
                    amount : amount,
                    canvasser : component.get("v.canvasser"),
                    contactId : component.get("v.socio.Id")
                });      
                
                action.setCallback(this, function(actionResult){
                    if(actionResult.getState() === 'SUCCESS'){
                        component.set("v.memberId",component.get("v.socio.Id"));
                        this.createSignatures(component);
                        
                        var dataValues = actionResult.getReturnValue();
                        this.showToast(dataValues.title,dataValues.msg,dataValues.type);
                        this.generatePDF(component,true);
                        this.toBack(component, event);
                        component.set('v.spinnerRecurring', false);
                    }else{
                        this.showMessage($A.get('$Label.c.MSF_FORM_F2F_ERROR_TITLE'),$A.get('$Label.c.MSF_UNKNOWN_ERROR'));
                    }
                })        
                $A.enqueueAction(action);
            }else{
                component.set('v.spinnerRecurring', false);
                component.find("otherApor").reportValidity();
            }  
        }else{
            component.set('v.spinnerRecurring', false);
            this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_BASIC_INFO_INCOMPLETE"));
        }
    },
    
    hideClass : function(id,param, component){
        if(param == "add"){
            for(var i=0;i<=id.length;i++){
                $A.util.addClass(component.find(id[i]),"slds-hide");
            }
        }
        if(param == "remove"){
            for(var i=0;i<=id.length;i++){
                $A.util.removeClass(component.find(id[i]),"slds-hide");
            }
        }
    },
    
    assignValues : function(id, param, component){
        component.find(id).set("v.value",component.get(param));
        (this.isNotEmpty(component.get(param))) ? component.find(id).set("v.disabled",true) : component.find(id).set("v.disabled",false);
    }, 
    
    toBack : function(component, event) {
        if(this.isNotEmpty(component.get("v.incomplete"))){
            
            var pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c:MSF_IncompleteManagement',
                },
                state: {
                    "incomplete": component.get("v.incomplete")
                }
            };  
            
            var navService = component.find("navService");
            event.preventDefault();
            navService.navigate(pageReference,true);
        }
        $A.get('e.force:refreshView').fire(); 
    },   
    
    contactDateChange : function(component){
        var dateA = new Date();
        var dateB = new Date(component.find("contactDate").get("v.value"));
        var dateC = new Date();
        dateC.setMonth(dateA.getMonth() + 1); //Fecha de aqui un mes; 
        if(dateB<=dateA){ 
            this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_CONTACT_DATE_LESSER_TODAY")); 
            component.find("contactDate").set("v.value","");
        }
        
        if (dateB > dateC) {
            this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_FORM_F2F_ERROR_CONTACT_DATE_GREATER_ONE_MONTH")); 
            component.find("contactDate").set("v.value","");
        }
    },
    
    getNumConvertation : function(component, event, helper, addConversation) {
        var action = component.get("c.getNumConvertation");
        action.setParams({ 
            numConversationActual : component.get("v.NumConversation"),
            addConversation : addConversation
        });
        
        action.setCallback(this, function(actionResult){
            if(actionResult.getState() == 'SUCCESS'){
                var infoCanvasser = actionResult.getReturnValue();
                if(infoCanvasser != null){
                    component.set("v.NumConversation", infoCanvasser);
                }else{
                    this.showMessage($A.get("$Label.c.MSF_FORM_F2F_ERROR_TITLE"),$A.get("$Label.c.MSF_UNKNOWN_ERROR"));
                }
            }
        })
        $A.enqueueAction(action);
    },
})