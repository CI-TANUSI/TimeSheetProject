import { LightningElement,track,api } from 'lwc';
import getAllUsers from '@salesforce/apex/TimeSheetAssignedProjectCodes.getAllUsers';
import createProjectCodeAccess from '@salesforce/apex/TimeSheetAssignedProjectCodes.createProjectCodeAccess';
import getAssignedUsers from '@salesforce/apex/TimeSheetAssignedProjectCodes.getAssignedUsers';
import deleteProjectCodeAccess from '@salesforce/apex/TimeSheetAssignedProjectCodes.deleteProjectCodeAccess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class PersonSelector extends LightningElement {
    @track isUser = true;
    @track isAssignUser = false;
    @track data = [];
    @track assigndata= [];
    @track searchTerm = '';
    @track selectedUserIds = [];
    @api recordId ;

    userColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Username', fieldName: 'Username__c' },
    ];

    get filteredData() {
        if (!this.searchTerm) return this.data;
        const term = this.searchTerm.toLowerCase();
        return this.data.filter(user =>
            (user.Name && user.Name.toLowerCase().includes(term)) ||
            (user.Username__c && user.Username__c.toLowerCase().includes(term))
        );
    }
       
    getAllPersons(){
         getAllUsers({opportunityId:this.recordId})
            .then(result => {
                this.data = result;
            })
            .catch(error => {
                console.error('Error fetching users:', error);
            });
        }   

    getAssignedPersons(){
        getAssignedUsers({opportunityId:this.recordId})
        .then(result => {
                this.assigndata = result;
            })
            .catch(error => {
                console.error('Error fetching users:', error);
            });
    }

    connectedCallback(){
        this.getAssignedPersons();
    }


    handleAssignedUsers() {
        this.isAssignUser = true;
        this.getAllPersons();
        this.isUser = false;
    }



    handleUserSearch(event) {
        this.searchTerm = event.target.value;
    }

    handleRowSelection(event) {
        this.selectedUserIds = event.detail.selectedRows.map(row => row.Id);
    }

       handleRemoveAssignedUsers(){
         let opportunityId = this.recordId;

           if (this.selectedUserIds.length === 0) {
            this.showtoast('Error', 'Please select at least one user', 'error');
            return;
        }
         deleteProjectCodeAccess({opportunityId, userIds: this.selectedUserIds})
           .then(() => {
                this.showtoast('Success', 'Person Removed Successfully', 'success');
                this.isAssignUser = false;
                this.isUser = true;
                this.selectedUserIds = [];
                this.getAssignedPersons();
            })
            .catch(error => {
                console.error('Error creating Project Code Access records:', error);
            });
      
    }

    handleAssign() {
      let opportunityId = this.recordId;
     
      if (this.selectedUserIds.length === 0) {
            this.showtoast('Error', 'Please select at least one user', 'error');
            return;
        }

        createProjectCodeAccess({ opportunityId, userIds: this.selectedUserIds })
            .then(() => {
                this.showtoast('Success', 'Person Assigned Successfully', 'success');
                this.isAssignUser = false;
                this.isUser = true;
                this.selectedUserIds = [];
                this.getAssignedPersons();
            })
            .catch(error => {
                console.error('Error creating Project Code Access records:', error);
            });
    }

    handleCancel() {
        this.isAssignUser = false;
        this.selectedUserIds = [];
        this.getAssignedPersons();
        this.isUser = true;
    }

     showtoast(title, message, variant) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
        }
}