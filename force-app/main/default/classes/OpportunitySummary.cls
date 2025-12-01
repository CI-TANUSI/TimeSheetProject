public with sharing class OpportunitySummary {

    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getSummary(String recordId) {
        Map<String, Decimal> summary = new Map<String, Decimal>{
            'FilledHours' => 0,
            'ApprovedHours' => 0,
            'UnapprovedHours' => 0,
            'BlankHours' => 0
        };
        if (String.isBlank(recordId) || recordId.length() < 3) {
            return summary;
        }
        String prefix = recordId.substring(0,3);
        String whereClause;
        if (prefix == '006') {
            whereClause = 'Opportunity__c = :recordId';
        } else {
            whereClause = 'Payment_Milestone__c = :recordId';
        }
        List<AggregateResult> results = Database.query(
            'SELECT SUM(Time_Taken_Hour__c) totalFilled, ' +
            'SUM(Approved_Time_Hour__c) totalApproved, ' +
            'SUM(Unapproved_Time_Hour__c) totalUnapproved ' +
            'FROM Timesheet__c WHERE ' + whereClause
        );
        if (!results.isEmpty()) {
            AggregateResult ar = results[0];
            summary.put('FilledHours', (Decimal)ar.get('totalFilled') ?? 0);
            summary.put('ApprovedHours', (Decimal)ar.get('totalApproved') ?? 0);
            summary.put('UnapprovedHours', (Decimal)ar.get('totalUnapproved') ?? 0);
        }
        List<AggregateResult> blankResults = Database.query(
            'SELECT SUM(Time_Taken_Hour__c) totalBlank FROM Timesheet__c WHERE ' + whereClause + ' AND (Status__c = \'Blank\')'
        );
        Decimal blankHours = 0;
        if (!blankResults.isEmpty() && blankResults[0].get('totalBlank') != null) {
            blankHours = (Decimal)blankResults[0].get('totalBlank');
        }
        summary.put('BlankHours', blankHours);
        return summary;
    }
}