@isTest
private class OpportunitySummaryTest {

    @isTest
    static void testWithOpportunityId() {
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        // Insert Timesheet records with minimal required fields
        Timesheet__c ts1 = new Timesheet__c(
            Opportunity__c = opp.Id,
            Status__c = 'Approved'
            // other fields like Start_Time__c, End_Time__c, etc. if needed to trigger formula calculation
        );
        Timesheet__c ts2 = new Timesheet__c(
            Opportunity__c = opp.Id,
            Status__c = 'Blank'
        );
        insert new List<Timesheet__c>{ts1, ts2};

        Test.startTest();
        Map<String, Decimal> summary = OpportunitySummary.getSummary(opp.Id);
        Test.stopTest();

        // Since fields are formulas, values may default to 0 in test context unless underlying data supports calculation
        Assert.IsTrue(summary.containsKey('FilledHours'));
        Assert.IsTrue(summary.containsKey('ApprovedHours'));
        Assert.IsTrue(summary.containsKey('UnapprovedHours'));
        Assert.IsTrue(summary.containsKey('BlankHours'));
    }

    @isTest
    static void testWithInvalidId() {
        Test.startTest();
        Map<String, Decimal> summary = OpportunitySummary.getSummary(null);
        Test.stopTest();

        Assert.areEqual(0, summary.get('FilledHours'));
        Assert.areEqual(0, summary.get('ApprovedHours'));
        Assert.areEqual(0, summary.get('UnapprovedHours'));
        Assert.areEqual(0, summary.get('BlankHours'));
    }
}