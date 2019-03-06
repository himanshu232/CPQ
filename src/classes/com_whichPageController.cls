public class com_whichPageController {
	////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	// TestClass: com_whichPageController_Test.cls
    // - Written by Hj 🌵 2017.11.29
    // Used to query SF metadata to determine a pages header
	// configuration. Used in a community using custom Oegen Theme
	// and dynamic, per-page header.
	////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/* >>- Changelog -<<
	 * _REPLACE_WITH_DATE_
	
	 */     
    @AuraEnabled
    public static Map<String, String> getHeaderInformation(String pageName){
        try{
            Community_config__mdt header = (community_config__mdt)getCustomMetadata('community_config__mdt', new List<String>{pageName})[0];
            Map<String,String> headerInformation = new Map<String,String>();
            
            System.debug(LoggingLevel.ERROR, 'pageName:'+ header.DeveloperName + ' L1:'+ header.header_line_1_label_Name__c + ' L2:'+ header.header_line_2_label_Name__c + ' Image:'+ header.header_background_image__c );
                
            headerInformation.put('pageName', header.DeveloperName);
            headerInformation.put('header_line_1_label_Name', header.header_line_1_label_Name__c);
            headerInformation.put('header_line_2_label_Name', header.header_line_2_label_Name__c);
            headerInformation.put('header_background_image', header.header_background_image__c);
            
            return headerInformation;    
            
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage());
            return null;
        }
    }


    public static List<SObject> getCustomMetadata(String objName, List<String> devNames) {
        //////////////////////////////////////////////////
        //  Return a list of all the records for a 
        //  a particular metadata type 
        //////////////////////////////////////////////////
        try {
            Set<String> settingFields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().keyset();
            String soqlStr = 'SELECT Id';
            for(String s : settingFields) {
                if(s.toLowerCase() != 'id') {
                    soqlStr += ',' + s;
                }
            }
            soqlStr += ' FROM ' + objName;
            if(!devNames.isEmpty()) {
                soqlStr += ' WHERE DeveloperName IN :devNames';
            }
            return Database.query(soqlStr);
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'Error occurred: ' + e.getMessage());
            return null;
        }
    }
}