({	
    linktopage : function(cmp, labeltext) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": labeltext
        });
        urlEvent.fire();
    },
    
    
    
    closeModal : function(cmp, evt, hlp){
        cmp.set("v.modalClass", "");
    },
    
})