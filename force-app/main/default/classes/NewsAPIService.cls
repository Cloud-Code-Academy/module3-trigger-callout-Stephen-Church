/**
 * Service class to interact with the NewsAPI for fetching top headlines
 */
public with sharing class NewsAPIService {
    @TestVisible private static final String API_NAMED_CREDENTIAL = 'callout:NewsAPI';
    @TestVisible private static final String API_ENDPOINT = '/v2/top-headlines';
    @TestVisible private static final String US_PARAM = 'country=us';
    @TestVisible private static final String CATEGORY_PARAM_PREFIX = 'category=';
    @TestVisible private static final String KEYWORD_PARAM_PREFIX = 'q=';
    @TestVisible private static final String PAGE_NUMBER_PARAM_PREFIX = 'page=';
    @TestVisible private static final String PAGE_SIZE_PARAM_PREFIX = 'pageSize=';
    @TestVisible private static final Integer PAGE_SIZE = 20; 
    @TestVisible private static final Set<String> VALID_CATEGORIES = new Set<String>{'business', 'entertainment', 'general', 'health', 'science', 'sports', 'technology'};
    @TestVisible private static final String EMPTY_RESPONSE_BODY_EXCEPTION_MESSAGE = 'News API returned an empty response body.';
    
    public static NewsAPIResponse getTopHeadlinesByCategory(Boolean usaOnly, String category, String keywords, Integer pageNumber) {

        String endpoint = constructEndpointWithParams(usaOnly, category, keywords, pageNumber);
        HttpResponse calloutResponse = makeCallout(endpoint);
        NewsAPIResponse parsedResponse = parseResponse(calloutResponse.getBody());
        
        return parsedResponse;
    }
    
    public static String constructEndpointWithParams(Boolean usaOnly, String category, String keywords, Integer pageNumber) {

        String fullEndpoint = API_NAMED_CREDENTIAL + API_ENDPOINT;
        String params = null;

        if (!VALID_CATEGORIES.contains(category)) {
            throw new NewsAPIException('Invalid category: ' + category + '. Valid categories: ' + VALID_CATEGORIES);
        } else {
            params = updateParams(params, CATEGORY_PARAM_PREFIX + category);
        }

        if (usaOnly != null && usaOnly) {
            params = updateParams(params, US_PARAM);
        }

        if (!String.isBlank(keywords)) {
            keywords = keywords.trim();
            params = updateParams(params, KEYWORD_PARAM_PREFIX + keywords);
        }

        if (pageNumber != null && pageNumber >= 1) {
            params = updateParams(params, PAGE_NUMBER_PARAM_PREFIX + pageNumber);
        } 

        params = updateParams(params, PAGE_SIZE_PARAM_PREFIX + PAGE_SIZE);

        return fullEndpoint + params;
    }

    public static String updateParams(String currentParams, String paramAddition) {

        if (String.isEmpty(currentParams)) {
            currentParams = '?';
        } else {
            currentParams += '&';
        }
        currentParams += paramAddition;

        return currentParams;
    }

    public static HttpResponse makeCallout(String endpoint) {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        HttpResponse res = new HttpResponse();

        try {
            res = h.send(req);
        } catch (CalloutException e) {
            throw new NewsAPIException('HTTP callout to NewsAPI failed: ' + e.getMessage());
        }

        Integer statusCode = res.getStatusCode();

        if (statusCode < 200 || statusCode >= 300) {
            throw new NewsAPIException('NewsAPI Callout is not a 200 code. Status Code = ' + statusCode);
        }

        return res;
    }
    
    public static NewsAPIResponse parseResponse(String jsonResponse) {
        
        if (String.isBlank(jsonResponse)) {
            throw new NewsAPIException(EMPTY_RESPONSE_BODY_EXCEPTION_MESSAGE);
        }

        try {
            return (NewsAPIResponse) System.JSON.deserialize(jsonResponse, NewsAPIResponse.class);
        } catch (JSONException e) {
            throw new NewsAPIException('Failed to parse response JSON. Message: ' + e.getMessage() + '. JSON: ' + jsonResponse);
        }
    }

    public static Boolean morePagesToCheck(Integer resultsOnPage) {

        return resultsOnPage == PAGE_SIZE;
    }

    public static void checkForErrorStatus(NewsAPIResponse response) {

        if (response.status == 'error') {
            throw new NewsAPIException('Callout has error message and code. Message: ' + response.message + '. Code: ' + response.code);
        }
    }

    public class NewsAPIException extends Exception {}
}