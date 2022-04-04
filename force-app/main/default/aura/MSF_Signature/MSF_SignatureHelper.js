({
    
    doInit: function(component, event, helper) {        
        
        var canvas, ctx, flag = false,            
            prevX = 0,            
            currX = 0,            
            prevY = 0,            
            currY = 0,            
            dot_flag = false;        
        
        var x = "black", y = 2, w, h;
        
        canvas = component.find('can').getElement();
        
        var ratio = Math.max(window.devicePixelRatio || 1, 1);
        
        w = canvas.width * ratio;        
        h = canvas.height * ratio;
        
        ctx= canvas.getContext("2d");        
        console.log('ctx:='+ctx);           
        
        canvas.addEventListener("mousemove", function (e) {            
            findxy('move', e)            
        },false);
        
        canvas.addEventListener("mousedown", function (e) {            
            findxy('down', e)            
        },false);
        
        canvas.addEventListener("mouseup", function (e) {            
            findxy('up', e)            
        },false);
        
        canvas.addEventListener("mouseout", function (e) {            
            findxy('out', e)            
        },false);
         
        // Set up touchevents for mobile, etc        
        canvas.addEventListener("touchstart", function (e) {
            var touch = e.touches[0];            
            var mouseEvent = new MouseEvent("mousedown", {                
                clientX: touch.clientX,                
                clientY: touch.clientY                
            });
            
            canvas.dispatchEvent(mouseEvent);            
            e.preventDefault();
            ///////////////
			e.stopPropagation();  
        },false);
        
        canvas.addEventListener("touchend", function (e) {   
            var mouseEvent = new MouseEvent("mouseup", {});            
            canvas.dispatchEvent(mouseEvent);            
        },false);
        
        canvas.addEventListener("touchmove", function (e) {            
            var touch = e.touches[0];            
            var mouseEvent = new MouseEvent("mousemove", {                
                clientX: touch.clientX,                
                clientY: touch.clientY                
            });
            
            canvas.dispatchEvent(mouseEvent);            
            e.preventDefault();
        },false);
        
        // Get theposition of a touch relative to the canvas        
        function getTouchPos(canvasDom, touchEvent){            
            var rect = canvasDom.getBoundingClientRect();            
            return {                
                x: touchEvent.touches[0].clientX - rect.left,                
                y: touchEvent.touches[0].clientY - rect.top                
            };            
        }
        
        function findxy(res, e){            
            const rect = canvas.getBoundingClientRect();
            
            if (res == 'down') {                
                prevX = currX;                
                prevY = currY;                
                currX = e.clientX - rect.left ;                
                currY = e.clientY - rect.top;
                flag = true;                
                dot_flag = true;
                
                if (dot_flag) {                    
                    ctx.beginPath();                    
                    ctx.fillStyle = x;                    
                    ctx.fillRect(currX, currY, 2, 2);                    
                    ctx.closePath();                    
                    dot_flag = false;                    
                }                
            }
            
            if (res == 'up' || res == "out") {                
                flag = false;                
            }
            
            if (res == 'move') {                
                if (flag) {                    
                    prevX = currX;                    
                    prevY = currY;                    
                    currX = e.clientX - rect.left;                    
                    currY = e.clientY - rect.top;                    
                    draw(component,ctx);                    
                }                
            }            
        }
        
        function draw() {            
            ctx.beginPath();            
            ctx.moveTo(prevX, prevY);            
            ctx.lineTo(currX, currY);            
            ctx.strokeStyle = x;            
            ctx.lineWidth = y;            
            ctx.stroke();            
            ctx.closePath();  
            component.set('v.signatureInformed',true);   
        }
    },
    
    eraseHelper: function(component, event, helper){        
        component.set('v.signatureInformed',false);
        
        /*var m = confirm("Want to clear");        
        if(m) {   */         
            var canvas=component.find('can').getElement();            
            var ctx = canvas.getContext("2d");            
            var w = canvas.width;            
            var h = canvas.height;            
            ctx.clearRect(0, 0, w, h);            
        //}  
    },
    
    dateConverter : function(){
        var value = new Date();
        return this.fixDigit(value.getDate())+"-"+(this.fixDigit(value.getMonth() + 1))+"-"+value.getFullYear();
    },
    
    fixDigit : function(val){
    return val.toString().length === 1 ? "0" + val : val;
  },
    
    saveHelper:function(component, event, helper){        
        var pad=component.find('can').getElement();        
        var dataUrl = pad.toDataURL();              
        var strDataURI = dataUrl.replace(/^data:image\/(png|jpg);base64,/, "");        
        var action = component.get("c.saveSignature"); 
        
        action.setParams({             
            signatureBody : strDataURI,
            signatureName : component.get('v.signatureName')+"_"+this.dateConverter(),
            signatureIdMember : component.get('v.signatureIdMember')
        });
        
        action.setCallback(this,function(res){            
            var state = res.getState();             
            if(!(state==="SUCCESS")){                
                this.showToast('Firma no creada','Error al crear la firma: '+signatureName,'Error');                                 
            }           
        });
        
        $A.enqueueAction(action);        
    },
    
    showToast : function(title, msg, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type,
            "mode" : 'dismissible'
        });
        toastEvent.fire();
    },
    
})