import { LightningElement } from 'lwc';

export default class TimeSheetPortalLWC extends LightningElement {
    
    isAuthenticated = false;
    userId;

    handleLoginPageEvent(event) {
        const detail = event.detail;

        console.log('detail----'+JSON.stringify(detail));

        if(detail && detail.loggedIn) {
            this.isAuthenticated = true;
            this.userId = detail.userId;
        }
    }
    
}