@isTest
public with sharing class NewsAPIServiceTest {

    public static final Set<String> VALID_CATEGORIES = NewsAPIService.VALID_CATEGORIES;
    public static final String VALID_CATEGORY = new List<String>(VALID_CATEGORIES).get(0);
    public static final String EXPECTED_USA_PARAM = NewsAPIService.US_PARAM;
    public static final String EXPECTED_KEYWORD_PARAM = NewsAPIService.KEYWORD_PARAM_PREFIX;
    public static final String EXPECTED_PAGE_NUMBER_PARAM = NewsAPIService.PAGE_NUMBER_PARAM_PREFIX;
    public static final String EXPECTED_ENDPOINT_START = NewsAPIService.API_NAMED_CREDENTIAL + NewsAPIService.API_ENDPOINT;
    public static final String EXPECTED_CATEGORY_PARAM = NewsAPIService.CATEGORY_PARAM_PREFIX;
    public static final String EXPECTED_PAGE_SIZE_PARAM = NewsAPIService.PAGE_SIZE_PARAM_PREFIX + NewsAPIService.PAGE_SIZE;

    public static void assertExceptionThrownBooleanIsTrue(Boolean result, String expectedExceptionType) {

        Assert.isTrue(result, 'A ' + expectedExceptionType + ' should have been thrown.');
    }

    public static void assertExceptionMessagesMatch(String expectedMessage, String actualMessage) {

        Assert.areEqual(expectedMessage, actualMessage, 'The message thrown in the exception is not as expected.');
    }

    public static void assertStringDoesNotContainParameter(String valueToCheck, String valueToCheckFor) {

        Assert.isFalse(valueToCheck.contains(valueToCheckFor), 'The returned string should not contain the parameter. Returned string: ' + valueToCheck + '. Parameter: ' + valueToCheckFor);
    }

    public static void assertEndpointStringsMatch(String expectedEndpoint, String actualEndpoint) {

        Assert.areEqual(expectedEndpoint, actualEndpoint, 'The endpoint returned is not as expected.');
    }

    public static void assertNewsAPIResponseSuccess(NewsAPIResponse response, Integer expectedArticleSize) {

        Assert.areEqual(NewsAPIResponseMock.SUCCESS_STATUS, response.status, 'The response status is not as expected.');
        Assert.areEqual(2, response.totalResults, 'totalResults is not set as expected');
        
        for (NewsAPIResponse.Article article : response.articles) {
            Assert.areEqual(NewsAPIResponseMock.DUMMY_AUTHOR_NAME, article.author, 'The Author Name is not set as expected');
            Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_TITLE, article.title,  'The Author Title is not set as expected');
            Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_DESCRIPTION, article.description, 'The Article Description is not set as expected');
            Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_URL, article.url, 'The Article URL is not set as expected');
            Assert.areEqual(NewsAPIResponseMock.DUMMY_IMAGE_URL, article.urlToImage, 'The Image URL is not set as expected');
            Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_PUBLISHED_AT, article.publishedAt, 'The Article Published At is not set as expected');
            Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_CONTENT, article.content, 'The Article Content is not set as expected');
            Assert.areEqual(NewsAPIResponseMock.DUMMY_SOURCE_ID, article.source.id, 'The Article Source Id is not set as expected');
            Assert.areEqual(NewsAPIResponseMock.DUMMY_SOURCE_NAME, article.source.name, 'The Article Source Name is not set as expected');
        }
    }

    @isTest
    static void constructEndpointWithParamas_invalidCategory_wrongValue() {

        Boolean newsAPIExceptionThrown = false;
        String exceptionMessageThrown = null;
        String expectedExceptionMessage = 'Invalid category: dummy category. Valid categories: ' + VALID_CATEGORIES;

        Test.startTest();
        try {
            NewsAPIService.constructEndpointWithParams(true, 'dummy category', 'Test', 1);
        } catch (NewsAPIService.NewsAPIException e) {
            newsAPIExceptionThrown = true;
            exceptionMessageThrown = e.getMessage();
        }
        Test.stopTest();

        assertExceptionThrownBooleanIsTrue(newsAPIExceptionThrown, 'NewsAPIException');
        assertExceptionMessagesMatch(expectedExceptionMessage, exceptionMessageThrown);
    }

    @isTest
    static void constructEndpointWithParamas_invalidCategory_null() {

        Boolean newsAPIExceptionThrown = false;
        String exceptionMessageThrown = null;
        String expectedExceptionMessage = 'Invalid category: null. Valid categories: ' + VALID_CATEGORIES;

        Test.startTest();
        try {
            NewsAPIService.constructEndpointWithParams(true, null, 'Test', 1);
        } catch (NewsAPIService.NewsAPIException e) {
            newsAPIExceptionThrown = true;
            exceptionMessageThrown = e.getMessage();
        }
        Test.stopTest();

        assertExceptionThrownBooleanIsTrue(newsAPIExceptionThrown, 'NewsAPIException');
        assertExceptionMessagesMatch(expectedExceptionMessage, exceptionMessageThrown);
    }

    @isTest
    static void constructEndpointWithParamas_invalidCategory_emptyString() {

        Boolean newsAPIExceptionThrown = false;
        String exceptionMessageThrown = null;
        String expectedExceptionMessage = 'Invalid category: . Valid categories: ' + VALID_CATEGORIES;

        Test.startTest();
        try {
            NewsAPIService.constructEndpointWithParams(true, '', 'Test', 1);
        } catch (NewsAPIService.NewsAPIException e) {
            newsAPIExceptionThrown = true;
            exceptionMessageThrown = e.getMessage();
        }
        Test.stopTest();

        assertExceptionThrownBooleanIsTrue(newsAPIExceptionThrown, 'NewsAPIException');
        assertExceptionMessagesMatch(expectedExceptionMessage, exceptionMessageThrown);
    }

    @isTest
    static void constructEndpointWithParams_usaOnly_null() {

        Test.startTest();
        String result = NewsAPIService.constructEndpointWithParams(null, VALID_CATEGORY, 'Test', 1);
        Test.stopTest();

        assertStringDoesNotContainParameter(result, EXPECTED_USA_PARAM); 
    }

    @isTest
    static void constructEndpointWithParams_usaOnly_false() {

        Test.startTest();
        String result = NewsAPIService.constructEndpointWithParams(false, VALID_CATEGORY, 'Test', 1);
        Test.stopTest();

        assertStringDoesNotContainParameter(result, EXPECTED_USA_PARAM); 
    }

    @isTest
    static void constructEndpointWithParams_noKeywords_null() {

        Test.startTest();
        String result = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, null, 1);
        Test.stopTest();

        assertStringDoesNotContainParameter(result, EXPECTED_KEYWORD_PARAM); 
    }

    @isTest
    static void constructEndpointWithParams_noKeywords_emptyString() {

        Test.startTest();
        String result = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, '', 1);
        Test.stopTest();

        assertStringDoesNotContainParameter(result, EXPECTED_KEYWORD_PARAM); 
    }

    @isTest
    static void constructEndpointWithParams_noPageNumber_null() {

        Test.startTest();
        String result = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, 'Test', null);
        Test.stopTest();

        assertStringDoesNotContainParameter(result, EXPECTED_PAGE_NUMBER_PARAM); 
    }

    @isTest
    static void constructEndpointWithParams_noPageNumber_0() {

        Test.startTest();
        String result = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, 'Test', 0);
        Test.stopTest();

        assertStringDoesNotContainParameter(result, EXPECTED_PAGE_NUMBER_PARAM); 
    }

    @isTest
    static void constructEndpointWithParams_allParams_keywordsNotTrimmed() {

        String keyword = 'Test';
        Integer pageNumber = 1;

        String expectedEndpoint = 
            EXPECTED_ENDPOINT_START +
            '?' + EXPECTED_CATEGORY_PARAM + VALID_CATEGORY + 
            '&' + EXPECTED_USA_PARAM +
            '&' + EXPECTED_KEYWORD_PARAM + keyword +
            '&' + EXPECTED_PAGE_NUMBER_PARAM + pageNumber +
            '&' + EXPECTED_PAGE_SIZE_PARAM;

        Test.startTest();
        String result = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, keyword, pageNumber);
        Test.stopTest();

        assertEndpointStringsMatch(expectedEndpoint, result);
    }

    @isTest
    static void constructEndpointWithParams_allParams_keywordsTrimmed() {

        Integer pageNumber = 1;

        String expectedEndpoint = 
            EXPECTED_ENDPOINT_START +
            '?' + EXPECTED_CATEGORY_PARAM + VALID_CATEGORY + 
            '&' + EXPECTED_USA_PARAM +
            '&' + EXPECTED_KEYWORD_PARAM + 'Test' +
            '&' + EXPECTED_PAGE_NUMBER_PARAM + pageNumber +
            '&' + EXPECTED_PAGE_SIZE_PARAM;

        Test.startTest();
        String result = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, ' Test ', pageNumber);
        Test.stopTest();

        assertEndpointStringsMatch(expectedEndpoint, result);

    }

    @isTest
    static void updateParams_currentParamsNull() {

        Test.startTest();
        String result = NewsAPIService.updateParams(null, 'Test');
        Test.stopTest();

        Assert.areEqual('?Test', result, 'The expected params were not returned');
    }

    @isTest
    static void updateParams_currentParamsEmpty() {

        Test.startTest();
        String result = NewsAPIService.updateParams('', 'Test');
        Test.stopTest();

        Assert.areEqual('?Test', result, 'The expected params were not returned');
    }

    @isTest
    static void updateParams_currentParamsNotPopulated() {

        Test.startTest();
        String result = NewsAPIService.updateParams('?Hello', 'Test');
        Test.stopTest();

        Assert.areEqual('?Hello&Test', result, 'The expected params were not returned');
    }

    @isTest
    static void makeCallout_calloutException() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(100, false, 1, true));
        String endpoint = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, 'Test', 1);
        Boolean exceptionCaught = false;
        String exceptionMessage = null;

        Test.startTest();
        try {
            HttpResponse callout = NewsAPIService.makeCallout(endpoint);
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionCaught = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, 'A NewsAPIException should have been caught');
        Assert.isTrue(exceptionMessage.startsWith('HTTP callout to NewsAPI failed: '), 'The exception message does not start with the expected string');
    }

    @isTest
    static void makeCallout_100StatusCode() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(100, false, 1, false));
        String endpoint = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, 'Test', 1);
        Boolean exceptionCaught = false;
        String exceptionMessage = null;
        String responseBody = null;

        Test.startTest();
        try {
            HttpResponse callout = NewsAPIService.makeCallout(endpoint);
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionCaught = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, 'A NewsAPIException should have been caught');
        Assert.areEqual('NewsAPI Callout is not a 200 code. Status Code = 100', exceptionMessage, 'The exception message is not as expected.');
    }

    @isTest
    static void makeCallout_300StatusCode() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(300, false, 1, false));
        String endpoint = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, 'Test', 1);
        Boolean exceptionCaught = false;
        String exceptionMessage = null;
        String responseBody = null;

        Test.startTest();
        try {
            HttpResponse callout = NewsAPIService.makeCallout(endpoint);
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionCaught = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionCaught, 'A NewsAPIException should have been caught');
        Assert.areEqual('NewsAPI Callout is not a 200 code. Status Code = 300', exceptionMessage, 'The exception message is not as expected.');
    }

    @isTest
    static void makeCallout_200StatusCode_parseResponse() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));
        String endpoint = NewsAPIService.constructEndpointWithParams(true, VALID_CATEGORY, 'Test', 1);
        Boolean exceptionCaught = false;

        Test.startTest();
        HttpResponse callout = NewsAPIService.makeCallout(endpoint);
        NewsAPIResponse response = NewsAPIService.parseResponse(callout.getBody());
        Test.stopTest();

        assertNewsAPIResponseSuccess(response, 2);
    }

    @isTest
    static void parseResponse_blankResponse() {

        Boolean exceptionThrown = false;
        String exceptionMessage = null;

        Test.startTest();
        try {
            NewsAPIService.parseResponse('');
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'An exception should have been thrown');
        Assert.areEqual(NewsAPIService.EMPTY_RESPONSE_BODY_EXCEPTION_MESSAGE, exceptionMessage, 'The exception message is not as expected');
    }

    @isTest
    static void parseResponse_nullResponse() {

        Boolean exceptionThrown = false;
        String exceptionMessage = null;

        Test.startTest();
        try {
            NewsAPIService.parseResponse(null);
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'An exception should have been thrown');
        Assert.areEqual(NewsAPIService.EMPTY_RESPONSE_BODY_EXCEPTION_MESSAGE, exceptionMessage, 'The exception message is not as expected');
    }

    @isTest
    static void parseResponse_invaldJSON() {

        Boolean exceptionThrown = false;
        String exceptionMessage = null;

        Test.startTest();
        try {
            NewsAPIService.parseResponse('Invalid JSON');
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'An exception should have been thrown');
        Assert.isTrue(exceptionMessage.startsWith('Failed to parse response JSON. Message: '), 'The exception message does not start as expected.');
        Assert.isTrue(exceptionMessage.endsWith('. JSON: ' + 'Invalid JSON'), 'The exception message does not end as expected.');        
    }

    @isTest
    static void morePagesToCheck_no() {

        Test.startTest();
        Boolean result = NewsAPIService.morePagesToCheck(10);
        Test.stopTest();

        Assert.isFalse(result, 'The result should be false since 10 is less than 20');
    }

    @isTest
    static void morePagesToCheck_yes() {

        Test.startTest();
        Boolean result = NewsAPIService.morePagesToCheck(20);
        Test.stopTest();

        Assert.isTrue(result, 'The result should be true since the max pages of 20 was passed to the method');  
    }

    @isTest
    static void checkForErrorStatus_yes() {

        NewsAPIResponseMock responseMock = new NewsAPIResponseMock(100, false, 1, false);
        Boolean exceptionThrown = false;
        String exceptionMessage = null;

        Test.startTest();
        try {
            NewsAPIService.checkForErrorStatus(responseMock.response);
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'An exception should have been thrown');
        Assert.areEqual('Callout has error message and code. Message: ' + NewsAPIResponseMock.ERROR_MESSAGE + '. Code: '+ NewsAPIResponseMock.ERROR_CODE, exceptionMessage, 'The exception message is not as expected.');  
    }

    @isTest
    static void checkForErrorStatus_no() {

        NewsAPIResponseMock responseMock = new NewsAPIResponseMock(200, true, 1, false);
        Boolean exceptionThrown = false;
        String exceptionMessage = null;

        Test.startTest();
        try {
            NewsAPIService.checkForErrorStatus(responseMock.response);
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isFalse(exceptionThrown, 'An exception should not have been thrown');
        Assert.isNull(exceptionMessage, 'There should be no exception message');  
        
    }

    @isTest
    static void getTopHeadlinesByCategory_success_usaOnly_hasKeywords() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        NewsAPIResponse response = NewsAPIService.getTopHeadlinesByCategory(true, VALID_CATEGORY, 'Test', 1);
        Test.stopTest();

        assertNewsAPIResponseSuccess(response, 2);
    }

    @isTest
    static void getTopHeadlinesByCategory_success_notUsaOnly_hasKeywords() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        NewsAPIResponse response = NewsAPIService.getTopHeadlinesByCategory(false, VALID_CATEGORY, 'Test', 1);
        Test.stopTest();

        assertNewsAPIResponseSuccess(response, 2);
    }

    @isTest
    static void getTopHeadlinesByCategory_success_usaOnly_hasNoKeywords() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        NewsAPIResponse response = NewsAPIService.getTopHeadlinesByCategory(true, VALID_CATEGORY, null, 1);
        Test.stopTest();

        assertNewsAPIResponseSuccess(response, 2);  
    }

    @isTest
    static void getTopHeadlinesByCategory_success_notUsaOnly_hasNoKeywords() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        NewsAPIResponse response = NewsAPIService.getTopHeadlinesByCategory(false, VALID_CATEGORY, null, 1);
        Test.stopTest();

        assertNewsAPIResponseSuccess(response, 2);  
        
    }

    @isTest
    static void getTopHeadlinesByCategory_failure_invalidCategory() {

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(null, true, 2, false));
        Boolean exceptionThrown = false;
        String exceptionMessage = null;

        Test.startTest();
        try {
            NewsAPIResponse response = NewsAPIService.getTopHeadlinesByCategory(false, 'Test', null, 1);
        } catch (NewsAPIService.NewsAPIException e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'An exception should have been thrown.');
        Assert.areEqual('Invalid category: Test. Valid categories: ' + VALID_CATEGORIES, exceptionMessage, 'The expected invalid category exception message was not returned.');
    }
}