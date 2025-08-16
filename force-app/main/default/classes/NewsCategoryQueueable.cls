/**
 * Queueable Apex class for processing News Category records with pagination support
 */
public class NewsCategoryQueueable implements Queueable, Database.AllowsCallouts {
    // Static variable for maximum pages to fetch
    private static final Integer MAX_PAGES = 3;
    
    private News_Category__c category;
    private Integer currentPage;
    
    /**
     * Constructor
     * @param category The News_Category__c record
     * @param currentPage Current page to process
     */
    public NewsCategoryQueueable(News_Category__c category, Integer currentPage) {
        // TODO: Initialize with category and current page
        this.category = category;
        this.currentPage = currentPage;
    }
    
    /**
     * Execute method for the queueable job
     * @param context The QueueableContext
     */
    public void execute(QueueableContext context) {
    // IMPORTANT: Create a separate instance of the category for updates
    News_Category__c updatedCategory = new News_Category__c(Id = category.Id);
        
    try {
            // TODO: Implement execute method
            // - Call NewsAPI for the current page
            // - Convert API articles to Salesforce articles using NewsAPIResponse.convertToSObject
            // - Add category reference to each article
            // - Insert the articles
            // - Check if reached MAX_PAGES or no more articles
            // HINT: When requeuing the job check if tests are running
            // - Update category with last synced date and sync flag = false
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
                System.enqueueJob(new NewsCategoryQueueable(category, currentPage + 1));
            }
            updatedCategory.Last_Synced__c = System.now();
            updatedCategory.Sync__c = false;
            
            try {
                update updatedCategory;
                System.debug('Successfully updated category. Last_Synced__c: ' + updatedCategory.Last_Synced__c);
            } catch (DmlException dmlEx) {
                System.debug('DML Exception during update: ' + dmlEx.getMessage());
                for (Integer i = 0; i < dmlEx.getNumDml(); i++) {
                    System.debug('DML Error[' + i + ']: ' + dmlEx.getDmlMessage(i));
                }
                throw dmlEx;
            }
        } catch (Exception e) {
            // TODO: Handle errors
            // - Update category with error information
            // - Log error to debug logs
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