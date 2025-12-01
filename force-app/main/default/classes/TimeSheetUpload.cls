public without sharing class TimeSheetUpload {
    @AuraEnabled
    public static void updateStatus(List<TSData> dataList, String statusValue, Id recordId) {
        Set<String> names = new Set<String>();
        Map<String, TSData> dataMap = new Map<String, TSData>();
        
        Decimal uploadApprovedMinutes = 0;
        
        for (TSData data : dataList) {
            if (String.isNotBlank(data.name)) {
                String trimmedName = data.name.trim();
                names.add(trimmedName);
                dataMap.put(trimmedName, data);
                uploadApprovedMinutes += data.approvedTime;
            }
        }
        
        List<Timesheet__c> toUpdate = [
            SELECT Id, Name, Status__c,
            Approved_Time__c, Temporary_Approved__c, Unapproved_Time__c,
            Opportunity__c
            FROM Timesheet__c
            WHERE Name IN :names
        ];
        
        if (toUpdate.isEmpty()) {
            throw new AuraHandledException('No matching Timesheet records found.');
        }
        
        // --- Check Opportunity consistency ---
        Set<Id> opportunityIds = new Set<Id>();
        for (Timesheet__c ts : toUpdate) {
            if (ts.Opportunity__c != null) {
                opportunityIds.add(ts.Opportunity__c);
            }
        }
        
        if (opportunityIds.size() > 1) {
            throw new AuraHandledException('All timesheet records must belong to the same Opportunity.');
        }
        
        // --- Fetch PM record including Opportunity and Number_Of_Hours__c ---
        Payment_Milestone__c pm = [
            SELECT Opportunity__c, Number_Of_Hours__c
            FROM Payment_Milestone__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        
        if (pm.Opportunity__c == null) {
            throw new AuraHandledException('The Payment Milestone does not have an Opportunity linked.');
        }
        
        Id pmOppId = pm.Opportunity__c;
        
        if (!opportunityIds.contains(pmOppId)) {
            throw new AuraHandledException('Timesheet records must belong to the same Opportunity as the Payment Milestone.');
        }
        
        // --- Get existing Timesheet__c linked to the same Payment Milestone ---
        List<Timesheet__c> existingPMTimesheets = [
            SELECT Temporary_Approved__c
            FROM Timesheet__c
            WHERE Payment_Milestone__c = :recordId
        ];
        
        Decimal existingApprovedMinutes = 0;
        for (Timesheet__c ts : existingPMTimesheets) {
            existingApprovedMinutes += (ts.Temporary_Approved__c != null) ? ts.Temporary_Approved__c : 0;
        }
        
        Decimal totalApprovedHours = (uploadApprovedMinutes + existingApprovedMinutes) / 60;
        
        if (pm.Number_Of_Hours__c != null && totalApprovedHours > pm.Number_Of_Hours__c) {
            throw new AuraHandledException('Total approved hours (existing + uploaded) exceed the allowed limit: ' + pm.Number_Of_Hours__c + ' hrs.');
        }
        
        // --- Proceed with updates ---
        for (Timesheet__c ts : toUpdate) {
            TSData input = dataMap.get(ts.Name.trim());
            if (input == null) continue;
            
            ts.Status__c = statusValue;
            ts.Payment_Milestone__c = recordId;
            
            if (statusValue == 'Temporary approved') {
                ts.Approved_Time__c = 0;
                ts.Temporary_Approved__c = input.approvedTime;
                ts.Unapproved_Time__c = input.timeTaken - input.approvedTime;
            } else if (statusValue == 'Unapproved') {
                ts.Approved_Time__c = 0;
                ts.Temporary_Approved__c = 0;
                ts.Unapproved_Time__c = 0;
            }
        }
        
        update toUpdate;
    }
    
    public class TSData {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Decimal timeTaken { get; set; }
        @AuraEnabled public Decimal approvedTime { get; set; }
    }
}