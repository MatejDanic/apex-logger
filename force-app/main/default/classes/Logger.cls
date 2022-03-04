public with sharing class Logger {

    public class LogParameter {
        
        @InvocableVariable(label = 'Message' description = 'Informative message content of the log' required = true)
        public String message;
        
        @InvocableVariable(label = 'Log Type' description='Type of the log record being created [\'Execution_Log\', \'Error_Log\', \'Debug_Log\', \'Warning_Log\']' required = true)
        public String logType;

        @InvocableVariable(label = 'Source Name' description = 'Name of the Flow or Process Builder that creates the log')
        public String sourceName;
        
    }

    @InvocableMethod(label='Log' description='Creates a log that is inserted as a record')
    public static void log(List<LogParameter> logParameterList) {

        List<Log__c> logsToInsert = new List<Log__c>();

        for (LogParameter logParameter : logParameterList) {
            logsToInsert.add(LoggerUtil.createLog(logParameter));
        }

        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }
    }

    public static void error(String message) {
        System.debug(LoggingLevel.ERROR, message);
    }

    public static void warn(String message) {
        System.debug(LoggingLevel.WARN, message);
    }

    public static void info(String message) {
        System.debug(LoggingLevel.INFO, message);
    }

    public static void debug(String message) {
        System.debug(LoggingLevel.DEBUG, message);
    }
    
    public static void logException(Exception e) {
        Log__c log = new Log__c();
        log.recordTypeId = Schema.getGlobalDescribe().get(LoggerConstants.OBJECT_LOG).getDescribe().getRecordTypeInfosByDeveloperName().get(LoggerConstants.RECORD_TYPE_DEVELOPER_NAME_ERROR_LOG).getRecordTypeId();
        log.Stack_Trace__c = e.getStackTraceString();
        log.Line_Number__c = e.getLineNumber();
        log.Exception_Message__c = e.getMessage();
        log.Exception_Type__c = e.getTypeName();
        insert log;
    }
}