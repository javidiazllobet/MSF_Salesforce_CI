({
    // Your renderer method overrides go here
    afterRender: function(component, helper){
        this.superAfterRender();
        
        
        //Para evitar el PullToRefresh en el formulario; 
        //Ids of MSF_Signature components; 
        let signaturesIds = ['sigDonorCmp', 'sigHolderCmp', 'sigRepCmp', 'sigDonorIncQuoCmp'];

        let getSignatureComponents = function() {
            let ret = [];
            for (let i = 0; i < signaturesIds.length; i++) {
                let key = signaturesIds[i];
                let c = component.find(key);
                if (typeof c !== "undefined") {
                    ret.push(c.getElement());   
                }
            }
            return ret; 
        }
        
        let isPointerEventInsideSignature = function (event) {
            let ret = false; 
            let i = 0;
            let signaturesComponents = getSignatureComponents();
            let pos = {
                x: event.targetTouches ? event.targetTouches[0].pageX : event.pageX,
                y: event.targetTouches ? event.targetTouches[0].pageY : event.pageY
            };
            
            do {
                let c = signaturesComponents[i];
                var rect = c.getBoundingClientRect();
                ret = pos.x < rect.right && pos.x > rect.left && pos.y < rect.bottom && pos.y > rect.top;
                i++; 
            }while(ret == false && i < signaturesComponents.length);
            
            return ret; 
        };
        

        let targetEl = component.find("mainContainer").getElement();
        targetEl.addEventListener(
            "touchmove", 
            function _listener(e) {
                let inside = isPointerEventInsideSignature(e);
                if (!inside) {
                    e.stopPropagation();
                } 
            },
            true 
        );
    }
})