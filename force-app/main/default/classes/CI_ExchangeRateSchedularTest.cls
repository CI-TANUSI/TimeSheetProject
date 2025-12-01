@isTest
public class CI_ExchangeRateSchedularTest {

    @TestSetup
    static void setupTestData() {
        
        Currency_Exchange_Rate_Settings__c exchangeRateSettings = new Currency_Exchange_Rate_Settings__c(
            Base_Endpoint__c = 'https://api.example.com/',
            API_Key__c = 'test-api-key'
        );
        insert exchangeRateSettings;
    }

    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"conversion_rates": {"USD": 0.0173}}');

            return res;
        }
    }

    private class ErrorMockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }

    @isTest
    static void testFetchCurrencyRatesSuccess() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        CI_ExchangeRateSchedular.fetchCurrencyRates('INR');
        Test.stopTest();

        
        List<Currency_Exchange_Rate__c> exchangeRates = [
            SELECT USD_Conversion_Rate__c FROM Currency_Exchange_Rate__c
        ];

        System.assertEquals(1, exchangeRates.size(), 'One exchange rate record should be created.');
        Currency_Exchange_Rate__c exchangeRate = exchangeRates[0];
        System.assertEquals(0.0173, exchangeRate.USD_Conversion_Rate__c, 'INR conversion rate should match the API response.');
    }

    @isTest
    static void testFetchCurrencyRatesError() {
        Test.setMock(HttpCalloutMock.class, new ErrorMockHttpResponse());

        Test.startTest();
        CI_ExchangeRateSchedular.fetchCurrencyRates('INR');
        Test.stopTest();

        List<Currency_Exchange_Rate__c> exchangeRates = [
            SELECT USD_Conversion_Rate__c FROM Currency_Exchange_Rate__c
        ];
        System.assertEquals(0, exchangeRates.size(), 'No exchange rate record should be created for an error response.');
    }
    
    @isTest
    static void testException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        CI_ExchangeRateSchedular.fetchCurrencyRates('Hello');
        Test.stopTest();

        List<Currency_Exchange_Rate__c> exchangeRates = [
            SELECT USD_Conversion_Rate__c FROM Currency_Exchange_Rate__c
        ];
        System.assertEquals(0, exchangeRates.size(), 'No exchange rate record should be created for an error response.');
    }
}