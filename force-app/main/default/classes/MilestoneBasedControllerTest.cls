@isTest
private class MilestoneBasedControllerTest {

    @testSetup
    static void setup() {
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCountry = 'India',
            BillingStreet = '123 Test St',
            BillingCity = 'Mumbai',
            BillingState = 'MH',
            BillingPostalCode = '400001',
            Phone = '1234567890',
            GST__c = '27ABCDE1234F2Z5'
        );
        insert acc;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            CurrencyIsoCode = 'INR',
            Deal_Source__c = 'Upwork',
            Upwork_Profile__c = 'Rohit'
        );
        insert opp;

        // Create Payment Milestone
        Payment_Milestone__c milestone = new Payment_Milestone__c(
            Name = 'Milestone 1',
            Amount__c = 10000,
            Account__c = acc.Id,
            Opportunity__c = opp.Id,
            Month__c = 'May',
            Rate__c = 500,
            Billable_Hours_Day__c = 8
        );
        insert milestone;
    }

    @isTest
    static void testMilestoneBasedControllerWithIGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.MilestoneBased; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('desc', 'Invoice for services');
        ApexPages.currentPage().getParameters().put('milestone', 'Milestone 1');
        ApexPages.currentPage().getParameters().put('devName', 'TestBillingAddress');
        ApexPages.currentPage().getParameters().put('AccountdevName', 'TestBank1');
        ApexPages.currentPage().getParameters().put('AccountdevNames', 'TestBank2');
        ApexPages.currentPage().getParameters().put('gst', 'Yes');
        ApexPages.currentPage().getParameters().put('gstType', 'IGST');
        ApexPages.currentPage().getParameters().put('igstValue', '18');
        ApexPages.currentPage().getParameters().put('sign', 'Yes');
        ApexPages.currentPage().getParameters().put('link', 'https://example.com/invoice');

        MilestoneBasedController controller = new MilestoneBasedController();
        System.assertNotEquals(null, controller.milestone);
        System.assert(controller.showIGST);
        System.assert(controller.showGST);
        System.assert(controller.showSign);
        System.assert(controller.formattedAmount != null);
        System.assert(controller.formattedDate != null);
        Test.stopTest();
    }

    @isTest
    static void testMilestoneBasedControllerWithCGST_SGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.MilestoneBased;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('desc', 'Invoice description');
        ApexPages.currentPage().getParameters().put('milestone', 'Milestone 1');
        ApexPages.currentPage().getParameters().put('devName', 'TestBillingAddress');
        ApexPages.currentPage().getParameters().put('AccountdevName', 'TestBank1');
        ApexPages.currentPage().getParameters().put('AccountdevNames', 'TestBank2');
        ApexPages.currentPage().getParameters().put('gst', 'Yes');
        ApexPages.currentPage().getParameters().put('gstType', 'CGST');
        ApexPages.currentPage().getParameters().put('sgstValue', '9');
        ApexPages.currentPage().getParameters().put('cgstValue', '9');
        ApexPages.currentPage().getParameters().put('sign', 'No');
        ApexPages.currentPage().getParameters().put('link', 'https://example.com/invoice');

        MilestoneBasedController controller = new MilestoneBasedController();
        System.assert(controller.showCGST_SGST);
        System.assertEquals(false, controller.showSign);
        System.assert(controller.formattedAmount != null);
        System.assert(controller.result != null);
        Test.stopTest();
    }

    @isTest
    static void testMilestoneBasedControllerWithNoGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.MilestoneBased;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('gst', 'No');
        ApexPages.currentPage().getParameters().put('gstType', '');
        ApexPages.currentPage().getParameters().put('sign', 'No');

        MilestoneBasedController controller = new MilestoneBasedController();
        System.assert(!controller.showGST);
        System.assertEquals(controller.grandTotal, controller.milestone.Amount__c);
        System.assert(controller.result != null);
        Test.stopTest();
    }
}