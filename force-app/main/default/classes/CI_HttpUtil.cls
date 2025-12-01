public class CI_HttpUtil {
    
    public transient HttpResponse response;
    public transient HttpRequest req;
    private String currentEndpoint;
    private String baseEndpoint;
    private Map<String, String> headers;
    
    public CI_HttpUtil(String baseEndpoint, Map<String, String> headers) {
        this.baseEndpoint = baseEndpoint;
        this.headers = headers;
        if (String.isNotBlank(baseEndpoint) && !baseEndpoint.endsWith('/')) {
            this.baseEndpoint += '/';
        }
    }
    
    public String post(String pathLet, Map<String, String> urlParams, String payload) {
        return doRequest('POST', pathLet, headers, urlParams, payload);
    }
    
    public String get(String pathLet, Map<String, String> urlParams) {
        return doRequest('GET', pathLet, headers, urlParams, null);
    }
    
    private String doRequest(String method, String pathLet, Map<String, String> headers, Map<String, String> urlParams, String payload) {
        req = new HttpRequest();
        setHeaders(req, headers);
        req.setMethod(method);
        if (payload != null) {
            req.setBody(payload);
        }
        req.setTimeout(2 * 60 * 1000);
        req.setEndpoint(getEndpoint(pathLet, urlParams));
        Http h = new Http();
        this.currentEndpoint = req.getEndpoint();
        this.response = h.send(req);
        System.debug('Header : ' + this.response.getHeaderKeys());
        System.debug('Body : ' + this.response.getBody());
        return this.response.getBody();
    }
    
    public HttpResponse getResponse() {
        return this.response;
    }

    public HttpRequest getRequest() {
        return this.req;
    }
    
    public String getEndpoint() {
        return this.currentEndpoint;
    }
    
    public static Map<String, String> encodeParams(Map<String, String> params) {
        Map<String, String> encoded = new Map<String, String>();
        for (String k : params.keySet()) {
            encoded.put(k, urlEncode(params.get(k)));
        }
        return encoded;
    }
    
    public static String urlEncode(String s) {
        return EncodingUtil.urlEncode(s, 'utf-8').replace('+', '%20').replace('*', '%2A').replace('%7E', '~');
    }
    
    private static void setHeaders(HttpRequest req, Map<String, String> headers) {
        if (headers != null)
            for (String k : headers.keySet()) {
                req.setHeader(k, headers.get(k));
            }
    }
    
    private String getEndpoint(String endpoint, Map<String, String> urlParams) {
        if (String.isNotBlank(this.baseEndpoint)) {
            endpoint = this.baseEndpoint + (endpoint.startsWith('/') ? endpoint.substring(1) : endpoint);
        }
        Pagereference et = new Pagereference(endpoint);
        if (urlParams != null && !urlParams.isEmpty()) {
            et.getParameters().putAll(urlParams);
        }
        return et.getUrl();
    }
    
    public Map<String, String> getResponseHeaders() {
        Map<String, String> headers = new Map<String, String>();
        for (String s : this.response.getHeaderKeys()) {
            headers.put(s, this.response.getHeader(s));
        }
        return headers;
    }
}