@isTest
public with sharing class NewsCategoryHelperTest {

    /***
    TESTS HELPER METHODS IN THIS CLASS. 
    SOME OF THE METHODS THAT ORECHESTRATE THE SYNC BY CALLING HELPER METHODS IN VARIOUS CLASSES WILL BE TESTED UNDER NEWSCATEGORYTRIGGERHANDLERTEST.
    ***/

    public static final String VALID_CATEGORY = NewsAPIServiceTest.VALID_CATEGORY;

    @TestSetup
    static void makeData(){

        News_Category__c nc = new News_Category__c();
        nc.Name = 'Test NC';
        insert nc;
    }

    static void testSyncChangedTrue(Boolean newNewsCategorySync, Boolean oldNewsCategorySync, Boolean expectedResult) {

        News_Category__c newNc = new News_Category__c();
        newNc.Sync__c = newNewsCategorySync;

        News_Category__c oldNc = new News_Category__c();
        oldNc.Sync__c = oldNewsCategorySync;

        Test.startTest();
        Boolean result = NewsCategoryHelper.syncChangedToTrue(newNc, oldNc);
        Test.stopTest();

        Assert.areEqual(expectedResult, result, 'The sync changed to TRUE value is not set as expected');
    }

    @isTest
    static void isValidCategoryToSync_true() {

        Test.startTest();
        Boolean result = NewsCategoryHelper.isValidCategoryToSync(VALID_CATEGORY);
        Test.stopTest();

        Assert.isTrue(result, 'The result should be TRUE since it is a valid category');
    }

    @isTest
    static void isValidCategoryToSync_false() {

        Test.startTest();
        Boolean result = NewsCategoryHelper.isValidCategoryToSync('Invalid category');
        Test.stopTest();

        Assert.isFalse(result, 'The result should be FALSE since it is not a valid category');
    }

    @isTest  
    static void syncChangedToTrue_yes() {

        testSyncChangedTrue(true, false, true);
    }

    @isTest  
    static void syncChangedToTrue_no_bothTrue() {

        testSyncChangedTrue(true, true, false);
    }

    @isTest  
    static void syncChangedToTrue_no_bothFalse() {

        testSyncChangedTrue(false, false, false);
    }

    @isTest  
    static void syncChangedToTrue_no_changedToFalse() {

        testSyncChangedTrue(false, true, false);        
    }

    @isTest  
    static void setNewsCategoryFieldsAfterSync() {

        News_Category__c nc = new News_Category__c();
        nc.Sync__c = true;
        nc.Sync_USA_Only__c = true;
        nc.Sync_Keywords__c = 'Test';
        nc.Sync_Page_Number__c = 1;
        nc.Sync_Failed__c = true;
        nc.Last_Synced__c = null;

        Test.startTest();
        nc = NewsCategoryHelper.setNewsCategoryFieldsAfterSync(nc);
        Test.stopTest();

        Assert.isFalse(nc.Sync__c, 'The Sync__c field should be set to FALSE after the sync');
        Assert.isFalse(nc.Sync_USA_Only__c, 'The USA_Only__c field should be set to FALSE after the sync');
        Assert.areEqual(null, nc.Sync_Keywords__c, 'The Sync_Keywords__c field should be null after the sync');
        Assert.areEqual(null, nc.Sync_Page_Number__c, 'The Sync_Page_Number__c field should be null after the sync');
        Assert.isFalse(nc.Sync_Failed__c, 'The Sync_Failed__c field should be set to FALSE after the sync');
        Assert.isTrue(nc.Last_Synced__c != null, 'The Last_Synced__c field should not be null after the sync');
    }

    @isTest  
    static void logSuccessSync() {

        News_Category__c nc = [SELECT Id FROM News_Category__c];

        Test.startTest();
        NewsCategoryHelper.logSuccessSync(nc);
        Test.stopTest();

        Integer countOfSuccessLogs = 0;
        List<LogEntry__c> logs = [SELECT Id, Message__c, RecordId__c FROM LogEntry__c WHERE RecordId__c = :nc.Id];
        for (LogEntry__c log : logs) {
            if (log.Message__c.startsWith('News Category Id ' + nc.Id + ' successfully synced at ')) {
                countOfSuccessLogs ++;
            }
        }
        Assert.areEqual(1, countOfSuccessLogs, '1 Success Log for the record was not returned');
    }

    @isTest  
    static void logFailedSync() {

        News_Category__c nc = [SELECT Id, Sync_Failed__c FROM News_Category__c];
        Assert.isFalse(nc.Sync_Failed__c, 'The Sync Failed field should be false before the test');

        Test.startTest();
        NewsCategoryHelper.logFailedSync('Message.', 'Exception Message', nc);
        Test.stopTest();

        Assert.isTrue(nc.Sync_Failed__c, 'The Sync Failed field should be true after the test');

        Integer countOfFailedLogs = 0;
        List<LogEntry__c> logs = [SELECT Id, Message__c, RecordId__c FROM LogEntry__c WHERE RecordId__c = :nc.Id];
        for (LogEntry__c log : logs) {
            if (log.Message__c == 'Message. Details: Exception Message') {
                countOfFailedLogs ++;
            }
        }
        Assert.areEqual(1, countOfFailedLogs, '1 Failed Log for the record was not returned');
    }
}