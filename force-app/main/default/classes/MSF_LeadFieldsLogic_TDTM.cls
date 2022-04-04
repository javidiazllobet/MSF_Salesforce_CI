/**
* @author 		Deloitte
* @date 		02-2019
* @group 		Lead
* @description	Logic of some fields.
*/
global without sharing class MSF_LeadFieldsLogic_TDTM extends npsp.TDTM_Runnable{
	
    /*******************************************************************************************************
    * @description	Trigger Handler on Leads that handles the donation vehicle. 
    * @param 		listNew the list of Leads from trigger new. 
    * @param 		listOld the list of Leads from trigger old. 
    * @param 		triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param 		objResult the describe for Leads.
    * @return 		dmlWrapper. 
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
    	
        //Attributes
        List<Lead> lNewLeads = (List<Lead>) newlist;          
        
        //Actions
        /*** BEFORE INSERT & BEFORE UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {	            
            
            MSF_SharedMethods_UTIL smUtil = new MSF_SharedMethods_UTIL();            
            Map<String, msf_LeadSourceMasterData__c> mLeadSourceValues = smUtil.getLeadSourceDependencies();
            
            for(Lead ld : lNewLeads){
            	setLeadSourceDependencies(ld, mLeadSourceValues);
                if(!getValidateNif(ld.msf_NIF__c)){
                    ld.msf_NIF__c.addError(System.Label.MSF_CONTACT_NIF_NIE_CIF_ERROR);
                }
                if(!getValidateNif(ld.msf_AuxNIF__c)){
                    ld.msf_AuxNIF__c.addError(System.Label.MSF_CONTACT_NIF_NIE_CIF_ERROR);
                }
                if(!getValidateNif(ld.msf_HolderNIF__c)){
                    ld.msf_HolderNIF__c.addError(System.Label.MSF_CONTACT_NIF_NIE_CIF_ERROR);
                }
                if(!getValidateIban(ld.msf_IBANCode__c,ld.msf_IBANEntity__c,ld.msf_IBANOffice__c,ld.msf_IBANDC__c,ld.msf_IBANAccountNumber__c) && ld.msf_PaymentMethod__c == 'Domiciliación bancaria'){
                    ld.msf_IBANCode__c.addError(System.Label.MSF_LEAD_IBAN_ERROR);
                    ld.msf_IBANOffice__c.addError(System.Label.MSF_LEAD_IBAN_ERROR);
                    ld.msf_IBANEntity__c.addError(System.Label.MSF_LEAD_IBAN_ERROR);
                    ld.msf_IBANDC__c.addError(System.Label.MSF_LEAD_IBAN_ERROR);
                    ld.msf_IBANAccountNumber__c.addError(System.Label.MSF_LEAD_IBAN_ERROR);
                }
                setLeadCountry(ld);
            }
        } 
        
        return null; 
    } 
    
    
    // PRIVATE METHODS
    
    /**
    * @description	Set the value of Country if is not settet. 
    * @param 		l is the Lead to update its fields.
     */
    private static void setLeadCountry(Lead l) {
        if (l.Street != null && l.Country == null) {
            l.Country = 'España'; 
        }
    }
    
	/*******************************************************************************************************
    * @description	Set the values in the 'LeadSource2; LeadSource3' fields in lead depending of the value 
    * 				of the 'LeadSource1' field.
    * @param 		l is the Lead to update its fields. 
    * @param 		mLsValues is a map that contains values for fields 'LeadSource2; LeadSource3'
    ********************************************************************************************************/
    private void setLeadSourceDependencies(Lead l, Map<String, msf_LeadSourceMasterData__c> mLsValues){
        if(mLsValues.containsKey(l.LeadSource)){
            l.msf_LeadSource2Level__c = mLsValues.get(l.LeadSource).msf_LeadSource2__c;
            l.msf_LeadSource3Level__c = mLsValues.get(l.LeadSource).msf_LeadSource3__c;
        }
    }
    
     //************* validate NIF *************
    private Boolean getValidateNif (String value){
        if(value != null ){
            String str = value.toUpperCase();
            
            String validChars = 'TRWAGMYFPDXBNJZSQVHLCKET';
            String nifRexp = '(\\d{1,8})([TRWAGMYFPDXBNJZSQVHLCKE]{1})';
            String nieRexp = '([XYZ]{1})(\\d{2,8})([TRWAGMYFPDXBNJZSQVHLCKE]{1})';
            String cifRexp = '([ABCDEFGHJKLMNPQRSUVW])(\\d{7})([0-9A-J])';
            
            if(Pattern.matches(nifRexp,str) || Pattern.matches(nieRexp,str))
            {
                String nie = str
                    .replace('X', '0')
                    .replace('Y', '1')
                    .replace('Z', '2');
                String letterA = str.substring(str.length()-1);
                Integer charIndex = math.mod(integer.valueof(nie.substring(0, 8)),23);
                String letterB = validChars.substring(charIndex,charIndex+1);
                if (letterB.equals(letterA)) {
                    return true;
                }
                return false; 
            }
            else if(Pattern.matches(cifRexp,str))
            {
                String aux = value.substring(0, 8);
                aux = validateCif(aux);
                return value.equals(aux);
            }
            else{
                return false;
            }   
        }
        return true;
    }
    
    private static String validateCif(String cif) 
    {
        return cif + calculateDigitoControl(cif);
    }
    
    private static Integer OddPosition(String str) 
    {
        Integer aux = Integer.valueOf(str);
        aux = aux * 2;
        aux = (aux / 10) + math.mod(aux, 10);
        return aux;
    }
    
    private static String calculateDigitoControl(String cif) 
    {
        String DIGITO_CONTORL_CIF = 'JABCDEFGHI';
        String CIF_CON_LETRA_FINAL = 'KNPQRSW';
        String str = cif.substring(1, 8);
        String cabecera = cif.substring(0, 1);
        Integer sumaPar = 0;
        Integer sumaImpar = 0;
        Integer sumaTotal;
        for (Integer i = 1; i < str.length(); i += 2) 
        {
            Integer aux = Integer.valueOf('' + str.substring(i,i+1));
            sumaPar += aux;
        }
        for (Integer i = 0; i < str.length(); i += 2) 
        {
            sumaImpar += OddPosition('' + str.substring(i,i+1));
        }
        sumaTotal = sumaPar + sumaImpar;
        Integer resto = math.mod(sumaTotal,10);
        if(resto == 0) sumaTotal = 0;
        else sumaTotal = 10 - resto;
        if (CIF_CON_LETRA_FINAL.contains(cabecera)) 
        {
            str = '' + DIGITO_CONTORL_CIF.substring(sumaTotal,sumaTotal+1);
        } 
        else 
        {
            str = '' + sumaTotal;
        }
        return str;
    }
    
    private static Boolean getValidateIban(String iban1, String iban2, String iban3, String iban4, String iban5 ) {
        if(iban1 != null && iban2 != null && iban3 != null && iban4 != null && iban5 != null){
            String iban =   iban1 + iban2 + iban3 + iban4 + iban5;
            
            String ibanRexp = '([ES]{2})(\\d{22})';
            if(!Pattern.matches(ibanRexp,iban)){
                return false;
            }
            iban = rearrange(iban);
            iban = convertToInteger(iban);
            Long result = performModulos(iban);
            
            return result == 1;
        }
        else if(iban1 == null && iban2 == null && iban3 == null && iban4 == null && iban5 == null){
            return true;
        }
        else{
            return false;
        }
    }
    
    private static String rearrange(String iban) {
        iban = iban.trim().toUpperCase();
        iban = iban.replaceAll('(\\s+)', '');
        String start = iban.substring(0,4);
        String ending = iban.substring(4);
        String rearranged = ending + start;
        
        return rearranged;
    }
    
    private static String convertToInteger(String iban) {
        iban = iban.replaceAll('E', '14');
        iban = iban.replaceAll('S', '28');

        return iban;
    }
    
    private static Long performModulos(String iban) {

		String part1 = iban.substring(0,9);
        Long result1 = Math.mod(Long.valueOf(part1) , Long.valueOf('97'));
       
        Integer currentPosition = 9;
        Boolean digitsRemaining = true;
        Long result = result1;
        String partN;

        while (digitsRemaining) {
            
            if (iban.length() < (currentPosition+7) ) {
                digitsRemaining = false;
            }
            
            if (digitsRemaining) {
                partN = String.valueOf(result) + iban.substring(currentPosition,currentPosition+7);
        		result = Math.mod(Long.valueOf(partN) , Long.valueOf('97') );
            } else {
                partN = String.valueOf(result) + iban.substring(currentPosition);
        		result = Math.mod(Long.valueOf(partN) , Long.valueOf('97') );
            }
            currentPosition+=7;
        }
       
        return result;
    }
}