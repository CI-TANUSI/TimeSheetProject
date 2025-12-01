public without sharing class TimeSheetTeamProductivity {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTeamProductivity(Integer year, Id personId) {
        Map<String, Object> result = new Map<String, Object>();
        // Query manager (self)
        List<Person__c> managerList = [SELECT Id, Name, Manager__c FROM Person__c WHERE Id = :personId];
        // Query team (direct reports)
        List<Person__c> teamList = [SELECT Id, Name, Manager__c FROM Person__c WHERE Manager__c = :personId];
        List<Person__c> fullTeam = new List<Person__c>();
        fullTeam.addAll(managerList);
        fullTeam.addAll(teamList);
        List<Id> personIds = new List<Id>();
        Map<Id, String> personIdToName = new Map<Id, String>();
        for (Person__c p : fullTeam) {
            personIds.add(p.Id);
            personIdToName.put(p.Id, p.Name);
        }
        // Always use all personIds in fullTeam for the query
        Date startDate = Date.newInstance(year, 1, 1);
        Date endDate = Date.newInstance(year, 12, 31);
        
        List<AggregateResult> ars = [
            SELECT 
            Person__c,
            CALENDAR_MONTH(Date__c) month,
            SUM(Time_Taken_Hour__c) filled,
            SUM(Approved_Time_Hour__c) approved,
            SUM(Unapproved_Time_Hour__c) unapproved,
            SUM(Temporary_Approved_Hour__c) tempApproved,
            Status__c
            FROM Timesheet__c
            WHERE Person__c IN :personIds AND Date__c >= :startDate AND Date__c <= :endDate
            GROUP BY Person__c, CALENDAR_MONTH(Date__c), Status__c
        ];
        
        // Build a map: personId -> month -> summary
        Map<Id, Map<Integer, Map<String, Object>>> personMonthMap = new Map<Id, Map<Integer, Map<String, Object>>>();
        for (AggregateResult ar : ars) {
            Id pid = (Id)ar.get('Person__c');
            Integer m = (Integer)ar.get('month');
            String status = (String)ar.get('Status__c');
            if (!personMonthMap.containsKey(pid)) personMonthMap.put(pid, new Map<Integer, Map<String, Object>>());
            if (!personMonthMap.get(pid).containsKey(m)) {
                personMonthMap.get(pid).put(m, new Map<String, Object>{
                    'filled' => 0, 'approved' => 0, 'unapproved' => 0, 'tempApproved' => 0, 'blank' => 0
                        });
            }
            Map<String, Object> summary = personMonthMap.get(pid).get(m);
            summary.put('filled', ((Decimal)summary.get('filled')) + ((Decimal)ar.get('filled')));
            summary.put('approved', ((Decimal)summary.get('approved')) + ((Decimal)ar.get('approved')));
            summary.put('unapproved', ((Decimal)summary.get('unapproved')) + ((Decimal)ar.get('unapproved')));
            summary.put('tempApproved', ((Decimal)summary.get('tempApproved')) + ((Decimal)ar.get('tempApproved')));
            if (status == 'Blank') {
                summary.put('blank', ((Decimal)summary.get('blank')) + ((Decimal)ar.get('filled')));
            }
        }
        
        // Build result: for each person, for each month (1-12), add a row (even if no data)
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        for (Id pid : personIds) {
            for (Integer m = 1; m <= 12; m++) {
                Map<String, Object> summary = personMonthMap.containsKey(pid) && personMonthMap.get(pid).containsKey(m)
                    ? personMonthMap.get(pid).get(m)
                    : new Map<String, Object>{'filled'=>0, 'approved'=>0, 'unapproved'=>0, 'tempApproved'=>0, 'blank'=>0};
                        Map<String, Object> row = new Map<String, Object>();
                row.put('personId', pid);
                row.put('personName', personIdToName.get(pid));
                row.put('month', m);
                row.put('filled', summary.get('filled'));
                row.put('approved', summary.get('approved'));
                row.put('unapproved', summary.get('unapproved'));
                row.put('tempApproved', summary.get('tempApproved'));
                row.put('blank', summary.get('blank'));
                rows.add(row);
            }
        }
        // Also return the team list for the UI (manager + team)
        List<Map<String, String>> teamResult = new List<Map<String, String>>();
        for (Person__c p : fullTeam) {
            teamResult.add(new Map<String, String>{
                'id'=>p.Id,
                    'name'=>p.Name,
                    'managerId'=>p.Manager__c != null ? String.valueOf(p.Manager__c) : ''
                        });
        }
        result.put('team', teamResult);
        result.put('rows', rows);
        return result;
    }
    
}