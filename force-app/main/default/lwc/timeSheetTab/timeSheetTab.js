import { LightningElement, track, wire, api } from 'lwc';
import saveTimesheet from '@salesforce/apex/timeSheetController.saveTimesheet';
import getProjectCodes from '@salesforce/apex/TimeSheetEntry.getProjectCodes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getpersons from '@salesforce/apex/TimeSheetEntry.getPersons';
import getTimesheetEntries from '@salesforce/apex/timeSheetController.getTimesheetEntries';
import getTimeSheetDatas from '@salesforce/apex/timeSheetController.getTimeSheetDatas';


export default class TimeSheetTab extends LightningElement {
    @api personId;
    @api recordId;
    @track weekStart = new Date();
    @track days = [];
    @track entries = [];
    @track totalRecords = 0;
    @track projectOptions = [];
    @track data = [];
    @track sortedBy = 'FormattedDate';
    @track sortedDirection = 'desc';
    @track pageNumber = 1;
    @track pageSize = 15;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track searchKey = '';
    @track showPopup = false;
    @track popupMessage = '';
    @track popupVariant = 'success';

   
    @track columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Date', fieldName: 'TimesheetDate__c', type: 'date' },
        { label: 'Project Code', fieldName: 'ProjectCode__c', type: 'text' },
        { label: 'Time Taken (Minutes)', fieldName: 'TimeTakenInMinutes__c', type: 'number' },
        { label: 'Technical Description', fieldName: 'TechnicalDescription__c', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' }
    ];
    
    
    // Explicit properties for 
    dateISO0; dateISO1; dateISO2; dateISO3; dateISO4; dateISO5; dateISO6;
    dayTotal0 = '0.0';
    dayTotal1 = '0.0';
    dayTotal2 = '0.0';
    dayTotal3 = '0.0';
    dayTotal4 = '0.0';
    dayTotal5 = '0.0';
    dayTotal6 = '0.0';
    @track weekTotal = '0.0';
    //HOURS_TO_MINUTES = 60; 
    connectedCallback() {
        console.log('personId+>'+ this.personId);
        
        this.initThisWeek();
        if (this.entries.length === 0) {
            this.addRow();
        }
        this.updateTotals(); // Initial calculation
        this.timesheetRecords();

    }
    createNewEntry() {
        return {
            id: Date.now(),
            ProjectCode__c: '',
            day0: 0, day1: 0, day2: 0, day3: 0, day4: 0, day5: 0, day6: 0, 
            total: 0,
        };
    }
    // --- WEEK HANDLING ---
    initThisWeek() {
        const today = new Date();
        const day = today.getDay(); 
        const diffToMonday = (day === 0) ? -6 : 1 - day;
        const monday = new Date(today);
        monday.setDate(today.getDate() + diffToMonday);
        monday.setHours(0, 0, 0, 0);
        this.setWeekStart(monday);
    }
    setWeekStart(dateObj) {
        this.weekStart = new Date(dateObj);
        this.buildDays();
        this.fetchWeekData();
        
    }
    buildDays() {
        const arr = [];
        for (let i = 0; i < 7; i++) {
            const d = new Date(this.weekStart);
            d.setDate(this.weekStart.getDate() + i);       
           // const dateISO = d.toISOString().split('T')[0];  
           const dateISO = d.getFullYear() + '-' +
                String(d.getMonth() + 1).padStart(2, '0') + '-' +
                String(d.getDate()).padStart(2, '0');
         
            arr.push({
                index: i,
                dateISO: dateISO,
                dateDisplay: d.toLocaleDateString(undefined, { day: 'numeric', month: 'short' }),
                dayName: d.toLocaleDateString(undefined, { weekday: 'short' })
            });    
            // Populate explicit component properties for template keys
            this[`dateISO${i}`] = dateISO; 
        }
        this.days = arr;
    }
    goPrevWeek() {
        const prev = new Date(this.weekStart);
        prev.setDate(this.weekStart.getDate() - 7);
        this.setWeekStart(prev);
    }
    goNextWeek() {
        const next = new Date(this.weekStart);
        next.setDate(this.weekStart.getDate() + 7);
        this.setWeekStart(next);
    }   
   goPrevAndClearWeek(){
    this.goPrevWeek();
} 
goNextAndClearWeek (){
    this.goNextWeek();
}

    // ---------- ROW/ENTRY HANDLERS ----------
    addRow() {
        this.clearMessages();
        this.entries = [...this.entries, this.createNewEntry()];
        this.updateTotals();
    }
    handleDeleteRow(event) {
        this.clearMessages();
        const index = parseInt(event.target.dataset.rowIndex, 10);
        this.entries.splice(index, 1);
        this.entries = [...this.entries]; 
        this.updateTotals();
    }
    /*handleProjectChange(event) {
        this.clearMessages();
        const index = parseInt(event.target.dataset.rowIndex, 10);
        
        const updatedEntries = [...this.entries];
        updatedEntries[index] = {
            ...updatedEntries[index],
            ProjectCode__c: event.detail.value
        };
        this.entries = updatedEntries;
    }*/
    handleProjectChange(event){
    const rowId = event.target.dataset.rowid;
    const selectedOppId = event.detail.value;

    this.entries = this.entries.map(r=>{
        if(r.id == rowId){
            r.Opportunity__c = selectedOppId;   // store Opp Id   
            r.ProjectCode__c = event.target.options.find(o=>o.value === selectedOppId).label;
        }
        return r;
    });
    console.log('Updated entries =>', JSON.stringify(this.entries));
}
    handleTimeChange(event) {
        this.clearMessages();
        const rowIndex = parseInt(event.target.dataset.rowIndex, 10);
        const dayIndex = parseInt(event.target.dataset.dayIndex, 10);
        const val = parseFloat(event.target.value) || 0;        
        const fieldName = `day${dayIndex}`; 
        const updatedEntries = [...this.entries];
        const updatedEntry = { ...updatedEntries[rowIndex] };      
        updatedEntry[fieldName] = val; 
        updatedEntry.total = this.calculateRowTotal(updatedEntry);       
        updatedEntries[rowIndex] = updatedEntry;
        this.entries = updatedEntries;
        this.updateTotals();
    }  
    clearMessages() {
        this.message = '';
        this.error = '';
    }
    calculateRowTotal(entry) {
        let total = 0;
        for (let i = 0; i < 7; i++) {
            total += Number(entry[`day${i}`] || 0);
        }
        return total.toFixed(1);
    }    
    // Updates both daily totals and the week total property
    updateTotals() {
        let grandTotal = 0;       
        for (let i = 0; i < 7; i++) {
            const fieldName = `day${i}`;
            const daySum = this.entries.reduce((sum, entry) => sum + Number(entry[fieldName] || 0), 0);           
            // Write to the explicit component property
            this[`dayTotal${i}`] = daySum.toFixed(1); 
            grandTotal += daySum;
        }     
        this.weekTotal = grandTotal.toFixed(1); 
    }
    
    // --- LABEL (Getter) ---
    get weekLabel() {
        if (!this.weekStart) return '';
        const start = this.weekStart.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' });
        const end = new Date(this.weekStart);
        end.setDate(this.weekStart.getDate() + 6);
        const endLabel = end.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' });
        const weekNumber = this.getWeekNumber(this.weekStart);
        return `Week ${weekNumber}: ${start} - ${endLabel}`;
    }
    getWeekNumber(date) {
        const tempDate = new Date(date.getTime());
        tempDate.setHours(0, 0, 0, 0);
        tempDate.setDate(tempDate.getDate() + 3 - ((tempDate.getDay() + 6) % 7));
        const week1 = new Date(tempDate.getFullYear(), 0, 4);
        return 1 + Math.round(((tempDate - week1) / 86400000 - 3 + ((week1.getDay() + 6) % 7)) / 7);
    }
    //Open popup
    openDescriptionPopup(event) {
        const rowIndex = event.target.dataset.rowIndex;
        const dayIndex = event.target.dataset.dayIndex;
        this.entries = this.entries.map((entry, idx) => {
            if(idx == rowIndex) {
                return {
                    ...entry,
                    [`showDesc${dayIndex}`]: true
                };
            }
            return entry;
        });
    }
    // Close popup + autosave
    closeDescriptionPopup(event) {
        const rowIndex = event.target.dataset.rowIndex;
        const dayIndex = event.target.dataset.dayIndex;
        this.entries = this.entries.map((entry, idx) => {
            if(idx == rowIndex) {
                return {
                    ...entry,
                    [`showDesc${dayIndex}`]: false,
                    [`desc${dayIndex}`]: entry[`desc${dayIndex}`] // already updated in handleDescInput
                };
            }
            return entry;
        });
    }
    // Handle textarea input (live autosave)
    handleDescInput(event) {
        const rowIndex = event.target.dataset.rowIndex;
        const dayIndex = event.target.dataset.dayIndex;
        const value = event.target.value;

        this.entries = this.entries.map((entry, idx) => {
            if(idx == rowIndex) {
                return {
                    ...entry,
                    [`desc${dayIndex}`]: value
                };
            }
            return entry;
        });
    }
        personPermission() {
                getpersons({ PersonId: this.personId })
                    .then(result => {
                        this.alloweddays = result[0].Timesheet_Entry_Allowed_Days__c;
                        this.extract = result[0].Extract_Timesheet__c;

                        if (this.alloweddays && this.alloweddays > 0) {
                            let today = new Date();
                            let pastDate = new Date();
                            pastDate.setDate(today.getDate() - this.alloweddays);
                            this.minDate = pastDate.toISOString().split('T')[0];
                        } else {
                            this.minDate = new Date().toISOString().split('T')[0];
                        }
                    })
                    .catch(error => {
                        console.log(error);
                    })
            }
    // --- PROJECT CODES ---
    @wire(getProjectCodes, {personId: '$personId' })
    wiredCodes({ data, error }) {
        if (data) {
            this.projectOptions = data.filter(item => item.Opportunity__r && item.Opportunity__r.Project_Code__c).map(item => ({
                label: item.Opportunity__r.Project_Code__c, // what user sees
                value: item.Opportunity__c // the real Opp Id
            }));
        } else if (error) {
            console.error('Error fetching project codes:', error);
        }
    }
    clearWeek() {
        this.entries = [];
        this.addRow();
        this.clearMessages();
        this.updateTotals();
    }

    saveTimesheetDraft(){
    this.saveDataToServer('Draft');
    }
    submitTimesheet(){
        this.saveDataToServer('Submitted');
    }
    saveDataToServer(statusValue){
        let entriesToSave = [];

        this.entries.forEach(entry =>{

            console.log('ENTRY ===> ', JSON.stringify(entry));  

            for(let i=0;i<7;i++){
                let hours = Number(entry[`day${i}`] || 0);
                if(hours>0 && entry.Opportunity__c){     
                   entriesToSave.push({
                        Opportunity__c : entry.Opportunity__c,    
                        TimesheetDate__c : this.days[i].dateISO,
                        TimeTakenInMinutes__c : hours*60,
                        TechnicalDescription__c : entry[`desc${i}`] || '',
                        Person__c : this.personId
                    });
                }
            }
        });  
        console.log('entriesToSave ===> ', JSON.stringify(entriesToSave));
        console.table(entriesToSave.map(e => ({
            Opportunity__c: e.Opportunity__c,
            TimesheetDate__c: e.TimesheetDate__c,
            TimeTakenInMinutes__c: e.TimeTakenInMinutes__c
        })));
        saveTimesheet({ entries:entriesToSave , status:statusValue })
        .then(()=>{
    this.showCustomPopup(`Timesheet ${statusValue} successfully`, 'success');

})

        .catch((err)=>{
    const errorMsg = err && err.body && err.body.message ? err.body.message : 'Something went wrong while saving.';
    this.showCustomPopup(errorMsg, 'error');

});

    }
    // Toast Helper
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    showCustomPopup(message, variant) {
    this.popupMessage = message;
    this.popupVariant = variant;
    this.showPopup = true;

    // auto hide after 3 seconds
    setTimeout(() => {
        this.showPopup = false;
    }, 3000);
}
    fetchWeekData() {
    if (!this.personId || !this.weekStart) return;

    const startDate = this.days[0].dateISO;
    const endDate = this.days[6].dateISO;

    console.log(`Fetching entries for week: ${startDate} to ${endDate}`);

    getTimesheetEntries({
        personId: this.personId,
        startDate: startDate,
        endDate: endDate
    })
        .then((result) => {
            console.log('Fetched Week Data ===> ', JSON.stringify(result));

            // Convert fetched data into your entries array structure
            let mapByOpportunity = {};

            result.forEach(rec => {
                const oppId = rec.Opportunity__c;
                const dateISO = rec.TimesheetDate__c;
                const dayIndex = this.days.findIndex(d => d.dateISO === dateISO);
                if (dayIndex === -1) return;

                if (!mapByOpportunity[oppId]) {
                    mapByOpportunity[oppId] = this.createNewEntry();
                    mapByOpportunity[oppId].Opportunity__c = oppId;
                }

                mapByOpportunity[oppId][`day${dayIndex}`] = (rec.TimeTakenInMinutes__c || 0) / 60;
                mapByOpportunity[oppId][`desc${dayIndex}`] = rec.TechnicalDescription__c;
            });

            this.entries = Object.values(mapByOpportunity);
            this.entries.forEach(e => e.total = this.calculateRowTotal(e));

            // If no entries, keep one blank row
            if (this.entries.length === 0) {
                this.addRow();
            }

            this.updateTotals();
        })
        .catch((error) => {
            console.error('Error fetching week data:', error);
            this.showToast('Error', 'Failed to load week data.', 'error');
        });

}

 // Apex method call
 /*   @wire(getTimeSheetDatas)
    wiredTimesheets({ error, data }) {
        if (data) {
            console.log('Fetched Data:', JSON.stringify(data));
            this.data = data;
        } else if (error) {
            console.error('Error fetching timesheet data:', error);
        }
    }*/
    timesheetRecords() {

    getTimeSheetDatas({
        pageNumber: this.pageNumber,
        pageSize: this.pageSize,
        searchKey: this.searchKey
    })
    .then(result => {
        this.data = result.records;
        this.totalRecords = result.totalRecords;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
    })
    .catch(error => {
        console.error('Error fetching records:', error);
        this.showToast('Error', 'Failed to fetch timesheet records.', 'error');
    });
}

     handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'regularize') {
            this.selectedRecord = { ...row };
            this.date = row.TimesheetDate__c || '';          
            this.projectCode = row.ProjectCode__c || '';           
            this.timeTaken = row.TimeTakenInMinutes__c || '';
            this.technical = row.TechnicalDescription__c || '';           
            this.showRegularizeModal = true;
        }
    }
    handleTabSelect(event) {
        this.selectedTab = event.target.value;
    }
    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber === this.totalPages;
    }
    handleSearchChange(event) {
    this.searchKey = event.target.value;
    this.pageNumber = 1; // reset to first page

    // Option 1 (for instant search)
    this.timesheetRecords();

    // OR Option 2 (if you added debounce)
    // clearTimeout(this.delayTimeout);
    // this.delayTimeout = setTimeout(() => this.timesheetRecords(), 400);
}


    handleEntriesChange(event) {
        this.pageSize = event.target.value;
        this.pageNumber = 1;
        this.timesheetRecords();
    }
    handlePrevious() {
    if (this.pageNumber > 1) {
        this.pageNumber--;
        this.timesheetRecords();
    }
}


    handleNext() {
    if (this.pageNumber < this.totalPages) {
        this.pageNumber++;
        this.timesheetRecords();
    }
}

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection: sortedDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortedDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortedDirection;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            if (a === b) {
                return 0;
            }
            if (a === null || typeof a === 'undefined') {
                return 1 * reverse;
            }
            if (b === null || typeof b === 'undefined') {
                return -1 * reverse;
            }
            return reverse * ((a > b) - (b > a));
        };
    }



}