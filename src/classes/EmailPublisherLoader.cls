public class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {

    //Empty constructor
    public EmailPublisherLoader() {
    }
    
    // The main interface method
    public void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {

        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
    
        // Check if the quick action is the standard Case Feed Send Email action
        for (Integer i = 0; i < defaults.size(); i++) {
            if (defaults.get(i) instanceof QuickAction.SendEmailQuickActionDefaults
                && defaults.get(i).getTargetSObject().getSObjectType() == EmailMessage.sObjectType
                && defaults.get(i).getActionName().equals('Case.Email')
                && defaults.get(i).getActionType().equals('Email')) {
                sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(i);
                break;
            }
        }

        if(sendEmailDefaults != null) {

            Id mServicesRecTypeId = [SELECT Id FROM RecordType WHERE (SObjectType = 'Case' AND DeveloperName = 'Managed_Services_Case')].Id;
            Case c = [SELECT Id, Status, SuppliedEmail, RecordTypeId, Contact.Email FROM Case WHERE Id = :sendEmailDefaults.getContextId()];

            // ONLY PROCEED IF CASE RECORD TYPE IS MANAGED SERVICES
            if(c.RecordTypeId == mServicesRecTypeId) {
            
                if (sendEmailDefaults != null) {
                
                    EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();    
                    
                    // If Web Email field on Case matches an Org-Wide Email Address, set the From Address and From Name to the Org-Wide Address
                    OrgWideEmailAddress orgWideAddress = getFromAddress(c.SuppliedEmail);
                    if(orgWideAddress != null) {
                        emailMessage.FromAddress = orgWideAddress.Address;
                        emailMessage.FromName = orgWideAddress.DisplayName;
                    }
                    
                    // If the quick action default To Address is blank
                    if(sendEmailDefaults.getInReplyToId() == null) {

                        // Try to set the To Address to the email address of the last email received from outside of MHR
                        try {
                            String toAddress = [SELECT FromAddress FROM EmailMessage WHERE ParentId = :c.Id AND Incoming = TRUE ORDER BY CreatedDate DESC LIMIT 1].FromAddress;
                            emailMessage.ToAddress = toAddress;
                        } catch (exception e) {
                            System.debug('An error occurred while getting FromAddress from most recent incoming email on Case ' + c.Id + ': ' + e.getMessage());
                        }
                        
                        // Else, if the ToAddress is still blank, try to set the ToAddress to the Case Contact's Email address
                        if(emailMessage.ToAddress == null || emailMessage.ToAddress == '') {
                            try {
                                emailMessage.ToAddress = c.Contact.Email;
                            } catch (exception e2) {
                                System.debug('An error occurred while getting email address for Contact on Case ' + c.Id + ': ' + e2.getMessage());
                            }
                        }
                        
                        // Un-comment if we want to dynamically set the reply template based on number of emails on the Case, etc.
                        /* 
                        Set Template related fields 
                        When the In Reply To Id field is null we know the interface 
                        is called on page load. Here we check if 
                        there are any previous emails attached to the case and load 
                        the 'New_Case_Created' or 'Automatic_Response' template.
                        When the In Reply To Id field is not null we know that 
                        the interface is called on click of reply/reply all 
                        of an email and we load the 'Default_reply_template' template
                        */
                        /*
                            if (emailCount != null && emailCount > 0) {
                                sendEmailDefaults.setTemplateId(getTemplateIdHelper('Automatic_Response'));
                            } else {
                                sendEmailDefaults.setTemplateId(getTemplateIdHelper('New_Case_Created'));
                            }
                            sendEmailDefaults.setInsertTemplateBody(false);
                            sendEmailDefaults.setIgnoreTemplateSubject(false);
                        } else {
                            sendEmailDefaults.setTemplateId(getTemplateIdHelper('Default_reply_template'));
                            sendEmailDefaults.setInsertTemplateBody(false);
                            sendEmailDefaults.setIgnoreTemplateSubject(true);
                        }
                        */
                    }
                }
            }
        }
    }
    
    /*
    private Id getTemplateIdHelper(String templateApiName) {
        Id templateId = null;
        try {
            templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = : templateApiName].Id;   
        } catch (Exception e) {
            system.debug('Unble to locate EmailTemplate using name: ' + templateApiName + ' refer to Setup | Communications Templates ' + templateApiName);
        }
        return templateId;
    }
    */

    private OrgWideEmailAddress getFromAddress(String webEmail) {
        if (webEmail != null) { 
            try {
                //Get Org-Wide Address
                OrgWideEmailAddress address = [SELECT Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :webEmail LIMIT 1];
                //Return Org-Wide Address
                return address;
            } catch (exception e) {
                System.debug('An error occurred while searching for Org-Wide Email Address: ' + webEmail);
                return null;
            }
        } else {
            return null;
        }
    }

}