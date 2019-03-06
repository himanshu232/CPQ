({
    updateBanner : function(cmp, evt, hlp){
        //console.log("UPDATING BANNER");
        var action = cmp.get("c.getHeaderInformation");
        action.setStorable();	// If the information has recently been queried use cached.
        let pageName = evt.getParam("pageName");

        action.setParams({
            "pageName" : pageName
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS" && cmp.isValid()){
                var returnValue = response.getReturnValue();
                //console.log(returnValue);
                                
                if(returnValue == null){
                    console.log("No metadata for pageName: "+pageName);
                    cmp.set("v.loading", false);
                    return;
                }
                
                let header_background_image="",
                	header_line_1_label_Name="",
                    header_line_2_label_Name="";
                
                //If metadata is entered for the page type.
                if(returnValue["pageName"] != undefined){
                
                    //To prevent null pointers
                    if(returnValue["header_background_image"] != undefined){
                        header_background_image = returnValue["header_background_image"];
                    }else{
                        // This should never happen because required field.
                        header_background_image = "";
                    }
                    
                    if(returnValue["header_line_1_label_Name"] != undefined){
                        header_line_1_label_Name = returnValue["header_line_1_label_Name"];
                    }else{
                        header_line_1_label_Name = "";
                    }
                    
                    if(returnValue["header_line_2_label_Name"] != undefined){
                        header_line_2_label_Name = returnValue["header_line_2_label_Name"];
                    }else{
                        header_line_2_label_Name = "";
                    }
                    
                    // Update the Component side.
                    cmp.set("v.header_background_image", header_background_image);
                    cmp.set("v.titleLabelName",	header_line_1_label_Name);
                    cmp.set("v.summaryLabelName", header_line_2_label_Name);
                    
                
                }
                
            } else if ( state ==="ERROR" ){
                console.log("Error:");
                
                for (var i in response.getError() ){
                    console.log( response.getError([i]) );
                }
            }else{
                console.log("Unknown error returned from action");
            }
            
            cmp.set("v.loading", false);
        });
        
        $A.enqueueAction(action);
    } 
})