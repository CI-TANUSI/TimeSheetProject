public without sharing class TimeSheetEntry {
   @AuraEnabled
public static TimesheetResult getTimeSheet(
    Id PersonId,
    Date startDate,
    Date endDate,
    Integer pageNumber,
    Integer pageSize,
    String searchKey
) {
    Integer offset = (pageNumber - 1) * pageSize;
    
    // Base filter
    String baseWhere = 'Person__c = :PersonId';
    if (startDate != null) baseWhere += ' AND TimesheetDate__c >= :startDate';
    if (endDate != null) baseWhere += ' AND TimesheetDate__c <= :endDate';
    
    // Search filter
    String searchFilter = '';
    if (String.isNotBlank(searchKey)) {
        String likeKey = '%' + searchKey + '%';
        searchFilter = ' AND (' +
            'Name LIKE :likeKey OR ' +
            'ProjectCode__c LIKE :likeKey OR ' +
            'Status__c LIKE :likeKey OR ' +
            'TechnicalDescription__c LIKE :likeKey OR ' +
            'Opportunity__c LIKE :likeKey' +
            ')';
    }
    
    String whereClause = baseWhere + searchFilter;
    
    // Fetch timesheet entries
    List<Timesheet_Entry__c> timesheets = Database.query(
        'SELECT Id, Name, TimesheetDate__c, ProjectCode__c, TimeTakenInMinutes__c, ' +
        'Status__c, TechnicalDescription__c, Opportunity__c ' +
        'FROM Timesheet_Entry__c WHERE ' + whereClause +
        ' ORDER BY TimesheetDate__c DESC LIMIT :pageSize OFFSET :offset'
    );
    
    // Count total records
    Integer totalRecords = Database.countQuery(
        'SELECT count() FROM Timesheet_Entry__c WHERE ' + whereClause
    );
    
    // Collect Timesheet IDs
    Set<Id> timesheetIds = new Set<Id>();
    for (Timesheet_Entry__c ts : timesheets) {
        timesheetIds.add(ts.Id);
    }
    // Fetch related logs (assuming Timesheet_Log__c has lookup to Timesheet_Entry__c)
    Map<Id, Timesheet_Log__c> logs = new Map<Id, Timesheet_Log__c>(
        [SELECT Timesheet_Entry__c FROM Timesheet_Log__c WHERE Timesheet_Entry__c IN :timesheetIds]
    );
    
    // Identify submitted timesheet IDs
    Set<Id> submittedIds = new Set<Id>();
    for (Timesheet_Log__c log : logs.values()) {
        submittedIds.add(log.Timesheet_Entry__c);
    }
    // Prepare result
    TimesheetResult result = new TimesheetResult();
    result.timesheets = timesheets;
    result.totalRecords = totalRecords;
    result.submittedTimesheetIds = submittedIds;  
    return result;
}
     @AuraEnabled(cacheable=true)
    public static List<Timesheet_Entry__c> getTimeSheetData() {
        return [
            SELECT Id,
                   Name,
                   TimesheetDate__c,
                   ProjectCode__c,
                   TimeTakenInMinutes__c,
                   TechnicalDescription__c,
                   Status__c
            FROM Timesheet_Entry__c
            LIMIT 50
        ];
    }

    
    @AuraEnabled(cacheable=true)
    public static List<Project_Code_Access__c> getProjectCodes(Id personId) {
        return [Select Opportunity__c,Person__c,Opportunity__r.Project_Code__c from Project_Code_Access__c where person__c= :personId AND IsActive__c = true];
        
    }
    
    
    @AuraEnabled
    public static List<person__c> getPersons(Id PersonId){
        return [SELECT Id,Name,Extract_Timesheet__c,Contractor__c,Timesheet_Entry_Allowed_Days__c 
                FROM Person__c 
                WHERE Id = :PersonId];
    }
    @AuraEnabled
    public static Boolean getTeamRegularizePermission(String personId){
        List<Person__c> teamRegularizeList = [Select id from Person__c where Manager__c = :personId];
        return !teamRegularizeList.isEmpty();
        
    }
    
    
   public class TimesheetResult {
    @AuraEnabled
    public List<Timesheet_Entry__c> timesheets { get; set; }

    @AuraEnabled
    public Integer totalRecords { get; set; }

    @AuraEnabled 
    public Set<Id> submittedTimesheetIds { get; set; }
}
    @AuraEnabled
    public static List<Timesheet__c> createTimesheet(
        String ProjectCode,
        String WorkType, 
        String WorkStatus, 
        Integer TimeTaken, 
        String Technical,                           
        String Functional,
        Date Dates,
        Id PersonId ) {
            
            List<Opportunity> oppList = new List<Opportunity>();                                                
            if (ProjectCode != null) {
                oppList = [Select id from Opportunity where Project_Code__c = :ProjectCode LIMIT 1];                                             
            }   
            
             Opportunity selectedOpp;
             if (!oppList.isEmpty()) {
                 selectedOpp = oppList[0];
             }

            List<Timesheet__c> newlist = new List<Timesheet__c>();
            Timesheet__c cc = new Timesheet__c();
            cc.Project_Code__c = ProjectCode;
            cc.Work_Status__c = WorkStatus;
            cc.Type__c = WorkType;
            cc.Time_Taken__c = TimeTaken;
            cc.Technical_description__c = Technical;
            cc.Functional_Description__c = Functional;
            cc.Date__c = Dates;
            cc.Person__c = PersonId;
            cc.Opportunity__c = selectedOpp.id;                                               
            newlist.add(cc);
            
            if (!newlist.IsEmpty()) {
                insert newlist;
                return newlist;
            }
            
            return null;
        }
    
}