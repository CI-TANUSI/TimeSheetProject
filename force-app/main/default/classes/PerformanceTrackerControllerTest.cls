@isTest
private class PerformanceTrackerControllerTest {
    @isTest
    static void testGetAmounts_Yearly() {
        // Insert test yearly record (without setting formula fields)
        Performance_Tracker_Yearly__c yearly = new Performance_Tracker_Yearly__c(
            Name = 'Yearly Test'
        );
        insert yearly;

        // Simulate fallback case
        Test.startTest();
        Map<String, Object> result = PerformanceTrackerController.getAmounts(yearly.Id);
        Test.stopTest();

        System.assert(result.containsKey('opportunity'), 'Missing opportunity key');
        System.assert(result.containsKey('pm'), 'Missing pm key');
        System.assert(result.containsKey('currencyIsoCode'), 'Missing currencyIsoCode key');
    }

    @isTest
    static void testGetAmounts_NoRecord() {
        // Call with a fake Id
        Id fakeId = 'a01000000000000AAA'; // Custom object Id prefix

        Test.startTest();
        Map<String, Object> result = PerformanceTrackerController.getAmounts(fakeId);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Expected empty result map');
    }
}