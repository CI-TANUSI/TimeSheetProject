@isTest
private class TimeSheetSummaryTest {

    @testSetup
    static void setupTestData() {
         //Create Account 
         Account acc = new Account(Name = 'Test Account');
         insert acc;
        
        // Create Opportunity
       Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;   
            
        // Create a test Person
        Person__c person = new Person__c(Name = 'Test Person', Account__c = acc.Id, Username__c = 'Nitin@123', Passwords__c = '12234');
        insert person;

        Date today = Date.today();
        List<Timesheet__c> timesheets = new List<Timesheet__c>();

        // Create records with different statuses
        timesheets.add(new Timesheet__c(
            Person__c = person.Id,
            Date__c = today,
            Opportunity__c = Opp.Id,
            Time_Taken__c = 480, // 8 hours
            Status__c = 'Approved'
        ));

        timesheets.add(new Timesheet__c(
            Person__c = person.Id,
            Date__c = today.addDays(-1),
            Time_Taken__c = 480,
            Opportunity__c = Opp.Id,
            Status__c = 'Unapproved'
        ));

        timesheets.add(new Timesheet__c(
            Person__c = person.Id,
            Date__c = today.addDays(-2),
            Time_Taken__c = 480,
            Opportunity__c = Opp.Id,
            Status__c = 'Temporary Approved'
        ));

        timesheets.add(new Timesheet__c(
            Person__c = person.Id,
            Date__c = today.addDays(-3),
            Time_Taken__c = 480,
            Opportunity__c = Opp.Id,
            Status__c = 'Approved'
        ));

        timesheets.add(new Timesheet__c(
            Person__c = person.Id,
            Date__c = today.addDays(-4),
            Time_Taken__c = 480,
            Opportunity__c = Opp.Id,
            Status__c = 'Blank' // For BlankHours
        ));

        insert timesheets;
    }

    @isTest
    static void testGetHomeSummary() {
        Person__c p = [SELECT Id FROM Person__c LIMIT 1];
        Date startDate = Date.today().addDays(-10);
        Date endDate = Date.today();

        Test.startTest();
        Map<String, Decimal> summary = TimeSheetSummary.getHomeSummary(p.Id, startDate, endDate);
        Test.stopTest();

        Assert.IsTrue(summary != null, 'Summary map should not be null');
        Assert.IsTrue(summary.get('FilledHours') > 0, 'Should have some filled hours');
        Assert.IsTrue(summary.get('ApprovedHours') >= 0, 'Should have approved hours');
        Assert.IsTrue(summary.get('UnapprovedHours') >= 0, 'Should have unapproved hours');
        Assert.IsTrue(summary.get('TempApprovedHours') >= 0, 'Should have temp approved hours');
        Assert.IsTrue(summary.get('BlankHours') >= 0, 'Should have blank hours');
    }

    @isTest
    static void testGetFilledHoursByDate() {
        Person__c p = [SELECT Id FROM Person__c LIMIT 1];

        Test.startTest();
        Map<String, Decimal> dateMap = TimeSheetSummary.getFilledHoursByDate(p.Id);
        Test.stopTest();

        Assert.IsTrue(dateMap != null && dateMap.size() > 0, 'Date map should not be empty');
 
    }

    @isTest
    static void testGetLeaderBoard() {
        Test.startTest();
        List<Map<String, Object>> board = TimeSheetSummary.getLeaderBoard();
        Test.stopTest();

        Assert.IsTrue(board != null && board.size() > 0, 'Leaderboard should have entries');
        Assert.areEqual('Test Person', board[0].get('name'));
    }
}