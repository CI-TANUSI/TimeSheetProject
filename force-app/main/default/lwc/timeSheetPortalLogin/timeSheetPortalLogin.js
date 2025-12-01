import { LightningElement } from 'lwc';
import TimeSheetResource from '@salesforce/resourceUrl/TimeSheet';
import loginUserApex from '@salesforce/apex/TimeSheetPortalController.loginUser';
import validateSessionApex from '@salesforce/apex/TimeSheetPortalController.validateSession';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TimeSheetPortalLogin extends LightningElement {

    logoUrl = TimeSheetResource + '/images/ci_logo.png';
    username = '';
    password = '';

    connectedCallback() {
        this.checkSession();
    }

    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
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

    async handleLogin() {
        if (!this.checkValidation()) {
            return;
        }

        const resp = await loginUserApex({ username: this.username, password: this.password });

        console.log('resp----'+JSON.stringify(resp));
        
        if(resp && resp.isSuccess) {
            if(resp.data && resp.data.isValidUser) {
                sessionStorage.setItem('sessionKey', resp.data.sessionKey);
                this.showToast('Success', 'Login Successful!', 'success');
                const obj = {
                    userId: resp.data.userId,
                    loggedIn : true
                }
                this.sendToParent(obj);

            } else {
                this.showToast('Error', 'Invalid Username or Password', 'error');
            }
        } else {
            this.showToast('Error', 'Something went wrong. Please contact Administrator', 'error');
        }
    }

    async checkSession() {
        const sessionKey = sessionStorage.getItem('sessionKey');

        if (sessionKey) {
            const resp = await validateSessionApex({ sessionKey: sessionKey });

            console.log('resp----'+JSON.stringify(resp));

            if (resp && resp.isSuccess) {

                if(resp.data && resp.data.isValidSession) {
                    const obj = {
                        userId: resp.data.userId,
                        loggedIn: true
                    }
                    this.sendToParent(obj);
                } else {
                    sessionStorage.removeItem('sessionKey');
                }
            } else {
                sessionStorage.removeItem('sessionKey');
            }
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    sendToParent(detail) {

        const selectedEvent = new CustomEvent("childevent", {
            detail: detail
        });

        this.dispatchEvent(selectedEvent);
    }
}