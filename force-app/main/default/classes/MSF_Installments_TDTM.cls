/**
* @author 		Deloitte
* @date 		05-2019
* @group 		Payment Profile
* @description	Trigger Handler that create GDPR logs
*/
global without sharing class MSF_Installments_TDTM extends npsp.TDTM_Runnable{
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {    
        
        List<cpm__Installment__c> lNewInstallments = (List<cpm__Installment__c>) newlist;      
        List<cpm__Installment__c> lOldInstallments = (List<cpm__Installment__c>) oldlist;
        Map<Id, cpm__Installment__c> mOldInstallments = new Map<Id, cpm__Installment__c>();
        if(lOldInstallments != null){            
            mOldInstallments.putAll(lOldInstallments);
        }   
        List<Opportunity> lOppsToUpdate = new List<Opportunity>();
        List<npsp__Allocation__c> gauAllocationsToInsert = new List<npsp__Allocation__c>(); 
        
        //Comprobar si se pueden modificar los installments;  
        Boolean canUpdate = true;
        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate || triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
            canUpdate = checkCanUpdate(lNewInstallments, mOldInstallments);
        }
        if (canUpdate == false) {
            return null;
        }
        
        List<Id> instOppsIds = new List<Id>();
        for (cpm__Installment__c installment : lNewInstallments) {
            if (installment.npsp4hub__Opportunity__c != null) {
                instOppsIds.add(installment.npsp4hub__Opportunity__c);
            }
        }
        
        Map<Id, Opportunity> mOpps = new Map<Id, Opportunity>();
        mOpps.putAll([SELECT Id, Amount, npe03__Recurring_Donation__c, StageName, isClosed, msf_LastReasonCodeReceived__c, msf_LastReversalDate__c, msf_NTimesReversed__c 
                      FROM Opportunity WHERE Id IN :instOppsIds]);   
        
        
        /*** BEFORE UPDATE ***/
        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate || triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
            for (cpm__Installment__c installment : lNewInstallments) {         
                cpm__Installment__c oldInst = mOldInstallments.get(installment.id);
                Opportunity opp = mOpps.get(installment.npsp4hub__Opportunity__c);
                Boolean updateInstallment = false; 
                if (opp != null) {
                    Double nTimesReversed = 0; 
                    if (installment.cpm__Payment_Method__c == 'CreditCard'){
                        nTimesReversed = getNtimesReversed(installment);
                    }
                    else{
                        nTimesReversed = installment.cpm__of_times_rejected__c;
                    }
                    
                    if (opp.npe03__Recurring_Donation__c != null) {
                        if (nTimesReversed < 3) {
                            updateInstallment = true; 
                        }
                    }
                    else {
                        if (nTimesReversed < 2) {
                            updateInstallment = true;  
                        }
                    }
                    
                    if (installment.cpm__Payment_Method__c == 'CreditCard' && opp.IsClosed == false && updateInstallment == true) {
                        if (oldInst!=null &&
                            (  oldInst.cpm__of_times_failed__c   != installment.cpm__of_times_failed__c
                            || oldInst.cpm__of_times_refunded__c != installment.cpm__of_times_refunded__c
                            || oldInst.cpm__of_times_reversed__c != installment.cpm__of_times_reversed__c)) {
                                installment.cpm__Status__c = 'New';
                            }
                    }
                    
                    if (installment.cpm__Payment_Method__c == 'Direct Debit' && installment.cpm__Last_ReasonCode_Received__c != null && updateInstallment == true) {
                        if (installment.cpm__Last_ReasonCode_Received__c == 'AM04' && installment.cpm__Status__c == 'Rejected') {
                            installment.cpm__Status__c = 'Pending recollection'; 
                        }
                    } 
                }  
            }
        }
        
        
        //AFTER INSERT && AFTER UPDATE; 
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate || triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
            
            List<npsp__Allocation__c> allocations = [SELECT Id, npsp__Opportunity__c FROM npsp__Allocation__c
                                                           WHERE npsp__Opportunity__c IN :mOpps.keyset()];
            Map<Id, npsp__Allocation__c> allocationsByOpp = new Map<Id, npsp__Allocation__c>(); 
            for (npsp__Allocation__c allocation : allocations) {
                Id oppId = allocation.npsp__Opportunity__c;
                allocationsByOpp.put(oppId , allocation);
            }
                       
            for (cpm__Installment__c installment : lNewInstallments) {
                cpm__Installment__c oldInst = mOldInstallments.get(installment.id);
                Opportunity opp = mOpps.get(installment.npsp4hub__Opportunity__c);
                Boolean updateOpp = false;               
                
                 
                if (opp != null) {     
                    if (installment.msf_LeadSource__c != null) {
                        opp.LeadSource = installment.msf_LeadSource__c; 
                        updateOpp = true; 
                    }
                    
                    if (installment.msf_Description__c != null) {
                        opp.Description = installment.msf_Description__c; 
                        updateOpp = true; 
                    }
                    
                    if (installment.msf_GAU__c != null && allocationsByOpp.get(opp.Id) == null) {
                        Id gau = installment.msf_GAU__c; 
                        npsp__Allocation__c gauAll = new npsp__Allocation__c();
                        gauAll.npsp__Amount__c = opp.Amount;
                        gauAll.npsp__General_Accounting_Unit__c = gau;
                        gauAll.npsp__Opportunity__c = opp.Id;
                        gauAllocationsToInsert.add(gauAll);
                    }
                    
                    if (oldInst != null) {
                        
                        Date t = getMaxLastReversalDate(installment);
                        if (t != opp.msf_LastReversalDate__c) {
                            opp.msf_LastReversalDate__c = t; 
                            updateOpp = true; 
                        }
                        
                        if (installment.cpm__Payment_Method__c == 'CreditCard') {
                            if (opp.IsClosed == false) {
                                if (  oldInst.cpm__of_times_failed__c   != installment.cpm__of_times_failed__c
                                    || oldInst.cpm__of_times_refunded__c != installment.cpm__of_times_refunded__c
                                    || oldInst.cpm__of_times_reversed__c != installment.cpm__of_times_reversed__c) {
                                        opp.StageName = 'Devuelta'; 
                                    }
                            }
                            opp.msf_LastReasonCodeReceived__c = installment.cpm__Last_Status_Reason__c;
                            opp.msf_NTimesReversed__c = getNTimesReversed(installment);
                            updateOpp = true; 
                        }
                        else {
                            
                            if (oldInst.cpm__of_times_rejected__c != installment.cpm__of_times_rejected__c || opp.msf_NTimesReversed__c!=installment.cpm__of_times_rejected__c) {
                                opp.msf_LastReasonCodeReceived__c = installment.cpm__Last_ReasonCode_Received__c;
                                opp.msf_NTimesReversed__c = installment.cpm__of_times_rejected__c;
                                updateOpp = true;  
                            }
                            
                            if (installment.cpm__Last_ReasonCode_Received__c != null) {
                                if (installment.cpm__Last_ReasonCode_Received__c != 'AM04' && 
                                    (installment.cpm__Status__c != 'New' && installment.cpm__Status__c != 'Pending recollection' && installment.cpm__Status__c != 'Collected')) {
                                        opp.StageName = 'Impagada'; 
                                        updateOpp = true; 
                                    }
                            }
                            
                        }                        
                    }
                    //System.debug('old'+oldInst.cpm__of_times_rejected__c);
                    //System.debug('new'+installment.cpm__of_times_rejected__c);
                    if (opp.npe03__Recurring_Donation__c != null) {
                        if ((oldInst == null || oldInst.cpm__of_times_rejected__c != installment.cpm__of_times_rejected__c 
                                    ||   oldInst.cpm__of_times_failed__c   != installment.cpm__of_times_failed__c
                                    || oldInst.cpm__of_times_refunded__c != installment.cpm__of_times_refunded__c
                                    || oldInst.cpm__of_times_reversed__c != installment.cpm__of_times_reversed__c) &&
                            opp.msf_NTimesReversed__c >= 3 && installment.cpm__Status__c != 'Collected') {
                            opp.StageName = 'Impagada'; 
                            updateOpp = true;
                        }
                    }
                    else {
                        if ((oldInst == null || oldInst.cpm__of_times_rejected__c != installment.cpm__of_times_rejected__c
                                    ||   oldInst.cpm__of_times_failed__c   != installment.cpm__of_times_failed__c
                                    || oldInst.cpm__of_times_refunded__c != installment.cpm__of_times_refunded__c
                                    || oldInst.cpm__of_times_reversed__c != installment.cpm__of_times_reversed__c) &&
                            opp.msf_NTimesReversed__c >= 2 && installment.cpm__Status__c != 'Collected') {
                            opp.StageName = 'Impagada';
                            updateOpp = true;
                        }
                    }
                    
                    
                    if (updateOpp == true && opp != null) {
                        lOppsToUpdate.add(opp);
                    }
                    
                }
            }
        }   
        
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        
        if (lOppsToUpdate.isEmpty() == false) {
            dmlWrapper.objectsToUpdate.addAll((List<Opportunity>) lOppsToUpdate);
        }
        if (gauAllocationsToInsert.isEmpty() == false) {
            dmlWrapper.objectsToInsert.addAll((List<npsp__Allocation__c>) gauAllocationsToInsert);
        }
        
        return dmlWrapper;
        
        //return null; 
    }
    
    
    private static Boolean checkCanUpdate(List<cpm__Installment__c> lNewInstallments, Map<Id, cpm__Installment__c> mOldInstallments) {
        Boolean canUpdate = true; 
        
        Id profileId = UserInfo.getProfileId();
        
        Boolean isAdmin = [SELECT PermissionsModifyAllData FROM Profile WHERE Id =: profileId].PermissionsModifyAllData;
        Boolean bEcoUser = [SELECT Id, msf_EconomicProcessUser__c FROM User WHERE Id =: UserInfo.getUserId()].msf_EconomicProcessUser__c;
        
        if (isAdmin == false && bEcoUser == false) {
            
            //PaymentSchedules;
            List<String> paymentSchedulesStatus = new List<String>{'Done'}; 
                List<cpm__Payment_Schedule__c> paymentSchedulesList = [SELECT Id, cpm__Status__c, cpm__PaymentMethod__c, cpm__Selection_Date__c FROM cpm__Payment_Schedule__c WHERE cpm__Status__c NOT IN :paymentSchedulesStatus]; 
            
            if (paymentSchedulesList.isEmpty() == false) {
                for (cpm__Installment__c installment : lNewInstallments) {
                    cpm__Installment__c oldInstallment = mOldInstallments.get(installment.id);
                    if (oldInstallment == null) { oldInstallment = installment; }
                    
                    if (oldInstallment.cpm__Status__c.equals('New') || oldInstallment.cpm__Status__c.equals('Pending recollection') ||
                        installment.cpm__Status__c.equals('New')    || installment.cpm__Status__c.equals('Pending recollection')) {  
                        for (cpm__Payment_Schedule__c ps : paymentSchedulesList) {
                            if ((oldInstallment.cpm__Due_Date__c <= ps.cpm__Selection_Date__c && oldInstallment.cpm__Payment_Method__c == ps.cpm__PaymentMethod__c) ||
                                (installment.cpm__Due_Date__c <= ps.cpm__Selection_Date__c && installment.cpm__Payment_Method__c == ps.cpm__PaymentMethod__c)) {
                                canUpdate = false; 
                                installment.addError(System.Label.MSF_INSTALLMENT_BLOCKED);    
                            }
                        }
                    }
                }
            }
        }
        
        return canUpdate; 
    }
    
    
    
    private static double getNtimesReversed(cpm__Installment__c installment) {
        Double ret = 0; 
        List<Double> toSum = new List<Double>();
        toSum.add(installment.cpm__of_times_failed__c);
        toSum.add(installment.cpm__of_times_refunded__c);
        toSum.add(installment.cpm__of_times_reversed__c);
        
        for (Double n : toSum) {
            if (n != null) {
                ret += n; 
            }
        }
        
        return ret; 
    } 
    
    private static Date getMaxLastReversalDate(cpm__Installment__c installment) {
        Date ret = null; 
        List<Date> dates = new List<Date>(); 
        dates.add(installment.cpm__Last_Failed_Date__c);
        dates.add(installment.cpm__Last_Refunded_Date__c);
        dates.add(installment.cpm__Last_Reversal_Date__c);
        dates.add(installment.cpm__Last_Rejection_Date__c);
        
        dates.sort();
        ret = dates[dates.size() - 1];
        
        return ret; 
    }
    
}