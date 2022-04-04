({
	closeButton : function(component, event, helper) {
		var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Opportunity"
        });
        homeEvt.fire();
    }
})