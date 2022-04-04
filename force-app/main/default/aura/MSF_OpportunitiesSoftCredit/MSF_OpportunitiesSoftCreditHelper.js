({
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        fieldName = fieldName == 'OppName' ? 'Name': fieldName;
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set('v.orderByName',fieldName);
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    },    
   /* openModal:function(cmp,id){
        cmp.set('v.isOpen',true);
        cmp.set('v.idToDelete',id);
        cmp.find("recordHandler").reloadRecord();
    },*/
    closeModal: function (cmp) {
        cmp.set('v.isOpen',false);
    },
    unrenderLoading: function(cmp) {
        var cmpTarget = cmp.find('forceModalSpinner');
        var cmpTarget = document.getElementsByClassName('forceModalSpinner')[0];        
        cmp.set("v.isLoading", false);
    },
    getData:function(component, recordId,page,nrows){
        var isSimple = component.get('v.simpleViewMode');
        var action = component.get("c.getSoftCreditOpportunities");
        action.setParams({ "Id" : recordId, "page":page,"nrows":nrows});
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataAdded = component.get('v.data');
                var returndata = response.getReturnValue();
                var totalElemCount = component.get('v.totalElemCount');

                if(isSimple){
                    totalElemCount = returndata.data.length;
                }else{
                    totalElemCount += returndata.data.length;
                }
                component.set('v.totalElemCount',totalElemCount);

                var returnedLength = returndata.moreThanReturned ? totalElemCount+'+': totalElemCount;
                component.set('v.totalElem',returnedLength);

                component.set('v.enableInfiniteLoading', returndata.moreThanReturned);
                returndata = returndata.data;
                for(var i=0; i < returndata.length; i++){
                    returndata[i].OppName = '/'+returndata[i].Id;
                    returndata[i].RecordTypeName = returndata[i].RecordType.DeveloperName;
                }
                if(dataAdded != null && !isSimple){
                    dataAdded = dataAdded.concat(returndata);
                }else{ 
                    dataAdded = returndata;
                }
                component.set('v.data', dataAdded);
                component.set("v.isLoading",false);
            } else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
    },
    getName:function(component, recordId){
        var action = component.get("c.getSoftCreditContactName");
        action.setParams({ "ids" : recordId});
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                var returndata = response.getReturnValue();
                component.set('v.recordName', returndata.Name);
            } else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
    },
    updateRow:function(data, idDestiny, newData){
        var found = false;
        for(var i = 0; i < data.length; i++){
            if(idDestiny == data[i].Id){
                found = true;
                data[i].Name = newData.Name != null ? newData.Name.value : data[i].Name;
                data[i].Amount = newData.Amount != null ? newData.Amount.value : data[i].Amount;
                data[i].StageName = newData.StageName != null ? newData.StageName.value : data[i].StageName;
                data[i].RecordTypeName = newData.RecordTypeName != null ? newData.RecordType.DeveloperName :data[i].RecordTypeName;
                data[i].npe01__Payments_Made__c = newData.npe01__Payments_Made__c != null ? newData.npe01__Payments_Made__c :data[i].npe01__Payments_Made__c;
                data[i].CloseDate = newData.CloseDate != null ? newData.CloseDate : data[i].CloseDate;
            }
        }
        return data;
    }
})