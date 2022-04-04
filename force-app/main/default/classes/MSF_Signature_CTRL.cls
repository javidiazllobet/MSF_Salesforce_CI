/**
* @author       Deloitte
* @date         12-2018
* @group        Signature
* @description  Controller for the lightning component MSF_Signature
*/
public without sharing class MSF_Signature_CTRL {
   
    @AuraEnabled    
    public static boolean saveSignature(String signatureBody, String signatureName, ID signatureIdMember){                
        
        if(signatureName == null){
        	signatureName = 'Firma_';    
        }    
        
        if(signatureIdMember != null){            
            try{
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; 									// S specify this document is in SF, use E for external files
                conVer.PathOnClient = signatureName +'.jpg'; 					// The files name, extension is very important here which will help the file in preview.
                conVer.Title = signatureName; 									// Display name of the files
                conVer.VersionData = EncodingUtil.base64Decode(signatureBody); 	// converting your binary string to Blob
                insert conVer;
                
                try{
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    
                    ContentDocumentLink CDL = new ContentDocumentLink();
                    CDL.ContentDocumentId = conDoc;
                    CDL.LinkedEntityId = signatureIdMember;	// you can use objectId,GroupId etc
                    CDL.ShareType = 'I'; 					// Inferred permission, checkout description of ContentDocumentLink object for more details
                    insert CDL;
                    
                    return true;                
                }catch(Exception ex){
                    System.debug('Error al adjuntar la firma al miembro: '+ex.getMessage()); 
                    return false;
                }            
            }catch(Exception ex){
                System.debug('Error al generar la firma: '+ex.getMessage());    
                return false;
            }     
        }  
        
        System.debug('No se ha recibido el id del donante correctamente.');   
        return false;
    }
}