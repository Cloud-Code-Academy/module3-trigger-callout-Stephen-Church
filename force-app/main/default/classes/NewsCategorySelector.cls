public with sharing class NewsCategorySelector {

    public static News_Category__c getNewsCategorySyncFieldsFromId(Id newsCategoryId) {

        News_Category__c newsCat = [
            SELECT Id, Name, Sync__c, Sync_Keywords__c, Sync_Page_Number__c, Sync_USA_Only__c, Sync_Failed__c
            FROM News_Category__c
            WHERE Id = :newsCategoryId
        ];

        return newsCat;
    }
}