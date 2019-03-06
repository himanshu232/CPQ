public with sharing class HRO_Checklist_MultiEdit_Controller {
	///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	// TestClass: Test_HRO_Checklist_MultiEdit_Controller.cls
	// John Hutchinson 🌵 2017.06
	///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
    
    //////////////////////////////////////////////////////////
    // Edit Performed: 16/07/2018
    // By: AHA 𝝺
    // Company: Oegen LTD
    // Description: Additional functionality was added to link in with the newActivitiesTab and the timesheets VF page
    //////////////////////////////////////////////////////////

    
	/*  Assistive notes:
		####################
		
    */
	public Map<Integer, String> errorCodes {get; private set;}
	
	public List<Activity_Checklist__c> activityChecklist {get;set;}
	public Map<Id, Activity_Checklist__c> id2checklist {get; private set;}
	public List<Activity_Checklist__c> updatedChecklist {get; private set;}
	public Integer updatedRecords {get; private set;}
	public Boolean recordsUpdated {get; private set;}
    public Boolean arrivedFromList {get; set;}
    public Boolean saveHasBeenPerformed {get; set;}
    public String activitytoChange {get; set;}

	// List of IDs selected on the Activity Check list view
	public List<Id> selectedCheckIds {get;set;}

	public String activityId {get;private set;}  							// String not an Id so it can capture invalid too.
	public String activityName {get;set;}
    public String activity {get;set;}
    public String activityCustomer {get;set;}
    public String activityEndDate {get;set;}
    
    public String EndField {get;set;}
    public String StageField {get;set;}
    public String ScheduleField {get;set;}
    public String AccountField {get;set;}
    public String AccId {get;set;}
    Public string selectedname{get;set;}
    
    public String currentActivityOwner{get;set;}
    public String currentActivityOwnerName{get;set;}
    
    public Boolean displayPopup {get; set;} 
    public Boolean popupOneDecision {get; set;}
	public Boolean doNavigate {get;private set;}
    public Boolean allComplete {get; set;}
    public Boolean extraData {get; set;}
    public Boolean notextraData {get; set;}
    public Boolean hideReturn {get; set;}
    public Boolean readOnlyMode {get; set;}
    
	public Map<Integer, String> feedbackPos {get;set;}
	public Map<Integer, String> feedbackNeg {get;set;}
    public List<Selectoption> lstnamesel {get;set;}
 
    // - AHA 𝝺 - Added to handle MHR request to handle User taking ownership of a record
	public boolean displayPopupTakeOwnership {get; set;}  
    
    // - AHA 𝝺 - Added to allow access to the current activity across classes
    public Payroll_Activities__c currentPageActivity {get; set;}

    // - Closes the "take ownership" popup if the user clicks "No".
    public void closePopup() {        
        displayPopup = false; 
        displayPopupTakeOwnership = false; 
        recordsUpdated = true;
        hideReturn = false;
        loadChecklist();
        readOnlyMode = true;
        System.debug('AHA - Debug - Popup closed');
    }
    
    // - AHA - Fired when a User checks Yes when asked if they want to take ownership.
    public void popupOneDecisionYes() {       

        // Ensures the return button stays on the page
        hideReturn = false;
        readOnlyMode = false;
    
        // Disables the "Take ownership" popup
        displayPopupTakeOwnership = false; 
        
        // Stores the current usersId
        String currentUserId = system.UserInfo.getUserId();
        
        
        System.debug('AHA - Debug - Current Activity Id: - ' + activityId);
        System.debug('AHA - Debug - Current User Id: - ' + currentUserId);
        
        // Use SOQL to retrieve Open timesheets for the Current user for the current Activity.
        Time_Card__c[] tc = [SELECT Id FROM Time_Card__c WHERE Activity__c = :activityId AND CreatedById = :currentUserId AND End__c = null];
        
        if(tc.size() > 0){
            
        }
        else{
            //Create a new timecard
            Time_Card__c tCrd = new Time_Card__c();
            tCrd.Activity__c = activityId;
            tCrd.Start__c = Datetime.now();
            insert tCrd;
        }
        
        try{
        Payroll_Activities__c currentAct = [SELECT Id, Activity_Owner__c FROM Payroll_Activities__c WHERE Id = :ActivityId LIMIT 1];
            if(currentAct != null){
                currentPageActivity = currentAct;
                if(currentAct.Activity_Owner__c != currentUserId){
                    currentAct.Activity_Owner__c = currentUserId;
                    update currentAct;
                }
            }
        }
        catch(exception e){
            System.debug('AHA - Debug - Error changing current activity owner - ' + e.getMessage()); 
        }
    }
    
	public Boolean feedbackBool{
		get{
			if(feedbackPos.size()>0 || feedbackNeg.size()>0){
				return TRUE;
			}
			else{
				return FALSE;
			}
		}
		set;
	}

	public Boolean hasApexMessages{
		get{
			if(ApexPages.hasMessages()){
				return TRUE;
			}
			else{
				return FALSE;
			}
		}
		private set;
	}
    
    public PageReference changeCheck(){
        if(extraData == false){
        	extraData = true;    
        }
        if(extraData == true){
        	extraData = false;
        } 
        if(notextraData == false){
        	notextraData = true;    
        }
        if(notextraData == true){
        	notextraData = false;
        } 
        return null;
    }
	

	public Boolean invalidOrig{
		get{
			if(activityId=='' || activityId==null && selectedCheckIds.isEmpty()){
				setFeedback(-404);
				return TRUE;
			}
			else{
				return FALSE;
			}
		}
		set;
	}

	
	/*	ApexPages.StandardController must be instantiated for standard controllers
		Technically this class is a controller extension, however the standard controller functionality is never used. 
		The reason for extending the standard controller is so the VF page can be linked to from the 
		related list on page layout.
	*/
	public HRO_Checklist_MultiEdit_Controller(ApexPages.StandardController controller) {
        selectedname = System.currentPageReference().getParameters().get('ActivityId');
        
        // - Retrieves the current Activity record to check if the record is owned.
        try{
            Payroll_Activities__c currentAct = [SELECT Id, Activity_Owner__c, Activity_Owner__r.Name FROM Payroll_Activities__c WHERE Id = :selectedname LIMIT 1];
            if(currentAct != null){
     			currentPageActivity = currentAct;
                if(currentAct.Activity_Owner__c != null){
                    currentActivityOwner = currentAct.Activity_Owner__c;
                    currentActivityOwnerName = currentAct.Activity_Owner__r.Name;
                }
            }
        }
        catch(exception e){
            system.debug('AHA - Debug - Error with retrieving current activity owner - ' + e.getMessage());
        }
        
        errorCodes = new Map<Integer, String>();
        errorCodes = OegenHelper.errorCodesInit();
		feedbackPos = new Map<Integer, String>();
		feedbackNeg = new Map<Integer, String>();

		updatedChecklist = new List<Activity_Checklist__c>();
        id2checklist = new Map<Id, Activity_Checklist__c>();
        updatedRecords = 0;
        recordsUpdated = FALSE;
        saveHasBeenPerformed = false;
        doNavigate = FALSE;
        if(System.currentPageReference().getParameters().get('arrivedFromList') != null){
        	arrivedFromList = Boolean.valueof(System.currentPageReference().getParameters().get('arrivedFromList'));
        }
        
        // - AHA - This section checks if the current activity check has an owner, if not if challanges the user to take ownership with a popup
        if(System.currentPageReference().getParameters().get('displayPopupTakeOwnership') != null){ 
            if(currentActivityOwner != null){
                if(currentActivityOwner == system.UserInfo.getUserId()){
                    displayPopupTakeOwnership = false;
                }
                else{
                    displayPopupTakeOwnership = true;
                }
            }
            else{
                displayPopupTakeOwnership = true;
            }
        }

		selectedCheckIds = new List<Id>();

        loadChecklist();
	}

	/*	ApexPages.StandardSetController must be present to allow us to display a Visualforce Page button on the Activity Checks list view
	*/
	public HRO_Checklist_MultiEdit_Controller(ApexPages.StandardSetController setController) {
        errorCodes = new Map<Integer, String>();
        errorCodes = OegenHelper.errorCodesInit();
		feedbackPos = new Map<Integer, String>();
		feedbackNeg = new Map<Integer, String>();
        
        selectedname = System.currentPageReference().getParameters().get('ActivityId');
        
        // - Retrieves the current Activity record to check if the record is owned.
        try{
            Payroll_Activities__c currentAct = [SELECT Id, Activity_Owner__c, Activity_Owner__r.Name FROM Payroll_Activities__c WHERE Id = :selectedname LIMIT 1];
            if(currentAct != null){
                currentPageActivity = currentAct;
                if(currentAct.Activity_Owner__c != null){
                    currentActivityOwner = currentAct.Activity_Owner__c;
                    currentActivityOwnerName = currentAct.Activity_Owner__r.Name;
                }
            }
        }
        catch(exception e){
            system.debug('AHA - Debug - Error with retrieving current activity owner - ' + e.getMessage());
        }
        
		updatedChecklist = new List<Activity_Checklist__c>();
        id2checklist = new Map<Id, Activity_Checklist__c>();
        updatedRecords = 0;
        saveHasBeenPerformed = false;
        recordsUpdated = FALSE;
        doNavigate = FALSE;
        extraData = false;
        notextraData = true;
        if(System.currentPageReference().getParameters().get('arrivedFromList') != null){
        	arrivedFromList = Boolean.valueof(System.currentPageReference().getParameters().get('arrivedFromList'));
        }
        
        // - AHA - This section checks if the current activity check has an owner, if not if challanges the user to take ownership with a popup
        if(System.currentPageReference().getParameters().get('displayPopupTakeOwnership') != null){
            if(currentActivityOwner != null){
                if(currentActivityOwner == system.UserInfo.getUserId()){
                    displayPopupTakeOwnership = false;
                }
                else{
                    displayPopupTakeOwnership = true;
                }
            }
            else{
                displayPopupTakeOwnership = true;
            }
        }
       
		// Get the selected Activity Checks
		List<Activity_Checklist__c> selected = new List<Activity_Checklist__c>((List<Activity_Checklist__c>)setController.getSelected());
		selectedCheckIds = new List<Id>();
        allComplete = true;
        
		for(Activity_Checklist__c c : selected) {
            if(!Test.isRunningTest()){
                if(c.Completed__c == false){
                    allComplete = false;
                }
            }
			selectedCheckIds.add(c.Id);
		}

        loadChecklist();
	}

	private void loadChecklist(){
		// Assuming valid newFund ID is passed in from previous fund. Do these things:
        try{
			if(selectedCheckIds.isEmpty()) {
				this.activityId = ApexPages.currentPage().getParameters().get('ActivityId');  								// Current activity id passed from previous page as param.
			}
            /*
            	Replaced by dynamic field set SOQL
            	this.activityChecklist = [ SELECT Id, Name, Payroll_Activity__c, Payroll_Activity__r.Name, Activity__c FROM Activity_Checklist__c WHERE Payroll_Activity__r.Id = :activityId ];
			*/
			/*----------------------------------<DYNAMIC SOQL QUERY>----------------------------------*/ 
			String queryFields = 'Id';										
	        for(Schema.FieldSetMember f : SObjectType.Activity_Checklist__c.FieldSets.MultiEditFS.getFields()) {
	            if(queryFields.length() > 0) {
	                queryFields += ', ';
	            }
	            queryFields += f.getFieldPath();
	        }
	        
	        // May be in the field set but may not, definitely used so checked for then added.
	        if(!(queryFields.contains(' Name'))){
	        	queryFields += ', Name';
	        }
	        if(!(queryFields.contains('Payroll_Activity__r.Name'))){
	        	queryFields += ', Payroll_Activity__r.Name';
	        }
	        if(!(queryFields.contains('Sequence_Number__c'))){
	        	queryFields += ', Sequence_Number__c';
	        }
            queryFields += ', Payroll_Activity__c';
            queryFields += ', Stage__c';
            queryFields += ', Payroll_Activity__r.Payroll_Stage__c';
	        System.debug('### '+queryFields);

	        // Build full SOQL query
	        String queryFull = 
	            ' SELECT ' +
	                queryFields +
	            ' FROM ' +
	                ' Activity_Checklist__c ' +
	            ' WHERE ';
				
			if(selectedCheckIds.isEmpty()) {
				queryFull += 'Payroll_Activity__r.Id = \'' + activityId + '\'';
			} else {
				queryFull += 'Id IN :selectedCheckIds';
			}
			queryFull += ' ORDER BY Sequence_Number__c';

			// Execute query
	        this.activityChecklist = Database.query(queryFull);
			/*----------------------------------</DYNAMIC SOQL QUERY>----------------------------------*/ 

			List<Selectoption> lstnamesel2 = new List<selectoption>();
            //lstnamesel2.add(new selectOption('', '- None -'));
            //System.debug('AHA - Debug - ' + activityChecklist[0].Payroll_Activity__r.Payroll_Stage__c);
            String relatedStage;
            for(Payroll_Activities__c pra : [SELECT Id, Name, Account__c, End_Date_Time__c, Payroll_Stage__r.Stage__c, Schedule_Name__c, Activity__c, Payroll_Stage__c, Payroll_Stage__r.Schedule__r.Account__c FROM Payroll_Activities__c WHERE Id = :ActivityId LIMIT 1]){
                relatedStage = pra.Payroll_Stage__c;
            }
            if(relatedStage != null){
                //Payroll_Activities__c[] praList = [SELECT Id, Name, Account__c, End_Date_Time__c, Payroll_Stage__r.Stage__c, Schedule_Name__c, Activity__c, Payroll_Stage__c FROM Payroll_Activities__c WHERE Payroll_Stage__c = :relatedStage ];
                Activity_Checklist__c[] chkList = [SELECT Id, Payroll_Activity__c, Payroll_Activity__r.Name, Payroll_Activity__r.Activity__c FROM Activity_Checklist__c WHERE Payroll_Activity__r.Payroll_Stage__c=:relatedStage];
                Map<String, String> prWithCheckLists = new Map<String, String>();
                
                
                for(Activity_Checklist__c ack : chkList){
                    if(!prWithCheckLists.keySet().contains(ack.Payroll_Activity__c)){
                        //prWithCheckLists.put(ack.Payroll_Activity__c, ack.Payroll_Activity__r.Name);
                        
                        // - AHA - Altered on request from Robin to display a name rather than a reference for UX
                        prWithCheckLists.put(ack.Payroll_Activity__c, ack.Payroll_Activity__r.Activity__c);

                    }
                }
                for(String s : prWithCheckLists.keySet()){
                    String praName = prWithCheckLists.get(s);
                    lstnamesel2.add(new selectoption(s,praName));
                }  
            }
           
            this.lstnamesel = lstnamesel2;
            
            Payroll_Activities__c pra = [SELECT Id, Account__c, End_Date_Time__c, Payroll_Stage__r.Stage__c, Schedule_Name__c, Activity__c, Payroll_Stage__r.Schedule__r.Account__c FROM Payroll_Activities__c WHERE id = :activityChecklist[0].Payroll_Activity__c LIMIT 1];
            this.activityName = activityChecklist[0].Payroll_Activity__r.Name;
            if(pra != null){
                
                this.activity = pra.Activity__c;
                //this.selectedname = pra.Activity__c;
                this.activityCustomer = pra.Account__c;
       
                ActivityName = pra.Activity__c;
                AccountField = pra.Account__c;
                if(pra.Payroll_Stage__r.Schedule__r.Account__c != null){
                	AccId = pra.Payroll_Stage__r.Schedule__r.Account__c;
                }
                Datetime endPreProcess = pra.End_Date_Time__c;
                String min;
                if(String.valueof(endPreProcess.minute()).length() == 2){
                    min = String.valueof(endPreProcess.minute());
                }
                else{
                    min = '0' + endPreProcess.minute();
                }
                
                String hour;
                if(String.valueof(endPreProcess.hour()).length() == 2){
                    hour = String.valueof(endPreProcess.hour());
                }
                else{
                    hour = '0' + endPreProcess.hour();
                }
                
                String day;
                if(String.valueof(endPreProcess.day()).length() == 2){
                    day = String.valueof(endPreProcess.day());
                }
                else{
                    day = '0' + endPreProcess.day();
                }
                
                String month;
                if(String.valueof(endPreProcess.month()).length() == 2){
                    month = String.valueof(endPreProcess.month());
                }
                else{
                    month = '0' + endPreProcess.month();
                }
                EndField = day + '-' + month + '-' + endPreProcess.year() + ' at ' + hour + ':' + min; 
                
                StageField = pra.Payroll_Stage__r.Stage__c;
                ScheduleField = pra.Schedule_Name__c;
            }
            datetime temp1 = datetime.valueof(pra.End_Date_Time__c);
            String day = String.valueof(temp1.Day());
            String Month = String.valueof(temp1.Month());
            
            if(day.length() == 1){
                day = '0'+day;
            }
            if(month.length() == 1){
                month = '0'+month;
            }
      
            this.activityEndDate = day + '/' + month + '/' + String.valueof(temp1.Year()) + ' ' + String.valueof(temp1).MID(11,5);
            
			// Populate a map of state when loaded to compare against.
			AllComplete = true;
            for( Activity_Checklist__c c : activityChecklist ){
                if(c.Completed__c == false){
                    AllComplete = false;
                }
				Activity_Checklist__c c2 = c.clone(TRUE, FALSE, TRUE, TRUE);
				id2checklist.put(c.Id, c2);
			}
        }
        catch(Exception e){
        	setFeedback(-404);
            system.debug('Exception### ' + e.getMessage());
            this.activityName='INVALID';
            invalidOrig = TRUE;
        }
	}

    // - On pressing the cancel button the user is returned to the page they arrived at the activity checklist from, IE New activities tab or Activity detail page
	public PageReference onCancel(){
        if(arrivedFromList != true){
			doNavigate = TRUE;
            return null;
        }
        else{
            PageReference tempPage = new PageReference('/apex/ActivitiesNewTab');            
            tempPage.setRedirect(true);
            return tempPage;
        }
	}

    // - On pressing the Close Button for the read only version of the page the user is returned ot the new activities tab.
    public PageReference onReturn(){
        //Release the current owner as they are leaving
        /*
        String currentUserId = system.UserInfo.getUserId();
        
        // - AHA 𝝺 - This ensures timecards are only closed if viewing the page in edit mode
        if(readOnlyMode != true){
            Time_Card__c[] tc = [SELECT Id FROM Time_Card__c WHERE Activity__c = :activityId AND CreatedById = :currentUserId AND End__c = null];
            System.debug('AHA - Debug - TimecardList - ' + tc);
            // Active timecards are found
            if(tc.size() > 0){
                for(Time_Card__c tcc : tc){
                    tcc.End__c = datetime.now();
                }
                update tc;
            }
        }
        
        //Release the current owner as they are leaving.
        Payroll_Activities__c currentAct = [SELECT Id, Activity_Owner__c FROM Payroll_Activities__c WHERE Id = :ActivityId LIMIT 1];
        if(currentAct.Activity_Owner__c != null){
            if(currentAct.Activity_Owner__c == system.UserInfo.getUserId()){
                currentAct.Activity_Owner__c = null;
                update currentAct;
            }
        }
        
        
        
        */
        //PageReference tempPage = new PageReference('/apex/ActivitiesNewTab');            
        //tempPage.setRedirect(true);
        //return tempPage;
        return new PageReference('javascript:window.close()');
    }
    
    // - AHA - 	Used to close off timecards when a user leaves the checklist once they have been editing or if no timecards are
    // 			Active, it instead creates a new timecard and routes the user to the Timecard page instead.
    public PageReference onReturnProcessing(){
        String currentUserId = system.UserInfo.getUserId();
        Time_Card__c[] tc = [SELECT Id FROM Time_Card__c WHERE Activity__c = :activityId AND CreatedById = :currentUserId AND End__c = null];
        System.debug('AHA - Debug - TimecardList - ' + tc);
        
        //Release the current owner as they are leaving
        currentPageActivity.Activity_Owner__c = null;
        update currentPageActivity;
        
        // Active timecards are found
        if(tc.size() > 0){
            for(Time_Card__c tcc : tc){
                tcc.End__c = datetime.now();
            }
            update tc;
            //PageReference tempPage = new PageReference('/apex/ActivitiesNewTab');            
            //tempPage.setRedirect(true);
            //return tempPage;
            return new PageReference('javascript:window.close()');
        }
        
        // No active timecards are found
        else{
            
            // If any edits have been performed on the Checklist page.
            if(saveHasBeenPerformed){
                Time_Card__c tCrd = new Time_Card__c();
                tCrd.Activity__c = activityId;
                tCrd.Start__c = Datetime.now();
                insert tCrd;
                PageReference tempPage = new PageReference('/apex/Ogn_Time_Card_Console?Id='+activityId);            
                tempPage.setRedirect(true);
                return tempPage;
                
            }
            
            // If no edits were performed.
            else{
                //PageReference tempPage = new PageReference('/apex/ActivitiesNewTab');            
                //tempPage.setRedirect(true);
                //return tempPage;
                return new PageReference('javascript:window.close()');
            }
        }   
    }
    
	public void onSave(){
		////////////////////////////////////////////
		//  Update the records changed
		////////////////////////////////////////////
		feedbackPos = new Map<Integer, String>();								//Re-init feedback for new opperation.
		feedbackNeg = new Map<Integer, String>();

		// Check for changes.
		allComplete = true;
		for( Activity_Checklist__c c : activityChecklist ){
            if(!c.Completed__c){
                allComplete = false;
            }
			if(c != id2checklist.get(c.Id) || (c.Completed__c == true && c.Started__c != true)) {
				// Update Started to true if Completed has been set to true
				if(c.Completed__c == true && c.Started__c != true) {
					c.Started__c = true;
				}
				updatedChecklist.add(c);
				updatedRecords ++;
			}
		}
		if(updatedChecklist.size() > 0){
			try{
				Database.saveResult[] result = Database.Update(updatedChecklist);
				if(result[0].isSuccess() == TRUE){
                    
					setFeedback(201, updatedRecords);
					recordsUpdated = TRUE;
                    saveHasBeenPerformed = true;
					loadChecklist();										// Re-load in case the order has changed.
				}
				else{
					recordsUpdated = FALSE;
				}
			}
			catch(DmlException e){
				System.debug('### '+e.getMessage());
				setFeedback(-1, e.getMessage());
			}
		}
		else{
			setFeedback(200);
		}
	}

	public void onSaveAndContinue(){
		////////////////////////////////////////////
		//  Update the records changed
		////////////////////////////////////////////
		feedbackPos = new Map<Integer, String>();								//Re-init feedback for new opperation.
		feedbackNeg = new Map<Integer, String>();
		List<Activity_Checklist__c> updatedChecklist2 = new List<Activity_Checklist__c>();
		// Check for changes.
		allComplete = true;
		for( Activity_Checklist__c c : activityChecklist ){
            if(!c.Completed__c){
                allComplete = false;
            }
			if(c != id2checklist.get(c.Id) || (c.Completed__c == true && c.Started__c != true)) {
				// Update Started to true if Completed has been set to true
				if(c.Completed__c == true && c.Started__c != true) {
					c.Started__c = true;
				}
				updatedChecklist2.add(c);
				updatedRecords ++;
			}
		}
		if(updatedChecklist2.size() > 0){
			try{
				Database.saveResult[] result = Database.Update(updatedChecklist2);
				if(result[0].isSuccess() == TRUE){
					setFeedback(201, updatedRecords);
					recordsUpdated = FALSE;
                    hideReturn = false;
                    saveHasBeenPerformed = true;
					loadChecklist();										// Re-load in case the order has changed.
				}
				else{
					recordsUpdated = FALSE;
				}
			}
			catch(DmlException e){
				System.debug('### '+e.getMessage());
				setFeedback(-1, e.getMessage());
			}
		}
		else{
			setFeedback(200);
		}
	}

    public void StartTimeCardIfNone(){
     	String currentUserId = system.UserInfo.getUserId();
        Time_Card__c[] tc = [SELECT Id FROM Time_Card__c WHERE Activity__c = :activityId AND CreatedById = :currentUserId AND End__c = null];
        
        if(tc.size() > 0){
            
        }
        else{
            //Create a new timecard
            Time_Card__c tCrd = new Time_Card__c();
            tCrd.Activity__c = activityId;
            tCrd.Start__c = Datetime.now();
            insert tCrd;
        }   
    }
    
    public void StartCardForAlreadyOwnedCard(){
        if(System.currentPageReference().getParameters().get('displayPopupTakeOwnership') != null){
            if(currentActivityOwner != null){
                if(currentActivityOwner == system.UserInfo.getUserId()){
                    StartTimeCardIfNone();
                }
            }
        }
    }
    
	public void setFeedback(Integer i){
		//////////////////////////////////////////////////
        //  Utility method to make body easier to read.
        //////////////////////////////////////////////////
		if (i < 0){
			feedbackNeg.put(i, errorCodes.get(i) );
		}
		else{
			feedbackPos.put(i, errorCodes.get(i) );
		}
	}
	public void setFeedback(Integer i, Integer c){
		if (i < 0){
			feedbackNeg.put(i, String.valueOf(c) + ' ' + errorCodes.get(i) );
		}
		else{
			feedbackPos.put(i, String.valueOf(c) + ' ' + errorCodes.get(i) );
		}
	}
	public void setFeedback(Integer i, String msg){
		if (i < 0){
			feedbackNeg.put(i, errorCodes.get(i) + ' ' + msg );
		}
		else{
			feedbackPos.put(i, errorCodes.get(i) + ' ' + msg );
		}
	}
    public PageReference changeActivity(){
        PageReference tempPage = new PageReference('/apex/HRO_Checklist_MultiEdit?ActivityId='+selectedname+'&arrivedFromList=false&displayPopupTakeOwnership=true');            
        tempPage.setRedirect(true);
        return tempPage;  
    }
    public void UncheckAllChecklist(){
        List<Activity_Checklist__c> ChkToUpodate = new List<Activity_Checklist__c>();
        for( Activity_Checklist__c c : activityChecklist ){
        	c.Completed__c = false;
            c.Started__c = false;
            ChkToUpodate.add(c);
        }
        if(ChkToUpodate.size() > 0){
            update ChkToUpodate;
        }
    }
}