({
    toggleMenu : function(cmp, evt, hlp) {
        
        var menu = cmp.find('menu');
        $A.util.toggleClass(menu, 'active');
    },
    
    hideMenu : function(cmp, evt, hlp) {
        
        var menu = cmp.find('menu');
        $A.util.removeClass(menu, 'active');
    },
    
    clickMenu : function(cmp, evt, hlp) {       
        var id = evt.target.dataset.menuItemId;
        if (id) {
            cmp.getSuper().navigate(id);
        }
    },
    
    
})