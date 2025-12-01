public without sharing class timeSheetController{
 @AuraEnabled
public static void saveTimesheet(List<Timesheet_Entry__c> entries, String status) {
    try {
        // Collect all Timesheet Dates from incoming entries
        Set<Date> entryDates = new Set<Date>();
        for (Timesheet_Entry__c t : entries) {
            if (t.TimesheetDate__c != null) {
                entryDates.add(t.TimesheetDate__c);
            }
        }

        // Fetch already submitted records for those dates
        List<Timesheet_Entry__c> submittedList = [
            SELECT Id, TimesheetDate__c, Status__c ,TimeTakenInMinutes__c,
            TechnicalDescription__c
            FROM Timesheet_Entry__c 
            WHERE TimesheetDate__c IN :entryDates  
            AND Status__c = 'Submitted'
        ];

        // Convert list to map<Date, Timesheet_Entry__c>
        Map<Date, Timesheet_Entry__c> alreadySubmitted = new Map<Date, Timesheet_Entry__c>();
        for (Timesheet_Entry__c rec : submittedList) {
            alreadySubmitted.put(rec.TimesheetDate__c, rec);
        }

        // If any date is already submitted, stop and throw an error
        if (!alreadySubmitted.isEmpty()) {
            List<String> submittedDates = new List<String>();
            for (Date d : alreadySubmitted.keySet()) {
                submittedDates.add(String.valueOf(d));
            }
            throw new AuraHandledException(
                'Cannot update timesheet. Entries for these dates are already submitted: ' 
                + String.join(submittedDates, ', ')
            );
        }
        // Continue only if no submitted entries exist for those dates
        for (Timesheet_Entry__c t : entries) {
            t.Status__c = status;
        }
        upsert entries;
    } catch (Exception e) {
        throw new AuraHandledException('Error saving timesheet: ' + e.getMessage());
    }
}
@AuraEnabled(cacheable=false)
public static List<Timesheet_Entry__c> getTimesheetEntries( Date startDate, Date endDate) {
    try {
        return [
            SELECT Id, Opportunity__c, TimesheetDate__c, TimeTakenInMinutes__c, TechnicalDescription__c, Status__c
            FROM Timesheet_Entry__c
            WHERE  TimesheetDate__c >= :startDate
            AND TimesheetDate__c <= :endDate
            ORDER BY TimesheetDate__c ASC
        ];
    } catch (Exception e) {
        throw new AuraHandledException('Error fetching timesheet: ' + e.getMessage());
    }
}@AuraEnabled(cacheable=false)
public static Map<String, Object> getTimeSheetDatas(Integer pageNumber, Integer pageSize, String searchKey) {
    Integer offsetValue = (pageNumber - 1) * pageSize;

    // Base query
    String baseQuery = 'SELECT Id, Name, TimesheetDate__c, ProjectCode__c, TimeTakenInMinutes__c, TechnicalDescription__c, Status__c ' +
                       'FROM Timesheet_Entry__c WHERE Id != null';

    // Apply search filter safely
    if (String.isNotBlank(searchKey)) {
        // Escape single quotes to avoid SOQL injection
        String safeKey = String.escapeSingleQuotes(searchKey);
        baseQuery += ' AND (Name LIKE \'%' + safeKey + '%\' ' +
                     'OR ProjectCode__c LIKE \'%' + safeKey + '%\' ' +
                     'OR TechnicalDescription__c LIKE \'%' + safeKey + '%\')';
    }

    // Sorting, limit & offset
    baseQuery += ' ORDER BY TimesheetDate__c DESC LIMIT :pageSize OFFSET :offsetValue';

    // Execute main query
    List<Timesheet_Entry__c> records = Database.query(baseQuery);

    // Count query for pagination
    String countQuery = 'SELECT COUNT() FROM Timesheet_Entry__c WHERE Id != null';
    if (String.isNotBlank(searchKey)) {
        String safeKey = String.escapeSingleQuotes(searchKey);
        countQuery += ' AND (Name LIKE \'%' + safeKey + '%\' ' +
                      'OR ProjectCode__c LIKE \'%' + safeKey + '%\' ' +
                      'OR TechnicalDescription__c LIKE \'%' + safeKey + '%\')';
    }

    Integer totalCount = (Integer)Database.countQuery(countQuery);

    // Return both records and count
    return new Map<String, Object>{
        'records' => records,
        'totalRecords' => totalCount
    };
}


}