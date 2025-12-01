public  without sharing class TimeSheetRegularize {
    
    @AuraEnabled
    public static List<Timesheet_Log__c> createTimesheetLog(
        String WorkType, 
        String WorkStatus, 
        Integer TimeTaken, 
        String Technical,                           
        String Functional,
        String  ProjectCode,
        Date Dates, 
        Id PersonId,
        Id TimesheetId) {
            
             List<Timesheet_Log__c> newlist = new List<Timesheet_Log__c>();
            Timesheet_Log__c cc = new Timesheet_Log__c();
            cc.Work_Status__c = WorkStatus;
            cc.Type__c = WorkType;
            cc.Time_Taken_Minutes__c = TimeTaken;
            cc.Technical_description__c = Technical;
            cc.Functional_Description__c = Functional;
            cc.Date__c = Dates;
            cc.Person__c = PersonId;
            cc.Timesheet_Entry__c	= TimesheetId; 
            cc.Project_Code__c = ProjectCode;
            newlist.add(cc);
            
            
            if (!newlist.IsEmpty()) {
                insert newlist;
                return newlist;
            }
            
            return null;
        }
    
    
    @AuraEnabled
    public static List<Timesheet_Log__c> getTimesheetLog(Id Personid){
        return [ 
            SELECT Id, Name,Status__c, Person__r.Name,Timesheet__r.Time_Taken__c,Timesheet__r.Date__c,Timesheet__r.Project_Code__c,
            Date__c, Project_Code__c,Time_Taken_Minutes__c, Technical_description__c,Functional_Description__c
            FROM Timesheet_Log__c 
            WHERE person__c = :Personid
        ];
    }
    
    @AuraEnabled
    public static List<Timesheet_Log__c> getTeamTimeSheetLog(String personId){
        List<Timesheet_Log__c> teamTimeSheetList =
            [
                SELECT Id, Name,Status__c, Person__r.Name,Timesheet__r.Time_Taken__c,Timesheet__r.Date__c,Timesheet__r.Project_Code__c,
                Date__c, Project_Code__c,Time_Taken_Minutes__c, Technical_description__c,Functional_Description__c
                FROM Timesheet_Log__c 
                WHERE Status__c ='Pending' AND person__c IN (Select id from Person__c where Manager__c = :personId)
            ];
        return teamTimeSheetList;
    }
    
    @AuraEnabled
    public static List<TimeSheet__c> updateTimeSheetRecord(String timesheetId, Decimal timeTaken, String projectCode, Date dates){
        List<Opportunity> oppList = new List<Opportunity>();                                                
        oppList = [SELECT Id FROM Opportunity WHERE Project_Code__c = :projectCode LIMIT 1];
        
        Opportunity selectedOpp;
        if(!oppList.IsEmpty()){
            selectedOpp = oppList[0];
        }
        
        
        List<Timesheet__c> timeSheetList = new List<Timesheet__c>();
        Timesheet__c timeSheet = new Timesheet__c();
        timeSheet.Id = timesheetId;
        timeSheet.Date__c = dates;
        timeSheet.Time_Taken__c = timeTaken;
        timeSheet.Project_Code__c = projectCode;
        timeSheet.Opportunity__c = selectedOpp?.id;
        timesheetList.add(timeSheet);
        
        if (!timesheetList.IsEmpty()) {
            update timesheetList;
            return timesheetList;
        }
        
        return null;
    }
    
    @AuraEnabled
    public static List<Timesheet_Log__c> updateTimeSheetLog(String timesheetLogId, String actionName){
        List<Timesheet_Log__c> newlist = new List<Timesheet_Log__c>();
        
        Timesheet_Log__c cc = new Timesheet_Log__c();
        cc.id = timesheetLogId; 
        if(actionName == 'approve'){
            cc.Status__c = 'Approved';
        }
        else {
            cc.Status__c = 'Rejected';
        }
        newlist.add(cc);
        
        if (!newlist.IsEmpty()) {
            update newlist;
            return newlist;
        }
        return null;
        
    }
    
    
}