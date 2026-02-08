public with sharing class NewsCategoryTriggerHandler {
    
    public static void handleAfterInsert(List<News_Category__c> newRecords) {
        NewsCategoryHelper.syncWhenValidCategoryCreated(newRecords);
    }
    
    public static void handleAfterUpdate(List<News_Category__c> newRecords, Map<Id, News_Category__c> oldMap) {
        NewsCategoryHelper.syncWhenSyncUpdatedForValidCategory(newRecords, oldMap);
    }
} 