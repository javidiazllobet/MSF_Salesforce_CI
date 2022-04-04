({
	handleClick : function(component, event, helper) {
		let recordId = component.get('v.recordId');
        window.location.href = '/' + recordId;
	}
})