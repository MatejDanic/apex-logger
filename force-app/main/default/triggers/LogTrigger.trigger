trigger LogTrigger on Log__c (after insert) {

    LogTriggerHandler.handleAfterInsert(Trigger.newMap);

}