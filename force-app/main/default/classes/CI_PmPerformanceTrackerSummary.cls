public without sharing class CI_PmPerformanceTrackerSummary {

    @InvocableMethod(label='Create PM Summary Records' category='Payment_Milestone__c')
    public static void createSummaryRecords(List<Id> pmIds) {

        List<PT_PM_Junction__c> ptpmListToUpsert = new List<PT_PM_Junction__c>();

        Map<Integer, Map<Integer, Map<String, String>>> ptmMap = getPtmMap();

        Map<String, String> ptpmMap = new Map<String, String>();
        for(PT_PM_Junction__c ptpm: [SELECT ID, Performance_Tracker_Monthly__c, Performance_Tracker_Monthly__r.Person__c, Performance_Tracker_Monthly__r.Exclusive_Identifier__c, Payment_Milestone__c, Amount__c, currencyIsoCode FROM PT_PM_Junction__c WHERE Performance_Tracker_Monthly__r.Person__c != null AND Payment_Milestone__c IN: pmIds]) {
            ptpmMap.put(ptpm.Payment_Milestone__c + '#' + (ptpm.Performance_Tracker_Monthly__r.Person__c != null ? ptpm.Performance_Tracker_Monthly__r.Person__c : ptpm.Performance_Tracker_Monthly__r.Exclusive_Identifier__c), ptpm.Id);
        }

        for(Payment_Milestone__c pm: getpmList(pmIds)) {

            Integer month = pm.Payment_Received_Date__c.month();
            Integer year = pm.Payment_Received_Date__c.year();

            if(!ptmMap.containsKey(year)) continue;

            if(pm.Opportunity__r.Technical_Owner__c != null && pm.Opportunity__r.Technical_Owner__r.Role__c == 'Technical Owner') {
                String uniqueId = pm.Id + '#' + pm.Opportunity__r.Technical_Owner__c;
                String ptmId = ptmMap.get(year).get(month).get(pm.Opportunity__r.Technical_Owner__c);
                
                if (String.isNotBlank(PtmId)) {
                    ptpmListToUpsert.add(new PT_PM_Junction__c(
                        Id = ptpmMap.containsKey(uniqueId) ? ptpmMap.get(uniqueId) : null,
                        Performance_Tracker_Monthly__c = ptmId,
                        Amount__c = pm.Amount__c,
                        CurrencyIsoCode = pm.CurrencyIsoCode,
                        Payment_Milestone__c = pm.Id
                    ));
                  }
               }

            if(pm.Opportunity__r.BA__c != null && pm.Opportunity__r.BA__r.Role__c == 'Business Analyst') {
                String uniqueId = pm.Id + '#' + pm.Opportunity__r.BA__c;
                String ptmId = ptmMap.get(year).get(month).get(pm.Opportunity__r.BA__c);
                
                if (String.isNotBlank(PtmId)){
                    ptpmListToUpsert.add(new PT_PM_Junction__c(
                    Id = ptpmMap.containsKey(uniqueId) ? ptpmMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmId,
                    Amount__c = pm.Amount__c,
                    CurrencyIsoCode = pm.CurrencyIsoCode,
                    Payment_Milestone__c = pm.Id
                ));
               }
             }

            if(pm.Opportunity__r.Delivery_Owner__c != null && pm.Opportunity__r.Delivery_Owner__r.Role__c == 'Delivery Owner') {
                String uniqueId = pm.Id + '#' + pm.Opportunity__r.Delivery_Owner__c;
                String ptmId = ptmMap.get(year).get(month).get(pm.Opportunity__r.Delivery_Owner__c);
                
                if (String.isNotBlank(PtmId)){
                ptpmListToUpsert.add(new PT_PM_Junction__c(
                    Id = ptpmMap.containsKey(uniqueId) ? ptpmMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmId,
                    Amount__c = pm.Amount__c,
                    CurrencyIsoCode = pm.CurrencyIsoCode,
                    Payment_Milestone__c = pm.Id
                ));
                }    
            }

            if(pm.Opportunity__r.Account_Manager__c != null && pm.Opportunity__r.Account_Manager__r.Role__c == 'Account Manager') {
                String uniqueId = pm.Id + '#' + pm.Opportunity__r.Account_Manager__c;
                String ptmId = ptmMap.get(year).get(month).get(pm.Opportunity__r.Account_Manager__c);
                  
                if (String.isNotBlank(PtmId)){
                ptpmListToUpsert.add(new PT_PM_Junction__c(
                    Id = ptpmMap.containsKey(uniqueId) ? ptpmMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmId,
                    Amount__c = pm.Amount__c,
                    CurrencyIsoCode = pm.CurrencyIsoCode,
                    Payment_Milestone__c = pm.Id
                ));
               }     
            }

            if(pm.Opportunity__r.Sales_Owner__c != null && pm.Opportunity__r.Sales_Owner__r.Role__c == 'Sales Owner') {
                String uniqueId = pm.Id + '#' + pm.Opportunity__r.Sales_Owner__c;
                String ptmId = ptmMap.get(year).get(month).get(pm.Opportunity__r.Sales_Owner__c);
                
                if (String.isNotBlank(PtmId)){
                ptpmListToUpsert.add(new PT_PM_Junction__c(
                    Id = ptpmMap.containsKey(uniqueId) ? ptpmMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmId,
                    Amount__c = pm.Amount__c,
                    CurrencyIsoCode = pm.CurrencyIsoCode,
                    Payment_Milestone__c = pm.Id
                ));
              }     
            }

            if(pm.Account__r.BillingCountry == 'India' && pm.Opportunity__r.BA__c != null && pm.Opportunity__r.BA__r.Territory__c == 'India') {
                String uniqueId = pm.Id + '#' + 'India Territory';
                String ptmId = ptmMap.get(year).get(month).get('India Territory');
                 
                if (String.isNotBlank(PtmId)){
                ptpmListToUpsert.add(new PT_PM_Junction__c(
                    Id = ptpmMap.containsKey(uniqueId) ? ptpmMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmId,
                    Amount__c = pm.Amount__c,
                    CurrencyIsoCode = pm.CurrencyIsoCode,
                    Payment_Milestone__c = pm.Id
                ));
               }      
            }

            if(pm.Opportunity__r.RecordType.Name == 'Professional Service' && pm.Opportunity__r.Deal_Source__c == 'Upwork') {
                String uniqueId = pm.Id + '#' + 'Upwork';
                String ptmId = ptmMap.get(year).get(month).get('Upwork');
                
                if (String.isNotBlank(PtmId)){
                ptpmListToUpsert.add(new PT_PM_Junction__c(
                    Id = ptpmMap.containsKey(uniqueId) ? ptpmMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmId,
                    Amount__c = pm.Amount__c,
                    CurrencyIsoCode = pm.CurrencyIsoCode,
                    Payment_Milestone__c = pm.Id
                ));
               }      
            }
        }

        if(!ptpmListToUpsert.isEmpty()) {
            upsert ptpmListToUpsert;
        }

        List<PT_PM_Junction__c> ptpmToBeDeleted = [SELECT ID FROM PT_PM_Junction__c WHERE ID NOT IN: ptpmListToUpsert AND Payment_Milestone__c IN: pmIds];

        if(ptpmToBeDeleted != null && !ptpmToBeDeleted.isEmpty()) {
            Database.delete(ptpmToBeDeleted);
        }

    }

    private static List<Payment_Milestone__c> getpmList(List<Id> pmIds) {
        return [
            SELECT
            ID,
            Amount__c,
            Account__c,
            Account__r.BillingCountry,
            CurrencyIsoCode,
            Payment_Received_Date__c,
            Opportunity__c,
            Opportunity__r.RecordType.Name,
            Opportunity__r.Deal_Source__c,
            Opportunity__r.Technical_Owner__c,
            Opportunity__r.Technical_Owner__r.Role__c,
            Opportunity__r.BA__c,
            Opportunity__r.BA__r.Role__c,
            Opportunity__r.BA__r.Territory__c,
            Opportunity__r.Delivery_Owner__c,
            Opportunity__r.Delivery_Owner__r.Role__c,
            Opportunity__r.Account_Manager__c,
            Opportunity__r.Account_Manager__r.Role__c,
            Opportunity__r.Sales_Owner__c,
            Opportunity__r.Sales_Owner__r.Role__c
            FROM Payment_Milestone__c
            WHERE ID IN: pmIds
        ];
    }

    private static Map<Integer, Map<Integer, Map<String, String>>> getPtmMap() {
        Map<Integer, Map<Integer, Map<String, String>>> ptmMap = new Map<Integer, Map<Integer, Map<String, String>>>();
        for(Performance_Tracker_Monthly__c ptm: [SELECT ID, Start_Date__c, Person__c, Exclusive_Identifier__c FROM Performance_Tracker_Monthly__c]) {
            Integer month = ptm.Start_Date__c.month();
            Integer year = ptm.Start_Date__c.year();

            String personName = ptm.Person__c == null ? ptm.Exclusive_Identifier__c : ptm.Person__c;

            if(ptmMap.containsKey(year)) {
                Map<Integer, Map<String, String>> tempMap = ptmMap.get(year);

                if(tempMap.containsKey(month)) {
                    Map<String, String> tempMap2 = tempMap.get(month);
                    tempMap2.put(personName, ptm.Id);

                    tempMap.put(month, tempMap2);
                } else {
                    tempMap.put(month, new Map<String, String> {
                        personName => ptm.Id
                    });
                }
                ptmMap.put(year, tempMap);

            } else {
                ptmMap.put(year, new Map<Integer, Map<String, String>> {
                    month => new Map<String, String> {
                        personName => ptm.Id
                    }
                });
            }
        }

        return ptmMap;
    }
}