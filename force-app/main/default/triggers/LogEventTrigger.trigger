trigger LogEventTrigger on Log_Event__e (after insert) {
    try {
        List<Log__c> logListToInsert = new List<Log__c>();
        for (Log_Event__e logEvent : Trigger.new) {
            logListToInsert.add((Log__c) JSON.deserialize(logEvent.Log_String__c, Log__c.class));
        }
        Database.insert(logListToInsert, false);
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, e.getTypeName() + ': ' + e.getMessage());
        System.debug(LoggingLevel.ERROR, e.getStackTraceString());
    }
}