@isTest
public class TimeSheetRegularizeTest {

    static testMethod void testTimeSheetRegularizeMethods() {
        
        Account acc = new Account(Name = 'New Account');
        insert acc;
       
        Opportunity opp = new Opportunity(Name = 'New Opp', Stagename = 'Closed Won', Amount = 1000, closeDate = Date.today() );
        insert opp;
        
        Person__c manager = new Person__c(Name = 'Manager Test', Account__c = acc.Id, Username__c = 'Nitin', Passwords__c = '1234');
        insert manager;

       
        Person__c subordinate = new Person__c(Name = 'Subordinate Test', Manager__c = manager.Id, Account__c = acc.Id, Username__c = 'Nitin12', Passwords__c = '12343');
        insert subordinate;

       
        TimeSheet__c ts = new TimeSheet__c(Date__c = Date.today(), Time_Taken__c = 60, Project_Code__c = 'P123' , Opportunity__c = opp.Id);
        insert ts;

       
        List<Timesheet_Log__c> logs = TimeSheetRegularize.createTimesheetLog(
            'Development',
            'Pending',
            120,
            'Tech Desc',
            'Func Desc',
            'P123',
            Date.today(),
            subordinate.Id,
            ts.Id
        );

       Assert.areNotEqual(null, logs);
       Assert.areEqual(1, logs.size());
       Assert.areEqual('Pending', logs[0].Work_Status__c);

        List<Timesheet_Log__c> logsByPerson = TimeSheetRegularize.getTimesheetLog(subordinate.Id);
        Assert.areEqual(1, logsByPerson.size());

        List<Timesheet_Log__c> teamLogs = TimeSheetRegularize.getTeamTimeSheetLog(manager.Id);
        Assert.areEqual(1, teamLogs.size());

        List<TimeSheet__c> updatedTS = TimeSheetRegularize.updateTimeSheetRecord(
            ts.Id,
            150,
            'P456',
            Date.today().addDays(1)
        );
        Assert.areEqual(1, updatedTS.size());
        Assert.areEqual(150, updatedTS[0].Time_Taken__c);
        Assert.areEqual('P456', updatedTS[0].Project_Code__c);

        List<Timesheet_Log__c> approvedLog = TimeSheetRegularize.updateTimeSheetLog(logs[0].Id, 'approve');
        Assert.areEqual('Approved', approvedLog[0].Status__c);

        List<Timesheet_Log__c> rejectedLog = TimeSheetRegularize.updateTimeSheetLog(logs[0].Id, 'reject');
        Assert.areEqual('Rejected', rejectedLog[0].Status__c);
    }
}