public with sharing class Logger {

    public static void logException(Exception e) {
        Log__c log = new Log__c();
        log.RecordTypeId = Schema.getGlobalDescribe().get('Log__c').getDescribe().getRecordTypeInfosByName().get('Exception Log').getRecordTypeId();
        log.Stack_Trace__c = e.getStackTraceString();
        log.Line_Number__c = e.getLineNumber();
        log.Queries__c = Limits.getQueries();
        log.DML_Statements__c = Limits.getDmlRows();
        log.DML_Rows__c = Limits.getDmlStatements();
        log.CPU_Time__c = Limits.getCpuTime();
        insert log;
    }

}
