public with sharing class bg_ContactUsController {
	public static Contact_Us__c getContactUsDetails() {
		return Contact_Us__c.getInstance('default');
	}
}