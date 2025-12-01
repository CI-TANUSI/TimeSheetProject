public without sharing class TimeSheetPersonProductivity {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getYearlyProductivity(Id personId, Integer year) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        Date startDate = Date.newInstance(year, 1, 1);
        Date endDate = Date.newInstance(year, 12, 31);
    
        // Query all records for the year, grouped by month and status
        List<AggregateResult> ars = [
            SELECT 
                CALENDAR_MONTH(Date__c) month,
                Status__c status,
                SUM(Time_Taken_Hour__c) filled,
                SUM(Approved_Time_Hour__c) approved,
                SUM(Unapproved_Time_Hour__c) unapproved,
                SUM(Temporary_Approved_Hour__c) tempApproved
            FROM Timesheet__c
            WHERE Person__c = :personId AND Date__c >= :startDate AND Date__c <= :endDate
            GROUP BY CALENDAR_MONTH(Date__c), Status__c
        ];
    
        // Prepare a map: month -> status -> AggregateResult
        Map<Integer, Map<String, AggregateResult>> monthStatusMap = new Map<Integer, Map<String, AggregateResult>>();
        for (AggregateResult ar : ars) {
            Integer month = (Integer)ar.get('month');
            String status = (String)ar.get('status');
            if (!monthStatusMap.containsKey(month)) {
                monthStatusMap.put(month, new Map<String, AggregateResult>());
            }
            monthStatusMap.get(month).put(status, ar);
        }
    
        // Build the result for all 12 months
        for (Integer m = 1; m <= 12; m++) {
            Map<String, AggregateResult> statusMap = monthStatusMap.get(m);
            Decimal filled = 0, approved = 0, unapproved = 0, tempApproved = 0, blank = 0;
            if (statusMap != null) {
                for (String status : statusMap.keySet()) {
                    AggregateResult ar = statusMap.get(status);
                    filled += (Decimal)ar.get('filled');
                    approved += (Decimal)ar.get('approved');
                    unapproved += (Decimal)ar.get('unapproved');
                    tempApproved += (Decimal)ar.get('tempApproved');
                    if (status == 'Blank') {
                        blank += (Decimal)ar.get('filled');
                    }
                }
            }
            Map<String, Object> row = new Map<String, Object>();
            row.put('month', m);
            row.put('filled', filled);
            row.put('approved', approved);
            row.put('unapproved', unapproved);
            row.put('tempApproved', tempApproved);
            row.put('blank', blank);
            result.add(row);
        }
        return result;
    }
    
}