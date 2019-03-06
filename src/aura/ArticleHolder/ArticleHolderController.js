({
	init : function(cmp, evt, hlp) {
		try{
			hlp.getArticles(cmp,evt,hlp);
		}catch(e){
			console.log("Error encounterd: "+e);
		}
	}, 
})