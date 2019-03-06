({
	readLabels : function(cmp) {
		
        var labelSubString = cmp.get("v.labelName");
        if(labelSubString != null){
            var labelReference = $A.getReference("$Label.c." + labelSubString);
            cmp.set("v.labelText", labelReference);
        }
	},
    
    
    
    fireNavEvent : function(cmp) {
        //console.log(">>>Nav event will be fired here<<<");
        
        var destPage = cmp.get("v.destPage");
        var appEvent = $A.get("e.c:NavEvent");
            
        if(destPage != "") {
            appEvent.setParams({ "pageDest" : destPage });
            appEvent.fire();
        }
        else {
            console.log("Event fired no params");
        }
        
        var appEvent = $A.get("e.c:NavEvent");
        if(cmp.get("v.pageDest") != null) {
            appEvent.setParams({ "pageDest" : cmp.get("v.pageDest") });
            appEvent.fire();
        }
    }
})