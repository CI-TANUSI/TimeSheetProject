import { LightningElement, api, track } from 'lwc';
import getTeamProductivity from '@salesforce/apex/TimeSheetTeamProductivity.getTeamProductivity';

export default class TeamProductivity extends LightningElement {
    @api personId; // Pass the current user's personId if needed
    @track selectedYear = new Date().getFullYear();
    @track selectedPerson = 'All';
    @track yearOptions = [];
    @track personOptions = [{ label: 'All', value: 'All' }];
    @track rows = [];
    @track team = [];

    connectedCallback() {
        this.initYearOptions();
        this.fetchData();
         
    }

    initYearOptions() {
        const thisYear = new Date().getFullYear();
        this.yearOptions = [];
        for (let y = thisYear; y >= thisYear - 5; y--) {
            this.yearOptions.push({ label: y.toString(), value: y });
        }
    }

    handleYearChange(event) {
        this.selectedYear = parseInt(event.target.value, 10);
        this.fetchData();
    }

    handlePersonChange(event) {
        this.selectedPerson = event.target.value;
        this.fetchData();
    }

    fetchData() {
        getTeamProductivity({ year: this.selectedYear, personId: this.personId })
            .then(data => {
                this.rows = (data.rows || []).map(row => ({
                    ...row,
                    monthName: this.getMonthName(row.month),
                    key: `${row.personId || ''}_${row.month}`
                }));
                this.team = data.team || [];
                // Add ALL option at the top
                this.personOptions = [
                    { label: 'ALL', value: 'All' },
                    ...this.team.map(p => ({ label: p.name, value: p.id }))
                ];
                // If selectedPerson is not in the new options, reset to ALL
                if (!this.personOptions.some(opt => opt.value === this.selectedPerson)) {
                    this.selectedPerson = 'All';
                }
            })
            .catch(() => {
                this.rows = [];
                this.team = [];
                this.personOptions = [{ label: 'ALL', value: 'All' }];
            });
    }

    get isAllSelected() {
        return this.selectedPerson === 'All';
    }

    getMonthName(monthNum) {
        return new Date(this.selectedYear, monthNum - 1).toLocaleString('default', { month: 'short' });
    }

    get tableRows() {
        if (this.selectedPerson === 'All') {
            // Sum productivity for all people for each month
            const monthMap = {};
            this.rows.forEach(row => {
                const m = row.month;
                if (!monthMap[m]) {
                    monthMap[m] = {
                        month: m,
                        monthName: row.monthName,
                        filled: 0,
                        approved: 0,
                        unapproved: 0,
                        tempApproved: 0,
                        blank: 0
                    };
                }
                monthMap[m].filled += row.filled;
                monthMap[m].approved += row.approved;
                monthMap[m].unapproved += row.unapproved;
                monthMap[m].tempApproved += row.tempApproved;
                monthMap[m].blank += row.blank;
            });
            // Return one row per month, sorted by month, with values formatted to 2 decimals
            return Object.values(monthMap)
                .sort((a, b) => a.month - b.month)
                .map(row => ({
                    ...row,
                    filled: Number(row.filled).toFixed(2),
                    approved: Number(row.approved).toFixed(2),
                    unapproved: Number(row.unapproved).toFixed(2),
                    tempApproved: Number(row.tempApproved).toFixed(2),
                    blank: Number(row.blank).toFixed(2)
                }));
        } else {
            // Only show rows for the selected person
            return this.rows
                .filter(row => row.personId === this.selectedPerson)
                .map(row => ({
                    ...row,
                    filled: Number(row.filled).toFixed(2),
                    approved: Number(row.approved).toFixed(2),
                    unapproved: Number(row.unapproved).toFixed(2),
                    tempApproved: Number(row.tempApproved).toFixed(2),
                    blank: Number(row.blank).toFixed(2)
                }));
        }
    }
}