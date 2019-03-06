public with sharing class com_articleController {
	////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	// TestClass: com_articleController_Test.cls
	// - Written by Hj 🌵 2017.11.29 -
	// Queries articles for display in a custom lightning component.
	////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/* >>- Changelog -<<
	 * _REPLACE_WITH_DATE_
	
	 */	 
	private static String languageCode;
	static {
		// If the user is british, change the code to en_US because the knowledge base is in en_US by default
		languageCode = UserInfo.getLocale();
		if(languageCode.toLowerCase() == 'en_gb') {
			languageCode = 'en_US';
		}
	}
	
	
	@AuraEnabled
	public static List<knowledgeWrapper> getArticleListSOSL(String articleType, String maxNumber, String sortOrder, Boolean evenSpread){
		
		Integer maxi = Integer.valueOf(maxNumber);
		
		List<String> sObjectAPINames = commaSeperateString(articleType);
		Integer limitPerType = 0;
		// evenly spread results across each of the queried knowledge article types.
		// Eg. If maxNumber is 20, and 4 articleTypes queried. Limit 5 of each type.
		if(evenSpread){
			
			limitPerType = Integer.valueOf( math.ceil( Double.valueOf(maxi)/sObjectAPINames.size() ));
			System.debug(limitPerType);
		} else {
			limitPerType = maxi;
		}
		
		// Build our SOSL query
        // 2018.04.17 - Hj🌵- An update to Salesforce SOSL processing prevents '{* OR *}' working breaking the query this is the workaround:
        String searchQuery  = 'FIND {(a*) OR (b*) OR (c*) OR (d*) OR (e*) OR (f*) OR (g*) OR (h*) OR (i*) OR (j*) OR (k*) OR (l*) OR (m*) OR (n*) OR (o*) OR (p*) OR (q*) OR (r*) OR (s*) OR (t*) OR (u*) OR (v*) OR (w*) OR (x*) OR (y*) OR (z*)} RETURNING ';
		
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		for(String apiName : sObjectAPINames){
			// Ensure the current user has access to the object specified in the builder.
			Boolean result = Boolean.valueOf( gd.get(apiName).getDescribe().isAccessible() );
			if(result){
				searchQuery += ( apiName+'(KnowledgeArticleId, Title, Summary, LastPublishedDate, Content__c, ctatext__c, thumbnail__c WHERE Language = \''+languageCode+'\' AND PublishStatus = \'online\' ORDER BY LastPublishedDate '+ sortOrder +' LIMIT '+limitPerType+'),' );
			}
		}
		searchQuery = searchQuery.removeEnd(',');
		
		System.debug( LoggingLevel.WARN, '### Search Query: '+searchQuery);
		
		try{
			// Execute the Query 
			List<List<SObject>> searchList = search.query(searchQuery);
			
			List<KnowledgeWrapper> knowledgeArticles = new List<KnowledgeWrapper>();
			
			
			for(List<SObject> innerList : searchList){
				for(SObject oneArticle : innerList){
					
					KnowledgeWrapper wrap = new KnowledgeWrapper(sortOrder);
					
					wrap.id = String.valueOf(oneArticle.get('KnowledgeArticleId'));
					wrap.title = String.valueOf(oneArticle.get('Title'));
					wrap.summary = String.valueOf(oneArticle.get('Summary'));
					wrap.lastPublishedDate = Date.valueOf(oneArticle.get('LastPublishedDate')); 
					wrap.content = String.valueOf(oneArticle.get('Content__c'));
					wrap.ctatext = String.valueOf(oneArticle.get('ctatext__c'));
					wrap.thumbnail = String.valueOf(oneArticle.get('thumbnail__c'));
					
					knowledgeArticles.add(wrap);
				}
					
			}
			System.debug(LOGGINGLEVEL.ERROR, knowledgeArticles);
			
			// Sort by 'LastPublishedDate'
			knowledgeArticles.sort();
			
			//Must sort first then chop down the results to limit by maxnumber.
			List<KnowledgeWrapper> knowledgeArticlesToReturn = new List<KnowledgeWrapper>();
			for(Integer i=0; (i<maxi && i<knowledgeArticles.size()) ; i++){
				knowledgeArticlesToReturn.add(knowledgeArticles[i]);
			}
			return knowledgeArticlesToReturn;
			
		}
		catch(Exception e){
			return null;
		}
	}
	
	
	public class KnowledgeWrapper implements Comparable{
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public String title {get;set;}
		@AuraEnabled public String summary {get;set;}
		@AuraEnabled public Date lastPublishedDate {get;set;}
		@AuraEnabled public String content {get;set;}
		@AuraEnabled public String ctatext {get;set;}
		@AuraEnabled public String thumbnail {get;set;}
		
		public String sortOrder {get;set;}		//ASC or DESC only
		
		public knowledgeWrapper(String sorder){
			// Sets the sort order from the attribute passed in from calling method.
			this.sortOrder = sorder;
		}
		
		// Allow the wrapper to be sorted by an order
		public Integer compareTo(Object compareTo) {
			KnowledgeWrapper compareToEmp = (KnowledgeWrapper)compareTo;
			/*
			// FIXED SORT ORDER
			if (LastPublishedDate == compareToEmp.LastPublishedDate) return 0;
			if (LastPublishedDate < compareToEmp.LastPublishedDate) return 1;
			return -1;
			*/
			// DYNAMIC SORT ORDER
			if(  (LastPublishedDate < compareToEmp.LastPublishedDate)  ){
				return sortOrder.equals('asc') ? 0 : 1;
			}else if (LastPublishedDate > compareToEmp.LastPublishedDate) {
				return sortOrder.equals('asc') ? 1 : 0;
			} else {
				return -1;
			}
		}
	}
	
	
	public static List<String> commaSeperateString(String line){
	//////////////////////////////////////////////////
	//  Reads a comma seperated list of object names.
	//  Returns a list of Strings without commas.
	//////////////////////////////////////////////////
		String delim = ',';
		String[] parts = new String[] {};

			line = line.removeEnd(delim);
			
			while(line != ''){
				Integer next = 0;
				
				next = line.indexOf(delim, next);
				if(next == -1)
					next = line.length();
					// NB in Substring, "endindex" is the index of the character AFTER the last index to get
				parts.add( String.escapeSingleQuotes( line.substring(0, next) ) );
				
				
				if(next == line.length() - 1){
					// case of a terminating comma.
					parts.add('');
				}
				line = next < line.length() ? line.substring(next+1) : '';
			}
		
		return parts;
	}
}