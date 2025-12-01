@isTest
private class StaffAugDaysControllerTest {
    
    @testSetup
    static void setupData() {
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCountry = 'India',
            BillingStreet = 'Street 123',
            BillingCity = 'CityX',
            BillingState = 'StateX',
            BillingPostalCode = '123456',
            Phone = '1234567890',
            GST__c = '29ABCDE1234F2Z5'
        );
        insert acc;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
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
            Amount__c = 1000,
            Month__c = 'January',
            Rate__c = 100,
            Billable_Hours_Day__c = 8
        );
        insert milestone;
    }

    static void setPageParams(String milestoneId, String gst, String gstType, String currencyIso, String sign) {
        Test.setCurrentPage(Page.StaffAugDays); 
        ApexPages.currentPage().getParameters().put('id', milestoneId);
        ApexPages.currentPage().getParameters().put('desc', 'Test Description');
        ApexPages.currentPage().getParameters().put('milestone', 'Test Milestone');
        ApexPages.currentPage().getParameters().put('devName', 'BillingDev');
        ApexPages.currentPage().getParameters().put('AccountdevName', 'BankDev1');
        ApexPages.currentPage().getParameters().put('AccountdevNames', 'BankDev2');
        ApexPages.currentPage().getParameters().put('gst', gst);
        ApexPages.currentPage().getParameters().put('gstType', gstType);
        ApexPages.currentPage().getParameters().put('igstValue', '18');
        ApexPages.currentPage().getParameters().put('sgstValue', '9');
        ApexPages.currentPage().getParameters().put('cgstValue', '9');
        ApexPages.currentPage().getParameters().put('totalworkingdays', '20');
        ApexPages.currentPage().getParameters().put('totalbillabledays', '18');
        ApexPages.currentPage().getParameters().put('rate', '100');
        ApexPages.currentPage().getParameters().put('sign', sign);
        ApexPages.currentPage().getParameters().put('link', 'http://example.com');
    }

    @isTest
    static void testWithIGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];
        setPageParams(milestone.Id, 'Yes', 'IGST', 'INR', 'Yes');

        Test.startTest();
        StaffAugDaysController controller = new StaffAugDaysController();
        Test.stopTest();

        System.assert(controller.showIGST);
        System.assertEquals(true, controller.showGST);
        System.assertNotEquals(null, controller.formattedAmount);
        System.assertNotEquals(null, controller.result);
    }

    @isTest
    static void testWithCGST_SGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];
        setPageParams(milestone.Id, 'Yes', 'CGST', 'INR', 'No');

        Test.startTest();
        StaffAugDaysController controller = new StaffAugDaysController();
        Test.stopTest();

        System.assert(controller.showCGST_SGST);
        System.assertEquals(true, controller.showGST);
        System.assertNotEquals(null, controller.formatcgst);
        System.assertNotEquals(null, controller.formatsgst);
    }

    @isTest
    static void testWithoutGST() {
        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c LIMIT 1];
        setPageParams(milestone.Id, 'No', '', 'INR', 'Yes');

        Test.startTest();
        StaffAugDaysController controller = new StaffAugDaysController();
        Test.stopTest();

        System.assertEquals(false, controller.showGST);
 //     System.assertEquals(milestone.Amount__c, controller.grandTotal);
    }

    @isTest
    static void testCurrencyHandling() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.CurrencyIsoCode = 'USD';
        update opp;

        Payment_Milestone__c milestone = [SELECT Id FROM Payment_Milestone__c WHERE Opportunity__c = :opp.Id LIMIT 1];
        setPageParams(milestone.Id, 'Yes', 'IGST', 'USD', 'Yes');

        Test.startTest();
        StaffAugDaysController controller = new StaffAugDaysController();
        Test.stopTest();

        System.assert(controller.result != null && controller.result.contains('Dollars'));
    }
}