({
	loadContent : function(cmp) {
        // Grab the field name to display, then set the display text to that content.
		var contentFieldName = cmp.get("v.contentFieldName");
        var article = cmp.get("v.article");
        cmp.set("v.contentFieldText", article[contentFieldName]);
        
        
        // Set the class variables dynamically.
        var variant = cmp.get("v.variant");		//Variant will be some string including word 'article'
        var styleClass = variant+" ";
        
        if(article.islastarticle){
            styleClass += "article-last ";
        }
        cmp.set("v.styleClass", styleClass);
        
	},
    
    
    setCtaText : function(cmp){
        // Sets the ctatext if it's not present in the article.
        var article = cmp.get("v.article");
        if(article['ctatext'] == undefined){
            cmp.set("v.article.ctatext", $A.get("$Label.c.pfc_ctatext_default") );
        }
    },
    
    
    fireNavigation : function(cmp,evt,hlp){
        var objectId = cmp.get("v.article.id");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": objectId 
        });
        navEvt.fire();    
    }
    
})