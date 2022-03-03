public with sharing class Logger {

    private static final Logger_Setting__mdt GLOBAL_SETTING = LoggerUtil.getLoggerConfiguration();

    public class LogParameter {
        
        @InvocableVariable(label = 'Content' description = 'Informative message content of the log' required = true)
        public String content;

        @InvocableVariable(label = 'Source' description = 'Name of the Flow or Process Builder that creates the log' required = true)
        public String source;

        @InvocableVariable(label = 'Type' description='Type of log being created [\'Exception Log\', \'Execution Log\', \'Debug Log\']' required = true)
        public String type;

        @InvocableVariable(label = 'Override: Insert Record' description='Determines if a log record get inserted (Overrides the Insert_Log_Records setting defined in the Logger_Setting custom MDT)')
        public Boolean insertRecord;

        @InvocableVariable(label = 'Override: Send Email' description='Determines if an email message is sent to addresses defined in the Administrator__c custom setting (Overrides the Send_Log_Emails setting defined in the Logger Setting custom MDT)')
        public Boolean sendEmail;
        
        public LogParameter() {}
        
        public LogParameter(String content, String source, String type, Boolean insertRecord, Boolean sendEmail) {
            this.content = content;
            this.source = source;
            this.type = type;
            this.insertRecord = insertRecord;
            this.sendEmail = sendEmail;
        }
    }

    @InvocableMethod(label='Log' description='Creates a log that is inserted as a record and/or sent as an email depending on the pe.')
    public static void log(List<LogParameter> logParameterList) {

        List<Log__c> logsToInsert = new List<Log__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> addressList = LoggerUtil.getAddressList();
        
        for (LogParameter logParameter : logParameterList) { 
            if (logParameter.sendEmail != null && logParameter.sendEmail || GLOBAL_SETTING.Send_Log_Emails__c) {
                emailList.add(LoggerUtil.createEmail(logParameter, addressList));
            }

            if (logParameter.insertRecord != null && logParameter.insertRecord || GLOBAL_SETTING.Insert_Log_Records__c) {
                logsToInsert.add(LoggerUtil.createLog(logParameter));
            }
        }
        
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }

        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }
    }

    public static void logException(Exception e) {
        Log__c log = LoggerUtil.log(new List<LogParameter>{new LogParameter()});
        log.RecordTypeId = Schema.getGlobalDescribe().get(LoggerConstants.RECORD_TYPE_LABEL_EXCEPTION_LOG).getDescribe().getRecordTypeInfosByName().get(LoggerConstants.RECORD_TYPE_LABEL_EXCEPTION_LOG).getRecordTypeId();
        log.Stack_Trace__c = e.getStackTraceString();
        log.Line_Number__c = e.getLineNumber();
        insert log;
    }

}