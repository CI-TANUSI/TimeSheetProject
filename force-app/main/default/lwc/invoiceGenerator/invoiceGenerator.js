import { LightningElement, api } from 'lwc';
import generateInvoiceAndSave from '@salesforce/apex/InvoicePDFFlowController.generateInvoiceAndSave';
import getInvoicePreviewUrl from '@salesforce/apex/InvoicePDFFlowController.getInvoicePreviewUrl';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationBackEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class InvoiceGenerator extends LightningElement {
    @api recordId; 
    @api descriptions;
    @api paymentmilestone;
    @api billingAddressDevName;
    @api billingAccountDevName;
    @api billingAccountDevNames;
    @api billingAccountWgDevNames;
    @api gstApplicable;
    @api gstType;
    @api igstValue;
    @api cgstValue;
    @api sgstValue;
    @api totalworkingdays;
    @api totalbillabledays;
    @api totalworkinghours;
    @api totalbillablehours;
    @api vfpage;
    @api rate;
    @api sign;
    @api link;
    @api upwork;
    @api invoicetype;

    handlePreview() {
       
               let wrapperJson ={
                recordId: this.recordId , 
                descriptions: this.descriptions, 
                paymentmilestone: this.paymentmilestone,
                billingAddressDevName: this.billingAddressDevName,  
                billingAccountDevName:this.billingAccountDevName,
                billingAccountDevNames:this.billingAccountDevNames,
                billingAccountWgDevNames:this.billingAccountWgDevNames,
                gstApplicable: this.gstApplicable,
                gstType: this.gstType, 
                igstValue: this.igstValue,
                cgstValue: this.cgstValue, 
                sgstValue: this.sgstValue, 
                totalworkingdays: this.totalworkingdays, 
                totalbillabledays: this.totalbillabledays, 
                totalworkinghours: this.totalworkinghours,
                totalbillablehours: this.totalbillablehours, 
                vfpage: this.vfpage,
                rate:this.rate,
                sign:this.sign,
                link:this.link,
                upwork:this.upwork,
                invoicetype: this.invoicetype
            }

        getInvoicePreviewUrl({requestWrapper: wrapperJson})
            .then(url => {
                window.open(url, '_blank');
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to preview invoice',
                        variant: 'error'
                    })
                );
                console.error('Error previewing invoice: ', error);
            });

    }

    handleSave() {
            
        let wrapperJson ={
            recordId: this.recordId , 
            descriptions: this.descriptions, 
            paymentmilestone: this.paymentmilestone,
            billingAddressDevName: this.billingAddressDevName,  
            billingAccountDevName:this.billingAccountDevName,
            billingAccountDevNames:this.billingAccountDevNames,
            billingAccountWgDevNames:this.billingAccountWgDevNames,
            gstApplicable: this.gstApplicable,
            gstType: this.gstType, 
            igstValue: this.igstValue,
            cgstValue: this.cgstValue, 
            sgstValue: this.sgstValue, 
            totalworkingdays: this.totalworkingdays, 
            totalbillabledays: this.totalbillabledays, 
            totalworkinghours: this.totalworkinghours,
            totalbillablehours: this.totalbillablehours, 
            vfpage: this.vfpage,
            rate:this.rate,
            sign:this.sign,
            link:this.link,
            upwork:this.upwork,
            invoicetype: this.invoicetype
        }

        generateInvoiceAndSave({requestWrapper: wrapperJson})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Invoice saved successfully!',
                        variant: 'success'
                    })
                );
                 
                this.dispatchEvent(new FlowNavigationFinishEvent());

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to save invoice',
                        variant: 'error'
                    })
                );
                console.error('Error saving invoice: ', error);
            });
    }

    handleBack() {
        this.dispatchEvent(new FlowNavigationBackEvent());
    }
}