@isTest
public with sharing class NewsCategorySelectorTest {

    @TestSetup
    static void makeData(){

        News_Category__c nc = new News_Category__c();
        nc.Name = 'Test NC';
        insert nc;
    }

    @isTest 
    static void getNewsCategorySyncFieldsFromId() {

        News_Category__c nc = new News_Category__c();
        nc.Name = 'Test NC';
        insert nc;
        
        nc = [SELECT Id, Name, Sync__c, Sync_Keywords__c, Sync_Page_Number__c, Sync_USA_Only__c, Sync_Failed__c FROM News_Category__c WHERE Id = :nc.Id];

        Test.startTest();
        News_Category__c ncReturned = NewsCategorySelector.getNewsCategorySyncFieldsFromId(nc.Id);
        Test.stopTest();

        Assert.areEqual(nc, ncReturned, 'The record returned does not match the expected record');
    }
}