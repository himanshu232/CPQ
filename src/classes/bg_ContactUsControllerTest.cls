@isTest
private class bg_ContactUsControllerTest {
    static testMethod void RedirectToContactUs() {
        Test.startTest();
        bg_ContactUsController.getContactUsDetails();
        Test.stopTest();
    }
}