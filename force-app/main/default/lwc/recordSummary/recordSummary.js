import { LightningElement, api, wire } from 'lwc';
import getSummary from '@salesforce/apex/OpportunitySummary.getSummary';

export default class RecordSummary extends LightningElement {
    @api recordId;
    summary = {};
    error;

    @wire(getSummary, { recordId: '$recordId' })
    wiredSummary({ error, data }) {
        if (data) {
            this.summary = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.summary = {};
        }
    }
}