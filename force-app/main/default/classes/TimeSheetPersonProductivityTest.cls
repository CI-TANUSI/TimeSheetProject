@isTest
private class TimeSheetPersonProductivityTest {

    @isTest
    static void testGetYearlyProductivity() {
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
          
        // Create required Person__c record
        Person__c person = new Person__c(Name = 'Test Person', Account__c = acc.Id, Username__c = 'Nitin@123', Passwords__c = '12234');
        insert person;

        Integer year = 2024;

        // Insert Timesheet__c records 
        List<Timesheet__c> timesheets = new List<Timesheet__c>{
            new Timesheet__c(
                Person__c = person.Id,
                Date__c = Date.newInstance(year, 1, 10),
                 Opportunity__c = Opp.Id,
                Status__c = 'Approved'
            ),
            new Timesheet__c(
                Person__c = person.Id,
                Date__c = Date.newInstance(year, 1, 15),
                Opportunity__c = Opp.Id,
                Status__c = 'Unapproved'
            ),
            new Timesheet__c(
                Person__c = person.Id,
                Date__c = Date.newInstance(year, 2, 5),
                Opportunity__c = Opp.Id,
                Status__c = 'Temporary Approved'
            ),
            new Timesheet__c(
                Person__c = person.Id,
                Date__c = Date.newInstance(year, 12, 20),
                Opportunity__c = Opp.Id,
                Status__c = 'Blank'
            )
        };
        insert timesheets;

        // Execute the method
        Test.startTest();
        List<Map<String, Object>> result = TimeSheetPersonProductivity.getYearlyProductivity(person.Id, year);
        Test.stopTest();

        // Assert 12 months of data
        Assert.areEqual(12, result.size());

        // Optional: Just check keys exist
        for (Map<String, Object> row : result) {
            Assert.IsTrue(row.containsKey('month'), 'Row must have month');
            Assert.IsTrue(row.containsKey('filled'), 'Row must have filled');
            Assert.IsTrue(row.containsKey('approved'), 'Row must have approved');
            Assert.IsTrue(row.containsKey('unapproved'), 'Row must have unapproved');
            Assert.IsTrue(row.containsKey('tempApproved'), 'Row must have tempApproved');
            Assert.IsTrue(row.containsKey('blank'), 'Row must have blank');
        }
    }
}