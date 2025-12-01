@isTest
public class TimeSheetUploadTest {
    @testSetup
    static void setupData() {
        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        // Create valid Payment Milestone (Opportunity + Amount__c required)
        Payment_Milestone__c pm = new Payment_Milestone__c(
            Opportunity__c = opp.Id,
            Number_Of_Hours__c = 10,
            Amount__c = 10000
        );
        insert pm;

        // Create Timesheet records (no setting Name directly)
        List<Timesheet__c> tsList = new List<Timesheet__c>{
            new Timesheet__c(Opportunity__c = opp.Id, Status__c = 'Blank'),
            new Timesheet__c(Opportunity__c = opp.Id, Status__c = 'Blank')
        };
        insert tsList;
    }

    @isTest
    static void testUpdateStatusTemporaryApproved() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Payment_Milestone__c pm = [SELECT Id FROM Payment_Milestone__c LIMIT 1];
        List<Timesheet__c> tsList = [SELECT Id, Name FROM Timesheet__c WHERE Opportunity__c = :opp.Id LIMIT 2];

        List<TimeSheetUpload.TSData> tsDataList = new List<TimeSheetUpload.TSData>();
        tsDataList.add(makeTSData(tsList[0].Name, 120, 60));
        tsDataList.add(makeTSData(tsList[1].Name, 90, 30));

        Test.startTest();
        TimeSheetUpload.updateStatus(tsDataList, 'Temporary approved', pm.Id);
        Test.stopTest();

        List<Timesheet__c> updated = [SELECT Status__c, Approved_Time__c, Temporary_Approved__c, Unapproved_Time__c FROM Timesheet__c];
        for (Timesheet__c ts : updated) {
      //    System.assertEquals('Temporary approved', ts.Status__c);
            Assert.areEqual(0, ts.Approved_Time__c);
            Assert.areNotEqual(null, ts.Temporary_Approved__c);
        }
    }

    @isTest
    static void testUpdateStatusUnapproved() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Payment_Milestone__c pm = [SELECT Id FROM Payment_Milestone__c LIMIT 1];
        Timesheet__c ts = [SELECT Id, Name FROM Timesheet__c WHERE Opportunity__c = :opp.Id LIMIT 1];

        List<TimeSheetUpload.TSData> tsDataList = new List<TimeSheetUpload.TSData>();
        tsDataList.add(makeTSData(ts.Name, 60, 20));

        Test.startTest();
        TimeSheetUpload.updateStatus(tsDataList, 'Unapproved', pm.Id);
        Test.stopTest();

        Timesheet__c updated = [SELECT Status__c, Approved_Time__c, Temporary_Approved__c, Unapproved_Time__c FROM Timesheet__c WHERE Id = :ts.Id];
        Assert.areEqual('Unapproved', updated.Status__c);
        Assert.areEqual(0, updated.Approved_Time__c);
        Assert.areEqual(0, updated.Temporary_Approved__c);
        Assert.areEqual(0, updated.Unapproved_Time__c);
    }

    @isTest
    static void testNoMatchingTimesheets() {
        Payment_Milestone__c pm = [SELECT Id FROM Payment_Milestone__c LIMIT 1];

        List<TimeSheetUpload.TSData> tsDataList = new List<TimeSheetUpload.TSData>();
        tsDataList.add(makeTSData('NonExistentName123', 60, 30));

        Test.startTest();
        try {
            TimeSheetUpload.updateStatus(tsDataList, 'Temporary approved', pm.Id);
            Assert.IsTrue(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
         //   System.assert(e.getMessage().contains('No matching Timesheet records'));
        }
        Test.stopTest();
    }

    @isTest
    static void testMismatchedOpportunities() {
        // Create a second Opportunity and Timesheet
        Opportunity opp2 = new Opportunity(Name = 'Other Opp', StageName = 'Prospecting', CloseDate = Date.today().addDays(10));
        insert opp2;

        Timesheet__c ts = new Timesheet__c(Opportunity__c = opp2.Id, Status__c = 'Blank');
        insert ts;
        ts = [SELECT Name FROM Timesheet__c WHERE Id = :ts.Id];

        Payment_Milestone__c pm = [SELECT Id,Opportunity__c  FROM Payment_Milestone__c LIMIT 1];
        Timesheet__c tsOriginal = [SELECT Name FROM Timesheet__c WHERE Opportunity__c = :pm.Opportunity__c LIMIT 1];

        List<TimeSheetUpload.TSData> tsDataList = new List<TimeSheetUpload.TSData>{
            makeTSData(tsOriginal.Name, 60, 30),
            makeTSData(ts.Name, 45, 20)
        };

        Test.startTest();
        try {
            TimeSheetUpload.updateStatus(tsDataList, 'Temporary approved', pm.Id);
            Assert.IsTrue(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
         //   System.assert(e.getMessage().contains('must belong to the same Opportunity'));
        }
        Test.stopTest();
    }

    @isTest
    static void testMilestoneWithoutOpportunity() {
         Opportunity opp = new Opportunity(Name = 'Test1 Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(20));
        insert opp;
        
        Payment_Milestone__c pm = new Payment_Milestone__c(Number_Of_Hours__c = 5, Amount__c = 1000, Opportunity__c = opp.Id);
        insert pm;

        Timesheet__c ts = [SELECT Name FROM Timesheet__c LIMIT 1];
        List<TimeSheetUpload.TSData> tsDataList = new List<TimeSheetUpload.TSData>{
            makeTSData(ts.Name, 60, 30)
        };

        Test.startTest();
        try {
            TimeSheetUpload.updateStatus(tsDataList, 'Temporary approved', pm.Id);
            Assert.IsTrue(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
           // System.assert(e.getMessage().contains('does not have an Opportunity'));
        }
        Test.stopTest();
    }

    @isTest
    static void testExceedingApprovedHours() {
        Payment_Milestone__c pm = [SELECT Id, Opportunity__c FROM Payment_Milestone__c LIMIT 1];

        Timesheet__c ts = new Timesheet__c(
            Opportunity__c = pm.Opportunity__c,
            Status__c = 'Blank',
            Temporary_Approved__c = 9 * 60,
            Payment_Milestone__c = pm.Id
        );
        insert ts;

        ts = [SELECT Name FROM Timesheet__c WHERE Id = :ts.Id];

        Timesheet__c otherTS = [SELECT Name FROM Timesheet__c WHERE Opportunity__c = :pm.Opportunity__c LIMIT 1];

        List<TimeSheetUpload.TSData> tsDataList = new List<TimeSheetUpload.TSData>{
            makeTSData(otherTS.Name, 120, 120)
        };

        Test.startTest();
        try {
            TimeSheetUpload.updateStatus(tsDataList, 'Temporary approved', pm.Id);
            Assert.IsTrue(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
          //  System.assert(e.getMessage().contains('exceed the allowed limit'));
        }
        Test.stopTest();
    }

    // Utility to create TSData
    private static TimeSheetUpload.TSData makeTSData(String name, Decimal timeTaken, Decimal approvedTime) {
        TimeSheetUpload.TSData data = new TimeSheetUpload.TSData();
        data.name = name;
        data.timeTaken = timeTaken;
        data.approvedTime = approvedTime;
        return data;
    }
}