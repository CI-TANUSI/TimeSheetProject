public without sharing class TS_TimeSheetLogin {
    
    
    @AuraEnabled
    public static Map<String,String> validateLogin(String username, String password) {
        
        List<Person__c> matchedRecords = [
            SELECT Id, Passwords__c  
            FROM Person__c 
            WHERE Username__c = :username LIMIT 1
        ];
        
        Map<String, String> responceMap = new Map<String, String>();
        
        if (!matchedRecords.isEmpty()) {
            Person__c person = matchedRecords[0];
            
            if (person.Passwords__c == password) {
                
                Blob key = Crypto.generateAesKey(128);
                String encodedKey = EncodingUtil.base64Encode(key);
                responceMap.put('Id', person.Id);
                responceMap.put('key', encodedKey);
                
                
                Session_Log__c sessionlog = new Session_Log__c();
                sessionlog.Person__c = person.Id;
                sessionlog.Session_Key__c = encodedKey;
                sessionlog.Login_Time__c = Datetime.now();
                sessionlog.Refresh_Time__c =Datetime.now();
                insert sessionlog;
                
                
                return responceMap;
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static String updateRefreshTime(String sessionKey) {
        
        if (String.isNotBlank(sessionKey)) {
            
            List<Session_Log__c> log = [
                SELECT Id, Login_time__c, Person__c,Refresh_Time__c 
                FROM Session_Log__c 
                WHERE Session_Key__c = :sessionKey 
                LIMIT 1
            ];
            
            if (log != null) {
                Session_Log__c logs = log[0];
                Long minutesSinceRefresh = (Datetime.now().getTime() - logs.Refresh_Time__c.getTime()) / (1000 * 60);
                  if (minutesSinceRefresh < 30) {
                     logs.Refresh_Time__c = Datetime.now();
                     update logs;
                    return logs.Person__c;
                }
               
            }
        }
        
        return null;
    }  
    

    
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

   
    
}