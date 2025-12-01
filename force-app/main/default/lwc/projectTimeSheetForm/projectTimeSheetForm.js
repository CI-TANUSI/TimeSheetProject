import { LightningElement, track, api, wire} from 'lwc';
import createTimeSheetEntry from '@salesforce/apex/timeSheetController.saveTimesheet';
//import updateTimeSheetEntry from '@salesforce/apex/timeSheetController.updateTimeSheetEntry';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TIMESHEET_OBJECT from '@salesforce/schema/Timesheet_Entry__c';
//import WORK_STATUS_FIELD from '@salesforce/schema/Timesheet_Entry__c.WorkStatus__c';


export default class ProjectTimeSheetForm extends LightningElement {
    @api selectedProjectCode; 
    @api selectedDate;
    @api selectedProjectCodes;
    @api todayDate;
    @track date;
    @track projectCode;
    @track type;
    @track workStatus;
    @track timeTaken;
    @track technicalDescription;
    @track functionalDescription;
    @track recordData = {};
    @api timeTakenInMin;
    @api recordId;
    @api type;
    @api status;
    @api functionDes;
    @api technicalDes;
    @api draft;
    @track isEditable =true;
    @track statusOptions = [];

@wire(getObjectInfo, { objectApiName: TIMESHEET_OBJECT })
objectInfo;

@wire(getPicklistValues, {
    recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    fieldApiName: WORK_STATUS_FIELD
})
wiredPicklistValues({ error, data }) {
    if (data) {
        this.statusOptions = data.values;
        console.log('WorkStatus picklist values:', JSON.stringify(data.values));
    } else if (error) {
        console.error('Error loading WorkStatus picklist:', error);
    }
}

    get projectCodeValue() {
        return this.selectedProjectCodes || this.selectedProjectCode || '';
    }

    projectOptions = [
        { label: 'P001 - Website Revamp', value: 'P001' },
        { label: 'P002 - Mobile App', value: 'P002' },
        { label: 'P003 - Salesforce Integration', value: 'P003',},
        { label: 'P004 -CRM Setup', value: 'P004'},
    ];

    typeOptions = [
        { label: 'Development', value: 'Development' },
        { label: 'Testing', value: 'Testing' },
        { label: 'Meeting', value: 'Meeting' },
    ];

    // statusOptions = [
    //     { label: 'In Progress', value: 'In Progress' },
    //     { label: 'Completed', value: 'Completed' },
    //     { label: 'Blocked', value: 'Blocked' },
    // ];

    connectedCallback() {
    this.projectCode = this.selectedProjectCodes || this.selectedProjectCode || '';
    this.date =  this.getTodayDate();
    this.type = this.type;
    this.workStatus = this.status;
    this.timeTaken =  this.timeTakenInMin;
    console.log('draft::'+this.draft);
    console.log('this.this.functionDes:::'+this.functionDes);
    this.functionalDescription=this.functionDes;
    this.technicalDescription=this.technicalDes;
    }
    getTodayDate() {
        console.log('sinide:::'+this.todayDate);
        const today = new Date(this.todayDate);
        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const year = today.getFullYear();
        return `${year}-${month}-${day}`;
    }

   handleChange(event) {
    const { name, value } = event.target;
    this.recordData[name] = value;

    if(name === 'Time_Taken_min__c') {
        this.timeTaken = parseFloat(value) || 0; 
    } else if(name === 'Type__c') {
        this.type = value;
    } else if(name === 'WorkStatus__c') {
        this.workStatus = value;
    } else if(name === 'Technical_Description__c') {
        this.technicalDescription = value;
    } else if(name === 'Functional_Description__c') {
        this.functionalDescription = value;
    }
}

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

 handleDraft() {
    const finalProjectCode = this.selectedProjectCodes || this.selectedProjectCode || this.projectCode;

    if (!finalProjectCode) {
        alert('Please select a Project Code before saving.');
        return;
    }

    this.recordData.Project_code__c = finalProjectCode;
    this.recordData.Date__c = this.date;
    this.recordData.Time_Taken_min__c = Number(this.timeTaken) || 0;
    this.recordData.Type__c = this.type;
    this.recordData.WorkStatus__c = this.workStatus;
    this.recordData.Technical_Description__c = this.technicalDescription;
    this.recordData.Functional_Description__c = this.functionalDescription;
    this.recordData.Draft__c = true;

    console.log('Saving Draft...', this.recordId, this.draft);

    if (this.recordId && (this.draft === true || this.draft === 'true')) {
        this.recordData.Id = this.recordId;
        updateTimeSheetEntry({ timeSheetData: this.recordData })
            .then(result => {
                 this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'saved changes updated, Reload the page for Current Changes',
                        variant: 'success'
                    })
                );
                this.recordData.Id = result;
                console.log('Draft updated successfully:', result);
                this.saveData('Draft');
            })
            .catch(error => {
                console.error('Error while updating draft:', error);
            });
    } else {
        
        createTimeSheetEntry({ timeSheetData: this.recordData })
            .then(result => {
                 this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Save Time Sheet successfully, Reload the page for Current Changes',
                        variant: 'success'
                    })
                );
                this.recordData.Id = result;
                console.log('Draft saved successfully:', result);
                this.saveData('Draft');
            })
            .catch(error => {
                console.error('Error while saving draft:', error);
            });
    }
}

    handleSubmit() {
        try{
            console.log('this.timeTaken13333::');
            console.log('this.timeTaken::'+this.timeTaken);
        const finalProjectCode = this.selectedProjectCodes || this.selectedProjectCode || this.projectCode;
        if (!finalProjectCode) {
            alert('Please select a Project Code before submitting.');
            return;
        }
        this.recordData.Project_code__c = finalProjectCode;
        this.recordData.Date__c = this.date;
       console.log('this.timeTaken:111:'+this.timeTaken);
        this.recordData.Time_Taken_min__c = Number(this.timeTaken) || 0;
       console.log('this.recordData.Time_Taken__c:::'+this.recordData.Time_Taken__c);
        this.recordData.Type__c = this.type;
        this.recordData.WorkStatus__c = this.workStatus;
        this.recordData.Technical_Description__c = this.technicalDescription;
        this.recordData.Functional_Description__c = this.functionalDescription;
        this.recordData.Draft__c = false;
        console.log(' this.draft::'+this.draft);
        if(this.draft == true || this.draft == undefined){
        createTimeSheetEntry({ timeSheetData: this.recordData })
            .then(result => {
                 this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Timesheet filled successfully',
                        variant: 'success'
                    })
                );
                console.log('Record Saved Successfully:', result);
                this.saveData('Submitted');
            })
            .catch(error => {
                console.error('Error while saving:', error);
            });
}else{
    this.recordData.Id = this.recordId;
    updateTimeSheetEntry({ timeSheetData: this.recordData })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Draft TimeSheet updated successfully, Please reload the page for Current Changes',
                        variant: 'success'
                    })
                );
                console.log('Record Saved Successfully:', result);
                this.saveData('Submitted');
            })
            .catch(error => {
                console.error('Error while saving:', error);
            });
}}catch(e){
            console.log('log:::'+log);
        }
    }
saveData(status) {
    const record = {
        id: this.recordData.Id,
        date: this.date,
        projectCode: this.selectedProjectCodes || this.selectedProjectCode || this.projectCode,
        type: this.type,
        workStatus: this.workStatus,
        timeTaken: this.timeTaken,
        technicalDescription: this.technicalDescription,
        functionalDescription: this.functionalDescription,
        hours: this.timeTaken,
        status
    };
    this.dispatchEvent(new CustomEvent('submit', { detail: record }));
}


}