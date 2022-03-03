public with sharing class LoggerUtil {

    public static List<String> getAddressList() {
        List<String> addressList = new list<String>();
        for(Administrator__c admin : Administrator__c.getall().values()) {
            addressList.add(admin.Email__c);
        }
        return addressList;    
    }

    public static Log__c createLog(Logger.LogParameter logParameter) {
        Log__c log = new Log__c();
        if (Schema.getGlobalDescribe().get(LoggerConstants.OBJECT_LOG).getDescribe().getRecordTypeInfosByName().get(logParameter.type) != null) {
            log.RecordTypeId = Schema.getGlobalDescribe().get(LoggerConstants.OBJECT_LOG).getDescribe().getRecordTypeInfosByName().get(logParameter.type).getRecordTypeId();
        }
        log.Queries__c = Limits.getQueries();
        log.DML_Statements__c = Limits.getDmlRows();
        log.DML_Rows__c = Limits.getDmlStatements();
        log.CPU_Time__c = Limits.getCpuTime();
        return log;
    }

    public static Messaging.SingleEmailMessage createEmail(Logger.LogParameter logParameter, List<String> addressList) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Error in ' + logParameter.source);
        email.setPlainTextBody(logParameter.content);
        email.setToAddresses(addressList);
        return email;
    }

    public static Logger_Setting__mdt getLoggerConfiguration() {
        return Logger_Setting__mdt.getInstance(LoggerConstants.GLOBAL_SETTING);
    }

}