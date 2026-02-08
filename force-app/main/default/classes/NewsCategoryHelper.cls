public with sharing class NewsCategoryHelper {

    @TestVisible public static final Set<String> VALID_NEWS_CATEGORIES = new Set<String>{'business', 'entertainment', 'general', 'health', 'science', 'sports', 'technology'};

    /***------------- METHODS TO INITIATE THE SYNC -------------***/

    public static void syncWhenSyncUpdatedForValidCategory(List<News_Category__c> newCategoriesToSync, Map<Id, News_Category__c> oldCategoriesById) {

        for (News_Category__c nc : newCategoriesToSync) {
            News_Category__c oldNc = oldCategoriesById.get(nc.Id);
            if (syncChangedToTrue(nc, oldNc) && isValidCategoryToSync(nc.Name)) {
                NewsCategoryQueueable ncq = new NewsCategoryQueueable(nc, 1);
                System.enqueueJob(ncq);
            }
        }
    }

    public static void syncWhenValidCategoryCreated(List<News_Category__c> newCategoriesToSync) {
        
        for (News_Category__c nc : newCategoriesToSync) {
            if (nc.Sync__c && isValidCategoryToSync(nc.Name)) {
                syncNewCategory(nc.Id);
            }
        }
    }

    @Future(callout=true)
    public static void syncNewCategory(Id newsCategoryId) {

        News_Category__c newsCategory = new News_Category__c();

        try {
            newsCategory = NewsCategorySelector.getNewsCategorySyncFieldsFromId(newsCategoryId);
            NewsAPIResponse response = NewsAPIService.getTopHeadlinesByCategory(newsCategory.Sync_USA_Only__c, newsCategory.Name, newsCategory.Sync_Keywords__c, Integer.valueOf(newsCategory.Sync_Page_Number__c));
            NewsAPIService.checkForErrorStatus(response);
            
            List<Article__c> articles = new List<Article__c>();
            for(NewsAPIResponse.Article article : response.articles) {
                articles.add(NewsAPIResponse.convertToSObject(article, newsCategory));
            }

            insert articles;

            if (!Test.isRunningTest() && NewsAPIService.morePagesToCheck(response.totalResults)) {
                NewsCategoryQueueable ncq = new NewsCategoryQueueable(newsCategory, 2);
                System.enqueueJob(ncq);
            } else {
                newsCategory = setNewsCategoryFieldsAfterSync(newsCategory);
                update newsCategory;
                logSuccessSync(newsCategory);
            }
        } catch (NewsAPIService.NewsAPIException e) {
            logFailedSync('Failure to sync articles for a new News Category.', e.getMessage(), newsCategory);
        } catch (Exception e) {
            logFailedSync('Unexpected failure in syncing articles for a new News Category.', e.getMessage(), newsCategory);
        }
    }   
    
    /***------------- HELPER METHODS FOR SYNCING -------------***/

    public static Boolean isValidCategoryToSync(String categoryName) {

        Boolean result = false;
        if (VALID_NEWS_CATEGORIES.contains(categoryName.toLowerCase())) {
            result = true;
        }
        return result;
    }

    public static Boolean syncChangedToTrue(News_Category__c newCategory, News_Category__c oldCategory) {

        return newCategory.Sync__c && (newCategory.Sync__c != oldCategory.Sync__c);
    }

    public static News_Category__c setNewsCategoryFieldsAfterSync (News_Category__c newsCategory) {
        newsCategory.Sync__c = false;
        newsCategory.Sync_USA_Only__c = false;
        newsCategory.Sync_Keywords__c = null;
        newsCategory.Sync_Page_Number__c = null;
        newsCategory.Sync_Failed__c = false;
        newsCategory.Last_Synced__c = Datetime.now();

        return newsCategory;
    }

    public static void logSuccessSync(News_Category__c newsCategorySynced) {

        String messageToLog ='News Category Id ' + String.valueOf(newsCategorySynced.Id) +  ' successfully synced at ' + String.valueOf(Datetime.now());
        Logger.info(messageToLog, newsCategorySynced);
        Logger.saveLog();
    }

    public static void logFailedSync (String message, String exceptionMessage, News_Category__c failedNewsCategory) {

        String messageToLog = message + ' Details: ' + exceptionMessage;
        Logger.info(messageToLog, failedNewsCategory);
        Logger.saveLog();
        failedNewsCategory.Sync_Failed__c = true;
        update failedNewsCategory;
    }
}