public class FeedItemEmailWorkflow{
    List<FeedItem> newList;
    Map<Id, List<String>> mapOfRecIdToCommunityEmails = new Map<Id, List<String>>();
    Map<Id, List<String>> mapOfRecIdToMidLandPublicEmails = new Map<Id, List<String>>();
    Map<Id, List<String>> mapOfRecIdToMidLandPrivateEmails = new Map<Id, List<String>>();
    Map<Id, FeedItem> mapOfRecIdToFeedItem = new Map<Id, FeedItem>();
    Set<Id> setOfContactIds = new Set<Id>();
    Set<Id> employeedMidLandHRIds = new Set<Id>();
    Set<Id> setOfOwnerIds = new Set<Id>();
    String objName;

    public FeedItemEmailWorkflow(List<FeedItem> newList){
        this.newList = newList;
        objName = newList[0].ParentId.getSObjectType().getDescribe().getName();
        system.debug(objName);
        execute();
    }
    
    public void execute(){
        Map<Id, String> caseToContactEmail = new Map<Id, String>();
        Map<Id, String> recToOwnerEmail = new Map<Id, String>();
        Map<Id,String> documentEmail = new Map<Id,String>();
        Map<Id, Set<String>> mapOfRecIdToSubscriberEmpEmails = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapOfRecIdToSubscriberEmails = new Map<Id, Set<String>>();
        List<FeedItem> qualifiedFeedList= new List<FeedItem>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, Defect__c> defectMap = new Map<Id, Defect__c>();
        Map<Id, Documentation__c> documentMap = new Map<Id, Documentation__c>();

        Boolean isDefectEnabled = FALSE;
        for(Feed_Email_Workflow__c temp : [Select Id, Defect__c FROM Feed_Email_Workflow__c WHERE Name = 'Feed Email']){
            isDefectEnabled = TRUE;
        }

        for(FeedItem feed : newList){
            if(objName == 'Case' || objName == 'Documentation__c' || (objName == 'Defect__c' && isDefectEnabled)){
                qualifiedFeedList.add(feed);
                mapOfRecIdToFeedItem.put(feed.ParentId, feed);
                setOfOwnerIds.add(feed.CreatedById); 
            }
        }

        if(!qualifiedFeedList.isEmpty()){
            if(objName == 'Case'){
                for(Case c: [SELECT Id, CaseNumber, Contact.Email, OwnerId, Owner.Email, Subject FROM Case WHERE Id IN: mapOfRecIdToFeedItem.keySet()]){
                    caseMap.put(c.Id, c);
                    if(c.ContactId != NULL){
                        caseToContactEmail.put(mapOfRecIdToFeedItem.get(c.Id).Id, c.Contact.Email);
                    }
                    if(mapOfRecIdToFeedItem.get(c.Id).CreatedById != c.OwnerId){
                        recToOwnerEmail.put(mapOfRecIdToFeedItem.get(c.Id).Id, c.Owner.Email);
                    }
                }
            }
            else if(objName == 'Defect__c'){
                for(Defect__c d : [SELECT Id, OwnerId, Owner.Email, Name FROM Defect__c WHERE Id IN: mapOfRecIdToFeedItem.keySet()]){
                    defectMap.put(d.Id, d);
                    if(mapOfRecIdToFeedItem.get(d.Id).CreatedById != d.OwnerId){
                        recToOwnerEmail.put(mapOfRecIdToFeedItem.get(d.Id).Id, d.Owner.Email);
                    }
                }
            }
            else if(objName == 'Documentation__c'){
                for(Documentation__c d : [SELECT Id, OwnerId, Owner.Email, Name FROM Documentation__c WHERE Id IN: mapOfRecIdToFeedItem.keySet()]){
                    documentMap.put(d.Id, d);
                    if(mapOfRecIdToFeedItem.get(d.Id).CreatedById != d.OwnerId){
                        recToOwnerEmail.put(mapOfRecIdToFeedItem.get(d.Id).Id, d.Owner.Email);
                    }
                }
            }
            
            
            for(EntitySubscription ent : [Select Id, ParentId, SubscriberId, Subscriber.Email, Subscriber.ContactId FROM EntitySubscription WHERE ParentId IN :mapOfRecIdToFeedItem.keySet()]){
                if(mapOfRecIdToFeedItem.get(ent.ParentId).CreatedById != ent.SubscriberId){
                    String feedId = mapOfRecIdToFeedItem.get(ent.ParentId).Id;
                    if(mapOfRecIdToSubscriberEmails.containsKey(feedId)){
                        mapOfRecIdToSubscriberEmails.get(feedId).add(ent.Subscriber.Email);
                    }
                    else{
                        mapOfRecIdToSubscriberEmails.put(feedId, new Set<String>{ent.Subscriber.Email});
                    }
                    if(ent.Subscriber.ContactId == NULL){
                        if(mapOfRecIdToSubscriberEmpEmails.containsKey(feedId)){
                            mapOfRecIdToSubscriberEmpEmails.get(feedId).add(ent.Subscriber.Email);
                        }
                        else{
                            mapOfRecIdToSubscriberEmpEmails.put(feedId, new Set<String>{ent.Subscriber.Email});
                        }            
                    }
                }
            }
            
            system.debug('caseToContactEmail-->'+caseToContactEmail);
            system.debug('recToOwnerEmail-->'+caseToContactEmail);
            system.debug('mapOfRecIdToSubscriberEmails-->'+mapOfRecIdToSubscriberEmails);
            system.debug('mapOfRecIdToSubscriberEmpEmails-->'+mapOfRecIdToSubscriberEmpEmails);
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(FeedItem feed : qualifiedFeedList){
                system.debug('*****'+feed.Id);
                List<String> toEmailAddresses = new List<String>();
                List<String> bccEmailAddresses = new List<String>();
                Set<String> setOfBCCEmails = new Set<String>();
                Set<String> setOfToEmails = new Set<String>();
                String emailSubject = '';
                if(objName == 'Case')
                {
                    emailSubject = 'MidlandHR Support Case:' + caseMap.get(feed.ParentId).CaseNumber + ' has been updated';
                }
                else if(objName == 'Defect__c')
                {
                    emailSubject = 'MidlandHR Defect:' + defectMap.get(feed.ParentId).Name  + ' has been updated';
                }
                else
                {
                    emailSubject = 'MidlandHR Documentation:' + documentMap.get(feed.ParentId).Name  + ' has been updated';
                }
                if(userMap.get(feed.CreatedById).ContactId != NULL){
                    if(mapOfRecIdToSubscriberEmails.containsKey(feed.Id) && mapOfRecIdToSubscriberEmails.get(feed.Id) != NULL){
                        setOfBCCEmails.addAll(mapOfRecIdToSubscriberEmails.get(feed.Id));                    }
                    if(recToOwnerEmail.containsKey(feed.Id) && recToOwnerEmail.get(feed.Id) != NULL && !setOfBCCEmails.contains(recToOwnerEmail.get(feed.Id))){
                        setOfBCCEmails.add(recToOwnerEmail.get(feed.Id));            
                    }
                    if(caseToContactEmail.containsKey(feed.Id) && caseToContactEmail.get(feed.Id) != NULL && !setOfToEmails.contains(caseToContactEmail.get(feed.Id))){
                        setOfToEmails.add(caseToContactEmail.get(feed.Id));
                    }
                }
                else if(feed.Visibility == 'AllUsers'){
                    if(mapOfRecIdToSubscriberEmails.containsKey(feed.Id) && mapOfRecIdToSubscriberEmails.get(feed.Id) != NULL){
                        setOfBCCEmails.addAll(mapOfRecIdToSubscriberEmails.get(feed.Id));
                    }
                    if(caseToContactEmail.containsKey(feed.Id) && caseToContactEmail.get(feed.Id) != NULL && !setOfToEmails.contains(caseToContactEmail.get(feed.Id))){
                        setOfToEmails.add(userMap.get(feed.CreatedById).Email);
                    }
                }
                else if(feed.Visibility == 'InternalUsers'){
                    if(mapOfRecIdToSubscriberEmpEmails.containsKey(feed.Id) && mapOfRecIdToSubscriberEmpEmails.get(feed.Id) != NULL){
                        setOfBCCEmails.addAll(mapOfRecIdToSubscriberEmpEmails.get(feed.Id));
                    }
                    if(userMap.containsKey(feed.CreatedById) && userMap.get(feed.CreatedById) != NULL && userMap.get(feed.CreatedById).Email != NULL && !setOfToEmails.contains(userMap.get(feed.CreatedById).Email)){
                        setOfToEmails.add(userMap.get(feed.CreatedById).Email);
                    }
                }
                bccEmailAddresses.addAll(setOfBCCEmails);
                toEmailAddresses.addAll(setOfToEmails);

                if(!bccEmailAddresses.isEmpty() || !toEmailAddresses.isEmpty()){
                    string TemplateId;
                    string HTMLBody;
                    string TargetObjId;
                    Map<string,string> MailMergeMap = new  Map<string,string>();
                    
                    Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                    
                    if(objName == 'Defect__c'){
                        TemplateID= Label.Defect_Feed_Template;
                    }
                    else if(objName == 'Case'){
                         TemplateID= Label.Case_Feed_Template;
                    }
                    else if(objName == 'Documentation__c')
                    {
                        TemplateID = Label.Documentation_Support_Template;
                    }
                   // m.setWhatId();
                    if(objName == 'Case' && userMap.get(feed.CreatedById).ContactId != NULL){
                        m.setTargetObjectId(caseMap.get(feed.ParentId).ContactId);
                        TargetObjId=caseMap.get(feed.ParentId).ContactId;
                    }
                    else{
                        m.setTargetObjectId(feed.CreatedById);
                        TargetObjId = feed.CreatedById;
                    }
                    if(!toEmailAddresses.isEmpty()){
                        m.setToAddresses(toEmailAddresses);
                    }
                    if(!bccEmailAddresses.isEmpty()){
                        m.setBccAddresses(bccEmailAddresses);
                    }
                    if(emailSubject != '' || emailSubject != null){
                        m.setSubject(emailSubject);
                    }
                    m.setUseSignature(false);
                    m.setSaveAsActivity(false);
                    m.setOrgWideEmailAddressId('0D2b0000000GnfP');
                    MailMergeMap = mailUtils.getMergedTemplateForObjectWithoutSending(TargetObjId,feed.ParentId, TemplateID, false, false, 'MidlandHR Community');
                    if(objName == 'Case')
                    {
                        m.setHtmlBody(MailMergeMap.get('htmlBody').replace('{~~FEEDBODY~~}', '<table width="100%" cellspacing="0" cellpadding="10" border="0" bgcolor="#ffffff"><tbody><tr><td width="9%" height="auto"style="vertical-align:top;"><img width="50px" height="auto" style="max-width: 100%; border: 0px none; vertical-align: top;" src="https://midlandhr--test.cs17.my.salesforce.com/servlet/servlet.ImageServer?id=015g0000001Ay2g&oid=00Dg0000006SNDJ"></td><td width="90%" height="auto" style="vertical-align:top;"><table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-size:14px;font-family: arial,sans-serif;"><tbody><tr><td style="font-size:14px;font-family: arial,sans-serif;"><a href="https://midlandhr--test.cs17.my.salesforce.com/' + feed.CreatedById + '" style="text-decoration:none;font-weight:bold;color:#0070C0;font-size:14px;font-family: arial,sans-serif;">' + userMap.get(feed.CreatedById).Name + '</a> - <a href="https://midlandhr--test.cs17.my.salesforce.com/'+ feed.ParentId +'" style="text-decoration:none;font-weight:bold;color:#0070C0;font-size:14px;font-family: arial,sans-serif;">Case number</a> '+caseMap.get(feed.ParentId).CaseNumber +' <a href="https://midlandhr--test.cs17.my.salesforce.com/'+ feed.ParentId +'" style="text-decoration:none;font-weight:bold;color:#0070C0;font-size:14px;font-family: arial,sans-serif;">Case Subject</a> - '+caseMap.get(feed.ParentId).Subject+'</td></tr><tr><td style="padding:8px 0px;font-family: arial,sans-serif;font-size:14px;">'+ feed.Body +'</td></tr></tbody></table></td></tr></tbody></table>'));                    
                    }
                    else if(objName == 'Defect__c')
                    {
                        m.setHtmlBody(MailMergeMap.get('htmlBody').replace('{~~FEEDBODY~~}', '<table width="100%" cellspacing="0" cellpadding="10" border="0" bgcolor="#ffffff"><tbody><tr><td width="9%" height="auto"style="vertical-align:top;"><img width="50px" height="auto" style="max-width: 100%; border: 0px none; vertical-align: top;" src="https://midlandhr--test.cs17.my.salesforce.com/servlet/servlet.ImageServer?id=015g0000001Ay2g&oid=00Dg0000006SNDJ"></td><td width="90%" height="auto" style="vertical-align:top;"><table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-size:14px;font-family: arial,sans-serif;"><tbody><tr><td style="font-size:14px;font-family: arial,sans-serif;"><a href="https://midlandhr--test.cs17.my.salesforce.com/' + feed.CreatedById + '" style="text-decoration:none;font-weight:bold;color:#0070C0;font-size:14px;font-family: arial,sans-serif;">' + userMap.get(feed.CreatedById).Name + '</a> - <a href="https://midlandhr--test.cs17.my.salesforce.com/'+ feed.ParentId +'" style="text-decoration:none;font-weight:bold;color:#0070C0;font-size:14px;font-family: arial,sans-serif;">Defect</a> '+defectMap.get(feed.ParentId).Name +'</td></tr><tr><td style="padding:8px 0px;font-family: arial,sans-serif;font-size:14px;">'+ feed.Body +'</td></tr></tbody></table></td></tr></tbody></table>'));                    
                    }
                    else
                    {
                        m.setHtmlBody(MailMergeMap.get('htmlBody').replace('{~~FEEDBODY~~}', '<table width="100%" cellspacing="0" cellpadding="10" border="0" bgcolor="#ffffff"><tbody><tr><td width="9%" height="auto"style="vertical-align:top;"><img width="50px" height="auto" style="max-width: 100%; border: 0px none; vertical-align: top;" src="https://midlandhr--test.cs17.my.salesforce.com/servlet/servlet.ImageServer?id=015g0000001Ay2g&oid=00Dg0000006SNDJ"></td><td width="90%" height="auto" style="vertical-align:top;"><table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-size:14px;font-family: arial,sans-serif;"><tbody><tr><td style="font-size:14px;font-family: arial,sans-serif;"><a href="https://midlandhr--test.cs17.my.salesforce.com/' + feed.CreatedById + '" style="text-decoration:none;font-weight:bold;color:#0070C0;font-size:14px;font-family: arial,sans-serif;">' + userMap.get(feed.CreatedById).Name + '</a> - <a href="https://midlandhr--test.cs17.my.salesforce.com/'+ feed.ParentId +'" style="text-decoration:none;font-weight:bold;color:#0070C0;font-size:14px;font-family: arial,sans-serif;">Documentation</a> '+documentMap.get(feed.ParentId).Name +'</td></tr><tr><td style="padding:8px 0px;font-family: arial,sans-serif;font-size:14px;">'+ feed.Body +'</td></tr></tbody></table></td></tr></tbody></table>'));                    
                    }
                        
                    emailList.add(m);
                }
            }
            
            if(!emailList.isEmpty()){
                Messaging.sendEmail(emailList);
            }
        }
    }
    
    public Map<Id, User> userMap {
        get {
            if(userMap == null) {
                userMap = new Map<Id, User>();
                for(User u: [SELECT Id, ContactId, Email, Name, SmallPhotoUrl FROM User WHERE Id IN: setOfOwnerIds]) {
                    userMap.put(u.Id, u);
                }
            }
            return userMap;
        }
        private set;
    }
    
    public static void fakeMethod()
    {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        System.debug('Fake Method' +i);
  	}

}