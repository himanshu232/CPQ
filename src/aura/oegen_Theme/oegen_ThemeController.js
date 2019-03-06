({
	goHome : function(cmp, evt, hlp) {
        try {
            hlp.goHome(cmp, evt, hlp);
        }
        catch(ex) {
            console.log('Error encountered: '+ex);
        }
	},    
    
})