@isTest
public class TMBasisControllerTest {

    @testSetup
    static void setupData() {
        // Create test Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCountry = 'India',
            BillingStreet = '123 Street',
            BillingCity = 'City',
            BillingState = 'State',
            BillingPostalCode = '123456',
            Phone = '1234567890',
            GST__c = '29ABCDE1234F2Z5'
        );
        insert acc;

        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CurrencyIsoCode = 'INR',
            Deal_Source__c = 'Upwork',
            Upwork_Profile__c = 'Rohit'
        );
        insert opp;

        // Create Payment Milestone
        Payment_Milestone__c milestone = new Payment_Milestone__c(
            Name = 'Milestone 1',
            Account__c = acc.Id,
            Opportunity__c = opp.Id,
            Amount__c = 10000
        );
        insert milestone;

       
    }

    @isTest
    static void testTMBasisController_IGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        Test.setCurrentPage(new PageReference('/apex/YourVisualforcePage'));
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('gst', 'Yes');
        ApexPages.currentPage().getParameters().put('gstType', 'IGST');
        ApexPages.currentPage().getParameters().put('devName', 'DevBilling');
        ApexPages.currentPage().getParameters().put('AccountdevName', 'DevBank');
        ApexPages.currentPage().getParameters().put('AccountdevNames', 'DevBank');
        ApexPages.currentPage().getParameters().put('sign', 'Yes');
        ApexPages.currentPage().getParameters().put('desc', 'Test Desc');
        ApexPages.currentPage().getParameters().put('milestone', 'Milestone 1');
        ApexPages.currentPage().getParameters().put('igstValue', '18');
        ApexPages.currentPage().getParameters().put('rate', '100');
        ApexPages.currentPage().getParameters().put('totalworkinghours', '80');
        ApexPages.currentPage().getParameters().put('totalbillablehours', '75');

        TMBasisController controller = new TMBasisController();

        System.assertNotEquals(null, controller.milestone);
        System.assert(controller.showGST);
        System.assert(controller.showIGST);
        System.assertEquals(true, controller.showSign);
        System.assertNotEquals(null, controller.formattedAmount);
        System.assert(controller.grandTotal > 0);
    }

    @isTest
    static void testTMBasisController_CGST_SGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        Test.setCurrentPage(new PageReference('/apex/YourVisualforcePage'));
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('gst', 'Yes');
        ApexPages.currentPage().getParameters().put('gstType', 'CGST');
        ApexPages.currentPage().getParameters().put('devName', 'DevBilling');
        ApexPages.currentPage().getParameters().put('AccountdevName', 'DevBank');
        ApexPages.currentPage().getParameters().put('AccountdevNames', 'DevBank');

        TMBasisController controller = new TMBasisController();

        System.assert(controller.showCGST_SGST);
        System.assert(controller.cgst > 0);
        System.assert(controller.sgst > 0);
        System.assert(controller.grandTotal > 0);
    }

    @isTest
    static void testTMBasisController_NoGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        Test.setCurrentPage(new PageReference('/apex/YourVisualforcePage'));
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('gst', 'No');

        TMBasisController controller = new TMBasisController();

        System.assert(!controller.showGST);
        System.assertEquals(controller.grandTotal, controller.milestone.Amount__c);
    }
}