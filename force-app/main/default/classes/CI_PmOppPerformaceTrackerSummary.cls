public class CI_PmOppPerformaceTrackerSummary {
    @InvocableMethod(label='Create PM Summary Records From Opportunity' category='Opportunity')
    public static void createSummaryRecordsFromOpp(List<Id> oppIds) {
        List<Id> pmIds = new List<Id>();

        for(Payment_Milestone__c pm: [SELECT ID FROM Payment_Milestone__c WHERE Opportunity__c IN: oppIds AND Status__c = 'Payment Received' AND Payment_Received_Date__c != null]) {
            pmIds.add(pm.Id);
        }

        CI_PmPerformanceTrackerSummary.createSummaryRecords(pmIds);
    }
}