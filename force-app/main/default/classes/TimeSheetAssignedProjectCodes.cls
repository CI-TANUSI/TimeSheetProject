public without sharing class TimeSheetAssignedProjectCodes {
    
    @AuraEnabled
    public static List<Person__c> getAllUsers(Id opportunityId) {
        return [
            SELECT Id, Name, Username__c 
            FROM Person__c where Id NOT IN (
                Select Person__c from Project_Code_Access__c 
                where Opportunity__c = :opportunityId AND 
                IsActive__c = true
            )
        ];
    }
    
    @AuraEnabled
    public static List<Person__c> getAssignedUsers(Id opportunityId) {
        return [
            SELECT Id, Name, Username__c 
            FROM Person__c where Id IN(
                Select Person__c from Project_Code_Access__c 
                WHERE Opportunity__c = :opportunityId AND 
                IsActive__c = true
            )
        ];
    }
    
    @AuraEnabled
    public static void createProjectCodeAccess(Id opportunityId, List<Id> userIds) {
        
        List<Project_Code_Access__c> existingRecords = [
            SELECT Id, Opportunity__c, Person__c, IsActive__c 
            FROM Project_Code_Access__c 
            WHERE Opportunity__c = :opportunityId 
            AND Person__c IN :userIds 
            AND IsActive__c = false
        ];
        
        
        Map<Id, Project_Code_Access__c> existingMap = new Map<Id, Project_Code_Access__c>(existingRecords);
        
        List<Project_Code_Access__c> toUpdate = new List<Project_Code_Access__c>();
        List<Project_Code_Access__c> toInsert = new List<Project_Code_Access__c>();
        
        for (Id userId : userIds) {
            if (existingMap.containsKey(userId)) {
                Project_Code_Access__c existing = existingMap.get(userId);
                if (existing.IsActive__c == false) {
                    existing.IsActive__c = true;
                    toUpdate.add(existing);
                }
            } else {
                toInsert.add(new Project_Code_Access__c(
                    Opportunity__c = opportunityId,
                    Person__c = userId,
                    IsActive__c = true
                ));
            }
        }
        
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
        
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
    
    
    @AuraEnabled
    public static void deleteProjectCodeAccess(Id opportunityId, List<Id> userIds) {
        List<Project_Code_Access__c> recordsToUpdate = [
            SELECT Id 
            FROM Project_Code_Access__c 
            WHERE Opportunity__c = :opportunityId 
            AND Person__c IN :userIds
        ];
        
        for(Project_Code_Access__c records: recordsToUpdate){
            records.IsActive__c = false;
        }
        
        if (!recordsToUpdate.isEmpty()) {
            Update recordsToUpdate;
        }
    }
    
    
}