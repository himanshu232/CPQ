public with sharing class OegenHelper {
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // TestClass: Test_OegenHelper.cls
    // Created by John Hutchinson 🌵
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    /*  Assistive notes:
		####################
		This class is written to generalise the methods used in other
		controllers and classes written by Oegen.

		If you use this class or any of its methods please credit the authors.
    */
    
	public static Map<Integer, String> errorCodesInit(){
		//////////////////////////////////////////////////
        //  Initialise error codes to a map of
        //  customisable codes.
        //////////////////////////////////////////////////
        Map<Integer, String> errorCodes = new Map<Integer, String>();
        /* Positive */
		errorCodes.put(206,     'Long-running Schedule replication was completed successfully.');
		errorCodes.put(205,     'This replication will take some time. You will receive an email shortly with a status update');
		errorCodes.put(204,     'Replication for this Schedule has been placed on hold');
		errorCodes.put(203,     'Successfully scheduled replication for tonight');
		errorCodes.put(202,		'Successfully replicated the Schedule. Click Continue to navigate to the Account where they are located');
		errorCodes.put(201,		'Record(s) updated');
		errorCodes.put(200,		'No updates to save');

        /* Negative */
		errorCodes.put(-404,	'Error: This page should be accessed by navigating to a valid activity first');
		errorCodes.put( -1,		'Error Saving:');
		errorCodes.put( -2,     'Please select a valid "When?" value, or click Cancel to go back to the Schedule');
		errorCodes.put( -3,     '\'How many times?\' must be greater than 0 and less than 53');
		errorCodes.put( -4,     'You must select an Account for the new Schedules');
		errorCodes.put( -5,     'An error occurred while replicating the Schedule. Please try again, or contact an Administrator.');

		return errorCodes;
	}

	public static Boolean emailIsEnabled {
        get {
            try {
                Messaging.reserveSingleEmailCapacity(0);
                return true;
            } catch (System.NoAccessException e) {
                return false;
            }
        }
    }

    public static Messaging.SingleEmailMessage initEmail(String emailSubject, String emailBody, List<String> toAddresses) {

        Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
        m.setSubject(emailSubject);
        m.setHTMLbody(emailBody);
        m.setToAddresses(toAddresses);
        m.setBccSender(false);
        m.setUseSignature(false);
		try {
			m.setOrgWideEmailAddressId(getOrgWideEmailAddressId('Managed Services'));
		} catch (Exception e) {
			System.debug(System.LoggingLevel.ERROR, 'Error while trying to set Org Wide Sending email address: ' + e.getMessage());
		}
        return m;

    }

	public static Id getOrgWideEmailAddressId(String displayName) {
		// Use Organization Wide Address
		return [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :displayName LIMIT 1].Id;
	}

	// Error code Methods for other classes to use Helper.
	// For usage examples see OegenHelper_Test.cls
	/*
	public void setFeedback(Integer i){
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
	public void setFeedback(Integer i, Integer c){
		if (i < 0){
			feedbackNeg.put(i, String.valueOf(c) + ' ' + errorCodes.get(i) );
		}
		else{
			feedbackPos.put(i, String.valueOf(c) + ' ' + errorCodes.get(i) );
		}
	}
	public void setFeedback(Integer i, String msg){
		if (i < 0){
			feedbackNeg.put(i, errorCodes.get(i) + ' ' + msg );
		}
		else{
			feedbackPos.put(i, errorCodes.get(i) + ' ' + msg );
		}
	}
	*/

}