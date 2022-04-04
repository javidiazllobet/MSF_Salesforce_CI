/**
* @author       Deloitte
* @date         04-2020
* @group        User.
* @description  Logic of some fields and processes.
*/
global without sharing class MSF_UserLogic_TDTM extends npsp.TDTM_Runnable {
	global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
        
        //Attributes
        List<User> lNewUser = (List<User>) newlist;
        List<User> lOldUser = (List<User>) oldlist;
        Map<Id, User> mOldUser = new Map<Id, User>();
        if(lOldUser != null){            
            mOldUser.putAll(lOldUser);
        }
        
        Id adminProfileId = [select Id FROM Profile WHERE Name = 'Administrador del Sistema' OR Name = 'System Administrator' LIMIT 1].Id;
        Id userProfileId = userinfo.getProfileId();
        
        //Si el usuario es admin no le afecta el trigger
        if (userProfileId == adminProfileId) {
            return null;
        }
        else {
            Id canvasserProfileId = [select Id FROM Profile WHERE Name = 'Canvasser'].Id;
            if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
                //Solo se puede insertar un user canvasser si no lo ejecuta un admin
                for (User u : lNewUser) {
                    if (u.ProfileId != canvasserProfileId) {
                        u.addError('Perfil incorrecto.');
                    }
                }
            } 
             if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
                //Solo un admin puede modificar el perfil de un canvasser
                for (User u : lNewUser) {
                    if (mOldUser.containsKey(u.Id) && u.ProfileId != mOldUser.get(u.Id).ProfileId){
                        u.addError('No puedes modificar el perfil de un usuario.');
                    } else if(u.Id != UserInfo.getUserId() && u.ProfileId != canvasserProfileId){
                        u.addError('No puedes editar usuarios con este perfil.');
                    }
                }
            } 
        }
        
        return null;
    }
}