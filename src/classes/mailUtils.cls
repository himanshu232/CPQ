public class mailUtils {
  public class mailUtilsException extends exception {}

  public Boolean useSig {get; private set;}
  public Boolean saveActivity {get; private set;}
  public String senderDisplayName {get; private set;}

  public mailUtils(Boolean useSig, Boolean saveActivity, String senderDisplayName){
    this.useSig = usesig;
    this.saveActivity = saveActivity;
    this.senderDisplayName = senderDisplayName;
  }

  public Messaging.SingleEmailMessage MergeTemplateWithoutSending(Id targetObjectId,Id WhatID, Id templateId) {
    Messaging.reserveSingleEmailCapacity(1);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    // Intentionally set a bogus email address.
    String[] toAddresses = new String[]{'invalid@emailaddr.es'};
    mail.setToAddresses(toAddresses);
    mail.setUseSignature(this.useSig);
    mail.setSaveAsActivity(this.saveActivity);
    mail.setSenderDisplayName(this.senderDisplayName);
    mail.setTargetObjectId(targetObjectId);
    mail.setTemplateId(templateId);
    mail.setWhatId(WhatId);

    // create a save point
    Savepoint sp = Database.setSavepoint();
    // Force the merge of the template.
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    // Force a rollback, and cancel mail send.
    Database.rollback(sp);

    // Return the mail object
    // You can access the merged template, subject, etc. via:
    // String mailTextBody = mail.getPlainTextBody();
    // String mailHtmlBody = mail.getHTMLBody();
    // String mailSubject = mail.getSubject();
    return mail;

  }

  public static Map<String,String> getMergedTemplateForObjectWithoutSending(Id targetObjectId,Id WhatID, Id templateId, Boolean useSig, Boolean saveActivity, String senderDisplayName) {
    Map<String,String> returnValue = new Map<String,String>();
    mailUtils mu = new mailUtils(useSig, saveActivity, senderDisplayName);
    Messaging.SingleEmailMessage mail = mu.MergeTemplateWithoutSending(targetObjectId,WhatID, templateId);
    returnValue.put('textBody', mail.getPlainTextBody());
    returnValue.put('htmlBody', mail.getHTMLBody());
    returnValue.put('subject', mail.getSubject());
    return returnValue;
  }

}