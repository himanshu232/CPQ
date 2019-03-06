({  
	clicker : function(cmp, evt, hlp) {
        try{
            var src = evt.currentTarget.dataset.src;
            var labeltext = evt.currentTarget.dataset.labeltext;
            hlp.linktopage(cmp, labeltext);
        }
        catch(e){
            console.log("Error encounterd: "+e);
        }
    },
    
    
    
    closeModal : function(cmp, evt, hlp){
        hlp.closeModal(cmp, evt, hlp);
    }
})