@isTest
private class TimeSheetEntryTest {

    @testSetup
    static void setupData() {
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create a Manager Person
        Person__c manager = new Person__c(
            Name = 'Manager User',
            Username__c = 'manager@test.com',
            Passwords__c = 'manager123',
            Account__c = acc.Id
        );
        insert manager;

        // Create a test Person (employee) with manager
        Person__c emp = new Person__c(
            Name = 'Test Employee',
            Username__c = 'emp@test.com',
            Passwords__c = 'emp123',
            Account__c = acc.Id,
            Manager__c = manager.Id,
            Extract_Timesheet__c = true,
            Contractor__c = false,
            Timesheet_Entry_Allowed_Days__c = 30
        );
        insert emp;

        // Create Opportunity with Project Code
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Project_Code__c = 'PCODE123'
            );
        insert opp;

        // Link Person and Opportunity via Project_Code_Access__c
        insert new Project_Code_Access__c(
            Person__c = emp.Id,
            Opportunity__c = opp.Id
        );

        // Create Payment Milestone
        Payment_Milestone__c pm = new Payment_Milestone__c(
            Name = 'Milestone 1',
            Opportunity__c = opp.Id,
            Amount__c = 1000
        );
        insert pm;

        // Create Timesheet
        Timesheet__c ts = new Timesheet__c(
            Project_Code__c = 'PCODE123',
            Work_Status__c = 'In Progress',
            Type__c = 'Development',
            Time_Taken__c = 5,
            Technical_description__c = 'Dev work',
            Functional_Description__c = 'Functionality',
            Date__c = Date.today(),
            Person__c = emp.Id,
            Opportunity__c = opp.Id,
            Payment_Milestone__c = pm.Id
        );
        insert ts;

        // Create Timesheet Log
        insert new Timesheet_Log__c(
            Timesheet__c = ts.Id
        );
    }

    @isTest
    static void testGetTimeSheet() {
        Person__c emp = [SELECT Id FROM Person__c WHERE Username__c = 'emp@test.com' LIMIT 1];
        Test.startTest();
        TimeSheetEntry.TimesheetResult result = TimeSheetEntry.getTimeSheet(
            emp.Id,
            Date.today().addDays(-1),
            Date.today().addDays(1),
            1,
            10,
            'Dev'
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.totalRecords > 0);
        System.assert(!result.submittedTimesheetIds.isEmpty());
    }

    @isTest
    static void testCreateTimesheet() {
        Person__c emp = [SELECT Id FROM Person__c WHERE Username__c = 'emp@test.com' LIMIT 1];
        Test.startTest();
        List<Timesheet__c> created = TimeSheetEntry.createTimesheet(
            'PCODE123',
            'QA',
            'In Progress',
             3,
            'Fixing UI bugs',
            'No functional change',
            Date.today(),
            emp.Id
        );
        Test.stopTest();

        System.assertNotEquals(null, created);
        System.assertEquals(1, created.size());
        System.assertEquals('QA', created[0].Type__c);
    }

    @isTest
    static void testGetProjectCodes() {
        Person__c emp = [SELECT Id FROM Person__c WHERE Username__c = 'emp@test.com' LIMIT 1];
        Test.startTest();
        List<Project_Code_Access__c> access = TimeSheetEntry.getProjectCodes(emp.Id);
        Test.stopTest();

      //  System.assert(!access.isEmpty(), 'Should return project access for person');
    }

    @isTest
    static void testGetPersons() {
        Person__c emp = [SELECT Id FROM Person__c WHERE Username__c = 'emp@test.com' LIMIT 1];
        Test.startTest();
        List<Person__c> person = TimeSheetEntry.getPersons(emp.Id);
        Test.stopTest();

        System.assertEquals(1, person.size());
        System.assertEquals(emp.Id, person[0].Id);
    }

    @isTest
    static void testGetTeamRegularizePermission() {
        Person__c manager = [SELECT Id FROM Person__c WHERE Username__c = 'manager@test.com' LIMIT 1];
        Test.startTest();
        Boolean hasPermission = TimeSheetEntry.getTeamRegularizePermission(manager.Id);
        Test.stopTest();

        System.assertEquals(true, hasPermission, 'Manager should have team members');
    }
}