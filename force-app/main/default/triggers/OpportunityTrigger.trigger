/**
 * @description       :
 * @author            : avargas@omegacrmconsulting.com
 * @group             :
 * @last modified on  : 26-10-2021
 * @last modified by  : avargas@omegacrmconsulting.com
 * Modifications Log
 * Ver   Date         Author                            Modification
 * 1.0   26-10-2021   avargas@omegacrmconsulting.com   Initial Version
 **/
trigger OpportunityTrigger on Opportunity (before insert, before Update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //To Before Insert
        }else if(Trigger.isUpdate){
            //To Before update
            MSF_OpportunityTriggerHandler.beforeInsert(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }else if(Trigger.isAfter){
        //To After
    }
}