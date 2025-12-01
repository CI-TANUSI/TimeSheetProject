import { LightningElement, track,api } from 'lwc';
import  getTimesheetLog from '@salesforce/apex/TimeSheetRegularize.getTimesheetLog';

const columns = [
    { label: 'Old Date', fieldName: 'OldDate' },
    { label: 'New Date', fieldName: 'Date__c' },
    { label: 'Old Time Taken - (Minutes)', fieldName: 'Oldtime' },
    { label: 'New Time Taken - (Minutes)', fieldName:'Time_Taken_Minutes__c'},
    { label: 'Old Project Code', fieldName: 'OldProjectCode' },
    {label: 'project Code', fieldName: 'Project_Code__c' },
    {label: 'Status', fieldName: 'Status__c'}
]

export default class TimeSheetRegularization extends LightningElement {
      @api personId;
      @track data = [];
      @track columns = columns;

      get hasData() {
        return this.data && this.data.length > 0;
      }

     connectedCallback() {
      this.timesheetlog();
     }
   
    timesheetlog(){
        getTimesheetLog({Personid: this.personId})
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

}