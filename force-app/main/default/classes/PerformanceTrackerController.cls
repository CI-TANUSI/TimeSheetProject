public with sharing class PerformanceTrackerController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAmounts(Id recordId) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            Performance_Tracker_Monthly__c monthly = [SELECT Id, Name, Opportunity_Amount__c, PM_Amount__c, CurrencyIsoCode,Expense_Amount__c FROM Performance_Tracker_Monthly__c WHERE Id = :recordId LIMIT 1];
            result.put('opportunity', monthly.Opportunity_Amount__c);result.put('pm', monthly.PM_Amount__c); result.put('currencyIsoCode', monthly.CurrencyIsoCode);result.put('expense', monthly.Expense_Amount__c);
            return result;
        } catch (Exception e1) {
            try {
                Performance_Tracker_Yearly__c yearly = [SELECT Total_Opportunity_Amount__c, Total_PM_Amount__c, CurrencyIsoCode,Total_Expense_amount__c FROM Performance_Tracker_Yearly__c WHERE Id = :recordId LIMIT 1];
                result.put('opportunity', yearly.Total_Opportunity_Amount__c);
                result.put('pm', yearly.Total_PM_Amount__c);
                result.put('currencyIsoCode', yearly.CurrencyIsoCode);
                 result.put('expense', yearly.Total_Expense_amount__c);
                return result;
            } catch (Exception e2) {
                
            }
        }

        return result;
    }
}