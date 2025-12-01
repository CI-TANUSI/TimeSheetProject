import { LightningElement, track, api, wire } from 'lwc';
import getHomeSummary from '@salesforce/apex/TimeSheetSummary.getHomeSummary';
import getFilledHoursByDate from '@salesforce/apex/TimeSheetSummary.getFilledHoursByDate';

export default class HomeSummary extends LightningElement {
    @api personId; // Person Id passed from parent
    @track startDate;
    @track endDate;
    @track summary = {};
    @track summaryLoaded = false;
    @track filledHoursPercentage = 0;
    @track calendarYear;
    @track calendarMonth;
    @track filledHoursByDate = {};
    

    // Set default dates and fetch summary on component load
    connectedCallback() {
        const today = new Date();
        this.calendarYear = today.getFullYear();
        this.calendarMonth = today.getMonth() + 1; // JS months are 0-based
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        this.startDate = firstDay.toISOString().slice(0, 10);
        this.endDate = today.toISOString().slice(0, 10);
        this.getSummary();
        this.fetchCalendarData(this.calendarYear, this.calendarMonth);
    }

   
    // Handle start date change - only update the value, don't fetch data
    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }
    
    // Handle end date change - only update the value, don't fetch data
    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    // Handle Go button click - fetch filtered data
    handleGoButtonClick() {
        this.getSummary();
        this.fetchCalendarData(this.calendarYear, this.calendarMonth);
    }

    // Handle month navigation from calendar
    handleMonthChange(event) {
        const { year, month } = event.detail;
        this.calendarYear = year;
        this.calendarMonth = month;
        this.fetchCalendarData(year, month);
    }

    // Fetch per-day filled hours from Apex (use personId)
    fetchCalendarData() {
        if (!this.personId) return;
        getFilledHoursByDate({ personId: this.personId})
            .then(data => {
                this.filledHoursByDate = data || {};
            })
            .catch(error => {
                this.filledHoursByDate = {};
                // eslint-disable-next-line no-console
                console.error('Error fetching filled hours by date:', error);
            });
    }

    // // Calculate percentage of filled hours (for legacy use)
    // calculateFilledHoursPercentage() {
    //     if (!this.summary || !this.summary.FilledHours || !this.summary.ApprovedHours ||
    //         !this.summary.UnapprovedHours || !this.summary.TempApprovedHours || !this.summary.BlankHours) {
    //         return 0;
    //     }

    //     const totalHours = this.summary.FilledHours + this.summary.ApprovedHours +
    //         this.summary.UnapprovedHours + this.summary.TempApprovedHours +
    //         this.summary.BlankHours;

    //     if (totalHours === 0) return 0;

    //     this.filledHoursPercentage = Math.round((this.summary.FilledHours / totalHours) * 100);
    //     return this.filledHoursPercentage;
    // }

    // Get percentage for a box based on Filled Hours
    getBoxPercentage(value) {
        const filled = this.summary.FilledHours || 0;
        if (filled === 0) return 0;
        if(value ===0) return 0;
        return Math.round((value / filled) * 100);
    }

    // Get color class for a box based on its percentage of Filled Hours
    getBoxColorClass(value) {
        const percent = this.getBoxPercentage(value);
        if (percent < 65) {
            return 'slds-box summary-card summary-card-red';
        } else if (percent >= 65 && percent < 100) {
            return 'slds-box summary-card summary-card-orange';
        } else if (percent === 100) {
            return 'slds-box summary-card summary-card-green';
        }
        return 'slds-box summary-card';
    }

    // Getters for color class and percent for each card
    get filledHoursColorClass() {
        return this.getBoxColorClass(this.summary.FilledHours);
    }
    get approvedHoursColorClass() {
        return this.getBoxColorClass(this.summary.ApprovedHours);
    }
    get unapprovedHoursColorClass() {
        return this.getBoxColorClass(this.summary.UnapprovedHours);
    }
    get tempApprovedHoursColorClass() {
        return this.getBoxColorClass(this.summary.TempApprovedHours);
    }
    get blankHoursColorClass() {
        return this.getBoxColorClass(this.summary.BlankHours);
    }

    get filledHoursPercent() {
        return this.getBoxPercentage(this.summary.FilledHours);
    }
    get approvedHoursPercent() {
        return this.getBoxPercentage(this.summary.ApprovedHours);
    }
    get unapprovedHoursPercent() {
        return this.getBoxPercentage(this.summary.UnapprovedHours);
    }
    get tempApprovedHoursPercent() {
        return this.getBoxPercentage(this.summary.TempApprovedHours);
    }
    get blankHoursPercent() {
        return this.getBoxPercentage(this.summary.BlankHours);
    }

    // Mock data for calendar demo (replace with real data in production)
    // get filledHoursByDate() {
    //     // Example for June 2024
    //     return {
    //         '2024-06-01': 8,
    //         '2024-06-02': 3,
    //         '2024-06-03': 7,
    //         '2024-06-04': 4,
    //         '2024-06-05': 8,
    //         '2024-06-06': 2,
    //         '2024-06-07': 8,
    //         '2024-06-08': 5,
    //         '2024-06-09': 8,
    //         '2024-06-10': 8,
    //         '2024-06-11': 6,
    //         '2024-06-12': 8,
    //         '2024-06-13': 8,
    //         '2024-06-14': 8,
    //         '2024-06-15': 8,
    //         '2024-06-16': 8,
    //         '2024-06-17': 8,
    //         '2024-06-18': 8,
    //         '2024-06-19': 8,
    //         '2024-06-20': 8,
    //         '2024-06-21': 8,
    //         '2024-06-22': 8,
    //         '2024-06-23': 8,
    //         '2024-06-24': 8,
    //         '2024-06-25': 8,
    //         '2024-06-26': 8,
    //         '2024-06-27': 8,
    //         '2024-06-28': 8,
    //         '2024-06-29': 8,
    //         '2024-06-30': 8
    //     };
    // }

    // Fetch summary data from Apex and trigger chart rendering
    getSummary() {
        if (!this.personId || !this.startDate || !this.endDate) {
            // Debug: Missing required parameters
            // eslint-disable-next-line no-console
            console.warn('Missing personId, startDate, or endDate');
            return;
        }
        getHomeSummary({ personId: this.personId, startDate: this.startDate, endDate: this.endDate })
            .then(result => {
                this.summary = result;
                this.summaryLoaded = true;
                // Calculate percentage after data is loaded
                // this.calculateFilledHoursPercentage();
                // Debug: Log summary data
                // eslint-disable-next-line no-console
                console.log('Summary data:', result);
                // console.log('Filled Hours Percentage:', this.filledHoursPercentage);
                // this.renderChart();
            })
            .catch(error => {
                this.summaryLoaded = false;
                // Debug: Log Apex error
                // eslint-disable-next-line no-console
                console.error('Error fetching summary:', error);
            });
    }

    
}