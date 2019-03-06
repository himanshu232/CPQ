@isTest
public class CaseUpdateOnEmailMessageTest {
    @isTest static void TestEmailMessage(){
        //Create case
        case myCase = new case (MServices_Contact_Email__c = 'ivorjenkins@mhr.co.uk');
        insert myCase;
        // create email message
        EmailMessage myEmail = new EmailMessage(ParentId = myCase.Id);
        insert myEmail;
        Attachment a0 = new Attachment(ParentId = myEmail.Id, Name = 'n0', Body = Blob.valueOf('b0'));
        insert a0;
        myEmail.TextBody = 'test';
        update myEmail;
        
    }
}