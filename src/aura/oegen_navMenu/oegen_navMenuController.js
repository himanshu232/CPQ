({
    toggleMenu : function(cmp, evt, hlp) {
        try {
            hlp.toggleMenu(cmp, evt, hlp);
        }
        catch(ex) {
            console.log('Error encountered: '+ex);
        }
    },
    
    hideMenu : function(cmp, evt, hlp) {
        try {
            hlp.hideMenu(cmp, evt, hlp);
        }
        catch(ex) {
            console.log('Error encountered: '+ex);
        }
    },
    
    clickMenu : function(cmp, evt, hlp) {
        try {
            hlp.clickMenu(cmp, evt, hlp);
        }
        catch(ex) {
            console.log('Error encountered: '+ex);
        }
	},
    
    updateActive : function(cmp, evt, hlp) {
        try {
            hlp.updateActive(cmp, evt, hlp);
        }
        catch(ex) {
            console.log('Error encountered: '+ex);
        }
    }
})