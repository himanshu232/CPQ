@isTest
public class com_whichPageController_Test {
	// ##################################################
	// FOR: com_whichPageController.cls
	// - Written by Hj 🌵 2017.12.12 -
	// ##################################################

	/* >>- Changelog -<<
	 * _REPLACE_WITH_DATE_
	

		* Useful information
		* ==================
		* 
	 */ 	
    
    @isTest(SeeAllData=true) static void test_1_1(){
        //////////////////////////////////////////////////
        //  Test 1 valid metadata entry returns information
        //  from the metadata configuration.
        ////////////////////////////////////////////////// 
        Map<String,String> result = new Map<String,String>();
        result = com_WhichPageController.getHeaderInformation('home');
        
        System.assert(result.get('header_line_1_label_Name__c') != '');
    }
    
    @isTest(SeeAllData=true) static void test_1_2(){
        //////////////////////////////////////////////////
        //  Test an invalid or null configuration where 
        //  controller returns null.
        ////////////////////////////////////////////////// 
        Map<String,String> result = new Map<String,String>();
        result = com_WhichPageController.getHeaderInformation('');
        
        System.assert(result == null);
    }
}