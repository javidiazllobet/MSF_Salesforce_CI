({     
    doInit: function(component, event, helper) { 
       
        helper.closeQuickAction();
        
        // Navigate to Data entry
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__MSF_FormDataEntry',
            },
            state: {
                "c__recordId": component.get('v.recordId'),
            }
        };
        
        var workspaceAPI = component.find("workspace");
        var navService = component.find("navService");

        workspaceAPI
        .isConsoleNavigation()
        .then(function(isConsole) {
            if (isConsole) {
                navService.generateUrl(pageReference).then(function(cmpURL) {
                    var focusedTabId;
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
            			focusedTabId = response.tabId;
                    workspaceAPI
                    .getEnclosingTabId()
                    .then(function(tabId) {
                        return workspaceAPI.openSubtab({
                            parentTabId: focusedTabId,
                            url: cmpURL,
                            focus: true
                        });
                    })
                    .then(function(subTabId) {
                        console.log("subTabId->",subTabId);
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: $A.get("$Label.c.MSF_FORM_DE_LABEL_TAB_CONSOLE")
                        });
                    });
                    
                   }); 
                    
                });
            } else {
                navService.navigate(pageReference, false);// this is standard navigation, use the navigate method to open the component
            }
        })
        .catch(function(error) {
            console.log(error);
        });

    },
})