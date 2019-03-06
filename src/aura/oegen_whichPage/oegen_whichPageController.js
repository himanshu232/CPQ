({
	doneRendering : function(cmp, evt, hlp){
        // Keep this lightweight it is run frequently.
        try {
            hlp.readWindow(cmp, evt, hlp);
        }
        catch(ex) {
            console.log('Error encountered: '+ex);
        }
    },
    
    /* Hopefully SF will update so we can listen for siteforce:viewchanged one day.
    changeView : function(cmp, evt, hlp){
        console.log("changeView");
        
    },
    
    viewChanged : function(cmp, evt, hlp){
        console.log("viewChanged");
    }*/
})