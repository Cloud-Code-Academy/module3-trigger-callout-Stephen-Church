/**
 * Queueable Apex class for processing News Category records with pagination support
 */
public class NewsCategoryQueueable implements Queueable, Database.AllowsCallouts {

    private static final Integer MAX_PAGES = 3;
    private News_Category__c category;
    private Integer currentPage;
    
    public NewsCategoryQueueable(News_Category__c category, Integer currentPage) {
        this.category = category;
        this.currentPage = currentPage;
    }
    
    public void execute(QueueableContext context) {
        
        News_Category__c updatedCategory = new News_Category__c();
        updatedCategory.Id = category.Id;

        try {
            NewsAPIResponse response = NewsAPIService.getTopHeadlinesByCategory(category.Sync_USA_Only__c, category.Name, category.Sync_Keywords__c, currentPage);
            NewsAPIService.checkForErrorStatus(response);
            
            List<Article__c> articles = new List<Article__c>();
            for (NewsAPIResponse.Article article : response.articles) {
                Article__c newArticle = NewsAPIResponse.convertToSObject(article, category);
                articles.add(newArticle);
            }

            insert articles;

            // Don't re-queue if the results had less than the max per page or we are on the max page, as there are no more to fetch.
            // If no more to fetch, update the News Category
            if (!Test.isRunningTest() && NewsAPIService.morePagesToCheck(response.articles.size()) && currentPage < MAX_PAGES) {
                NewsCategoryQueueable ncq = new NewsCategoryQueueable(category, currentPage + 1);
                System.enqueueJob(ncq);
            } else {
                // IMPORTANT: Create a separate instance of the category for updates
                updatedCategory = NewsCategoryHelper.setNewsCategoryFieldsAfterSync(updatedCategory);
                update updatedCategory;
                NewsCategoryHelper.logSuccessSync(updatedCategory);
            }
        } catch (NewsAPIService.NewsAPIException e) {
            NewsCategoryHelper.logFailedSync('Failure to sync articles for a new News Category.', e.getMessage(), updatedCategory);
        } catch (Exception e) {
            NewsCategoryHelper.logFailedSync('Unexpected failure in syncing articles for a new News Category.', e.getMessage(), updatedCategory);
        }
    }
} 