@isTest(SeeAllData=false)
public class com_articleController_Test {
	// ##################################################
	// FOR: com_articleController.cls
	// - Written by Hj 🌵 2017.11.29 -
	// ##################################################

	/* >>- Changelog -<<
	 * _REPLACE_WITH_DATE_
	
		* Useful information
		* ==================
	 */ 
	
	static Account a;
	static List<User> uList;
    
	static {
		// Create account with 10 seats
		a = TestFactory.createAccount();
		uList = new List<User>();
		List<Profile> pList = [SELECT Id, Name FROM Profile];
		
		// If more profiles are added over time then this method of creating users will support that. Credit to MRA 🐀.
		for(Profile p : pList){
                if(p.Name.contains('MHR - Service Cloud - people first') ){
				Contact c = TestFactory.createContact(a);
				User u = TestFactory.createCommUser(c, p.Id);
                System.debug(u);
				uList.add(u);
                System.debug('Created user name: '+u.LastName);
			}
		}
		System.debug('Total number test users is '+ uList.size());

		
        /*
		System.debug('Article IDs: '+ article1.Id + ', '
									+ article2.Id + ', '
									+ article3.Id + ', '
									+ article4.Id );	*/
        
	}
	
	// ##################################################
	// Description: getArticleList for a valid Article Type with list size of 1
	// Expected result: 1 article is served up (not 2)
	// ##################################################
	@isTest public static void test_1_1() {

        SObject article1 = TestFactory.createKnowledgeArticleByType('TestArticle1', 'Latest_News__kav');
		SObject article2 = TestFactory.createKnowledgeArticleByType('TestArticle2', 'Latest_News__kav');
		SObject article3 = TestFactory.createKnowledgeArticleByType('TestArticle3', 'people_first__kav');
		SObject article4 = TestFactory.createKnowledgeArticleByType('TestArticle4', 'people_first__kav');
		System.debug('Article IDs: '+ article1.Id + ', '
									+ article2.Id + ', '
									+ article3.Id + ', '
									+ article4.Id );
        
		List<com_articleController.KnowledgeWrapper> articles = new List<com_articleController.KnowledgeWrapper>();

        Id [] fixedSearchResults = new Id[]{article1.Id};
        Test.setFixedSearchResults(fixedSearchResults);
		Test.startTest();
		
        for(User u : uList){
			System.runAs(u) {
                System.debug('Running as User: '+u.LastName);
				articles = com_articleController.getArticleListSOSL('Latest_News__kav', '10', 'desc', false);
				// Signature: getArticleListSOSL(String articleType, String maxNumber, String sortOrder, Boolean evenSpread)
			}
		}
        
        
        //System.assert(articles.size()!=0, articles.size());
		
		Test.stopTest();

		
	}
	
    
    // ##################################################
	// Description: getArticleList for a valid Article Type with list size of 1
	// Expected result: 1 article is served up (not 2)
	// ##################################################
	@isTest	public static void test_1_2() {

        SObject article1 = TestFactory.createKnowledgeArticleByType('TestArticle1', 'Latest_News__kav');
		SObject article2 = TestFactory.createKnowledgeArticleByType('TestArticle2', 'Latest_News__kav');
		SObject article3 = TestFactory.createKnowledgeArticleByType('TestArticle3', 'people_first__kav');
		SObject article4 = TestFactory.createKnowledgeArticleByType('TestArticle4', 'people_first__kav');
		System.debug('Article IDs: '+ article1.Id + ', '
									+ article2.Id + ', '
									+ article3.Id + ', '
									+ article4.Id );
        
		Test.startTest();
        
        List<com_articleController.KnowledgeWrapper> articles = com_articleController.getArticleListSOSL('Latest_News__kav', '10', 'desc', true);
		
        System.debug(articles.size());
		//System.assert(articles.size()!=0, articles.size());
        
        Test.stopTest();
	}
    
    
    // ##################################################
	// Description: Independant Coverage for the wrapper 
	// sub class
	// Expected result: List of wrappers is sorted in
	// ascending order
	// ##################################################
	@isTest	public static void test_2_1() {
    List<com_articleController.KnowledgeWrapper> someArticles = new List<com_articleController.KnowledgeWrapper>();
        
        for(Integer i = 4; i > 0; i--){
            com_articleController.KnowledgeWrapper wrap = new com_articleController.KnowledgeWrapper('asc');
            wrap.id = 'fakeId';
            wrap.title = 'Test'+String.valueOf(i);
            wrap.summary = 'Summary';
            wrap.lastPublishedDate = (Date.today()-i);
            wrap.content='Article Content';
            wrap.ctatext='clickme';
            wrap.thumbnail='thumb';
            
            someArticles.add(wrap);
        }
        someArticles.sort();
        
        //Check sort order was correctly descending
       	System.assert(someArticles[0].title == 'Test4', someArticles[0].title);
    }
    
    
    // ##################################################
	// Description: Independant Coverage for the wrapper 
	// sub class
	// Expected result: List of wrappers is sorted in
	// descending order
	// For code coverage we create the list differently.
	// ##################################################
	@isTest	public static void test_2_2() {
    List<com_articleController.KnowledgeWrapper> someArticles = new List<com_articleController.KnowledgeWrapper>();
        	
        com_articleController.KnowledgeWrapper wrap2 = new com_articleController.KnowledgeWrapper('desc');
        wrap2.title = 'TestX';
        wrap2.summary = 'Summary';
        wrap2.lastPublishedDate = (Date.today()+10);
        someArticles.add(wrap2);
        
        for(Integer i = 4; i > 0; i--){
            com_articleController.KnowledgeWrapper wrap = new com_articleController.KnowledgeWrapper('desc');
            wrap.id = 'fakeId';
            wrap.title = 'Test'+String.valueOf(i);
            wrap.summary = 'Summary';
            wrap.lastPublishedDate = (Date.today()-i);
            wrap.content='Article Content';
            wrap.ctatext='clickme';
            wrap.thumbnail='thumb';
            
            someArticles.add(wrap);
        }
        someArticles.sort();
        
        //Check sort order was correctly ascending
       	System.assert(someArticles[0].title == 'TestX', someArticles[0].title);
    }
    
}