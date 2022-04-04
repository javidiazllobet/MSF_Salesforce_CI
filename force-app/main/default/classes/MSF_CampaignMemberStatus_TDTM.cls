global without sharing class MSF_CampaignMemberStatus_TDTM extends npsp.TDTM_Runnable{
	global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        
        List<CampaignMember> lNewCm = (List<CampaignMember>) newlist;        
        List<CampaignMember> lOldCm = (List<CampaignMember>) oldlist;
        Map<Id, CampaignMember> mOldCm = new Map<Id, CampaignMember>();
        if(lOldCm != null){            
            mOldCm.putAll(lOldCm);
        }
        
        //Before Update; 
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            for (CampaignMember cm : lNewCm) {
                if (mOldCm.get(cm.Id).Status == 'Respondida (cerrada)') {
                    cm.Status = 'Respondida (cerrada)';
                }
            }
        }
        
        return null; 
    }
}