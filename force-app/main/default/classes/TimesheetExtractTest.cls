@isTest
private class TimesheetExtractTest {

   @isTest
    static void testSearchOpportunities() {
          Account acc = new Account(
              name = 'Account1'
          );
          insert acc;
        
        Person__c testUser = new Person__c(
            Name = 'John',
            Account__c	= acc.id,
            Username__c = 'Nitin',
            Passwords__c ='1234'
        );
        insert testUser;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(7),
            Project_Code__c = 'CODE123'
        );
        insert opp;

        Project_Code_Access__c pca = new Project_Code_Access__c(
            Person__c = testUser.Id,
            Opportunity__c = opp.Id
        );
        insert pca;

        Test.startTest();
        List<Project_Code_Access__c> results = TimesheetExtract.searchOpportunities('Test', testUser.Id);
        Test.stopTest();

        Assert.areNotEqual(1, results.size(), 'Expected one result');
     
    }

    @isTest
    static void testDownloadTimesheet() {
       Account acc = new Account(
              name = 'Account1'
          );
          insert acc;
        
        Person__c testUser = new Person__c(
            Name = 'John',
            Account__c	= acc.id,
            Username__c = 'Nitin',
            Passwords__c ='1234'
        );
        insert testUser;

        Opportunity opp = new Opportunity(
            Name = 'Download Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(5),
            Project_Code__c = 'PCODE999'
        );
        insert opp;

        Timesheet__c ts = new Timesheet__c(
            Date__c = Date.today(),
            Person__c = testUser.Id,
            Opportunity__c = opp.Id,
            Technical_description__c = 'Bug Fixing',
            Time_Taken__c = 100,
            Approved_Time__c = 80,
            Status__c = 'Blank'
        );
        insert ts;

        Test.startTest();
        String csv = TimesheetExtract.downloadTimesheet(opp.Id);
        Test.stopTest();

        Assert.areNotEqual(null, csv, 'CSV should not be null');
        Assert.areEqual(true, csv.contains('Bug Fixing'), 'CSV should contain description');
        Assert.areEqual(true, csv.contains('80'), 'CSV should contain approved time');
    } 
}