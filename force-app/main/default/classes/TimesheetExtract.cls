public without sharing class TimesheetExtract {
    @AuraEnabled(cacheable=true)
    
    public static List<Project_Code_Access__c> searchOpportunities(String searchKey, Id personId) {
        
        List<Project_Code_Access__c> oppList = [
            Select Opportunity__c,Person__c,Opportunity__r.Project_Code__c,Opportunity__r.Name from Project_Code_Access__c  
            WHERE person__c= :personId AND IsActive__c = True AND (Opportunity__r.Name LIKE :('%' + searchKey + '%') 
                                                                   OR Opportunity__r.Project_Code__c LIKE :('%' + searchKey + '%'))
        ];
        
        System.debug('opplist=>'+ oppList);
        return oppList;
    }   
    
   @AuraEnabled
    public static String downloadTimesheet(Id opportunityId) {
        List<Timesheet__c> sheets = [
            SELECT Name, Date__c,Person__r.name, Technical_description__c, Time_Taken__c,Approved_Time__c
            FROM Timesheet__c
            WHERE Opportunity__c = :opportunityId And Status__c = 'Blank' 
        ];
        
        
        String csv = '\uFEFF';
        csv+=  'TimeSheet Code,Date,Day,TimeSheet Description,Time Taken(mins),Approved Time(mins),TimeEntry By\n';
        for (Timesheet__c t : sheets) {
            String dayName = '';
            if (t.Date__c != null) {
                Datetime dt = Datetime.newInstance(t.Date__c.year(), t.Date__c.month(), t.Date__c.day());
                dayName = dt.format('EEEE');
            }
            
            String description = '';
            if (t.Technical_description__c != null) {
                description = t.Technical_description__c
                    .replace('"', '""')       // Escape double quotes
                    .replace('\r\n', ' ')     // Handle Windows newlines
                    .replace('\n', ' ')       // Handle Unix newlines
                    .replace('\r', ' ')      // Handle old Mac newlines
                    .replace('#','');
                description = ' ' + description + ' ';
            }
            
            csv += '"' + t.Name + '",'
                + '"' + String.valueOf(t.Date__c) + '",'
                + '"' + dayName + '",'
                + '"' + description + '",'
                + '"' + String.valueOf(t.Time_Taken__c) + '",'
                + '"' + (t.Approved_Time__c != null ? String.valueOf(t.Approved_Time__c) : '') + '",'
                + '"' + String.valueOf(t.Person__r.Name) + '"\n';
        }
        return csv;
        
    }

    
}