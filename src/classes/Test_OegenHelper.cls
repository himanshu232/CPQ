@isTest
private class Test_OegenHelper {
    // ##################################################
    // FOR: OegenHelper.cls
    // Created by John Hutchinson 🌵
    // ##################################################
    /*----------------------------------<Vars Error Codes >----------------------------------*/ 
    public static Map<Integer, String> errorCodes  {get; private set;}
    public static Map<Integer, String> feedbackPos {get;set;}
    public static Map<Integer, String> feedbackNeg {get;set;}
    /*----------------------------------</Vars Error Codes>----------------------------------*/ 


    @isTest
    static void test_errorCodesInit() {
        ////////////////////////////////////////
        //  Initialise error codes Map and read
        ////////////////////////////////////////
        errorCodes = new Map<Integer, String>();
        feedbackPos = new Map<Integer, String>();                           //Re-init feedback for new opperation.
        feedbackNeg = new Map<Integer, String>();

        errorCodes = OegenHelper.errorCodesInit();

        System.assert(errorCodes.containsKey(201));

    }
    



    @isTest
    static void test_Usage_Example() {
        ////////////////////////////////////////
        //  Set an error and check for it
        ////////////////////////////////////////
        errorCodes = new Map<Integer, String>();
        feedbackPos = new Map<Integer, String>();                           //Re-init feedback for new opperation.
        feedbackNeg = new Map<Integer, String>();

        errorCodes = OegenHelper.errorCodesInit();

        Test.startTest();
        setFeedback(-1, 'General error saving.');
        setFeedback(201);

        System.assert(feedbackNeg.containsKey(-1));
        System.assert(feedbackPos.containsKey(201));

    }




    static void setFeedback(Integer i){
        //////////////////////////////////////////////////
        //  Utility method to make body easier to read.
        //////////////////////////////////////////////////
        if (i < 0){
            feedbackNeg.put(i, errorCodes.get(i) );
        }
        else{
            feedbackPos.put(i, errorCodes.get(i) );
        }
    }
    static void setFeedback(Integer i, Integer c){
        if (i < 0){
            feedbackNeg.put(i, String.valueOf(c) + ' ' + errorCodes.get(i) );
        }
        else{
            feedbackPos.put(i, String.valueOf(c) + ' ' + errorCodes.get(i) );
        }
    }
    static void setFeedback(Integer i, String msg){
        if (i < 0){
            feedbackNeg.put(i, errorCodes.get(i) + ' ' + msg );
        }
        else{
            feedbackPos.put(i, errorCodes.get(i) + ' ' + msg );
        }
    }
    
}