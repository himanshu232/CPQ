({
    readWindow : function(cmp, evt, hlp){
        // Keep this lightweight it is run frequently.
        // this function reads the community path and stores current page view.
        
        var pageurl = decodeURIComponent(window.location.pathname),
            urlparts = pageurl.split('/'),
            i,
            index,
            pagename;
        index = urlparts.indexOf("s");
        
        pagename = urlparts[index+1];
        if(pagename == ""){pagename="home";}
        
        
        //Compare to existing value and if changed set it.
        let oldpagename = cmp.get("v.pagename");
        if(pagename != oldpagename){
            cmp.set("v.pagename", pagename);	
            
            //Fire an application event to sub for the one we can't listen for.
            var appEvt = $A.get("e.c:pageChange");
            //console.log(pagename);
            
            appEvt.setParams({"pageName" : pagename,
                              "urlParts" : urlparts });
            
            appEvt.fire();
        }
    },
})