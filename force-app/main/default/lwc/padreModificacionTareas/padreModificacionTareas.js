import TimeZoneSidKey from '@salesforce/schema/User.TimeZoneSidKey';
import { LightningElement,api } from 'lwc';

export default class PadreModificacionTareas extends LightningElement {
    @api infoListView
    @api infoModMasivaTareas
    @api infoModificacionTareas

    connectedCallback(){
        this.infoListView = true;
        this.infoModMasivaTareas = true;
        this.infoModificacionTareas = false;
    }

    setMostrarComponente(){
        this.infoListView = false;
        this.infoModMasivaTareas = false;
        this.infoModificacionTareas = true;
    }
}