({
	init : function(cmp, evt, hlp) {
        try{
            hlp.readLabels(cmp);
        }
        catch(ex){
            console.log('Error encountered: '+ex);
        }
	},
    
    linkClicked : function(cmp, evt, hlp){
        try{
            hlp.fireNavEvent(cmp);   
        }
        catch(ex){
            console.log('Error encountered: '+ex);
        }
    }
    
})