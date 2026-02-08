@isTest
public class NewsAPIResponseMock implements HttpCalloutMock {

    // Values for dummy NewsAPIResponse
    public static final String SUCCESS_STATUS = 'ok';
    public static final String ERROR_STATUS = 'error';
    public static final String ERROR_CODE = '123456';
    public static final String ERROR_MESSAGE = 'Error messasge';

    // Values for dummy Articles
    public static final String DUMMY_AUTHOR_NAME = 'Bob Smith';
    public static final String DUMMY_ARTICLE_TITLE = 'Dummy Article Title';
    public static final String DUMMY_ARTICLE_DESCRIPTION = 'This is a really cool and interesting article';
    public static final String DUMMY_ARTICLE_URL = 'https://www.bbc.com/news/2026/01/01/dummy-article-01234567';
    public static final String DUMMY_IMAGE_URL = 'https://www.bbc.com/dims4/default/resize/1200/quality/90/format/jpg?url=https%3A%2F%2Fstatic.bbc.com%2F5b%2F5d%2F3c3c82a440ccbb250c59926a334d%2Fdummy-image-12345.jpg';
    public static final String DUMMY_ARTICLE_PUBLISHED_AT = '2026-01-01T00:00:00.0000000Z';
    public static final String DUMMY_ARTICLE_PUBLISHED_AT_SOBJECT_STRING = '2026-01-01 00:00:00';
    public static final String DUMMY_ARTICLE_CONTENT = 'This is the really fun and exciting content, wow I cannot put this down';

    // Values for dummy Source
    public static final String DUMMY_SOURCE_ID = 'bbc-news';
    public static final String DUMMY_SOURCE_NAME = 'BBC News';

    // Variables to be set with the response and status code
    public NewsAPIResponse response;
    public final Integer responseStatusCode;
    public final Boolean generateSuccess;
    public final Integer countOfArticlesToGenerate;
    public final Boolean throwCalloutException;
    public static final String CALLOUT_FAILURE_MESSAGE = 'Dummy callout failure';

    public NewsAPIResponseMock(Integer responseStatusCode, Boolean generateSuccess, Integer countOfArticlesToGenerate, Boolean throwCalloutException) {

        this.responseStatusCode = responseStatusCode;
        this.generateSuccess = generateSuccess;
        this.countOfArticlesToGenerate = countOfArticlesToGenerate;
        this.throwCalloutException = throwCalloutException;
        this.response = generateDummyResponse();
    }

    // ****** HELPER METHODS ****** //

    public NewsAPIResponse generateDummyResponse() {

        NewsAPIResponse response = new NewsAPIResponse();

        // Set fields depending on whether the response is a success or not
        if (generateSuccess) {
            response.status = SUCCESS_STATUS;
        } else {
            response.status = ERROR_STATUS;
            response.code = ERROR_CODE;
            response.message = ERROR_MESSAGE;
            return response;
        }

        // Generate articles
        List<NewsAPIResponse.Article> articles = new List<NewsAPIResponse.Article>();
        for (Integer i = 0; i < countOfArticlesToGenerate; i++) {
            
            // Set Article values
            NewsAPIResponse.Article a = new NewsAPIResponse.Article();
            a.author = DUMMY_AUTHOR_NAME;
            a.title = DUMMY_ARTICLE_TITLE;
            a.description = DUMMY_ARTICLE_DESCRIPTION;
            a.url = DUMMY_ARTICLE_URL;
            a.urlToImage = DUMMY_IMAGE_URL;
            a.publishedAt = DUMMY_ARTICLE_PUBLISHED_AT;
            a.content = DUMMY_ARTICLE_CONTENT;

            // Set Source values
            NewsAPIResponse.Source s = new NewsAPIResponse.Source();
            s.id = DUMMY_SOURCE_ID;
            s.name = DUMMY_SOURCE_NAME;

            // Add Source to Article and Article to list
            a.source = s;
            articles.add(a);
        }

        response.totalResults = articles.size();
        response.articles = articles;

        return response;
    }
    
    public HttpResponse respond (HttpRequest req) {

        if (throwCalloutException) {
            throw new CalloutException(CALLOUT_FAILURE_MESSAGE);
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(response));
        res.setStatusCode(responseStatusCode);

        return res;
    }
}