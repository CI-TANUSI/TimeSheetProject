@IsTest
public class CI_HTTPUtilTest {
    
    @isTest
    static void doGet() {
        CI_HTTPUtil http = new CI_HTTPUtil('https://example.com/', null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenericHTTPMock());
        http.get('/', new Map<String, String>{ 'test' => 'test' });
        Test.stopTest();
        Assert.isTrue(http.getEndpoint().contains('https://example.com/'), 'Endpoint does not match expected value');
        Assert.areNotEqual(null, http.getResponse(), 'Response should not be null');
        Assert.areNotEqual(null, http.getResponseHeaders(), 'Response headers should not be null');
        Assert.areNotEqual(null, CI_HTTPUtil.encodeParams(new Map<String, String>{ 'test' => 'test' }), 'Encoded params should not be null');
    }
    
    @isTest
    static void doPost() {
        CI_HTTPUtil http = new CI_HTTPUtil('https://example.com/', null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenericHTTPMock());
        http.post('/', new Map<String, String>{ 'test' => 'test' }, 'test');
        Test.stopTest();
        HttpResponse response = http.getResponse();
        Assert.areEqual(200, response.getStatusCode(), 'Status code should be 200');
        Assert.areEqual('{"text":"value"}', response.getBody(), 'Response body does not match expected value');
    }
    
    private class GenericHTTPMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"text":"value"}');
            res.setStatusCode(200);
            return res;
        }
    }
}