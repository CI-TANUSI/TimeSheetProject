public with sharing class CI_ShareOpportunity implements CI_SharingInterface {
    
    public void shareRecord(Set<Id> oppIdSet) {
    //     if (oppIdSet == null || oppIdSet.isEmpty()) {
    //         return;
    //     }

    //     Map<Id, Set<String>> opportunityToUserMap = new Map<Id, Set<String>>();

    //     List<Opportunity_Team_Member__c> otmRecords = [
    //         SELECT Opportunity__c, 
    //                Person__r.User__c, 
    //                Person__r.Manager_L2__r.User__c, 
    //                Person__r.Manager_L3__r.User__c, 
    //                Person__r.Manager_L4__r.User__c, 
    //                Person__r.Manager_L5__r.User__c, 
    //                Person__r.Manager_L6__r.User__c, 
    //                Person__r.Manager_L7__r.User__c, 
    //                Person__r.Manager_L8__r.User__c, 
    //                Person__r.Manager_L9__r.User__c, 
    //                Person__r.Manager_L10__r.User__c, 
    //                Person__r.Manager_L11__r.User__c, 
    //                Person__r.Manager_L12__r.User__c, 
    //                Person__r.Manager_L13__r.User__c, 
    //                Person__r.Manager_L14__r.User__c, 
    //                Person__r.Manager_L15__r.User__c
    //         FROM Opportunity_Team_Member__c
    //         WHERE Opportunity__c IN :oppIdSet AND Active__c = true
    //     ];

    //     for (Opportunity_Team_Member__c otmRec : otmRecords) {
    //         Id opportunityId = otmRec.Opportunity__c;

    //         // Initialize the set for this opportunity if it doesn't exist
    //         if (!opportunityToUserMap.containsKey(opportunityId)) {
    //             opportunityToUserMap.put(opportunityId, new Set<String>());
    //         }

    //         // Add the User ID of the Person
    //         if (otmRec.Person__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.User__c);
    //         }

    //         // Add User IDs for all manager levels
    //         if (otmRec.Person__r.Manager_L2__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L2__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L3__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L3__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L4__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L4__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L5__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L5__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L6__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L6__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L7__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L7__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L8__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L8__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L9__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L9__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L10__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L10__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L11__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L11__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L12__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L12__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L13__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L13__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L14__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L14__r.User__c);
    //         }
    //         if (otmRec.Person__r.Manager_L15__r.User__c != null) {
    //             opportunityToUserMap.get(opportunityId).add(otmRec.Person__r.Manager_L15__r.User__c);
    //         }
    //     }


    //     // Step 4: Create new shares
    //     List<OpportunityShare> opportunityShares = new List<OpportunityShare>();

    //     for (Id opportunityId : opportunityToUserMap.keySet()) {
    //         for (String userId : opportunityToUserMap.get(opportunityId)) {
    //             if (userId != null) {
    //                 opportunityShares.add(new OpportunityShare(
    //                     OpportunityId = opportunityId,
    //                     UserOrGroupId = userId,
    //                     OpportunityAccessLevel = CI_Constants.ACCESS_LEVEL_EDIT,
    //                     RowCause = Schema.OpportunityShare.RowCause.Manual
    //                 ));
    //             }
    //         }
    //     }

    //     if (!opportunityShares.isEmpty()) {
    //         try {
    //             insert opportunityShares;
    //         } catch (DmlException ex) {
    //             CI_ExceptionLogger.logException(ex);
    //         }
    //     }

    // Set<Id> oppIdSetFromShares = new Set<Id>();
    //     Set<Id> shareIdSet = new Set<Id>();

    //     for (OpportunityShare share : opportunityShares) {
    //         if (share.OpportunityId != null) {
    //             oppIdSetFromShares.add(share.OpportunityId);
    //         }
    //         if (share.Id != null) {
    //             shareIdSet.add(share.Id);
    //         }
    //     }

    //     List<OpportunityShare> existingShares = [
    //         SELECT Id, OpportunityId, UserOrGroupId
    //         FROM OpportunityShare
    //         WHERE OpportunityId IN :oppIdSetFromShares
    //         AND Id NOT IN :shareIdSet
    //         AND RowCause = 'Manual'
    //     ];


    //     if (!existingShares.isEmpty()) {
    //         try {
    //             delete existingShares;
    //         } catch (Exception ex) {
    //             CI_ExceptionLogger.logException(ex);
    //         }
    //     }
    }
}