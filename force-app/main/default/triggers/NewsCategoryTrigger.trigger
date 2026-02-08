trigger NewsCategoryTrigger on News_Category__c (after insert, after update) {

    switch on Trigger.operationType {
        when AFTER_INSERT {
            NewsCategoryTriggerHandler.handleAfterInsert(Trigger.new);
        }
        when AFTER_UPDATE {
            NewsCategoryTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }    
    }
} 