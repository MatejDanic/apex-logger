public with sharing class LogTriggerHandler {

    private static final Logger_Setting__mdt LOGGER_SETTING = LoggerUtil.getLoggerSetting();

    public static void handleAfterInsert(Map<Id, Log__c> logMap) {

        Set<Id> logIdForEmailSet = new Set<Id>();

        for (Log__c log : logMap.values()) {
            if (LOGGER_SETTING.Send_Error_Log_Emails__c && log.RecordType.Name == LoggerConstants.RECORD_TYPE_LABEL_ERROR_LOG
            || LOGGER_SETTING.Send_Warning_Log_Emails__c && log.RecordType.Name == LoggerConstants.RECORD_TYPE_LABEL_WARNING_LOG
            || LOGGER_SETTING.Send_Execution_Log_Emails__c && log.RecordType.Name == LoggerConstants.RECORD_TYPE_LABEL_EXECUTION_LOG
            || LOGGER_SETTING.Send_Debug_Log_Emails__c && log.RecordType.Name == LoggerConstants.RECORD_TYPE_LABEL_DEBUG_LOG) {
                logIdForEmailSet.add(log.Id);
            }
        }    

        if (!logIdForEmailSet.isEmpty()) {
            LoggerUtil.sendLogEmails(logIdForEmailSet);   
        }

    }

}