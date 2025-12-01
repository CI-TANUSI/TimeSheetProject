import { LightningElement, track, api } from 'lwc';
import getTeamTimeSheetLog from '@salesforce/apex/TimeSheetRegularize.getTeamTimeSheetLog';
import updateTimeSheetRecord from '@salesforce/apex/TimeSheetRegularize.updateTimeSheetRecord';
import updateTimeSheetLog from '@salesforce/apex/TimeSheetRegularize.updateTimeSheetLog';


const columns = [
    { label: 'Employee', fieldName: 'PersonName' },
    { label: 'Old Date', fieldName: 'OldDate' },
    { label: 'New Date', fieldName: 'Date__c' },
    { label: 'Old Time Taken - (Minutes)', fieldName: 'Oldtime' },
    { label: 'New Time Taken - (Minutes)', fieldName: 'Time_Taken_Minutes__c' },
    {label: 'Old Project Code', fieldName: 'OldProjectCode'},
    { label: 'project Code', fieldName: 'Project_Code__c' },
    {
        type: 'button',
        typeAttributes: {
            label: 'Approve',
            name: 'approve',
            title: 'Approve',
            disabled: false,
            value: 'approve',
            iconPosition: 'left',
            variant: 'success'
        }
    },
    {
        type: 'button',
        typeAttributes: {
            label: 'Reject',
            name: 'reject',
            title: 'Reject',
            disabled: false,
            value: 'reject',
            iconPosition: 'left',
            variant: 'destructive'
        }
    }
]

export default class TimeSheetTeamRegularization extends LightningElement {

    @api personId;
    @track data = [];
    @track columns = columns;
    @track selectedRecord;
    @track Status;

    get hasData() {
        return this.data && this.data.length > 0;
      }

    connectedCallback() {
        this.teamTimesheetLog();
    }

    teamTimesheetLog() {

        getTeamTimeSheetLog({ personId: this.personId })
            .then(result => {
                this.data = result.map(row => ({
                    ...row,
                    PersonName: row.Person__r ? row.Person__r.Name : '',
                    Oldtime: row.Timesheet__r ? row.Timesheet__r.Time_Taken__c : '',
                    OldProjectCode: row.Timesheet__r ? row.Timesheet__r.Project_Code__c : '',
                    OldDate: row.Timesheet__r ? row.Timesheet__r.Date__c : ''
                }));
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;


        if (actionName === 'approve') {
            this.selectedRecord = { ...row };
            this.Status = actionName;
            console.log('Selected Record: ' + JSON.stringify(this.selectedRecord));
            this.updateTimeSheetRecord();
            this.updateTimeSheetLog();

        }

        if (actionName === 'reject') {
            this.selectedRecord = { ...row };
            this.Status = actionName;
            console.log('Selected Record: ' + JSON.stringify(this.selectedRecord));
            this.updateTimeSheetLog();
        }
    }


    updateTimeSheetRecord() {
        updateTimeSheetRecord({
            timesheetId: this.selectedRecord.Timesheet__c,
            timeTaken: this.selectedRecord.Time_Taken_Minutes__c,
            projectCode: this.selectedRecord.Project_Code__c,
            dates: this.selectedRecord.Date__c
        })
            .then(result => {
                console.log('Updated: ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log(error);
            });
    }


    updateTimeSheetLog() {
        updateTimeSheetLog({
            timesheetLogId: this.selectedRecord.Id,
            actionName: this.Status
        })
            .then(result => {
                this.teamTimesheetLog();
                console.log('TimeSheetLog: ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log(error);
            });
    }
}