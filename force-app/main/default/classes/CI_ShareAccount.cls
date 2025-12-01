public with sharing class CI_ShareAccount implements CI_SharingInterface {
    
    public void shareRecord(Set<Id> accountIdSet) {
        // if (accountIdSet == null || accountIdSet.isEmpty()) {
        //     return;
        // }
        
        // Map<Id,Set<String>> accountToUserMap = new  Map<Id,Set<String>>();
        // Set<Id> accountIdSetFromShares = new Set<Id>();
        // Set<Id> shareIdSet = new Set<Id>();
        
        // List<Account_Team_Member__c> atmRecords = [
        //     SELECT Account__c, 
        //     Person__r.User__c, 
        //     Person__r.Manager_L2__r.User__c, 
        //     Person__r.Manager_L3__r.User__c, 
        //     Person__r.Manager_L4__r.User__c, 
        //     Person__r.Manager_L5__r.User__c, 
        //     Person__r.Manager_L6__r.User__c, 
        //     Person__r.Manager_L7__r.User__c, 
        //     Person__r.Manager_L8__r.User__c, 
        //     Person__r.Manager_L9__r.User__c, 
        //     Person__r.Manager_L10__r.User__c, 
        //     Person__r.Manager_L11__r.User__c, 
        //     Person__r.Manager_L12__r.User__c, 
        //     Person__r.Manager_L13__r.User__c, 
        //     Person__r.Manager_L14__r.User__c, 
        //     Person__r.Manager_L15__r.User__c
        //     FROM Account_Team_Member__c
        //     WHERE Account__c IN :accountIdSet AND Active__c = true
        // ];
        
        // for (Account_Team_Member__c atmRec : atmRecords) {
        //     Id accountId = atmRec.Account__c;
            
        //     if (!accountToUserMap.containsKey(accountId)) {
        //         accountToUserMap.put(accountId, new Set<String>());
        //     }
            
        //     if (atmRec.Person__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.User__c);
        //     }
            
        //     if (atmRec.Person__r.Manager_L2__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L2__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L3__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L3__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L4__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L4__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L5__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L5__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L6__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L6__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L7__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L7__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L8__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L8__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L9__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L9__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L10__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L10__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L11__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L11__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L12__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L12__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L13__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L13__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L14__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L14__r.User__c);
        //     }
        //     if (atmRec.Person__r.Manager_L15__r.User__c != null) {
        //         accountToUserMap.get(accountId).add(atmRec.Person__r.Manager_L15__r.User__c);
        //     }
        // }
        
        // List<AccountShare> accShareList = new List<AccountShare>();
        
        // for(Id accountId:accountToUserMap.keySet()){
            
        //     for(String userId:accountToUserMap.get(accountId)){
        //         if(userId != null){
        //             accShareList.add(new AccountShare(
        //                 AccountId = accountId,
        //                 UserOrGroupId = userId,
        //                 RowCause = CI_Constants.ROW_CAUSE_MANUAL,
        //                 AccountAccessLevel = CI_Constants.ACCESS_LEVEL_EDIT,
        //                 OpportunityAccessLevel = CI_Constants.ACCESS_LEVEL_NONE
        //             ));
        //         }
        //     }
        // }
        
        // if (!accShareList.isEmpty()) {
        //     Database.insert(accShareList, false);
        // }
        
        // List<AccountShare> accShareListToDelete = [SELECT Id FROM AccountShare WHERE AccountId IN :accountIdSet AND Id NOT IN :accShareList AND RowCause =: CI_Constants.ROW_CAUSE_MANUAL];
        
        // if(accShareListToDelete != null && !accShareListToDelete.isEmpty()) {
        //     try {
        //         delete accShareListToDelete;
        //     } catch(Exception ex) {
        //         CI_ExceptionLogger.logException(ex);
        //     }
        // }       
    }
    
}