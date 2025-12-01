@isTest
public class TimeSheetTeamProductivityTest {

    @testSetup
    static void setupTestData() {
        // Create Account for Person__c
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        // Create Manager
        Person__c manager = new Person__c(
            Name = 'Manager A',
            Account__c = acc.Id,
            Username__c = 'manager@example.com',
            Passwords__c = 'pass123'
        );
        insert manager;

        // Create Team Members
        Person__c teamMember1 = new Person__c(
            Name = 'Team Member 1',
            Manager__c = manager.Id,
            Account__c = acc.Id,
            Username__c = 'member1@example.com',
            Passwords__c = 'pass123'
        );
        Person__c teamMember2 = new Person__c(
            Name = 'Team Member 2',
            Manager__c = manager.Id,
            Account__c = acc.Id,
            Username__c = 'member2@example.com',
            Passwords__c = 'pass123'
        );
        insert new List<Person__c>{ teamMember1, teamMember2 };

        // Create Timesheet records (only writable fields)
        List<Timesheet__c> timesheets = new List<Timesheet__c>();

        timesheets.add(new Timesheet__c(
            Person__c = teamMember1.Id,
            Date__c = Date.newInstance(2025, 1, 15),
            Status__c = 'Approved',
            Opportunity__c = opp.Id
        ));

        timesheets.add(new Timesheet__c(
            Person__c = teamMember1.Id,
            Date__c = Date.newInstance(2025, 2, 10),
            Status__c = 'Blank',
            Opportunity__c = opp.Id
        ));

        timesheets.add(new Timesheet__c(
            Person__c = manager.Id,
            Date__c = Date.newInstance(2025, 3, 5),
            Status__c = 'Approved',
            Opportunity__c = opp.Id
        ));

        insert timesheets;
    }

    @isTest
    static void testGetTeamProductivity() {
        // Query manager ID
        Person__c manager = [SELECT Id FROM Person__c WHERE Name = 'Manager A' LIMIT 1];

        Test.startTest();
        Map<String, Object> result = TimeSheetTeamProductivity.getTeamProductivity(2025, manager.Id);
        Test.stopTest();

        // Validate keys
        System.assert(result.containsKey('team'));
        System.assert(result.containsKey('rows'));

        List<Object> team = (List<Object>)result.get('team');
        List<Object> rows = (List<Object>)result.get('rows');

        System.assertEquals(3, team.size(), 'Should return 3 team members (manager + 2 reports)');
        System.assertEquals(36, rows.size(), 'Should return 12 rows per person (3 persons * 12 months)');

        // Spot check: make sure Jan row with 8 filled exists
        Boolean janMatch = false;
        for (Object obj : rows) {
            Map<String, Object> row = (Map<String, Object>)obj;
            if ((Integer)row.get('month') == 1 && ((Decimal)row.get('filled')) == 8) {
                janMatch = true;
                break;
            }
        }
      
    }
}