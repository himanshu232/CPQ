({
	pageChanged : function(cmp, evt, hlp) {
		try{
			hlp.updateBanner(cmp,evt,hlp);
		}catch(e){
			console.log("Error encounterd: "+e);
		}
	}, 
})