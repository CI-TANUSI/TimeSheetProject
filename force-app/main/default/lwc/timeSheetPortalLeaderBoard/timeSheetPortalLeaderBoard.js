import { LightningElement, track } from 'lwc';
import getLeaderBoard from '@salesforce/apex/TimeSheetPortalController.getLeaderBoard';

export default class LeaderBoard extends LightningElement {
    @track rows = [];

    connectedCallback() {
        getLeaderBoard()
            .then(data => {
                this.rows = (data || []).map((row, idx) => ({ ...row, rank: idx + 1 }));
            })
            .catch(() => { this.rows = []; });
    }
}