import { LightningElement ,api, wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsubOmega';
import { fireEvent } from 'c/pubsubOmega';
import MSF_TaskSubject from '@salesforce/label/c.MSF_TaskSubject';
import MSF_DueDates from '@salesforce/label/c.MSF_DueDates';
import MSF_TaskStatus from '@salesforce/label/c.MSF_TaskStatus';
import MSF_Who from '@salesforce/label/c.MSF_Who';
import MSF_TaskOwner from '@salesforce/label/c.MSF_TaskOwner';
import MSF_NombreTabla from '@salesforce/label/c.MSF_NombreTabla';
import MSF_ActualizacionMasivaTareas from '@salesforce/label/c.MSF_ActualizacionMasivaTareas';


export default class ModificacionMasivaTareas extends NavigationMixin(LightningElement) {
 
    @api infoPadre;
    mostrarComponente;
    tableElement;
    @track totalRecords;
    loadMoreStatus;
    @api totalNumberOfRows;
    ofListView;
    idListView;
    finalTaskList;
    @track isLoaded = true;
    numRegistros;
    itemsLabel;
    mensaje = [];
    @track nombreTabla;
    espacios = "    ";
    @track botonActualizacionMasiva;
    @track prueba;

    @api recordId;
    @track columns = [{
        label: MSF_TaskSubject,
        fieldName: 'Subject',
        type: 'text',
        sortable: true,
        editable: false
    },
    {
        label: MSF_DueDates,
        fieldName: 'ActivityDate',
        type: 'text',
        sortable: true,
        editable: false
    },
    {
        label: MSF_TaskStatus,
        fieldName: 'Status',
        type: 'text',
        sortable: true,
        editable: false
    },
    {
        label: MSF_Who,
        fieldName: 'Who',
        type: 'text',
        sortable: true,
        editable: false
    },
    {
        label: MSF_TaskOwner,
        fieldName: 'Owner',
        type: 'text',
        sortable: true,
        editable: false
    },
    ];
    @track taskList;

    @wire(CurrentPageReference) pageRef;


    connectedCallback() {
        this.prueba = 'prueba';
        registerListener('messageAppEvent', this.handleMessage, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
 
    handleMessage(payload){
        this.ofListView = true;
        this.taskListAll = payload[0];
        if (this.taskListAll.length < payload[1]){
            this.numRegistros = this.taskListAll.length;
        } else {
            this.numRegistros = payload[1];
        }
        this.itemsLabel = payload[2];
        if (this.tableElement != null){
            this.tableElement.enableInfiniteLoading = true;
        }
        let tempDatos = [];
        if (this.taskListAll.length > 0){

            for (let i = 0; i < this.numRegistros; i++) {
                let tempDato = {};
                tempDato.Id = this.taskListAll[i].Id;
                this.idListView = this.taskListAll[i].Id;
                tempDato.Subject = this.taskListAll[i].Subject;
                tempDato.ActivityDate = this.taskListAll[i].ActivityDate;
                tempDato.Owner = this.taskListAll[i].Owner;
                tempDato.Who = this.taskListAll[i].Who;
                tempDato.Status = this.taskListAll[i].Status;
                tempDatos.push(tempDato);
            }
            this.taskList = tempDatos;
            this.totalNumberOfRows = this.taskListAll.length;
            if (payload[3]){
                this.totalRecords = this.taskList.length + '+';
            }else {
                this.totalRecords = this.taskList.length;
            }            
        } else {
            this.totalRecords = 0;
            this.taskList = [];
        }
        this.nombreTabla = MSF_NombreTabla;
        this.botonActualizacionMasiva = MSF_ActualizacionMasivaTareas;
        
    }

    getDataListView(){
            let tempDatos = [];
            this.finalTaskList = false;
            this.loadMoreStatus = 'Loading';
            const currentRecord = this.taskList;
            let indexFinal = 0;
            
            for (let i = 0; i < this.totalNumberOfRows; i++) {
                if (indexFinal != 0){
                    let tempDato = {};
                    tempDato.Id = this.taskListAll[i].Id;
                    tempDato.Subject = this.taskListAll[i].Subject;
                    tempDato.ActivityDate = this.taskListAll[i].ActivityDate;
                    tempDato.Owner = this.taskListAll[i].Owner;
                    tempDato.Who = this.taskListAll[i].Who;
                    tempDato.Status = this.taskListAll[i].Status;
                    tempDatos.push(tempDato);
                    if (indexFinal == i){
                        this.idListView = this.taskListAll[i].Id;
                        break;
                    }
                }
                if (this.taskListAll[i].Id == this.idListView){
                    indexFinal = i + this.numRegistros;
                }
                
            }
            const currentData = tempDatos;
            //Appends new data to the end of the table
            const newData = currentRecord.concat(currentData);
            this.taskList = newData; 
            if (this.taskList.length < this.totalNumberOfRows){
                this.totalRecords = this.taskList.length + '+';
            }else {
                this.totalRecords = this.taskList.length;
            }
            if (this.taskList.length >= this.totalNumberOfRows) {
                this.finalTaskList = true;
                this.loadMoreStatus = 'No more data to load';
            } else {
                this.loadMoreStatus = '';
            }
        
    }

    handleclick(){
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();
        this.mensaje = selected;
        this.mostrarComponente = false;
        fireEvent(this.pageRef, 'messageInfoTareas', this.mensaje);
        this.dispatchEvent(new CustomEvent('selectcomponente', {detail: this.mostrarComponente}));
    }

    handleSortAccountData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortAccountData(event.detail.fieldName, event.detail.sortDirection);
    }


    sortAccountData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.taskList));
        let keyValue = (a) => {
            return a[fieldname];
        };
       let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        this.taskList = parseData;
    }
}