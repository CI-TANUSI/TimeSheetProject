import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Logo1 from '@salesforce/resourceUrl/logo1';
import validateLogin from '@salesforce/apex/TS_TimeSheetLogin.validateLogin';
import updateRefreshTime from '@salesforce/apex/TS_TimeSheetLogin.updateRefreshTime';
import { NavigationMixin } from 'lightning/navigation';

export default class TimeSheetLoginPage extends NavigationMixin(LightningElement) {

    logoUrl = Logo1;
    showLoginpage = true;
    showEntrypage = false;
    @track isLoading = true;
    @track username = '';
    @track password = '';
    @track personId;
  
    connectedCallback() {
        this.checkSession();
    }

    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    handleLogin() {
        if (!this.checkValidation()) {
            return;
        }
        validateLogin({ username: this.username, password: this.password })
            .then(response => {
                if (response) {
                    // this.username='';
                    // this.password='';
                    this.personId = response.Id;
                    const sessionKey = response.key;

                    sessionStorage.setItem('sessionKey', sessionKey);

                    this.showToast('Success', 'Login Successfuly', 'Success');
                    console.log('response ==> ' + JSON.stringify(response));
                    //   window.location.href = '/TimeSheet/apex/TimeSheetEntry?personId=' + response;
                    this.showEntrypage = true;
                    this.showLoginpage = false;

                } else {
                    console.log('Login Failed');
                    this.showToast('Error', 'Username and Password does not match', 'Error');
                }

                this.username = '';
                this.password = '';
            })
    }

    checkSession() {

        const sessionKey = sessionStorage.getItem('sessionKey');

        if (sessionKey) {
            updateRefreshTime({ sessionKey })
                .then(response => {
                    this.personId = response;
                    if (this.personId != null) {
                        this.showLoginpage = false;
                        this.showEntrypage = true;
                        console.log("refresh=>" + response);
                        console.log('Refresh time updated');
                    }

                })
                .catch(err => {
                    console.error('Error updating refresh time', err.message);
                })
                .finally(() => {
                    this.isLoading = false; // done loading
                });
        } else {
            this.isLoading = false; // no session, show login
        }
        
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

    handleLogoutFromChild(event) {
        this.showLoginpage = event.detail.showLoginpage;
        this.showEntrypage = event.detail.showEntrypage;
        this.personId = null;
        this.username = '';
        this.password = '';
        sessionStorage.clear();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}