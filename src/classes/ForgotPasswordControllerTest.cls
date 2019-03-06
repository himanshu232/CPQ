/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest public with sharing class ForgotPasswordControllerTest {
  	 @IsTest public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	
        controller.username = 'test@salesforce.com';
    	System.assertEquals(controller.forgotPassword(),null);

    	Profile p = [select Id from Profile where UserType = 'Standard' LIMIT 1];
    	//Create the User and set defaults.
    	User u = new User();
    	u.LastName = 'Dummy';
    	u.Alias = 'ddum1234';
    	u.Email = 'dummy@d.com';
    	u.Username = 'dummy'+datetime.now().millisecond()+datetime.now().millisecond()+'@test.com';
    	u.ProfileId = p.Id;
    	u.TimeZoneSidKey = 'Europe/London';
    	u.LocaleSidKey = 'en_US';
    	u.EmailEncodingKey = 'ISO-8859-1';
    	u.LanguageLocaleKey = 'en_US';
    	insert u;
         
        Controller.username = u.Username;
        controller.forgotPassword();
         
        Controller.username = '';
        controller.forgotPassword();
    }
}