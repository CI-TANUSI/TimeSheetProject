import { LightningElement, track, wire, api } from 'lwc';
import createTimesheet from '@salesforce/apex/TimeSheetEntry.createTimesheet';
import getTimeSheet from '@salesforce/apex/TimeSheetEntry.getTimeSheet';
import getProjectCodes from '@salesforce/apex/TimeSheetEntry.getProjectCodes';
import getpersons from '@salesforce/apex/TimeSheetEntry.getPersons';
import createTimesheetLog from '@salesforce/apex/TimeSheetRegularize.createTimesheetLog';
import getTeamRegularizePermission from '@salesforce/apex/TimeSheetEntry.getTeamRegularizePermission';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Name', fieldName: 'Name', sortable: true },
    { label: 'Date', fieldName: 'FormattedDate', sortable: true },
    { label: 'Project Code', fieldName: 'Project_Code__c', sortable: true },
    { label: 'Type', fieldName: 'Type__c', sortable: true },
    { label: 'Time Taken - (Minutes)', fieldName: 'Time_Taken__c', sortable: true, type: 'number' },
    { label: 'Work Status', fieldName: 'Work_Status__c', sortable: true },
    { label: 'Technical Status', fieldName: 'Technical_description__c', sortable: true },
    {
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'regularizeButtonLabel' },
            name: 'regularize',
            title: 'Regularize',
            disabled: { fieldName: 'regularizeButtonDisabled' },
            value: 'regularize',
            iconPosition: 'left',
            variant: 'brand'
        }
    }
];

const summaryColumns = [
    { label: 'Work Status', fieldName: 'workStatus' },
    { label: 'Total Entries', fieldName: 'count', type: 'number' },
    { label: 'Total Hours', fieldName: 'totalTimeInHours', type: 'number' }
];

export default class TimeSheetEntry extends LightningElement {
    @api personId;
    @track selectedTab = 'home';
    @track isLoading = false;
    @track showtimesheetmodal = false;
    @track projectCode = '';
    @track type = '';
    @track workStatus = '';
    @track timeTaken = '';
    @track technical = '';
    @track functional = '';
    @track date = new Date().toISOString().split('T')[0];
    @track columns = columns;
    @track data = [];
    @track projectCodeOptions = [];
    @track alloweddays = '';
    @track extract = '';
    @track maxDate = new Date().toISOString().split('T')[0];
    @track minDate;
   
    @track showRegularizeModal = false;
    @track selectedRecord;
    @track tabteamregularize = false;
    @track filterStartDate = '';
    @track filterEndDate = '';
    @track pageNumber = 1;
    @track pageSize = 25;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track searchKey = '';
    @track timesheetSummary = [];
    @track sortedBy = 'FormattedDate';
    @track sortedDirection = 'desc';
    summaryColumns = summaryColumns;
    @track submittedRows = new Set();

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
        this.pageNumber = 1;
        this.timesheetRecords();
    }

    handleEntriesChange(event) {
        this.pageSize = event.target.value;
        this.pageNumber = 1;
        this.timesheetRecords();
    }

    handleNewClick() {
        this.showtimesheetmodal = true;
    }

    closeTimesheetModal() {
        this.showtimesheetmodal = false;
    }

    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'ProjectCode') {
            this.projectCode = event.target.value;
        }
        else if (field === 'WorkType') {
            this.type = event.target.value;
        }
        else if (field === 'WorkStatus') {
            this.workStatus = event.target.value;
        }
        else if (field === 'TimeTaken') {
            this.timeTaken = event.target.value;
        }
        else if (field === 'Technical') {
            this.technical = event.target.value;
        }
        else if (field === 'Functional') {
            this.functional = event.target.value;
        }
        else if (field === 'Date') {
            this.date = event.target.value;
        }

    }

    @wire(getProjectCodes, { personId: '$personId' })
    wiredCodes({ data, error }) {
        if (data) {
            const optionsFromOpp = data.map(item => ({
                label: item.Opportunity__r.Project_Code__c,
                value: item.Opportunity__r.Project_Code__c
            }));

            this.projectCodeOptions = [
                ...optionsFromOpp
            ];
        } else if (error) {
            console.error('Error fetching project codes:', error);
        }
    }

    timesheetRecords() {
        console.log('Timesheet record method' +this.pageNumber
            +'\n Page Size : ' +this.pageSize
            +'\n Page searchKey : ' +this.searchKey
            +'\n Page filterEndDate : ' +this.filterEndDate
            +'\n Page filterStartDate : ' +this.filterStartDate
            +'\n Page personId : ' +this.personId
        );
        getTimeSheet({
            PersonId: this.personId,
            startDate: this.filterStartDate || null,
            endDate: this.filterEndDate || null,
            pageNumber: this.pageNumber,
            pageSize: this.pageSize,
            searchKey: this.searchKey
        })
            .then(result => {
                this.submittedRows = new Set(result.submittedTimesheetIds || []);
                this.data = result.timesheets.map(item => {
                    let formattedDate = '';
                    if (item.Date__c) {
                        const date = new Date(item.Date__c);
                        const day = String(date.getUTCDate()).padStart(2, '0');
                        const month = String(date.getUTCMonth() + 1).padStart(2, '0');
                        const year = date.getUTCFullYear();
                        formattedDate = `${day}-${month}-${year}`;
                    }
                    let isSubmitted = this.submittedRows.has(item.Id);
                    return {
                        ...item,
                        FormattedDate: formattedDate,
                        regularizeButtonLabel: isSubmitted ? 'Submitted' : 'Regularize',
                        regularizeButtonDisabled: isSubmitted || item.Status__c != 'Blank'
                    };
                });
                this.totalRecords = result.totalRecords;
                this.totalPages = Math.ceil(result.totalRecords / this.pageSize);
            })
            .catch(error => {
                console.log(error);
            })
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

    teamTabPermission() {
        getTeamRegularizePermission({ personId: this.personId })
            .then(result => {
                this.tabteamregularize = result;
            })
            .catch(error => {
                console.log(error);
            })
    }

    

    connectedCallback() {
    // const saved = localStorage.getItem('submittedTimesheets');
    // this.submittedRows = new Set(saved ? JSON.parse(saved) : []);
        this.timesheetRecords();
        this.personPermission();
        this.teamTabPermission();
 
    }

    saveTimesheet() {
        if (!this.checkValidation()) {
            return;
        }
         
        this.isLoading = true;

        createTimesheet({
            ProjectCode: this.projectCode, WorkType: this.type, WorkStatus: this.workStatus, TimeTaken: this.timeTaken,
            Technical: this.technical, Functional: this.functional, Dates: this.date, PersonId: this.personId
        })
            .then(result => {
                this.showtoast('Success', 'Record Created Successfully', 'success');
                this.projectCode = '';
                this.type = '';
                this.workStatus = '';
                this.timeTaken = '';
                this.technical = '';
                this.functional = '';
                this.showtimesheetmodal = false;
                this.timesheetRecords();
            })
            .catch(error => {
                console.log(error);
                this.showtoast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    saveAndNew() {
        if (!this.checkValidation()) {
            return;
        }

        this.isLoading = true;

        createTimesheet({
            ProjectCode: this.projectCode, WorkType: this.type, WorkStatus: this.workStatus, TimeTaken: this.timeTaken,
            Technical: this.technical, Functional: this.functional, Dates: this.date, PersonId: this.personId
        })
            .then(result => {
                this.showtoast('Success', 'Record Created Successfully', 'success');
                this.projectCode = '';
                this.type = '';
                this.workStatus = '';
                this.timeTaken = '';
                this.technical = '';
                this.functional = '';
                this.timesheetRecords();
            })
            .catch(error => {
                this.showtoast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    checkValidation() {
        let isValid = true;
        const requiredFields = this.template.querySelectorAll('.validation');
        requiredFields.forEach(field => {
            if (!field.checkValidity()) {
                field.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleLogout() {
        const event = new CustomEvent('logout', {
            detail: {
                showLoginpage: true,
                showEntrypage: false
            }
        });
        this.dispatchEvent(event);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'regularize') {
            this.selectedRecord = { ...row };
            this.date = row.Date__c || '';
            this.type = row.Type__c || '';
            this.projectCode = row.Project_Code__c || '';
            this.workStatus = row.Work_Status__c || '';
            this.timeTaken = row.Time_Taken__c || '';
            this.technical = row.Technical_description__c || '';
            this.functional = row.Functional_Description__c || '';
            this.showRegularizeModal = true;
        }
    }

    closeRegularizeModal() {
        this.showRegularizeModal = false;
        this.selectedRecord = null;
        this.date = '';
        this.type = '';
        this.workStatus = '';
        this.timeTaken = '';
        this.technical = '';
        this.functional = '';
        this.projectCode = '';
    }

    handleRegularize() {
        if (!this.checkValidation()) {
            return;
        }
        
        this.timesheetRecords();
        this.isLoading = true;
        
        createTimesheetLog({
            WorkType: this.type,
            WorkStatus: this.workStatus,
            TimeTaken: this.timeTaken,
            Technical: this.technical,
            Functional: this.functional,
            ProjectCode: this.projectCode,
            Dates: this.date,
            PersonId: this.personId,
            TimesheetId: this.selectedRecord.Id
        })
            .then(result => {
                this.showtoast('Success', 'Record Regularized Successfully', 'success');
                this.submittedRows.add(this.selectedRecord.Id);
                localStorage.setItem('submittedTimesheets', JSON.stringify([...this.submittedRows]));
                this.closeRegularizeModal();
                this.timesheetRecords();
            })
            .catch(error => {
                console.log(error);
                this.showtoast('Error', error.body.message, 'error');
            });
    }

    showtoast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }

    handleFilterDateChange(event) {
        const field = event.target.name;
        if (field === 'filterStartDate') {
            this.filterStartDate = event.target.value;
        } else if (field === 'filterEndDate') {
            this.filterEndDate = event.target.value;
        }
    }

    handleFilterClick() {
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