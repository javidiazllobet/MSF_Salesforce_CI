({
	init: function (component, event, helper) {
        helper.getIncompletes(component, event, helper);
        
        var actions = [
            { label: 'Completar', name: 'complete' },
            { label: 'Eliminar', name: 'delete' }
        ];
        component.set('v.columns', [{label: 'Fecha de contacto', fieldName: 'msf_ContactDate__c', type: 'date', sortable: true,
                                     typeAttributes:{
                                         year: "numeric",
                                         month: "2-digit",
                                         day: "2-digit",
                                         hour: "2-digit",
                                         minute: "2-digit"
                                     }},
            						{label: 'Nombre', fieldName: 'Name', type: 'text', sortable: true},
                                    {label: 'Organización', fieldName: 'msf_esOrganizacion__c', type: 'boolean'},
                                    {label: 'Teléfono móvil', fieldName: 'MobilePhone', type: 'text'},
                                    {type: 'action', typeAttributes: {rowActions: actions} }
        ]);
        
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'complete':
                helper.goToForm(component, event, row);
            break;
            case 'delete':
                helper.removeIncomplete(component, row);
            break;
        }
    },
    
    updateColumnSorting: function (component, event, helper) {
        component.set('v.spinnerDelete', true);

        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        
        helper.sortData(component, fieldName, sortDirection);
        component.set('v.spinnerDelete', false);
    },
})