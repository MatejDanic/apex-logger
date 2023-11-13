@IsTest
public class ApexLoggerTest {
    
    @TestSetup
    private static void createCustomSetting() {
        Logger_Configuration__c config = new Logger_Configuration__c();
        config.Log_Inserting_Active__c = true;
        config.Asynchronous_Mode__c = false;
        config.Highest_Log_Level_for_Insert__c = String.valueOf(LoggingLevel.DEBUG);
        config.Event_Based_Logging__c = true;
        insert config;
    }
    
    private static ApexLogger logger = ApexLogger.getLogger(ApexLoggerTest.class);
    
    @IsTest
    public static void testAsynchronousLog() {
        logger.config.Asynchronous_Mode__c = true;
        Test.startTest();
        logger.log('Default Log');
        Test.stopTest();
    }
    
    @IsTest
    public static void testMissingConfiguration() {
        logger.config = null;
        Test.startTest();
        logger.log('Default Log');
        logger.log('Default Log', 1);
        logger.error(new DMLException());
        Test.stopTest();
    }

    @IsTest
    public static void testGenerateAndInsertLogRecord() {
        Test.startTest();
        logger.generateAndInsertLogRecord(LoggingLevel.INFO, 'Info log');
        Test.stopTest();
    }

    @IsTest
    public static void testInsertLogRecordWithEvent() {
        Log__c log = new Log__c();
        log.Message__c = 'Test message';
        log.Data__c = 'Test data';
        log.Quiddity__c = 'AURA';

        Test.startTest();
        logger.insertLogRecord(log);
        Test.stopTest();
    }

    @IsTest
    public static void testIsInsertEnabledForLogLevel() {
        logger.config = null;
        Exception caughtException;

        Test.startTest();
        try {
            logger.isInsertEnabledForLogLevel(LoggingLevel.FINEST);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
        
        System.assert(caughtException instanceof ApexLogger.InvalidLoggerConfigurationException);
    }

    @IsTest
    public static void testinvalidData() {
        Test.startTest();
        logger.log('Default Log', null);
        Test.stopTest();
    }
    
    @IsTest
    public static void testLoggerInitialization() {
        logger = new ApexLogger();
        Test.startTest();
        logger = ApexLogger.getLogger('Test Logger');
        Test.stopTest();
    }
    
    @IsTest
    public static void testDefaultLog() {
        Test.startTest();
        logger.log('Default Log');
        logger.log('Default Log', 1);
        Test.stopTest();
    }
    
    @IsTest
    public static void testErrorLog() {
        Test.startTest();
        logger.error('Error Log');
        logger.error('Error Log', 1);
        Test.stopTest();
    }
    
    @IsTest
    public static void testExceptionLog() {
        Test.startTest();
        logger.error(new DMLException('Exception Log'));
        Test.stopTest();
    }
    
    @IsTest
    public static void testWarnLog() {
        Test.startTest();
        logger.warn('Warn Log');
        logger.warn('Warn Log', 1);
        Test.stopTest();
    }
    
    @IsTest
    public static void testInfoLog() {
        Test.startTest();
        logger.info('Info Log');
        logger.info('Info Log', 1);
        Test.stopTest();
    }
    
    @IsTest
    public static void testEnteringLog() {
        Test.startTest();
        logger.entering();
        Test.stopTest();
    }
    
    @IsTest
    public static void testExitingLog() {
        Test.startTest();
        logger.exiting();
        Test.stopTest();
    }
    
    @IsTest
    public static void testDebugLog() {
        Test.startTest();
        logger.debug('Debug Log');
        logger.debug('Debug Log', 1);
        Test.stopTest();
    }
    
    @IsTest
    public static void testFineLog() {
        Test.startTest();
        logger.fine('Fine Log');
        logger.fine('Fine Log', 1);
        Test.stopTest();
    }
    
    @IsTest
    public static void testFinerLog() {
        Test.startTest();
        logger.finer('Finer Log');
        logger.finer('Finer Log', 1);
        Test.stopTest();
    }
    
    @IsTest
    public static void testFinestLog() {
        Test.startTest();
        logger.finest('Finest Log');
        logger.finest('Finest Log', 1);
        Test.stopTest();
    }
}