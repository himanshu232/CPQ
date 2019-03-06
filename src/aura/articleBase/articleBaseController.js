({
    init : function(cmp, evt, hlp) {
		try{
			hlp.loadContent(cmp,evt,hlp);
            hlp.setCtaText(cmp);
		}catch(e){
			console.log("Error encounterd: "+e);
		}
	}, 
    
    
    ctaClick : function(cmp, evt, hlp){
        try{
			hlp.fireNavigation(cmp,evt,hlp);
		}catch(e){
			console.log("Error encounterd: "+e);
		}
    }
 })