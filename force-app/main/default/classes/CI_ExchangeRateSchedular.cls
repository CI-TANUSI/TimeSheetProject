public class CI_ExchangeRateSchedular implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        fetchCurrencyRates('INR');
        fetchCurrencyRates('GBP');
        fetchCurrencyRates('AUD');
    }
    
    @future(callout=true)
    public static void fetchCurrencyRates(String currencyIsoCode) {
        
        try {
            Currency_Exchange_Rate_Settings__c exchangeSettings = Currency_Exchange_Rate_Settings__c.getInstance();
            
            String baseurl = exchangeSettings.Base_Endpoint__c;
            String path = '/v6/' + exchangeSettings.API_Key__c + '/latest/' + currencyIsoCode;
            
            CI_HttpUtil httpUtil = new CI_HttpUtil(baseurl, null);
            httpUtil.get(path, null);
            
            HttpResponse response = httpUtil.getResponse();
            
            if(response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> conversionRates = (Map<String, Object>)responseMap.get('conversion_rates');

                if(conversionRates.containsKey('USD')) {
                    Double usdRate = Double.valueOf(conversionRates.get('USD'));

                    Currency_Exchange_Rate__c exchangeRate = new Currency_Exchange_Rate__c(
                        CurrencyIsoCode = currencyIsoCode,
                        USD_Conversion_Rate__c = usdRate
                    );

                    insert exchangeRate;
                }
            } else {
                CI_ExceptionLogger.logException('CI_ExchangeRateSchedular', 'fetchCurrencyRates', httpUtil.getRequest(), httpUtil.getResponse());
            }
        } catch(Exception ex) {
            CI_ExceptionLogger.logException(ex);
        }
    }
}