public inherited sharing class TimeSheetPortalService {
    private static TimeSheetPortalService serviceInstance;
    public static TimeSheetPortalService getInstance() {
        if (serviceInstance == null) {
            serviceInstance = new TimeSheetPortalService();
        }
        return serviceInstance;
    }
    public Map<String, Object> login(String username, String password) {
        Map<String, Object> response = new Map<String, Object>();
        if( username == null && password == null && String.isBlank(username) && String.isBlank(password)) {
            response.put('isValidUser', false);
            return response;
        }

        List<Person__c> personList = [
            SELECT Id, Passwords__c
            FROM Person__c
            WHERE Username__c = :username ORDER BY CreatedDate DESC
            LIMIT 1
        ];


        if(personList != null && !personList.isEmpty()) {
            Person__c loggedInUser = personList[0];

            if(loggedInUser.Passwords__c != password) {
                response.put('isValidUser', false);
                return response;
            }

            Blob key = Crypto.generateAesKey(128);
            String sessionKey = EncodingUtil.base64Encode(key);

            Session_Log__c sessionLog = new Session_Log__c(
                Person__c = loggedInUser.Id,
                Session_Key__c = sessionKey,
                Login_Time__c = Datetime.now(),
                Refresh_Time__c = Datetime.now()
            );

            insert sessionLog;

            response.put('isValidUser', true);
            response.put('sessionKey', sessionKey);
            response.put('userId', loggedInUser.Id);
        } else {
            response.put('isValidUser', false);
        }

        return response;
    }

    public Map<String, Object> validateSession(String sessionKey) {

        Map<String, Object> response = new Map<String, Object>();

        if(!validateSessionHelper(sessionKey)) {
            response.put('isValidSession', false);

            return response;
        }

        Session_Log__c log = getSessionRecord(sessionKey);

        response.put('isValidSession', true);
        response.put('userId', log.Person__c);

        return response;
    }

    public Map<String, Object> refreshSession(String sessionKey) {
        Map<String, Object> response = new Map<String, Object>();

        if(!validateSessionHelper(sessionKey)) {
            response.put('isValidSession', false);

            return response;
        }
        Session_Log__c log = getSessionRecord(sessionKey);
        log.Refresh_Time__c = Datetime.now();
        update log;

        response.put('isValidSession', true);

        return response;
    }

    //for calender
    public class DayInfo {
        @AuraEnabled public String dateStr;
        @AuraEnabled public Decimal hours;
        @AuraEnabled public String color;
        @AuraEnabled public String title;
    }
    public static List<DayInfo> getFilledHoursByDate(Id userId) {
        Map<Date, Decimal> hoursMap = new Map<Date, Decimal>();
        for (AggregateResult ar : [
            SELECT TimesheetDate__c, SUM(TimeInHour__c) totaltime
            FROM Timesheet_Entry__c
            WHERE Person__c = :userId AND TimesheetDate__c <= TODAY
            GROUP BY TimesheetDate__c
        ]) {
            hoursMap.put(
                (Date) ar.get('TimesheetDate__c'),
                (Decimal) ar.get('totaltime')
            );
        }
        List<DayInfo> responseList = new List<DayInfo>();
        Date startDate = Date.today().addDays(-365);
        Date endDate = Date.today();
        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            String dayName = dt.format('E');  
            if (dayName == 'Sat' || dayName == 'Sun') {
                continue;
            }
            DayInfo info = new DayInfo();
            info.dateStr = d.format(); 
            info.hours = hoursMap.containsKey(d) ? hoursMap.get(d) : 0;  
            if (info.hours < 4) {
                info.color = '#dc3545';
                info.title = 'Timesheet: ' + info.hours + 'h (Low/Unfilled)';
            }
            else if (info.hours < 8) {
                info.color = '#ffc107';
                info.title = 'Timesheet: ' + info.hours + 'h (Partial)';
            }
            else {
                info.color = '#28a745';
                info.title = 'Timesheet: ' + info.hours + 'h (Filled)';
            }
            responseList.add(info);
        }
        return responseList;
    }
   
    //Chart
    public Object getChartData(String userId, String filter) {
        Map<String, Object> responseMap = new Map<String, Object>();
        Date startDate = Date.today();
        Integer lastnMonths = 2;
        if(filter == '3Months') {
            lastnMonths = 2;
        } else if(filter == '6Months') {
            lastnMonths = 5;
        } else if(filter == '9Months') {
            lastnMonths = 8;
        } else if(filter == '12Months') {
            lastnMonths = 11;
        }
        List<String> monthsList = getMonthsName(lastnMonths);
        Map<String, Map<Integer, Decimal>> statusVsMonthVsTimeTakenMap = new Map<String, Map<Integer, Decimal>>();
        for(AggregateResult agg: getChartQueryData(userId, lastnMonths)) {
            String status = getUpdatedStatus((String)agg.get('status'));
            Integer month = (Integer)agg.get('month');
            Decimal timeTaken = (Decimal)agg.get('timetaken');
            if(status != null) {
                if(!statusVsMonthVsTimeTakenMap.containsKey(status)) {
                    statusVsMonthVsTimeTakenMap.put(status, new Map<Integer, Decimal>());
                }
                Map<Integer, Decimal> tempMap = statusVsMonthVsTimeTakenMap.get(status);
                if(!tempMap.containsKey(month)) {
                    tempMap.put(month, 0);
                } 
                tempMap.put(month, timeTaken + tempMap.get(month));
                statusVsMonthVsTimeTakenMap.put(status, tempMap);
            }
            // Logic for Filled Timesheet
            String filledStatus = 'Filled';
            if(!statusVsMonthVsTimeTakenMap.containsKey(filledStatus)) {
                statusVsMonthVsTimeTakenMap.put(filledStatus, new Map<Integer, Decimal>());
            }
            Map<Integer, Decimal> tempMap = statusVsMonthVsTimeTakenMap.get(filledStatus);
            if(!tempMap.containsKey(month)) {
                tempMap.put(month, 0);
            }
            tempMap.put(month, timeTaken + tempMap.get(month));
            statusVsMonthVsTimeTakenMap.put(filledStatus, tempMap);
        }
        List<Object> objList = new List<Object>();
        for(String str: statusVsMonthVsTimeTakenMap.keySet()) {
            List<Decimal> dataList = new List<Decimal>();
            Map<Integer, Decimal> tempMap = statusVsMonthVsTimeTakenMap.get(str);
            for(String monthStr: monthsList) {
                if(tempMap.containsKey(getMonthNameByIndex(monthStr))) {
                    dataList.add(tempMap.get(getMonthNameByIndex(monthStr)));
                } else {
                    dataList.add(0);
                }
            }

            objList.add(new Map<String, Object> {
                'label' => str,
                'data' => dataList,
                'borderColor' => getColor(str),
                'backgroundColor' => getColor(str)
            });
        }

        responseMap.put('datasets', objList);
        responseMap.put('labels', monthsList);

        return responseMap;

    }

    private Integer getMonthNameByIndex(String monthName) {
        Map<String, Integer> monthsMap = new Map<String, Integer> {
            'Jan' => 1,
            'Feb' => 2,
            'Mar' => 3,
            'Apr' => 4,
            'May' => 5,
            'Jun' => 6,
            'Jul' => 7,
            'Aug' => 8,
            'Sep' => 9,
            'Oct' => 10,
            'Nov' => 11,
            'Dec' => 12
        };

        return monthsMap.get(monthName);
    }
    private List<String> getMonthsName(Integer lastNMonths) {
        List<String> lastThreeMonthsIncludingCurrent = new List<String>{};
        Date today = Date.today();

        for (Integer i = 0; i <= lastNMonths; i++) {
            Date targetMonth = today.addMonths(-i).toStartOfMonth();
            if(lastThreeMonthsIncludingCurrent.isEmpty()) {
                lastThreeMonthsIncludingCurrent.add(getMonthName(targetMonth));
            } else {
                lastThreeMonthsIncludingCurrent.add(0, getMonthName(targetMonth));
            }
            
        }

        return lastThreeMonthsIncludingCurrent;
    }

    private String getMonthName(Date d) {
        Map<Integer, String> monthNames = new Map<Integer, String>{
            1 => 'Jan',
            2 => 'Feb',
            3 => 'Mar',
            4 => 'Apr',
            5 => 'May',
            6 => 'Jun',
            7 => 'Jul',
            8 => 'Aug',
            9 => 'Sep',
            10 => 'Oct',
            11 => 'Nov',
            12 => 'Dec'
        };
        return monthNames.get(d.month());
    }
    private String getColor(String status) {
        Map<String, String> colorsMap = new Map<String, String> {
            'Approved By PM' => 'rgb(255, 205, 86)',
            'Unapproved' => 'rgb(255, 99, 132)',
            'Approved By Finance' => 'rgb(75, 192, 192)',
            'Filled' => 'rgb(54, 162, 235)'
        };

        return colorsMap.get(status);
    }
    private String getUpdatedStatus(String status) {
        Map<String, String> displayStatusMap = new Map<String, String> {
            'Approved by PM' => 'Approved By PM',
            'Send for Invoicing' => 'Approved By PM',
            'Rejected by PM' => 'Unapproved',
            'Rejected by Finance' => 'Unapproved',
            'Invoice Raised' => 'Approved By Finance',
            'Approved by Finance' => 'Approved By Finance',
            'Approved by Finance(Non Billable)' => 'Approved By Finance'
        };

        return displayStatusMap.get(status);
    }

    private List<AggregateResult> getChartQueryData(String userId, Integer lastnMonths) {

        String dateCondition = ' ( TimesheetDate__c = LAST_N_MONTHS:' + lastnMonths + ' OR TimesheetDate__c = THIS_MONTH )';

        String queryString = 
            'SELECT CALENDAR_MONTH(TimesheetDate__c) month, Status__c status, SUM(TimeInHour__c) timetaken' +
            ' FROM Timesheet_Entry__c' +
            ' WHERE ' + dateCondition + 
            ' AND Person__c =:userId ' +
            ' AND Status__c != null ' +
            ' AND Status__c != \'Draft\''+
            ' GROUP BY CALENDAR_MONTH(TimesheetDate__c), Status__c';

        return Database.query(queryString);
    }

    private Boolean validateSessionHelper(String sessionKey) {
        Map<String, Object> response = new Map<String, Object>();

        if (String.isBlank(sessionKey)) {
            return false;
        }

        Session_Log__c log = getSessionRecord(sessionKey);
        if (log == null) {
            return false;
        }

        Long minutes = getMinutesDifference(log.Refresh_Time__c, Datetime.now());

        if (minutes >= 30) {
            return false;
        }

        return true;

    }

    private Session_Log__c getSessionRecord(String sessionKey) {
        if (String.isBlank(sessionKey)) return null;

        List<Session_Log__c> logs = [
            SELECT Id, Person__c, Login_Time__c, Refresh_Time__c
            FROM Session_Log__c
            WHERE Session_Key__c = :sessionKey
            LIMIT 1
        ];

        return logs.isEmpty() ? null : logs[0];
    }

    private Long getMinutesDifference(Datetime oldTime, Datetime newTime) {
        return (newTime.getTime() - oldTime.getTime()) / (1000 * 60);

    }

    public static List<Project_Code_Access__c> getProjectCodes(Id personId) {
        return [
            SELECT Opportunity__c, Opportunity__r.Project_Code__c 
            FROM Project_Code_Access__c 
            WHERE Person__c = :personId 
            AND IsActive__c = true
        ];
    }
    
    public static List<Person__c> getPersons(Id userId){
        return [
            SELECT Id, Name, Extract_Timesheet__c, Contractor__c, Timesheet_Entry_Allowed_Days__c 
            FROM Person__c 
            WHERE Id = :userId
        ];
    }
    
    public static List<Timesheet_Entry__c> getTimesheetEntries(Date startDate, Date endDate) {
        return [
            SELECT Id, Opportunity__c, TimesheetDate__c, TimeTakenInMinutes__c, TechnicalDescription__c, Status__c
            FROM Timesheet_Entry__c
            WHERE TimesheetDate__c >= :startDate
            AND TimesheetDate__c <= :endDate
            ORDER BY TimesheetDate__c ASC
        ];
    }

    public static Map<String, Object> getTimeSheetDatas(Integer pageNumber, Integer pageSize, String searchKey) {
        Integer offsetValue = (pageNumber - 1) * pageSize;

        String baseQuery = 'SELECT Id, Name, TimesheetDate__c, ProjectCode__c, TimeTakenInMinutes__c, TechnicalDescription__c, Status__c ' +
                           'FROM Timesheet_Entry__c WHERE Id != null';

        String countQuery = 'SELECT COUNT() FROM Timesheet_Entry__c WHERE Id != null';
        
        if (String.isNotBlank(searchKey)) {
            String safeKey = String.escapeSingleQuotes(searchKey);
            String searchFilter = ' AND (Name LIKE \'%' + safeKey + '%\' ' +
                                  'OR ProjectCode__c LIKE \'%' + safeKey + '%\' ' +
                                  'OR TechnicalDescription__c LIKE \'%' + safeKey + '%\')';
                                  
            baseQuery += searchFilter;
            countQuery += searchFilter;
        }

        baseQuery += ' ORDER BY TimesheetDate__c DESC LIMIT :pageSize OFFSET :offsetValue';

        List<Timesheet_Entry__c> records = Database.query(baseQuery);
        Integer totalCount = (Integer)Database.countQuery(countQuery);

        return new Map<String, Object>{
            'records' => records,
            'totalRecords' => totalCount
        };
    }
    
    public static void saveTimesheet(List<Timesheet_Entry__c> entries, String status) {
        
        Set<Date> entryDates = new Set<Date>();
        for (Timesheet_Entry__c t : entries) {
            if (t.TimesheetDate__c != null) {
                entryDates.add(t.TimesheetDate__c);
            }
        }

        List<Timesheet_Entry__c> submittedList = [
            SELECT Id, TimesheetDate__c
            FROM Timesheet_Entry__c 
            WHERE TimesheetDate__c IN :entryDates 
            AND Status__c = 'Submitted'
        ];

        if (!submittedList.isEmpty()) {
            Set<Date> submittedDatesSet = new Set<Date>();
            for(Timesheet_Entry__c rec : submittedList) {
                submittedDatesSet.add(rec.TimesheetDate__c);
            }
            List<String> submittedDates = new List<String>();
            for (Date d : submittedDatesSet) {
                submittedDates.add(String.valueOf(d));
            }
            throw new AuraHandledException(
                'Entries for these dates are already submitted: ' 
                + String.join(submittedDates, ', ')
            );
        }

        for (Timesheet_Entry__c t : entries) {
            t.Status__c = status;
        }

        upsert entries;
    }
}