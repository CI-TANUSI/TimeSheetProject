@isTest
public class StaffAugHourlyControllerTest {
    
    @testSetup
    static void setupData() {
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCountry = 'India',
            BillingStreet = '123 Street',
            BillingCity = 'City',
            BillingState = 'State',
            BillingPostalCode = '123456',
            GST__c = '22AAAAA0000A1Z5'
        );
        insert acc;

        // Create Opportunity
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
            Amount__c = 10000,
            Account__c = acc.Id,
            Opportunity__c = opp.Id,
            Rate__c = 1000,
            Billable_Hours_Day__c = 8
        );
        insert milestone;

        
    }
     
    @isTest 
    static void testControllerWithIGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        Test.setCurrentPage(Page.StaffAugHourly); 
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('desc', 'Test Description');
        ApexPages.currentPage().getParameters().put('milestone', 'Milestone 1');
        ApexPages.currentPage().getParameters().put('devName', 'Test_Billing_Address');
        ApexPages.currentPage().getParameters().put('AccountdevName', 'Test_Bank_Account');
        ApexPages.currentPage().getParameters().put('gst', 'Yes');
        ApexPages.currentPage().getParameters().put('gstType', 'IGST');
        ApexPages.currentPage().getParameters().put('igstValue', '18');
        ApexPages.currentPage().getParameters().put('sign', 'Yes');

        StaffAugHourlyController controller = new StaffAugHourlyController();

        System.assertEquals(true, controller.showGST);
        System.assertEquals(true, controller.showIGST);
        System.assertNotEquals(null, controller.formattedAmount);
    }
     
    @isTest
    static void testControllerWithCGST_SGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        Test.setCurrentPage(Page.StaffAugHourly); 
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('desc', 'Test Description');
        ApexPages.currentPage().getParameters().put('milestone', 'Milestone 1');
        ApexPages.currentPage().getParameters().put('devName', 'Test_Billing_Address');
        ApexPages.currentPage().getParameters().put('AccountdevName', 'Test_Bank_Account');
        ApexPages.currentPage().getParameters().put('gst', 'Yes');
        ApexPages.currentPage().getParameters().put('gstType', 'CGST_SGST');
        ApexPages.currentPage().getParameters().put('cgstValue', '9');
        ApexPages.currentPage().getParameters().put('sgstValue', '9');

        StaffAugHourlyController controller = new StaffAugHourlyController();

        System.assertEquals(true, controller.showGST);
        System.assertEquals(true, controller.showCGST_SGST);
        System.assertNotEquals(null, controller.formattedAmount);
    }
     
    @isTest
    static void testControllerWithoutGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        Test.setCurrentPage(Page.StaffAugHourly); 
        ApexPages.currentPage().getParameters().put('id', milestone.Id);
        ApexPages.currentPage().getParameters().put('gst', 'No');

        StaffAugHourlyController controller = new StaffAugHourlyController();

        System.assertEquals(false, controller.showGST);
        System.assertEquals(false, controller.showIGST);
        System.assertEquals(false, controller.showCGST_SGST);
        System.assertNotEquals(null, controller.formattedAmount);
    }
}