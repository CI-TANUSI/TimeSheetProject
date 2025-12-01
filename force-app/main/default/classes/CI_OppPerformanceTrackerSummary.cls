public without sharing class CI_OppPerformanceTrackerSummary {
    
    @InvocableMethod(label='Create OPP Summary Records' category='Opportunity')
    public static void createSummaryRecords(List<Id> oppIds) {

        List<PT_Opp_Junction__c> ptoppListToUpsert = new List<PT_Opp_Junction__c>();

        Map<Integer, Map<Integer, Map<String, String>>> ptmMap = getPtmMap();

        Map<String, String> ptoppMap = new Map<String, String>();
        for(PT_Opp_Junction__c ptopp: [SELECT ID, Performance_Tracker_Monthly__c, Performance_Tracker_Monthly__r.Person__c, Performance_Tracker_Monthly__r.Exclusive_Identifier__c, Opportunity__c, Amount__c, currencyIsoCode FROM PT_Opp_Junction__c WHERE Performance_Tracker_Monthly__r.Person__c != null AND Opportunity__c IN: oppIds]) {
            ptoppMap.put(ptopp.Opportunity__c + '#' +(ptopp.Performance_Tracker_Monthly__r.Person__c != null ? ptopp.Performance_Tracker_Monthly__r.Person__c : ptopp.Performance_Tracker_Monthly__r.Exclusive_Identifier__c), ptopp.Id);
        }

        for(Opportunity opp: getOppList(oppIds)) {

            Integer month = opp.CloseDate.month();
            Integer year = opp.CloseDate.year();

            if(!ptmMap.containsKey(year)) continue;

            if(opp.Technical_Owner__c != null && opp.Technical_Owner__r.Role__c == 'Technical Owner') {
                String uniqueId = opp.Id + '#' + opp.Technical_Owner__c;
                String ptmId = ptmMap.get(year).get(month).get(opp.Technical_Owner__c); 
                
                if (String.isNotBlank(PtmId)) {
                ptoppListToUpsert.add(new PT_Opp_Junction__c(
                    Id = ptoppMap.containsKey(uniqueId) ? ptoppMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmMap.get(year).get(month).get(opp.Technical_Owner__c),
                    Amount__c = opp.Amount,
                    CurrencyIsoCode = opp.CurrencyIsoCode,
                    Opportunity__c = opp.Id
                ));
                }     
            }

            if(opp.BA__c != null && opp.BA__r.Role__c == 'Business Analyst') {
                String uniqueId = opp.Id + '#' + opp.BA__c;
                String ptmId = ptmMap.get(year).get(month).get(opp.BA__c);
                
                if (String.isNotBlank(PtmId)) {
                ptoppListToUpsert.add(new PT_Opp_Junction__c(
                    Id = ptoppMap.containsKey(uniqueId) ? ptoppMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmMap.get(year).get(month).get(opp.BA__c),
                    Amount__c = opp.Amount,
                    CurrencyIsoCode = opp.CurrencyIsoCode,
                    Opportunity__c = opp.Id
                ));
               }     
            }

            if(opp.Delivery_Owner__c != null && opp.Delivery_Owner__r.Role__c == 'Delivery Owner') {
                String uniqueId = opp.Id + '#' + opp.Delivery_Owner__c;
                String ptmId = ptmMap.get(year).get(month).get(opp.Delivery_Owner__c);
                
                if (String.isNotBlank(PtmId)) {
                ptoppListToUpsert.add(new PT_Opp_Junction__c(
                    Id = ptoppMap.containsKey(uniqueId) ? ptoppMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmMap.get(year).get(month).get(opp.Delivery_Owner__c),
                    Amount__c = opp.Amount,
                    CurrencyIsoCode = opp.CurrencyIsoCode,
                    Opportunity__c = opp.Id
                ));
               }     
            }

            if(opp.Account_Manager__c != null && opp.Account_Manager__r.Role__c == 'Account Manager') {
                String uniqueId = opp.Id + '#' + opp.Account_Manager__c;
                String ptmId = ptmMap.get(year).get(month).get(opp.Account_Manager__c);
                
                if (String.isNotBlank(PtmId)) {
                ptoppListToUpsert.add(new PT_Opp_Junction__c(
                    Id = ptoppMap.containsKey(uniqueId) ? ptoppMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmMap.get(year).get(month).get(opp.Account_Manager__c),
                    Amount__c = opp.Amount,
                    CurrencyIsoCode = opp.CurrencyIsoCode,
                    Opportunity__c = opp.Id
                ));
               }     
            }

            if(opp.Sales_Owner__c != null && opp.Sales_Owner__r.Role__c == 'Sales Owner') {
                String uniqueId = opp.Id + '#' + opp.Sales_Owner__c;
                String ptmId = ptmMap.get(year).get(month).get(opp.Sales_Owner__c);
                
                if (String.isNotBlank(PtmId)) {
                ptoppListToUpsert.add(new PT_Opp_Junction__c(
                    Id = ptoppMap.containsKey(uniqueId) ? ptoppMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmMap.get(year).get(month).get(opp.Sales_Owner__c),
                    Amount__c = opp.Amount,
                    CurrencyIsoCode = opp.CurrencyIsoCode,
                    Opportunity__c = opp.Id
                ));
               }     
            }

            if(opp.Account.BillingCountry == 'India' && opp.BA__c != null && opp.BA__r.Territory__c == 'India') {
                String uniqueId = opp.Id + '#' + 'India Territory';
                String ptmId = ptmMap.get(year).get(month).get('India Territory');
                
                if (String.isNotBlank(PtmId)) {
                ptoppListToUpsert.add(new PT_Opp_Junction__c(
                    Id = ptoppMap.containsKey(uniqueId) ? ptoppMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmMap.get(year).get(month).get('India Territory'),
                    Amount__c = opp.Amount,
                    CurrencyIsoCode = opp.CurrencyIsoCode,
                    Opportunity__c = opp.Id
                ));
               }     
            }

            if(opp.RecordType.Name == 'Professional Service' && opp.Deal_Source__c == 'Upwork') {
                String uniqueId = opp.Id + '#' + 'Upwork';
                String ptmId = ptmMap.get(year).get(month).get('Upwork');
                
                if (String.isNotBlank(PtmId)) {
                ptoppListToUpsert.add(new PT_Opp_Junction__c(
                    Id = ptoppMap.containsKey(uniqueId) ? ptoppMap.get(uniqueId) : null,
                    Performance_Tracker_Monthly__c = ptmMap.get(year).get(month).get('Upwork'),
                    Amount__c = opp.Amount,
                    CurrencyIsoCode = opp.CurrencyIsoCode,
                    Opportunity__c = opp.Id
                ));
               }     
            }
        }

        if(!ptoppListToUpsert.isEmpty()) {
            upsert ptoppListToUpsert;
        }

        List<PT_Opp_Junction__c> ptpmToBeDeleted = [SELECT ID FROM PT_Opp_Junction__c WHERE ID NOT IN: ptoppListToUpsert AND Opportunity__c IN: oppIds];

        if(ptpmToBeDeleted != null && !ptpmToBeDeleted.isEmpty()) {
            Database.delete(ptpmToBeDeleted);
        }

    }

    private static List<Opportunity> getOppList(List<Id> oppIds) {
        return [
            SELECT
            ID,
            Amount,
            Deal_Source__c,
            RecordType.Name,
            Account.BillingCountry,
            CurrencyIsoCode,
            CloseDate,
            Technical_Owner__c,
            Technical_Owner__r.Role__c,
            BA__c,
            BA__r.Role__c,
            BA__r.Territory__c,
            Delivery_Owner__c,
            Delivery_Owner__r.Role__c,
            Account_Manager__c,
            Account_Manager__r.Role__c,
            Sales_Owner__c,
            Sales_Owner__r.Role__c
            FROM Opportunity
            WHERE ID IN: oppIds
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