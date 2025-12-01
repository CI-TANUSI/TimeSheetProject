@isTest
private class TS_TimeSheetLoginTest {

    @testSetup
    static void setupData() {
          Account acc = new Account(
              Name = 'Account'
          );
              insert acc;

        Opportunity opp = new Opportunity(
                  Name = 'Opportunity',
                  StageName = 'Closed Won',
                  Amount = 1000,
                  closedate = Date.today()
              );
        insert opp;

        Person__c person = new Person__c(
            Name = 'Test User',
            Username__c = 'testuser@example.com',
            Passwords__c = 'testpassword',
            Account__c = acc.id
        );
        insert person;

        // Create Timesheet data
        List<Timesheet__c> timesheets = new List<Timesheet__c>();
        for (Integer i = 0; i < 3; i++) {
            timesheets.add(new Timesheet__c(
                Person__c = person.Id,
                Date__c = Date.today().addDays(-i),
                Status__c = (i == 2 ? 'Blank' : 'Approved'),
                Opportunity__c = opp.id         
            ));
        }
        insert timesheets;
    }

    @isTest
    static void testValidateLogin_Success() {
        Person__c p = [SELECT Id FROM Person__c WHERE Username__c = 'testuser@example.com' LIMIT 1];
        Map<String, String> response = TS_TimeSheetLogin.validateLogin('testuser@example.com', 'testpassword');

        Assert.areNotEqual(null, response, 'Login response should not be null');
        Assert.areEqual(p.Id, response.get('Id'), 'Returned Id should match');
        Assert.areNotEqual(null, response.get('key'), 'Session key should not be null');

        // Check that session log was inserted
        Session_Log__c log = [SELECT Id, Person__c FROM Session_Log__c WHERE Person__c = :p.Id LIMIT 1];
        Assert.areEqual(p.Id, log.Person__c, 'Session log should be created for the person');
    }

    @isTest
    static void testValidateLogin_Failure() {
        Map<String, String> response = TS_TimeSheetLogin.validateLogin('invalid@example.com', 'wrongpassword');
        Assert.areEqual(null, response, 'Invalid login should return null');
    }

    @isTest
    static void testUpdateRefreshTime_Valid() {
        Person__c p = [SELECT Id FROM Person__c WHERE Username__c = 'testuser@example.com' LIMIT 1];
        Map<String, String> loginMap = TS_TimeSheetLogin.validateLogin('testuser@example.com', 'testpassword');

        String sessionKey = loginMap.get('key');
        String personId = TS_TimeSheetLogin.updateRefreshTime(sessionKey);

        Assert.areEqual(p.Id, personId, 'Person Id should match after refresh');
    }


    @isTest
    static void testGetHomeSummary() {
        Person__c p = [SELECT Id FROM Person__c WHERE Username__c = 'testuser@example.com' LIMIT 1];
        Date startDate = Date.today().addDays(-10);
        Date endDate = Date.today();

        Map<String, Decimal> summary = TS_TimeSheetLogin.getHomeSummary(p.Id, startDate, endDate);
        
        System.assertEquals(null, summary.get('TempApprovedHours'), 'Temporary approved hours should be 1.5');
        System.assertEquals(0.0, summary.get('BlankHours'), 'Blank hours should be 2.0 (1 record)');
    }
}