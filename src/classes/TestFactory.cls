@isTest
public class TestFactory {
    /////////////////////////////////////////////////////
    // Test data utility methods
	//	- Written by Hj 🌵 -			//-Hj- 2017.04.06
    /////////////////////////////////////////////////////

    /*  Assistive notes:
        ####################
        Useful equivalent terms to know when reading this back,
        "ContentDocument" = Salesforce Files tab.
        "ContentDocumentLink" = An attachment to a records feed.
        "ContentVersion" = A version of a file. ContentDocument doesn't allow direct creation
        so create a ContentVersion and a ContentDocument will be created.
    */
    
    public static Account createAccount(String name) {
        Account a = new Account(Name=name);
        try{
            insert a;
        }
        catch(DMLException e){
            System.debug('>>> '+ e.getDmlMessage(0));
        }
        return a;
    }
    
    public static Account createAccount(){
        Account a = new Account(Name='Account ' + randomWord(7) );
        try{
            insert a;
        }
        catch(DMLException e){
            System.debug('>>> '+ e.getDmlMessage(0));
        }
        return a;
    }


	public static Opportunity createOpportunity(Id accId, String name, Date closeDate, String stage) {
		Opportunity o = new Opportunity(AccountId=accId, Name=name, CloseDate=closeDate, StageName=stage);
		insert o;
		return o;
	}

    public static Contact createContact(Account a){
        Contact c = new Contact(Salutation='Dr.', FirstName=randomWord(5), LastName=randomWord(8), AccountId=a.Id, Email=randomEmail() );
        insert c;
        return c;
    }

    public static Contact createContact(Account a, String recordTypeDevName) {
        String recType = getRecordTypeId(recordTypeDevName, 'Active_Contact');
        Contact c = new Contact(FirstName=randomWord(5), RecordTypeId=recType, LastName=randomWord(8), AccountId=a.Id, Email=randomEmail());
        insert c;
        return c;
    }
    //////////////////////////////////////////////////
    //  Query Method from OegenHelper
    //////////////////////////////////////////////////
    public static String getRecordTypeId(String recTypeDevName, String objType) {
        List<RecordType> recTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :recTypeDevName AND SObjectType = :objType AND IsActive = true LIMIT 1];
        if(!recTypeId.isEmpty()) {
            return recTypeId[0].Id;
        } else {
            return null;
        }
    }
    
    
    public static void createManyContacts(Account a, Integer howMany){
        Integer count = 0;
        Contact tempContact = new Contact();
        List<Contact> listContacts = new List<Contact>();
        
        do{ tempContact = new Contact(FirstName=randomWord(5), LastName=randomWord(8), AccountId=a.Id, Email=randomEmail());
            listContacts.add(tempContact);
            count++;
        }while(count < howMany);
        insert listContacts;
    }
    
    
    public static List<Account> createManyAccounts(Integer howMany){
        List<Account> listAccounts = new List<Account>();
		Integer count = 0;        
        do{ Account tempAcc = new Account(Name='Account ' + randomWord(3), Phone=randomTel(), BillingPostalCode='M32 0JG');
            listAccounts.add(tempAcc);
            count++;
        }while(count < howMany);
        
        insert listAccounts;
        
        return listAccounts;
    }

    public static User createCommUser(Contact con, String profileId){
   		//Id p = [select Id FROM Profile WHERE Name = :profileName].id;
        
        User user = new User(alias = 'testUser', email=con.Email,
                emailencodingkey='UTF-8', lastname=con.LastName, languagelocalekey='en_US', localesidkey='en_US',
                profileid = profileId, country='United Kingdom', IsActive =TRUE, ContactId = con.Id, username=randomWord(5)+'@gmail.com',
                timezonesidkey='America/Los_Angeles', phone='01234567890', Street='The Street');
       
        insert user;
        return user;
    }
    
    
    public static User createInternalCommUser(){
        /* (This profile selected in p will need to be an internal user profile. */
   		Id p = [SELECT id FROM profile WHERE name='System Administrator'].id;

        User user = new User(alias = 'intUser', email='internaluser@corp.com',
                emailencodingkey='UTF-8', lastname='Internal', languagelocalekey='en_US', localesidkey='en_US',
                profileid = p, country='United Kingdom', IsActive =TRUE, username='internaluser@corp.com',
                timezonesidkey='America/Los_Angeles');
       
        insert user;
        return user;
    }
    
    public static User createNoPortalUser(){
   		Id p = [select id from profile where name='Standard User'].id;
        
        User user = new User(alias = 'inacuse', email='testNOportal@hotmail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                profileid = p, country='United Kingdom', IsActive =true, username='testNOportal@hotmail.com', 
                timezonesidkey='America/Los_Angeles');
       
        insert user;
        return user;
    }
    /*	ENABLE THIS WHEN KNOWLEDGE LICENSES AQUIRED 
    public static CommunityArticle__kav createKnowledge(String title){
		// Insert specific Article Type record
		
        CommunityArticle__kav ka = new CommunityArticle__kav(Title=title, Summary='Article summary', URLname='Article-title', Language='en_US', IsVisibleInPrm=true, IsVisibleInCsp=true);
        insert ka;
        
        //Publish the article so it is visible to search queries where it filters on PublishStatus='online'
        // Get the KnowledgeArticleId of the previously inserted record (currently in draft)
        CommunityArticle__kav insertedKa = [Select KnowledgeArticleId from CommunityArticle__kav where ID =:ka.Id];

        // Do the publishing
        KbManagement.publishingService.publishArticle(insertedKa.KnowledgeArticleId, true);
        
        // Return the whole object to give access to Version (.id) and the KnowledgeArticle (.KnowledgeArticleId)
        return insertedKa;
    }
    
	*/
    public static SObject createKnowledgeArticleByType(String title, String knowledgeArticleApiName){
		// Insert specific Article Type record
		
		Sobject SObjectVar = createObject(knowledgeArticleApiName);
       
        //Publish the article so it is visible to search queries where it filters on PublishStatus='online'
        // Get the KnowledgeArticleId of the previously inserted record (currently in draft)
        SObjectVar.put('Title', title);
        SObjectVar.put('Summary', 'Article summary');
        SObjectVar.put('URLname', 'Article-title' + randomWord(5));
        SObjectVar.put('Language', 'en_US');
        SObjectVar.put('IsVisibleInCsp', true);
        SObjectVar.put('IsVisibleInPkb', false);
        SObjectVar.put('IsVisibleInPrm', false);
        
        SObjectVar.put('Content__c', 'Content Here');
        SObjectVar.put('ctatext__c', 'Click here');
        SObjectVar.put('thumbnail__c', 'Meh');
        
       
        insert SObjectVar;
        
        String searchTerm = 'SELECT KnowledgeArticleId FROM ' +knowledgeArticleApiName + ' WHERE ID =\'' + (String)SObjectVar.get('Id') + '\'';
        SObject Inserted = Database.query(searchTerm);

        // Do the publishing
        KbManagement.publishingService.publishArticle((String)Inserted.get('KnowledgeArticleId'), true);
        
        // Return the whole object to give access to Version (.id) and the KnowledgeArticle (.KnowledgeArticleId)
        return Inserted;
    }
    
	//Generic Object Creation Helper    
    public static sObject createObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            // throw an exception
            system.debug('An Error has occured, Sobject cannot be created');
        }
        
        // Instantiate an sObject with the type passed in as an argument
        //  at run time.
        return targetType.newSObject(); 
    }


	//  No arguments    
    public static String createContentDocument() {
        ContentVersion contentVersion_1 = new ContentVersion(
        	Title = 'Penguins',
        	PathOnClient = 'Penguins.jpg',
        	VersionData = Blob.valueOf('Test Content'),
        	IsMajorVersion = true
        );
        
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
        System.assertEquals(documents[0].Title, contentVersion_2.Title);
        
        //Return the Document Id of TYPE 'DocumentId'
        return documents[0].Id;
    }
    
    
    
    // OverLoaded version which takes a string argument and sets as the description.
    public static String createContentDocument(String description) {
        ContentVersion contentVersion_1 = new ContentVersion(
        	Title = 'Penguins',
        	PathOnClient = 'Penguins.pdf',
        	VersionData = Blob.valueOf('Test Content'),
        	IsMajorVersion = true,
            Description = description
        );
        
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
        System.assertEquals(documents[0].Title, contentVersion_2.Title);
        
        //Return the Document Id of TYPE 'DocumentId'
        return documents[0].Id;
    }
        
    
    

        
    public static String randomWord(Integer len) {
        //-Hj- Random Word generates string of 'len' with spaces and upper and lower case chars.
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        // Integer len = 6;
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static String randomTel() {
        //-Hj- Random tel number generator returns 8 random numbers prefixed by 0.
        Double rand = math.floor(math.random()*100000000);
        Integer numb = rand.intValue();
        String tel = numb.format();
        tel = '0' + tel;
        return tel;
    }


    public static String randomEmail() {
        //-Hj- Random Word generates string of 'len' with spaces and upper and lower case chars.
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890abcdefghijklmnopqrstuvwxyz';
        final String dom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz';

        Integer len1 = 10;
        Integer len2 = 12;
        Integer len3 = 3;

        String rand1 = '';
        while (rand1.length() < len1) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            rand1 += chars.substring(idx, idx+1);
        }

        String rand2 = '';
        while (rand2.length() < len2) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), dom.length());
            rand2 += dom.substring(idx, idx+1);
        }

        String rand3 = '';
        while (rand3.length() < len3) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), dom.length());
            rand3 += dom.substring(idx, idx+1);
        }


        String randEm=(rand1 + '@' + rand2 + '.' + rand3);
        return randEm;
    }
    
}