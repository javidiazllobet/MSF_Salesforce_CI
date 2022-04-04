import {LightningElement,wire,track,api} from 'lwc';
import getListView from '@salesforce/apex/MSF_ListViewTareasController.getListView';
import getDataListView from '@salesforce/apex/MSF_ListViewTareasController.getDataListView';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsubOmega';
import MSF_ListView from '@salesforce/label/c.MSF_ListView';
import msf_HelpTextListView from '@salesforce/label/c.msf_HelpTextListView';


export default class ListViewTareas extends LightningElement {

    @api infoPadre;
    @track activateFilters = false;
    @track idListView;
    @track optionsStatus;
    @track optionsSubject;
    @track optionListView;
    @track optionsUser;
    @track value;
    @track spinner;
    nombreTabla;
    helpText;
    numRegistros; 
    itemsLabel;
    hayMasRegistros;
    listViewLabel;
    taskList = [];
    mensaje = [];
    initialized = false;
    botonActualizacionMasiva;

    @wire(CurrentPageReference) pageRef;

    connectedCallback(){
        this.datosActualizar = [];
        this.activateFilters = false;
        this.spinner = true;
        this.getList();
    }

    getList(){
        getListView().then(res =>{
            let tempDatos = [];
            let tempDatoInicial = {};
            this.value = res.value;
            this.helpText = msf_HelpTextListView;
            this.numRegistros = res.numRegistros;
            this.itemsLabel = res.itemsLabel;
            this.hayMasRegistros = res.hayMasRegistros;
            this.listViewLabel = MSF_ListView
            this.nombreTabla = res.nombreTabla;
            this.botonActualizacionMasiva = res.botonActualizacionMasiva;

            tempDatoInicial.value = res.value;
            tempDatoInicial.label = res.label;
            tempDatos.push(tempDatoInicial);
            let defaultLV = {};
            defaultLV.value = '000000000000000000';
            defaultLV.label = '--none--';
            if (tempDatoInicial.value != defaultLV.value){
                tempDatos.push(defaultLV);
            }
            res.listListView.forEach(dato => {
                let tempDato = {};
                tempDato.value = dato.Id;
                tempDato.label = dato.Name;
                tempDato.Id = dato.Id;
                if (tempDatoInicial.value != tempDato.value){
                    tempDatos.push(tempDato);
                }
            });
            this.optionListView = tempDatos;

            if (res.listTask != null) {
                let tempTask = [];
                res.listTask.forEach(dato => {
                    let tempDato = {};
                    tempDato.Id = dato.Id;
                    tempDato.Subject = dato.Subject;
                    tempDato.ActivityDate = dato.ActivityDate;
                    tempDato.Owner = dato.Owner.Name;
                    if (dato.WhoId != null){
                        tempDato.Who = dato.Who.Name;
                    } else {
                        tempDato.Who = '';
                    }
                    tempDato.Status = dato.Status;
                    tempTask.push(tempDato);
                });
                this.taskList = tempTask;
                this.mensaje = [];
                this.mensaje.push(this.taskList);
                this.mensaje.push(this.numRegistros);
                this.mensaje.push(this.itemsLabel);
                this.mensaje.push(this.hayMasRegistros);
                this.spinner = false;
                this.sendMessage();
            } else {
                //this.showToast('No se ha encontrado ningún registro',res,'error')
            }
        })
    }

    getData(){
        this.spinner = true;
        getDataListView({Identificador : this.idListView}).then(res=> {
            if (res != null) {
                let tempDatos = [];
                if (res.listTask != null){
                    res.listTask.forEach(dato => {
                        let tempDato = {};
                        tempDato.Id = dato.Id;
                        tempDato.Subject = dato.Subject;
                        tempDato.ActivityDate = dato.ActivityDate;
                        tempDato.Owner = dato.Owner.Name;
                        tempDato.Status = dato.Status;
                        tempDatos.push(tempDato);
                    });
                }
                this.taskList = tempDatos;
                this.mensaje = [];
                this.mensaje.push(this.taskList);
                this.mensaje.push(this.numRegistros);
                this.mensaje.push(this.itemsLabel);
                this.hayMasRegistros = res.hayMasRegistros;
                this.mensaje.push(this.hayMasRegistros);
                this.spinner = false;
                this.sendMessage();
            } else {
                //this.showToast('No se ha encontrado ningún registro',res,'error')
            }
        })
        .catch( err => {
            this.optionListView = this.optionListView;
            this.showToast('KO!',err.body.message,'error')
        })
    }

    handleChange(evt) {
        this.idListView = evt.target.value;
        this.getData();
    }

    showToast(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({title: title,message: msg, variant: variant}))
    }

    sendMessage() {
        fireEvent(this.pageRef, 'messageAppEvent', this.mensaje);
        }
}