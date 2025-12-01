import { LightningElement, track, api } from 'lwc';
import searchOpportunities from '@salesforce/apex/TimesheetExtract.searchOpportunities';
import downloadTimesheet from '@salesforce/apex/TimesheetExtract.downloadTimesheet';

export default class TimeSheetExtract extends LightningElement {
    @api personId;
    @track searchResults = [];
    @track selectedRecord = null;
    @track searchKeyword = '';

    handleUserSearch(event) {
        const keyword = event.target.value;
        this.searchKeyword = keyword;

        if (keyword.length >= 2) {
            searchOpportunities({ searchKey: keyword, personId: this.personId })
                .then(result => {
                    this.searchResults = result;
                })
                .catch(error => {
                    console.error(error);
                    this.searchResults = [];
                });
        } else {
            this.searchResults = [];
        }
    }
    
    get showDropdown() {
    return this.searchResults.length > 0 && this.selectedRecord === null;
      }

    handleSelect(event) {
        const id = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;
        const code = event.currentTarget.dataset.code; 

        this.selectedRecord = { id, name,code };
        this.searchKeyword = code;
        this.searchResults = [];
    }

       clearSelection() {
        this.selectedRecord = null;
        this.searchKeyword = '';
        this.searchResults = [];
    }

    handleExtract() {
        if (!this.selectedRecord?.id) return;

        downloadTimesheet({ opportunityId: this.selectedRecord.id })
            .then(result => {
                const link = document.createElement('a');
                link.href = 'data:text/csv;charset=utf-8,' + encodeURI(result);
                link.download = 'Timesheet.csv';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);

                // Reset to allow new search
                this.selectedRecord = null;
                this.searchKeyword = '';
            })
            .catch(error => {
                console.error(error);
            });
    }
}