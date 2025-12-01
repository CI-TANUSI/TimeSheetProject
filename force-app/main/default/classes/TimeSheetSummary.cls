public without sharing class TimeSheetSummary {
@AuraEnabled(cacheable=true)
public static Map<String, Decimal> getHomeSummary(Id personId, Date startDate, Date endDate) {
    Map<String, Decimal> summary = new Map<String, Decimal>{
        'FilledHours' => 0,
        'ApprovedHours' => 0,
        'UnapprovedHours' => 0,
        'TempApprovedHours' => 0,
        'BlankHours' => 0
    };

    List<AggregateResult> results = [
        SELECT
            SUM(Time_Taken_Hour__c) totalFilled,
            SUM(Approved_Time_Hour__c) totalApproved,
            SUM(Unapproved_Time_Hour__c) totalUnapproved,
            SUM(Temporary_Approved_Hour__c) totalTempApproved
        FROM Timesheet__c
        WHERE Person__c = :personId
        AND Date__c >= :startDate
        AND Date__c <= :endDate
    ];

    if (!results.isEmpty()) {
        AggregateResult ar = results[0];
        summary.put('FilledHours', (Decimal)ar.get('totalFilled'));
        summary.put('ApprovedHours', (Decimal)ar.get('totalApproved'));
        summary.put('UnapprovedHours', (Decimal)ar.get('totalUnapproved'));
        summary.put('TempApprovedHours', (Decimal)ar.get('totalTempApproved'));
    }

    // Blank Hours: Time_Taken__c where Work_Status__c is null or blank
    List<AggregateResult> blankResults = [
        SELECT SUM(Time_Taken_Hour__c) totalBlank
        FROM Timesheet__c
        WHERE Person__c = :personId
        AND Date__c >= :startDate
        AND Date__c <= :endDate
        AND (Status__c = 'Blank')
    ];
    if (!blankResults.isEmpty()) {
        summary.put('BlankHours', (Decimal)blankResults[0].get('totalBlank'));
    }

    return summary;
}

@AuraEnabled(cacheable=true)
public static Map<String, Decimal> getFilledHoursByDate(Id personId) {
    Map<String, Decimal> result = new Map<String, Decimal>();

    for (AggregateResult ar : [
        SELECT Date__c,Sum(Time_Taken_Hour__c) total
        FROM Timesheet__c
        WHERE Person__c = :personId AND Date__c <= TODAY
        Group By Date__c
        
    ]) {
        Date d = (Date) ar.get('Date__c');
        
        String yearStr = String.valueOf(d.year());
        String monthStr = d.month() < 10 ? '0' + d.month() : String.valueOf(d.month());
        String dayStr = d.day() < 10 ? '0' + d.day() : String.valueOf(d.day());
        String key = yearStr + '-' + monthStr + '-' + dayStr;

        result.put(key, (Decimal)ar.get('total'));
    }

    System.debug('Filled hours map: ' + result);
    return result;
    System.debug
}

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getLeaderBoard() {
List<Map<String, Object>> result = new List<Map<String, Object>>();
for (AggregateResult ar : [
    SELECT Person__r.Name name, SUM(Approved_Time_Hour__c) approved
    FROM Timesheet__c
    WHERE Date__c <= TODAY AND person__c!= null AND Person__r.Profile__c In ('Developer','QA','B.A') AND Person__r.IsActive__c = true
    GROUP BY Person__r.Name
    ORDER BY SUM(Approved_Time_Hour__c) DESC
]) {
    Map<String, Object> row = new Map<String, Object>();
    row.put('name', (String)ar.get('name'));
    row.put('approved', (Decimal)ar.get('approved'));
    result.add(row);
}
return result;
}
}