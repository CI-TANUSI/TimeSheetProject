public without sharing class TimeSheetPortalController {

    private static TimeSheetPortalService serviceInstance;

    private static TimeSheetPortalService service(){
        if(serviceInstance == null) {
            serviceInstance = TimeSheetPortalService.getInstance();
        }
        return serviceInstance;
    }

    @AuraEnabled
    public static Object loginUser(String username, String password){
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            responseMap.put('data', service().login(username, password));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled
    public static Object validateSession(String sessionKey){
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            responseMap.put('data', service().validateSession(sessionKey));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object refreshSession(String sessionKey){
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            responseMap.put('data', service().refreshSession(sessionKey));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }
    //for calender

    
      @AuraEnabled
    public static Object getFilledHoursByDate(String userId){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap.put('data', TimeSheetPortalService.getFilledHoursByDate(Id.valueOf(userId)));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
            responseMap.put('lineNumber', e.getLineNumber());
            responseMap.put('stackTrace', e.getStackTraceString());
        }
        return responseMap;
    }

    
    @AuraEnabled
    public static Object getChartData(String userId, String filter){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap.put('data', service().getChartData(userId, filter));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
            responseMap.put('lineNumber', e.getLineNumber());
            responseMap.put('stackTrace', e.getStackTraceString());
        }
        return responseMap;
    }
     @AuraEnabled(cacheable=true)
    public static Object getProjectCodes(Id personId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap.put('data', TimeSheetPortalService.getProjectCodes(personId)); 
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }
        return responseMap;
    }
    @AuraEnabled
    public static Object getPersons(Id userId){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap.put('data', TimeSheetPortalService.getPersons(userId));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }
        return responseMap;
    }
    @AuraEnabled
    public static Object getTimesheetEntries(Date startDate, Date endDate) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap.put('data', TimeSheetPortalService.getTimesheetEntries(startDate, endDate));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', 'Error fetching timesheet: ' + e.getMessage());
        }
        return responseMap;
    }
    @AuraEnabled
    public static Map<String, Object> getTimeSheetDatas(Integer pageNumber, Integer pageSize, String searchKey) {
        try {
            return TimeSheetPortalService.getTimeSheetDatas(pageNumber, pageSize, searchKey);
        } catch (Exception e) {
            return new Map<String, Object>{
                'records' => new List<Timesheet_Entry__c>(),
                'totalRecords' => 0,
                'isError' => true,
                'errorMessage' => 'Error fetching paginated timesheet data: ' + e.getMessage()
            };
        }
    }  
    @AuraEnabled
    public static void saveTimesheet(List<Timesheet_Entry__c> entries, String status) {
        try {
            TimeSheetPortalService.saveTimesheet(entries, status);
        } catch (Exception e) {
            if (e.getMessage().contains('Entries for these dates are already submitted')) {
                throw new AuraHandledException('Cannot update timesheet. ' + e.getMessage());
            } else {
                throw new AuraHandledException('Error saving timesheet: ' + e.getMessage());
            }
        }
    }      
}