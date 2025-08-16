/**
 * Queueable Apex class for processing News Category records with pagination support
 */
public class NewsCategoryQueueable implements Queueable, Database.AllowsCallouts {
    // Static variable for maximum pages to fetch
    private static final Integer MAX_PAGES = 3;
    
    private List<News_Category__c> categories;
    private Integer currentPage;
    
    /**
     * Constructor
     * @param categories The list of News_Category__c records
     * @param currentPage Current page to process
     */
    public NewsCategoryQueueable(List<News_Category__c> categories, Integer currentPage) {
        this.categories = categories;
        this.currentPage = currentPage;
    }
    
    /**
     * Execute method for the queueable job
     * @param context The QueueableContext
     */
    public void execute(QueueableContext context) {
        for (News_Category__c category : categories) {
            News_Category__c updatedCategory = new News_Category__c(Id = category.Id);
            try {
                NewsAPIResponse apiResponse = NewsAPIService.getTopHeadlinesByCategory(category.Name, currentPage);
                List<Article__c> articlesToInsert = new List<Article__c>();
                if (apiResponse != null && apiResponse.articles != null) {
                    for (NewsAPIResponse.Article apiArticle : apiResponse.articles) {
                        Article__c article = NewsAPIResponse.convertToSObject(apiArticle);
                        article.News_Category__c = category.Id;
                        article.Category__c = category.Name;
                        articlesToInsert.add(article);
                    }
                }
                if(!articlesToInsert.isEmpty()) {
                    insert articlesToInsert;
                }

                Boolean isMorePages = (currentPage < MAX_PAGES) && (apiResponse != null && apiResponse.articles != null && !apiResponse.articles.isEmpty());
                if (isMorePages && !Test.isRunningTest()) {
                    System.enqueueJob(new NewsCategoryQueueable(new List<News_Category__c>{category}, currentPage + 1));
                }
                updatedCategory.Last_Synced__c = System.now();
                updatedCategory.Sync__c = false;
                try {
                    update updatedCategory;
                } catch (DmlException dmlEx) {
                    System.debug('DML Exception during update: ' + dmlEx.getMessage());
                    for (Integer i = 0; i < dmlEx.getNumDml(); i++) {
                        System.debug('DML Error[' + i + ']: ' + dmlEx.getDmlMessage(i));
                    }
                    throw dmlEx;
                }
            } catch (Exception e) {
                System.debug('Exception in Queueable: ' + e.getMessage());
                System.debug('Error: ' + e.getMessage());
                try {
                    update updatedCategory;
                } catch (DmlException dmlEx) {
                    System.debug('DML Exception during error update: ' + dmlEx.getMessage());
                }
            }
        }
    }
} 