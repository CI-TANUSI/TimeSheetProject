public class InvoicePDFFlowController {
    
    @AuraEnabled
    public static String getInvoicePreviewUrl(InvoicePDFRequestWrapper requestWrapper) {
        PageReference pageRef = new PageReference('/apex/' + requestWrapper.vfPage);
        pageRef.getParameters().put('id', requestWrapper.recordId);
        pageRef.getParameters().put('desc', requestWrapper.descriptions);
        pageRef.getParameters().put('milestone', requestWrapper.paymentMilestone);
        pageRef.getParameters().put('devName', requestWrapper.billingAddressDevName);
        pageRef.getParameters().put('AccountdevName', requestWrapper.billingAccountDevName);
        pageRef.getParameters().put('AccountdevNames', requestWrapper.billingAccountDevNames);
        pageRef.getParameters().put('AccountWgdevNames', requestWrapper.billingAccountWgDevNames);
        pageRef.getParameters().put('gst', requestWrapper.gstApplicable);
        pageRef.getParameters().put('gstType', requestWrapper.gstType);
        pageRef.getParameters().put('igstValue', requestWrapper.igstValue);
        pageRef.getParameters().put('cgstValue', requestWrapper.cgstValue);
        pageRef.getParameters().put('sgstValue', requestWrapper.sgstValue);
        pageRef.getParameters().put('totalworkingdays', requestWrapper.totalWorkingDays);
        pageRef.getParameters().put('totalbillabledays', requestWrapper.totalBillableDays);
        pageRef.getParameters().put('totalworkinghours', requestWrapper.totalWorkingHours);
        pageRef.getParameters().put('totalbillablehours', requestWrapper.totalBillableHours);
        pageRef.getParameters().put('rate', requestWrapper.rate);
        pageRef.getParameters().put('sign', requestWrapper.sign);
        pageRef.getParameters().put('link', requestWrapper.link);
        pageRef.getParameters().put('upwork', requestWrapper.upwork);
        pageRef.getParameters().put('invoicetype', requestWrapper.invoicetype);
        
        return pageRef.getUrl();
    }
    
    @AuraEnabled
    public static void generateInvoiceAndSave(InvoicePDFRequestWrapper requestWrapper) {
        
        Payment_Milestone__c milestone = [Select id,Name,Amount__c,Opportunity__c from Payment_Milestone__c where id= :requestWrapper.recordId];
        
        Opportunity opp = [SELECT Id,AccountId,Deal_Source__c,Upwork_Profile__c FROM Opportunity WHERE Id = :milestone.Opportunity__c LIMIT 1];
        
        Invoice_Series_Configuration_c__c configuration = [select id,CI_Series__c,WG_Series__c,Financial_Year__c,Upwork_Series__c,PI_Series__c from Invoice_Series_Configuration_c__c Limit 1]; 
        
        decimal igst, sgst_cgst, cgst,sgst;
        if (requestWrapper.gstApplicable=='Yes') {
            if (requestWrapper.gstType=='IGST') {
                igst = (milestone.Amount__c*18)/100;
            }
            else {
                cgst= (milestone.Amount__c*9)/100;
                sgst= (milestone.Amount__c*9)/100;
                sgst_cgst= cgst+ cgst;
            }
        }
        
        Decimal Upwork,Wg,CI,PI;
        String seriesType;
        String formattedNumber;
        if(requestWrapper.upwork == 'Rohit'){
            Upwork = configuration.Upwork_Series__c + 1;
            PI = configuration.PI_Series__c ;
            CI = configuration.CI_Series__c ;
            Wg = configuration.WG_Series__c ;
            seriesType = 'RB';
            formattedNumber = String.Valueof(Upwork);
            formattedNumber = formattedNumber.leftpad(3,'0');
        }
        else if(requestWrapper.billingAddressDevName == 'WGCLOUD_INGENIOUS_TECHNOLOGIES_PRIVATE_L'){
            Wg = configuration.WG_Series__c + 1;
            PI = configuration.PI_Series__c ;
            CI = configuration.CI_Series__c ;
            Upwork = configuration.Upwork_Series__c;
            seriesType = 'WG';
            formattedNumber = String.Valueof(Wg);
            formattedNumber = formattedNumber.leftpad(3,'0');
              
        }
        else if(requestWrapper.invoicetype == 'PI Invoice'){
            PI = configuration.PI_Series__c + 1;
            Wg = configuration.WG_Series__c ;
            CI = configuration.CI_Series__c ;
            Upwork = configuration.Upwork_Series__c;
            seriesType = 'PI';
            formattedNumber = String.Valueof(PI);
            formattedNumber = formattedNumber.leftpad(3,'0');
              
        }
        else{
            CI = configuration.CI_Series__c + 1;
            PI = configuration.PI_Series__c ;
            Wg = configuration.WG_Series__c ;
            Upwork = configuration.Upwork_Series__c;
            seriesType = 'CI';
            formattedNumber = String.Valueof(CI);
            formattedNumber = formattedNumber.leftpad(3,'0');
        }
        
        Invoice_Series_Configuration_c__c series = new Invoice_Series_Configuration_c__c(
            id = configuration.id,
            CI_Series__c = CI,
            WG_Series__c = Wg,
            PI_Series__c = PI,
            Upwork_Series__c = Upwork );
            update series;
        
        
        String finalInvoiceNumber = seriesType + '/' + configuration.Financial_Year__c + '/' + formattedNumber;
        Invoice__c invoiceRecord = new Invoice__c(
            Payment_Milestone__c = requestWrapper.recordId,
            Amount__c = milestone.amount__c,
            IGST__c= igst,
            SGST__c= sgst,
            CGST__c= cgst,
            Invoice_Number__c = finalInvoiceNumber);
        insert invoiceRecord;
        invoiceRecord = [SELECT Id, Name FROM Invoice__c WHERE Id = :invoiceRecord.Id];
        
        
        
        
        if (String.isNotBlank(requestWrapper.paymentMilestone)) {
            Payment_Milestone__c milename = new Payment_Milestone__c();
            milename.Id = requestWrapper.recordId;
            milename.Name = requestWrapper.paymentMilestone;
            update milename;
        }
        
        
        if (String.isNotBlank(requestWrapper.descriptions)) {
            Payment_Milestone__c milenotes = new Payment_Milestone__c();
            milenotes.Id = requestWrapper.recordId;
            milenotes.PM_Description__c = requestWrapper.descriptions;
            update milenotes;
        }
        
        
        PageReference pdfPage = new PageReference('/apex/' + requestWrapper.vfPage);
        pdfPage.getParameters().put('id', requestWrapper.recordId);
        pdfPage.getParameters().put('desc', requestWrapper.descriptions);
        pdfPage.getParameters().put('milestone', requestWrapper.paymentMilestone);
        pdfPage.getParameters().put('devName', requestWrapper.billingAddressDevName);
        pdfPage.getParameters().put('AccountdevName', requestWrapper.billingAccountDevName);
        pdfPage.getParameters().put('AccountdevNames', requestWrapper.billingAccountDevNames);
        pdfPage.getParameters().put('AccountWgdevNames', requestWrapper.billingAccountWgDevNames);
        pdfPage.getParameters().put('gst', requestWrapper.gstApplicable);
        pdfPage.getParameters().put('gstType', requestWrapper.gstType);
        pdfPage.getParameters().put('igstValue', requestWrapper.igstValue);
        pdfPage.getParameters().put('cgstValue', requestWrapper.cgstValue);
        pdfPage.getParameters().put('sgstValue', requestWrapper.sgstValue);
        pdfPage.getParameters().put('totalworkingdays', requestWrapper.totalWorkingDays);
        pdfPage.getParameters().put('totalbillabledays', requestWrapper.totalBillableDays);
        pdfPage.getParameters().put('totalworkinghours', requestWrapper.totalWorkingHours);
        pdfPage.getParameters().put('totalbillablehours', requestWrapper.totalBillableHours);
        pdfPage.getParameters().put('invoiceName', invoiceRecord.Name);
        pdfPage.getParameters().put('rate', requestWrapper.rate);
        pdfPage.getParameters().put('sign', requestWrapper.sign);
        pdfPage.getParameters().put('link', requestWrapper.link);
        pdfPage.getParameters().put('SeriesType', SeriesType);
        pdfPage.getParameters().put('formattedNumber', formattedNumber);
        pdfPage.getParameters().put('Financial', configuration.Financial_Year__c);
        pdfPage.getParameters().put('upwork', requestWrapper.upwork);
        pdfPage.getParameters().put('invoicetype', requestWrapper.invoicetype);
        
        
        Blob pdfBlob;
        if (!Test.isRunningTest()) {
            pdfBlob = pdfPage.getContentAsPDF();
        } else {
            pdfBlob = Blob.valueOf('Test PDF content');
        }
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Invoice_' + requestWrapper.recordId;
        cv.PathOnClient = 'Invoice.pdf';
        cv.VersionData = pdfBlob;
        insert cv;
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        link.LinkedEntityId = requestWrapper.recordId;
        link.ShareType = 'V';
        insert link;
    }
    
    public class InvoicePDFRequestWrapper {
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public String descriptions { get; set; }
        @AuraEnabled public String paymentMilestone { get; set; }
        @AuraEnabled public String billingAddressDevName { get; set; }
        @AuraEnabled public String billingAccountDevName { get; set; }
        @AuraEnabled public String billingAccountDevNames { get; set; }
        @AuraEnabled public String billingAccountWgDevNames { get; set; }
        @AuraEnabled public String gstApplicable { get; set; }
        @AuraEnabled public String gstType  { get; set; }
        @AuraEnabled public String igstValue { get; set; }
        @AuraEnabled public String cgstValue { get; set; }
        @AuraEnabled public String sgstValue { get; set; }
        @AuraEnabled public String totalWorkingDays { get; set; }
        @AuraEnabled public String totalBillableDays { get; set; }
        @AuraEnabled public String totalWorkingHours { get; set; }
        @AuraEnabled public String totalBillableHours { get; set; }
        @AuraEnabled public String vfPage { get; set; }
        @AuraEnabled public String rate { get; set; }  
        @AuraEnabled public String sign { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String upwork { get; set; }
        @AuraEnabled public String invoicetype { get; set; } 
    }
    
}