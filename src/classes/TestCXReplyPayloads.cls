@isTest
public class TestCXReplyPayloads {

    static testMethod void validateGetToken() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setToken('60006f70d1706da3');
        System.assertEquals(payload.getToken(), '60006f70d1706da3');
    }

    static testMethod void validateGetName() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setName('Anonymous 2');
        System.assertEquals(payload.getName(), 'Anonymous 2');
    }

    static testMethod void validateEmail() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setEmail('joe1@email.com');
        System.assertEquals(payload.getEmail(), 'joe1@email.com');
    }

    static testMethod void validateAnsweredAt() {
        CXReplyPayload payload = new CXReplyPayload();
        DateTime answered_at = DateTime.now();
        payload.setAnsweredAt(answered_at);
        System.assertEquals(payload.getAnsweredAt(), answered_at);
    }

    static testMethod void validateNps() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setNps(8);
        System.assertEquals(payload.getNps(), 8);
    }

    static testMethod void validateNpsReason() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setNpsReason('Reason 2');
        System.assertEquals(payload.getNpsReason(), 'Reason 2');
    }

    static testMethod void validateReplyUrl() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setReplyUrl('http://cx.dev/app/replies/60006f70d1706da1');
        System.assertEquals(payload.getReplyUrl(), 'http://cx.dev/app/replies/60006f70d1706da1');
    }

    static testMethod void validateQuestionsAnswered() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setQuestionsAnswered(3);
        System.assertEquals(payload.getQuestionsAnswered(), 3);
    }

    static testMethod void validateSurveyName() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setSurveyName('Churned Feedback 2');
        System.assertEquals(payload.getSurveyName(), 'Churned Feedback 2');
    }

    static testMethod void validateRegion() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setRegion('CA');
        System.assertEquals(payload.getRegion(), 'CA');
    }

    static testMethod void validateCountryCode() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setCountryCode('CA');
        System.assertEquals(payload.getCountryCode(), 'CA');
    }

    static testMethod void validateSentiment() {
        CXReplyPayload payload = new CXReplyPayload();
        payload.setSentiment('detractor');
        System.assertEquals(payload.getSentiment(), 'detractor');
    }

}