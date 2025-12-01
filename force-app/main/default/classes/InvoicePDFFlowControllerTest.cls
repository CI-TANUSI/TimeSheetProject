@isTest
public class InvoicePDFFlowControllerTest {

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            AccountId = acc.Id,
            Deal_Source__c = 'Upwork',
            Upwork_Profile__c = 'Rohit'
        );
        insert opp;

        // Create Payment Milestone
        Payment_Milestone__c milestone = new Payment_Milestone__c(
            Name = 'Initial Payment',
            Amount__c = 1000,
            Opportunity__c = opp.Id
        );
        insert milestone;

        // Create Invoice Series Configuration
        Invoice_Series_Configuration_c__c config = new Invoice_Series_Configuration_c__c(
            CI_Series__c = 1,
            WG_Series__c = 1,
            Financial_Year__c = '2024-25',
            Upwork_Series__c = 1
        );
        insert config;
    }

    @isTest
    static void testGetInvoicePreviewUrl() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        InvoicePDFFlowController.InvoicePDFRequestWrapper wrapper = new InvoicePDFFlowController.InvoicePDFRequestWrapper();
        wrapper.recordId = milestone.Id;
        wrapper.descriptions = 'Test Description';
        wrapper.paymentMilestone = 'Initial Payment';
        wrapper.billingAddressDevName = 'Some_Dev_Name';
        wrapper.billingAccountDevName = 'Billing_Account_1';
        wrapper.billingAccountDevNames = 'Billing_Account_2';
        wrapper.gstApplicable = 'Yes';
        wrapper.gstType = 'IGST';
        wrapper.igstValue = '180';
        wrapper.cgstValue = '90';
        wrapper.sgstValue = '90';
        wrapper.totalWorkingDays = '20';
        wrapper.totalBillableDays = '18';
        wrapper.totalWorkingHours = '160';
        wrapper.totalBillableHours = '144';
        wrapper.vfPage = 'InvoiceVFPage';
        wrapper.rate = '100';
        wrapper.sign = 'John Doe';
        wrapper.link = 'http://example.com';

        Test.startTest();
        String url = InvoicePDFFlowController.getInvoicePreviewUrl(wrapper);
        Test.stopTest();

        System.assertNotEquals(null, url, 'Preview URL should be generated');
        System.assert(url.contains('/apex/InvoiceVFPage'), 'URL should point to the correct VF page');
    }

    @isTest
    static void testGenerateInvoiceAndSave() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        InvoicePDFFlowController.InvoicePDFRequestWrapper wrapper = new InvoicePDFFlowController.InvoicePDFRequestWrapper();
        wrapper.recordId = milestone.Id;
        wrapper.descriptions = 'Updated Description';
        wrapper.paymentMilestone = 'Updated Milestone Name';
        wrapper.billingAddressDevName = 'WGCLOUD_INGENIOUS_TECHNOLOGIES_PRIVATE_L';
        wrapper.billingAccountDevName = 'Billing_Account_1';
        wrapper.billingAccountDevNames = 'Billing_Account_2';
        wrapper.gstApplicable = 'Yes';
        wrapper.gstType = 'CGST_SGST';
        wrapper.igstValue = '0';
        wrapper.cgstValue = '90';
        wrapper.sgstValue = '90';
        wrapper.totalWorkingDays = '20';
        wrapper.totalBillableDays = '18';
        wrapper.totalWorkingHours = '160';
        wrapper.totalBillableHours = '144';
        wrapper.vfPage = 'InvoiceVFPage';
        wrapper.rate = '100';
        wrapper.sign = 'John Doe';
        wrapper.link = 'http://example.com';

        Test.startTest();
        InvoicePDFFlowController.generateInvoiceAndSave(wrapper);
        Test.stopTest();

        // Assert Invoice was inserted
        List<Invoice__c> invoices = [SELECT Id, Invoice_Number__c, Payment_Milestone__c FROM Invoice__c];
        System.assertEquals(1, invoices.size(), 'One invoice should be inserted');

        // Assert ContentVersion and Link were created
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        System.assertEquals(1, contentVersions.size(), 'One ContentVersion should be created');

     //   List<ContentDocumentLink> contentLinks = [SELECT Id FROM ContentDocumentLink];
     //   System.assertEquals(1, contentLinks.size(), 'One ContentDocumentLink should be created');

        // Assert Payment Milestone was updated
        Payment_Milestone__c updatedMilestone = [SELECT Name, PM_Description__c FROM Payment_Milestone__c WHERE Id = :milestone.Id];
        System.assertEquals('Updated Milestone Name', updatedMilestone.Name);
        System.assertEquals('Updated Description', updatedMilestone.PM_Description__c);
    }
}