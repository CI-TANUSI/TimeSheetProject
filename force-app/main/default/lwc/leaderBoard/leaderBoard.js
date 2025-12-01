import { LightningElement, track } from 'lwc';
import getLeaderBoard from '@salesforce/apex/TimeSheetSummary.getLeaderBoard';

export default class LeaderBoard extends LightningElement {
    @track rows = [];

    connectedCallback() {
        getLeaderBoard()
            .then(data => {
                // Add rank to each row based on its index (starting from 1)
                this.rows = (data || []).map((row, idx) => ({ ...row, rank: idx + 1 }));
            })
            .catch(() => { this.rows = []; });
    }
}