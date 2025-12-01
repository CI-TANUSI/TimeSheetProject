@isTest
private class TimeSheetAssignedProjectCodesTest {

    @isTest
    static void testAllMethods() {
       
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        List<Person__c> users = new List<Person__c>();
        for (Integer i = 0; i < 3; i++) {
            users.add(new Person__c(
                Name = 'User ' + i,
                Username__c = 'user' + i + '@test.com',
                Passwords__c = 'test' + i,
                Account__c = acc.Id 
            ));
        }
        insert users;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;

        insert new Project_Code_Access__c(
            Opportunity__c = opp.Id,
            Person__c = users[0].Id
        );

        List<Person__c> assigned = TimeSheetAssignedProjectCodes.getAssignedUsers(opp.Id);
         Assert.areEqual(1, assigned.size(), 'One user should be assigned');
         Assert.areEqual(users[0].Id, assigned[0].Id);

        List<Person__c> unassigned = TimeSheetAssignedProjectCodes.getAllUsers(opp.Id);
         Assert.areEqual(2, unassigned.size(), 'Two users should be unassigned');

        List<Id> toAssign = new List<Id>{ users[1].Id, users[2].Id };
        TimeSheetAssignedProjectCodes.createProjectCodeAccess(opp.Id, toAssign);

        List<Person__c> allAssigned = TimeSheetAssignedProjectCodes.getAssignedUsers(opp.Id);
        Assert.areEqual(3, allAssigned.size(), 'All users should be assigned');
        
        TimeSheetAssignedProjectCodes.deleteProjectCodeAccess(opp.Id, toAssign);
        
        List<Person__c> finalAssigned = TimeSheetAssignedProjectCodes.getAssignedUsers(opp.Id);
        Assert.areEqual(1, finalAssigned.size(), 'Only one user should remain assigned');
        Assert.areEqual(users[0].Id, finalAssigned[0].Id);
    }
}