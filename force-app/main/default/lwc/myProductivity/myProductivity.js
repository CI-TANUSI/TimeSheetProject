import { LightningElement, api, track } from 'lwc';
import getYearlyProductivity from '@salesforce/apex/TimeSheetPersonProductivity.getYearlyProductivity';

export default class MyProductivity extends LightningElement {
    @api personId; // Pass this from parent if needed
    @track selectedYear = new Date().getFullYear();
    @track summaryRows = [];
    @track yearOptions = [];

    connectedCallback() {
        this.initYearOptions();
        this.fetchSummary();
    }

    initYearOptions() {
        const thisYear = new Date().getFullYear();
        this.yearOptions = [];
        for (let y = thisYear; y >= thisYear - 5; y--) {
            this.yearOptions.push(y);
        }
    }

    handleYearChange(event) {
        this.selectedYear = parseInt(event.target.value, 10);
        this.fetchSummary();
    }

    fetchSummary() {
        getYearlyProductivity({ personId: this.personId, year: this.selectedYear })
            .then(data => {
                this.summaryRows = (data || []).map(row => ({
                    ...row,
                    monthName: this.getMonthName(row.month)
                }));
            })
            .catch(() => { this.summaryRows = []; });
    }

    getMonthName(monthNum) {
        return new Date(this.selectedYear, monthNum - 1).toLocaleString('default', { month: 'short' });
    }
}