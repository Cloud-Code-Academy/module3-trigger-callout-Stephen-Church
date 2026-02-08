@isTest
public with sharing class NewsCategoryTriggerHandlerTest {

    public static final String VALID_CATEGORY = NewsAPIServiceTest.VALID_CATEGORY;

    @TestSetup 
    static void makeData() {

        List<News_Category__c> newsCategories = generateNewsCategories(2, true, false);
        insert newsCategories;
    }

    public static Set<Id> extractNewsCategoryIds (List<News_Category__c> ncs) {

        Set<Id> ncIds = new Set<Id>();
        for (News_Category__c nc : ncs) {
            ncIds.add(nc.Id);
        }
        return ncIds;
    }

    public static void assertPostSuccessfulSyncFields(List<News_Category__c> ncs) {

        for (News_Category__c nc : ncs) {
            Assert.isFalse(nc.Sync__c, 'The Sync__c field should be set to FALSE after the sync');
            Assert.isFalse(nc.Sync_USA_Only__c, 'The USA_Only__c field should be set to FALSE after the sync');
            Assert.areEqual(null, nc.Sync_Keywords__c, 'The Sync_Keywords__c field should be null after the sync');
            Assert.areEqual(null, nc.Sync_Page_Number__c, 'The Sync_Page_Number__c field should be null after the sync');
            Assert.isFalse(nc.Sync_Failed__c, 'The Sync_Failed__c field should be set to FALSE after the sync');
            Assert.isTrue(nc.Last_Synced__c != null, 'The Last_Synced__c field should not be null after the sync');
        }
    }

    public static Map<Id, News_Category__c> queryNewsCategoryRecordsFromIds(Set<Id> ncIds) {

        Map<Id, News_Category__c> newsCategoriesById = new Map<Id, News_Category__c>([
            SELECT Id, Sync__c, Sync_USA_Only__c, Sync_Keywords__c, Sync_Page_Number__c, Sync_Failed__c, Last_Synced__c, Name
            FROM News_Category__c
            WHERE Id IN :ncIds
        ]);

        return newsCategoriesById;
    }

    public static Map<Id, List<Article__c>> queryArticlesByNewsCategoryId(Set<Id> ncIds) {

        List<Article__c> articles = [
            SELECT Id, News_Category__c, Category__c, Author__c, Published_At__c, Name, Description__c, Source__c, Title__c, url__c, Content__c, urlToImage__c
            FROM Article__c
            WHERE News_Category__c IN :ncIds
        ];

        Map<Id, List<Article__c>> articlesByNcId = new Map<Id, List<Article__c>>();
        for (Article__c ar : articles) {
            List<Article__c> arList = new List<Article__c>();
            if (!articlesByNcId.containsKey(ar.News_Category__c)) {
                arList.add(ar);
                articlesByNcId.put(ar.News_Category__c, arList);
            } else {
                arList = articlesByNcId.get(ar.News_Category__c);
                arList.add(ar);
                articlesByNcId.put(ar.News_Category__c, arList);
            }
        }
        return articlesByNcId;
    }

    public static void assertArticleFields(Map<Id, List<Article__c>> articlesByNcId, Map<Id, News_Category__c> ncsById) {

        for (Id ncId : articlesByNcId.keySet()) {
            List<Article__c> ncIdArticles = articlesByNcId.get(ncId);
            String expectedCategory = ncsById.get(ncId).Name;
            for (Article__c article : ncIdArticles) {
                Assert.areEqual(ncId, article.News_Category__c, 'The Article is not related to the expected News_Category__c');
                Assert.areEqual(expectedCategory, article.Category__c, 'The Article Category does not match the News_Category__c name');
                Assert.areEqual(NewsAPIResponseMock.DUMMY_AUTHOR_NAME, article.Author__c, 'The Article Author is not set as expected');
                DateTime expectedDateTime = (DateTime)JSON.deserialize('"' + NewsAPIResponseMock.DUMMY_ARTICLE_PUBLISHED_AT + '"', DateTime.class);
                Assert.areEqual(expectedDateTime, article.Published_At__c, 'The Article Published_At__c time is not as expected');
                String expectedName = NewsAPIResponseMock.DUMMY_AUTHOR_NAME + ' - ' + NewsAPIResponseMock.DUMMY_ARTICLE_PUBLISHED_AT_SOBJECT_STRING;
                Assert.areEqual(expectedName, article.Name, 'The Article Name is not set as expected');
                Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_DESCRIPTION, article.Description__c, 'The Article Description is not set as expected');
                Assert.areEqual(NewsAPIResponseMock.DUMMY_SOURCE_NAME, article.Source__c, 'The Article Source is not set as expected');
                Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_TITLE, article.Title__c, 'The Article Title is not set as expected');
                Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_URL, article.url__c, 'The Article URL is not set as expected');
                Assert.areEqual(NewsAPIResponseMock.DUMMY_ARTICLE_CONTENT, article.Content__c, 'The Article Content is not set as expected');
                Assert.areEqual(NewsAPIResponseMock.DUMMY_IMAGE_URL, article.urlToImage__c, 'The Article Image URL is not set as expected');
            }
        }
    }

    public static void assertLogEntries(Set<Id> ncIds, Boolean assertSuccess) {

        Set<Id> ncIdsWithSuccessLogEntries = new Set<Id>();
        Set<Id> ncIdsWithFailedLogEntries = new Set<Id>();
        List<LogEntry__c> logEntries = [SELECT Id, RecordId__c, Message__c FROM LogEntry__c WHERE RecordId__c IN :ncIds];

        for (LogEntry__c log : logEntries) {

            if (log.Message__c.contains('News Category Id ') && log.Message__c.contains('successfully synced at ')) {
                ncIdsWithSuccessLogEntries.add(log.RecordId__c);
            }

            if (log.Message__c.contains('Failure')) {
                ncIdsWithFailedLogEntries.add(log.RecordId__c);
            }
        }
        
        if (assertSuccess) {
            Assert.areEqual(ncIds, ncIdsWithSuccessLogEntries, 'Not all of the expected News Category Ids have success logs');
            Assert.isTrue(ncIdsWithFailedLogEntries.isEmpty(), 'Some News Category Ids have unexpected failed logs');
        } else {
            Assert.areEqual(ncIds, ncIdsWithFailedLogEntries, 'Not all of the expected News Category Ids have failed logs');
            Assert.isTrue(ncIdsWithSuccessLogEntries.isEmpty(), 'Some News Category Ids have unexpected success logs');
        }
    }

    public static void assertNoArticles(Set<Id> newsCategoryIds) {

        List<Article__c> articles = [SELECT Id FROM Article__c WHERE News_Category__c IN :newsCategoryIds];
        Assert.isTrue(articles.isEmpty(), 'No Articles should have been synced to the News Categories');
    }

    public static void assertSyncFailedField(Set<Id> newsCategoryIds) {

        List<News_Category__c> newsCategories = [SELECT Id, Sync_Failed__c FROM News_Category__c WHERE Id IN :newsCategoryIds];
        for (News_Category__c nc : newsCategories) {
            Assert.isTrue(nc.Sync_Failed__c, 'The Sync Failed field should be selected');
        }
    }

    public static List<News_Category__c> generateNewsCategories(Integer countToGenerate, Boolean useValidCategory, Boolean syncValue) {

        List<News_Category__c> ncs = new List<News_Category__c>();
        for (Integer i = 0; i < countToGenerate; i++) {
            News_Category__c nc = new News_Category__c();
            nc.Sync__c = syncValue;
            if (useValidCategory) {
                nc.Name = VALID_CATEGORY;
            } else {
                nc.Name = 'Invalid Category';
            }
            ncs.add(nc);
        }
        return ncs;
    }

    public static List<News_Category__c> queryExistingNewsCategories() {

        List<News_Category__c> newsCategories = [SELECT Id, Sync__c, Name FROM News_Category__c];
        return newsCategories;
    }

    public static List<News_Category__c> updateSyncField(List<News_Category__c> newsCategories, Boolean valueToSet) {

        for (News_Category__c nc : newsCategories) {
            nc.Sync__c = valueToSet;
        }
        return newsCategories;
    }

    public static List<News_Category__c> updateCategoryName(List<News_Category__c> newsCategories, String nameToSet) {

        for (News_Category__c nc : newsCategories) {
            nc.Name = nameToSet;
        }
        return newsCategories;
    }

    /***** END TO END INSERT TESTS *****/

    @isTest
    static void insertNewsCategories_syncYes_validCategory() {

        List<News_Category__c> ncs = generateNewsCategories(2, true, true);
        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        insert ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        Map<Id, News_Category__c> ncsById = queryNewsCategoryRecordsFromIds(ncIds);
        assertPostSuccessfulSyncFields(ncsById.values());
        Map<Id, List<Article__c>> articlesByNcId = queryArticlesByNewsCategoryId(ncIds);
        assertArticleFields(articlesByNcId, ncsById);
        assertLogEntries(ncIds, true);
    }

    @isTest
    static void insertNewsCategories_syncYes_invalidCategory() {

        List<News_Category__c> ncs = generateNewsCategories(2, false, true);
        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        insert ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        assertNoArticles(ncIds);
    }

    @isTest
    static void insertNewsCategories_syncNo_validCategory() {

        List<News_Category__c> ncs = generateNewsCategories(2, true, false);
        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        insert ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        assertNoArticles(ncIds);
    }

    @isTest
    static void insertNewsCategories_syncNo_invalidCategory() {

        List<News_Category__c> ncs = generateNewsCategories(2, false, false);
        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        insert ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        assertNoArticles(ncIds);
    }

    @isTest
    static void insertNewsCategories_syncYes_validCategory_error() {

        List<News_Category__c> ncs = generateNewsCategories(2, true, true);
        Boolean exceptionThrown = false;
        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(100, true, 0, false));

        Test.startTest();
        insert ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        assertNoArticles(ncIds);
        assertSyncFailedField(ncIds);
        assertLogEntries(ncIds, false);
    }

    /***** END TO END UPDATE TESTS *****/

    @isTest  
    static void updateNewsCategories_syncChangedToTrue_validCategory() {

        List<News_Category__c> ncs = queryExistingNewsCategories();
        ncs = updateSyncField(ncs, true);
        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        update ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        Map<Id, News_Category__c> ncsById = queryNewsCategoryRecordsFromIds(ncIds);
        assertPostSuccessfulSyncFields(ncsById.values());
        Map<Id, List<Article__c>> articlesByNcId = queryArticlesByNewsCategoryId(ncIds);
        assertArticleFields(articlesByNcId, ncsById);
        assertLogEntries(ncIds, true);
    }

    @isTest  
    static void updateNewsCategories_syncChangedToTrue_invalidCategory() {

        List<News_Category__c> ncs = queryExistingNewsCategories();
        ncs = updateSyncField(ncs, true);
        ncs = updateCategoryName(ncs, 'Invalid Category');
        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        update ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        assertNoArticles(ncIds);
    }

    @isTest  
    static void updateNewsCategories_syncChangedToFalse_validCategory() {

        List<News_Category__c> ncs = queryExistingNewsCategories();
        ncs = updateSyncField(ncs, true);
        ncs = updateCategoryName(ncs, 'Invalid Category');
        update ncs;

        ncs = updateSyncField(ncs, false);
        ncs = updateCategoryName(ncs, VALID_CATEGORY);

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        update ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        assertNoArticles(ncIds);
    }

    @isTest  
    static void updateNewsCategories_syncChangedToFalse_invalidCategory() {

        List<News_Category__c> ncs = queryExistingNewsCategories();
        ncs = updateSyncField(ncs, true);
        ncs = updateCategoryName(ncs, 'Invalid Category');
        update ncs;

        ncs = updateSyncField(ncs, false);

        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(200, true, 2, false));

        Test.startTest();
        update ncs;
        Test.stopTest();

        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        assertNoArticles(ncIds);     
    }

    @isTest  
    static void updateNewsCategories_syncChangedToTrue_error() {

        List<News_Category__c> ncs = queryExistingNewsCategories();
        ncs = updateSyncField(ncs, true);
        Test.setMock(HttpCalloutMock.class, new NewsAPIResponseMock(100, true, 0, false));

        Test.startTest();
        update ncs;
        Test.stopTest();
        
        Set<Id> ncIds = extractNewsCategoryIds(ncs);
        assertNoArticles(ncIds);
        assertSyncFailedField(ncIds);
        assertLogEntries(ncIds, false);
    }
}