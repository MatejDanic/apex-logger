/**
 	LoggingLevel:
  
	Highest
           ______
          /FINEST\			2
         / FINER  \			3
        /  FINE    \ 		4
       /   DEBUG    \ 		5	
      /    INFO      \ 		6	
     /     WARN       \ 	7 
    /      ERROR       \	8
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	Lowest
*/
public class ApexLogger {

    public String name { get; private set; }
    // custom setting that controls specific logging aspects like asynchronous inserting etc.
    public Logger_Configuration__c config = Logger_Configuration__c.getInstance(UserInfo.getUserId());
	// if no Logging Level is provided, the default is used
    private static final LoggingLevel DEFAULT_LOGGING_LEVEL = LoggingLevel.INFO;
    // map of all currently instanced loggers by name 
    private static Map<String, ApexLogger> loggerMap = new Map<String, ApexLogger>();

    public ApexLogger() {}
    
    public ApexLogger(String name) {
        this.name = name;
    }
    
    public static ApexLogger getLogger(Type targetType) {
        return getLogger(targetType.getName());
    }
    
    // returns an existing logger if found by name, otherwise creates a new one
    public static ApexLogger getLogger(String name) {
        if(!loggerMap.containsKey(name)) {
            ApexLogger logger = new ApexLogger(name);
            loggerMap.put(name, logger);
        }    
        return loggerMap.get(name);
    }
    
    private String filteredStackTrace {
        get {
            // simulate exception without throwing to get current stack trace
            String stackTrace = new DmlException().getStackTraceString();
            // exclude all traces of the logger class from stack trace
            String filteredStackTrace = '';
            for (String line : stackTrace.split('\n')) {
                // dot after class name is needed for test coverage,
                // becase the condition includes the test class name without it
                if (!line.startsWith('Class.ApexLogger.')) {
                	filteredStackTrace += line + '\n';
                }
            }
            return filteredStackTrace;
        }
    }
   
    // returns class and method where the log was taken from
    private String sourceClassAndMethod {
        get {
            String sourceClassAndMethod = '';
            // stack trace is ordered from latest to earliest, 
            // so the the first entry from is from the source class and method
            for (String line : filteredStackTrace.split('\n')) {
                sourceClassAndMethod = line.substringBetween('.', ':');
                break;
            }
            return sourceClassAndMethod;
        }
    }

    // logs a message with the default LoggingLevel
    public void log(String message) {
        log(DEFAULT_LOGGING_LEVEL, message);
    }

    public void log(String message, Object data) {
        log(DEFAULT_LOGGING_LEVEL, message, data);
    }
    
    // logs a message with a specific LoggingLevel
    public void log(LoggingLevel level, String message) {
        message = '<' + sourceClassAndMethod + '> ' + message;
        System.debug(level, message);
        try {
            if (isInsertEnabledForLogLevel(level)) {
            	generateAndInsertLogRecord(level, message);
        	}
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getTypeName() + ': ' + e.getMessage());
        	System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
        
    }

    public void log(LoggingLevel level, String message, Object data) {
        try {
            String dataString = JSON.serializePretty(data);
            System.debug(level, message + '\n' + dataString);
            if (isInsertEnabledForLogLevel(level)) {
            	generateAndInsertLogRecord(level, message, dataString);
        	}
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getTypeName() + ': ' + e.getMessage());
        	System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }
    
    // logs an exception with information like type name and stack trace string
    public void logException(Exception exc) {
        System.debug(LoggingLevel.ERROR, exc.getTypeName() + ': ' + exc.getMessage());
        System.debug(LoggingLevel.ERROR, exc.getStackTraceString());
        try {
            if (isInsertEnabledForLogLevel(LoggingLevel.ERROR)) {
            	generateAndInsertExceptionLogRecord(exc);
        	}
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getTypeName() + ': ' + e.getMessage());
        	System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
        
    }
    
    // checks custom setting if provided level is lower or equal to the highest log level for insert
    @TestVisible
    private Boolean isInsertEnabledForLogLevel(LoggingLevel level) {
        if (config == null) {
            throw new InvalidLoggerConfigurationException('Please create a Logger Configuration Custom Setting record.');
        }
        // LoggingLevel Enum ordinal value has the opposite direction than expected (i.e. ERROR => 8, ..., FINEST => 2)
        // for that reason, the operator is higher or equal instead of lower or equal
        return config.Log_Inserting_Active__c && level.ordinal() >= LoggingLevel.valueOf(config.Highest_Log_Level_for_Insert__c).ordinal();
    }
    
    public class InvalidLoggerConfigurationException extends Exception {}

    @TestVisible
    private void generateAndInsertLogRecord(LoggingLevel level, String message) {
        Log__c log = generateLogRecord(level, message);
        insertLogRecord(log);
    }
    
    private void generateAndInsertLogRecord(LoggingLevel level, String message, String dataString) {
        Log__c log = generateLogRecord(level, message, dataString);
        insertLogRecord(log);
    }
    
    private void generateAndInsertExceptionLogRecord(Exception exc) {
        Log__c log = generateLogRecord(LoggingLevel.ERROR, exc.getMessage());
        log.Exception__c = exc.getTypeName();
        log.Stack_Trace__c = exc.getStackTraceString();
        insertLogRecord(log);
    }
   
    private Log__c generateLogRecord(LoggingLevel level, String message) {
        Log__c log = new Log__c();
        log.Message__c = message;
        log.Stack_Trace__c = filteredStackTrace;
        log.RecordTypeId = Schema.SObjectType.Log__c.getRecordTypeInfosByDeveloperName().get(String.valueOf(level)).getRecordTypeId();
        appendContextInfo(log);
        appendLimitInfo(log);
        return log;
    }

    private Log__c generateLogRecord(LoggingLevel level, String message, String dataString) {
        Log__c log = generateLogRecord(level, message);
        log.Data__c = dataString;
        return log;
    }
                              
   	private void appendContextInfo(Log__c log) {
        log.User__c = UserInfo.getUserId();
        log.Time__c = DateTime.now();
        log.Is_Batch__c = System.isBatch();
        log.Is_Future__c = System.isFuture();
        log.Is_Scheduled__c = System.isScheduled();
        log.Is_Queueable__c = System.isQueueable();
        log.Request_Id__c = Request.getCurrent().getRequestId();
		log.Quiddity__c = String.valueOf(Request.getCurrent().getQuiddity());
    }

    private void appendLimitInfo(Log__c log) {
        log.CPU_Time__c = Limits.getCPUTime();
        log.CPU_Time_Limit__c = Limits.getLimitCPUTime();
        log.DML_Rows__c = Limits.getDMLRows();
        log.DML_Rows_Limit__c = Limits.getLimitDMLRows();
        log.DML_Statements__c = Limits.getDMLStatements();
        log.DML_Statements_Limit__c = Limits.getLimitDMLStatements();
        log.Heap_Size__c = Limits.getHeapSize();
        log.Heap_Size_Limit__c = Limits.getLimitHeapSize();
        log.Queries__c = Limits.getQueries();
        log.Queries_Limit__c = Limits.getLimitQueries();
        log.Query_Rows__c = Limits.getQueryRows();
        log.Query_Rows_Limit__c = Limits.getLimitQueryRows();
    }
    
    @TestVisible
    private void insertLogRecord(Log__c log) {
        if (config.Event_Based_Logging__c && 'AURA'.equals(log.Quiddity__c)) {
            String logJson = JSON.serialize(log);
            Log_event__e event = new Log_event__e(Log__c = logJson);
            EventBus.publish(event);            
        } else if (config.Asynchronous_Mode__c) {
            System.enqueueJob(new AsyncApexLogger(new List<Log__c>{log}));
        } else {
            Database.insert(log);
        }
    }
    
    public void error(String message) {
        log(LoggingLevel.ERROR, message);
    }

    public void error(String message, Object data) {
        log(LoggingLevel.ERROR, message, data);
    }
    
    public void error(Exception exc) {
        logException(exc);
    }

    public void warn(String message) {
        log(LoggingLevel.WARN, message);
    }

    public void warn(String message, Object data) {
        log(LoggingLevel.WARN, message, data);
    }
    
    public void info(String message) {
        log(LoggingLevel.INFO, message);
    }   

    public void info(String message, Object data) {
        log(LoggingLevel.INFO, message, data);
    }    
    
    // logs a method entry
    public void entering() {
        fine('Entering: ' + sourceClassAndMethod);
    }

    // logs a method return
    public void exiting() {
        fine('Exiting: ' + sourceClassAndMethod);
    }
    
    // logs a DEBUG message, these logs should be used tempoarary, used only while developing and deleted afterwards
    public void debug(String message) {
        log(LoggingLevel.DEBUG, message);
    }

    public void debug(String message, Object data) {
        log(LoggingLevel.DEBUG, message, data);
    }

    public void fine(String message) {
        log(LoggingLevel.FINE, message); 
    }

    public void fine(String message, Object data) {
        log(LoggingLevel.FINE, message, data); 
    }

    public void finer(String message) {
        log(LoggingLevel.FINER, message); 
    }    
    
    public void finer(String message, Object data) {
        log(LoggingLevel.FINER, message, data); 
    }

    public void finest(String message) {
        log(LoggingLevel.FINEST, message); 
    }

    public void finest(String message, Object data) {
        log(LoggingLevel.FINEST, message, data); 
    }
    
    public class AsyncApexLogger implements System.Queueable {
    
        private List<Log__c> logList;
        
        public AsyncApexLogger(List<Log__c> logList) {
            this.logList = logList;
        }
    
        public void execute(System.QueueableContext qc) {
            Database.insert(logList, false);
        }
	}
}