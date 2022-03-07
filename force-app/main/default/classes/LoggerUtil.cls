public with sharing class LoggerUtil {

    public static List<String> getAddressList() {
        List<String> addressList = new list<String>();
        for(Administrator__c admin : Administrator__c.getall().values()) {
            addressList.add(admin.Email__c);
        }
        return addressList;    
    }

    public static Logger_Setting__mdt getLoggerSetting() {
        return Logger_Setting__mdt.getInstance(LoggerConstants.CUSTOM_METADATA_TYPE_RECORD_LOGGER_SETTING);
    }

    public static Log__c createLog(Logger.LogParameter logParameter) {
        Log__c log = new Log__c();
        if (Schema.getGlobalDescribe().get(LoggerConstants.OBJECT_LOG).getDescribe().getRecordTypeInfosByDeveloperName().get(logParameter.logType) != null) {
            log.RecordTypeId = Schema.getGlobalDescribe().get(LoggerConstants.OBJECT_LOG).getDescribe().getRecordTypeInfosByDeveloperName().get(logParameter.logType).getRecordTypeId();
        }
        log.Queries__c = Limits.getQueries();
        log.DML_Statements__c = Limits.getDmlRows();
        log.DML_Rows__c = Limits.getDmlStatements();
        log.CPU_Time__c = Limits.getCpuTime();
        return log;
    }

    public static Messaging.SingleEmailMessage createEmail(Logger.LogParameter logParameter, List<String> addressList) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Error in ' + logParameter.sourceName);
        email.setPlainTextBody(logParameter.message);
        email.setToAddresses(addressList);
        return email;
    }

    @Future(callout=true)
    public static void sendLogEmails(Set<Id> logIdSet) {   

        List<Log__c> logList = [
            SELECT Id
            FROM Log__c
            WHERE Id IN :logIdSet
        ];

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Log__c log : logList) {
            Messaging.SingleEmailmessage email = new Messaging.SingleEmailmessage();
            emailList.add(email);
        }

        if (emailList.size() > 0) {
            Messaging.sendEmail(emailList);
        }
    }

    public static String getClassName() {
        return getClassName(new DmlException().getStackTraceString().substringAfter('\n'));
    }

    public static String getMethodName() {
        return getMethodName(new DmlException().getStackTraceString().substringAfter('\n'));
    }

    private static String getClassName(String line) {
        if (line.startsWith('Class.'))
            line = line.substringAfter('Class.');
        return line.substringBefore(':').substringBeforeLast('.');
    }    

    private static String getMethodName(String line) {
        return line.substringBefore(':').substringAfterLast('.');
    }
}