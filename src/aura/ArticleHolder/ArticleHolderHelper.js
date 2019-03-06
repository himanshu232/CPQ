({
	getArticles : function(cmp) {
		var action = cmp.get("c.getArticleListSOSL");
        action.setAbortable();
        // Mark the action as storable, so that we grab the return value from the cache if it's less than 30 seconds since the last execution.
        action.setStorable();
        
        var articleType = cmp.get("v.articleType");
        var maxNumber = cmp.get("v.maxNumber");
        var sortOrder = cmp.get("v.sortOrder");
        var evenSpread = cmp.get("v.evenSpread");
        
        action.setParams({
            "articleType" : articleType,
            "maxNumber" : maxNumber,
            "sortOrder" : sortOrder,
            "evenSpread" : evenSpread
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();

            if (cmp.isValid() && state === "SUCCESS") {
                var articles = response.getReturnValue();
                                
                if(articles != null && articles.length != 0){
                    // Calculate number returned and if even, add set islastarticle TRUE ('article-last' class) to last 2.
                    // or if odd then set this on the last 1.
                    articles[articles.length-1].islastarticle = true;
                    if(this.isEven(articles.length)){
                        articles[articles.length -2].islastarticle = true;
                    }
                    cmp.set("v.articles", articles);
                }
                
            } else if ( state ==="ERROR" ){
				console.log("Error:");
				for (var i in response.getError() ){
					console.log( response.getError([i]) );
				}
			}else{
				console.log("Unknown error returned from action");
			}
        });
     
        $A.enqueueAction(action);
	},
    
    
    // Use abstract equality == for "is number" test
    isEven : function(n) {
        return n == parseFloat(n)? !(n%2) : void 0;
    },
    
    // Use strict equality === for "is number" test
    isEvenStrict : function(n) {
        return n === parseFloat(n)? !(n%2) : void 0;
    }
})