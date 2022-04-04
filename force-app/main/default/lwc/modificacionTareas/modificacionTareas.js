import { LightningElement, track, api,wire } from 'lwc';
import getPickListValuesStatus from '@salesforce/apex/MSF_ModificacionTareasController.getPickListValuesStatus';
import getPickListValuesSubject from '@salesforce/apex/MSF_ModificacionTareasController.getPickListValuesSubject';
import submitDate from '@salesforce/apex/MSF_ModificacionTareasController.submitDate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsubOmega';
import { CurrentPageReference } from 'lightning/navigation';

export default class ModificacionTareas extends NavigationMixin(LightningElement) {

    @api infoPadre;
    @api propertyValue;
    @track datosActualizar = {Subject : '' , Status : '' , DueDate : '' , Owner : '' }
    value = '';
    @track optionsStatus;
    @track optionsSubject;
    @track message = '';
    selectedAccount;
    @track taskList;

    @wire(CurrentPageReference) pageRef;

    handleAccountSelection(event){
        this.selectedAccount = event.target.value;
    }

    connectedCallback(){
        this.getStatus();
        registerListener('messageInfoTareas', this.handleMessage, this);
    }
    getStatus(){
        getPickListValuesStatus().then(res => {
            let tempDatos = [];
            res.forEach(dato => {
                let tempDato = {};
                tempDato.value = dato;
                tempDato.label = dato;
                tempDatos.push(tempDato);
            });
            this.optionsStatus = tempDatos;
        })
        .catch(error => {
            console.error(error)
        })
        getPickListValuesSubject().then(res => {
            let tempDatos = [];
            res.forEach(dato => {
                let tempDato = {};
                tempDato.value = dato;
                tempDato.label = dato;
                tempDatos.push(tempDato);
            });
            this.optionsSubject = tempDatos;
        })
        .catch(error => {
            console.error(error)
        })
    }
    handleChange(evt) {
        this.datosActualizar[evt.currentTarget.dataset.field] = evt.target.value;
    }

    
    handleClick(){
        let PropertyValueId = [];
        Object.values(this.taskList).forEach( field => {
            let id = {};
            id = field.Id
            PropertyValueId.push(id);
        });
        
        if (this.datosActualizar.DueDate === ''){
            this.datosActualizar.DueDate = '1900-01-01';
        }
        submitDate({ Ids : PropertyValueId, Subject : this.datosActualizar.Subject, Status : this.datosActualizar.Status, DueDate : this.datosActualizar.DueDate, Owner : this.datosActualizar.Owner })
        .then( res => {
            if (res == 'success') {
                this.showToast('OK!','Tarea actualizada correctamente', 'success');
                this.navigateToMyCustomApp();
            } else {
                this.showToast('NOK!',res,'error')
            }
        })
        .catch( err => {
            var mensaje = err.body.message;
            //this.showToast('prueba',err.body,'error')
            this.showToast('',mensaje,'error')
        })
    }

    handleMessage(payload){
        this.taskList = payload;
    }

    
    navigateToMyCustomApp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Modificaciones_M_sivas_de_Tareas',
            }
        });
    }

    handleCancel(){
        this.navigateToMyCustomApp();
        }

    handleAccountSelection(event){
        this.datosActualizar.Owner = event.detail;
    }
    
    showToast(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({title: title,message: msg, variant: variant}))
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}