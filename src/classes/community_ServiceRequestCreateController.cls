public with sharing class community_ServiceRequestCreateController {
    
    //############## Standard Variables
    
    Private boolean IS_SANDBOX = true;
    Private string [] DEBUG_toAddresses = new String [] {'ashley.hardy@mhr.co.uk', 'ian.lonie@mhr.co.uk', 'lucy.paul@mhr.co.uk'};
    
    public string IS_CONSOLE {get;set;}
    public boolean IS_SUPER {get;set;}
    
    public SelectOption [] customerList {get;set;}
    
    public string validationMessage {get;set;}
    public string nopeMessage {get;set;}
    public boolean disablePage {get;set;}
    public string trentVersion {get;set;} //updated by 'trent version calculator'
    public string trentVersionString {get;set;}
    public boolean readyToSave {get;set;}
    public SelectOption [] requestTypeItems {get;set;}
    public string debugString {get;set;}
    public string contactID {get;set;}
    public string customerID {get;set;}
    public string customerName {get;set;}
    public SelectOption [] targetEnvironments {get;set;}
    public SelectOption [] sourceEnvironments {get;set;}
    public SelectOption [] serviceDates {get;set;}
    public SelectOption [] requestApproverList {get;set;}
    public string serviceDateList {get;set;}
    public string serviceStartDate {get;set;}
    public string serviceEndDate {get;set;}
    public SelectOption [] serviceTimes {get;set;}
    public SelectOption [] patchTypes {get;set;}
    public SelectOption [] copPITOptions {get;set;}
    public SelectOption [] copPITDateSelect {get;set;}
    public SelectOption [] copPITTime_Hour {get;set;}
    public SelectOption [] copPITTime_Mins {get;set;}
    private Date [] bankHolidayDates {get;set;}
    public string copVersionTargetErr {get;set;}
    private Service_Request_Availability_Schedule__c [] serviceRequestMax {get;set;}
    public Date [] upgNoLives {get;set;}
    
    public boolean hsr_CreditStop {get;set;}
    public boolean hsr_CreditStop_ShowMessage {get;set;}
    
    //############## Page Display Variables
    public boolean type_ShowList {get;set;}
    public boolean type_ShowAuth {get;set;}
    public boolean pat_ShowForm {get;set;}
    public boolean pat_ShowPatchTypes {get;set;}
    public boolean pat_ShowMatchEnvironment {get;set;}
    public boolean cop_ShowForm {get;set;}
    public boolean cop_ShowTargets {get;set;}
    public boolean cop_ShowPIT {get;set;}
    public boolean cop_ShowPITOptions {get;set;}
    public boolean upg_ShowForm {get;set;}    
    public boolean upg_ShowNoLiveUpgradeMsg {get;set;}
    public boolean upg_IfNotLive {get;set;}
    public Boolean isLastMandatory {get;set;}
    public Boolean showServiceTimes {get;set;}
    public Boolean HIDE_SAVE {get;set;}
    
    //############## User Input Variables
    public Hosted_Service_Request__c input_Customer_Lookup {get;set;} //Utilise the customer lookup on Hosted Environment to generate a lookup field on the internal creation page.
    public String input_Customer {get;set;}
    public String input_CustomerApprover {get;set;}
    public String input_Authoriser {get;set;}
    public string input_TypeRequested {get;set;}
    public string input_TargetEnvironment {get;set;}
    public string input_SourceEnvironment {get;set;}
    public date input_ServiceDate {get;set;}
    public string input_TimeSlot {get;set;}

    public boolean input_UpgCopyRequired {get;set;}
    public string input_PatchType {get;set;}
    
    public string input_DBPIT {get;set;}
    public string input_DBPITDate {get;set;}
    public string input_DBPITHour {get;set;}
    public string input_DBPITMins {get;set;}
    
    //############## Custom Settings
    public string copyTerms {get;set;}
    public string patchTerms {get;set;}
    public string upgradeTerms {get;set;}
    public decimal upgradeMargin {get;set;}
    public decimal upgradeNonLiveOnlyMargin {get;set;}
    public Date maxEndDate {get;set;}
    public Boolean pageDisabled_SUPER {get;set;}
    public Boolean allowAuthoriserRequests {get;set;}
    
    public string thisPage {get;set;}
    
    //############## Feature Specific Variables (started 18/10/2016)
    
    // - Authorised Contacts for HRO IT
    public boolean addAuth_ShowForm {get;set;}
    public String auth_input_AuthContact {get;set;}
    public SelectOption [] auth_ContactList {get;set;}
    public SelectOption [] auth_ContactListWithPerm {get;set;}
    
    //############## Logic
    
    public community_ServiceRequestCreateController() {
        input_Customer_Lookup = new Hosted_Service_Request__c();
        
        debug('Is 10.18 mandatory? ' + isTrentVersionMandatory('10.18'));
        debug('Is 10.19 mandatory? ' + isTrentVersionMandatory('10.19'));
        debug('Is 10.20 mandatory? ' + isTrentVersionMandatory('10.20'));
        debug('Is 10.21 mandatory? ' + isTrentVersionMandatory('10.21'));
        debug('Is 10.22 mandatory? ' + isTrentVersionMandatory('10.22'));
        debug('Is 10.23 mandatory? ' + isTrentVersionMandatory('10.23'));
        debug('Is 10.24 mandatory? ' + isTrentVersionMandatory('10.24'));
        debug('Is 10.25 mandatory? ' + isTrentVersionMandatory('10.25'));
        debug('Is 10.26 mandatory? ' + isTrentVersionMandatory('10.26'));
        debug('Is 10.27 mandatory? ' + isTrentVersionMandatory('10.27'));
        debug('Is 10.28 mandatory? ' + isTrentVersionMandatory('10.28'));
        debug('Is 10.29 mandatory? ' + isTrentVersionMandatory('10.29'));
        debug('Is 10.30 mandatory? ' + isTrentVersionMandatory('10.30'));
                
        IS_CONSOLE = 'NO';
    
        //instantiate the controller
        
        IS_SUPER = false;
        
        readyToSave = false;
        type_ShowList = false;
        type_ShowAuth = false;
        pat_ShowForm = false;
        cop_ShowForm = false;
        upg_ShowForm = false;
        
        isLastMandatory = true;
        
        upg_ShowNoLiveUpgradeMsg = false;
        
        //upg_IfNotLive = true;
        trentVersionString = 'Once a date has been selected, this text will display the iTrent version that will be installed.';
        nopeMessage= ''; 
        
        customerList = new List<SelectOption>();        
        sourceEnvironments = new List<SelectOption>();
        requestApproverList = new List<SelectOption>();
        targetEnvironments = new List<SelectOption>();
        serviceDates = new List<SelectOption>();
        serviceTimes = new List<SelectOption>();
        copPITOptions = new List<SelectOption>();
        copPITDateSelect = new List<SelectOption>();
        copPitTime_Hour = new List<SelectOption>();
        copPitTime_Mins = new List<SelectOption>();
        upgNoLives = new List<Date>();
        
        patchTypes = new List<SelectOption>();
        patchTypes.add(new SelectOption('Up to Date', 'Patch up to date'));
        patchTypes.add(new SelectOption('Patch to Match', 'Patch to Match'));
        
        input_PatchType = 'Up to Date';
        
        serviceRequestMax = new List<Service_Request_Availability_Schedule__c>();
        serviceRequestMax = [SELECT sra_CopyAM__c, sra_CopyPM__c, sra_EffectiveDate__c, sra_PatchAM__c, sra_PatchPM__c, sra_Upgrades__c FROM Service_Request_Availability_Schedule__c WHERE sra_EffectiveDate__c < : maxEndDate];
        
        calculateTrentVersionOnDate(Date.today());
        

        User currentUser = [SELECT id, contactid, contact.accountid, alias FROM user WHERE id= : UserInfo.getUserID() LIMIT 1];
        try {
            contactID = currentUser.contactid;
            customerID = currentUser.Contact.AccountID;
            customerName = [SELECT name FROM account WHERE id= : customerID LIMIT 1].Name;
        } catch(Exception e) {
            //If this fails, we could be running in the SF Console as a user without a customer. We need to confirm this, but generate the customer list anyway (saves time)...
            IS_CONSOLE = 'MAYBE';
        }
        
        //Let's confirm our suspiscions... 
        String currentURL = ApexPages.currentPage().getUrl();
        try {
            currentURL = currentURL.split('apex/')[1];
            
            if(currentURL.left(32) == 'community_ServiceRequestInternal') {
                IS_CONSOLE = 'YES';
            }
        } catch (Exception e) {
            //This is allowed to fail... 'apex/' might not exist!
        }        
        
        system.debug(currentURL);
        
        thisPage = currentURL;
        
        bankHolidayDates = new List<Date>();
        for(List<Bank_Holidays__c> bankHolidays : [SELECT Bank_Holiday_Date__c, Bank_Holiday_Name__c FROM Bank_Holidays__c WHERE Legislation_Country__c = 'UK' OR Legislation_Country__c = 'UK Scotland']) {
            for(Bank_Holidays__c holiday : bankHolidays) {
                bankHolidayDates.add(holiday.Bank_Holiday_Date__c);
            }
        }
        
        //Custom_Settings__c settings = [SELECT settingAuthorisationRequestsEnabled__c, settingSREnabled__c, settingCopyTC__c, settingPatchTC__c, settingUpgradeTC__c, settingNonLiveMargin__c, settingUpgradeMargin__c, settingEndDate__c, settingsPortalSuperusers__c FROM Custom_Settings__c WHERE settingIdentifier__c = 'HSR' LIMIT 1];
        Custom_Settings__c settings = [SELECT settingSREnabled__c, settingCopyTC__c, settingPatchTC__c, settingUpgradeTC__c, settingNonLiveMargin__c, settingUpgradeMargin__c, settingEndDate__c, settingsPortalSuperusers__c FROM Custom_Settings__c WHERE settingIdentifier__c = 'HSR' LIMIT 1];
        patchTerms = settings.settingPatchTC__c;
        copyTerms = settings.settingcopyTC__c;
        upgradeTerms = settings.settingUpgradeTC__c;
        upgradeMargin = settings.settingUpgradeMargin__c;
        upgradeNonLiveOnlyMargin = settings.settingNonLiveMargin__c;
        maxEndDate = settings.settingEndDate__c;
        //allowAuthoriserRequests = settings.settingAuthorisationRequestsEnabled__c;
                
        //let's check if this user is a defined superuser of the portal.
        try {
            String userList = '';
            if(settings.settingsPortalSuperusers__c.length() > 0) {
                settings.settingsPortalSuperusers__c.replace(' ', '');
                if(userList.contains(currentUser.alias)) {
                    IS_SUPER = true; //this user is a superuser.
                }
            }
        } catch(Exception e) {
            //This could also fail, but that's fine because it means this user is not a superuser.
        }
        
        if(settings.settingSREnabled__c == false) {
            //Kill the page. Not enabled.
            disablePage = true;
            pageDisabled_SUPER = true; //only used as a display var.
            if(IS_SUPER) {
                disablePage = false;
                //don't disable the page if they are a super user.
            }
        }
        
        //auth contact 18/10/2016
        auth_ContactList = New List<SelectOption>();
        auth_ContactListWithPerm = New List<SelectOption>();
        
        requestTypeItems = new List<SelectOption>();
        requestTypeItems.add(new SelectOption(' -- None -- ', ' -- None -- '));
        requestTypeItems.add(new SelectOption('Patch', 'Patch Install'));
        requestTypeItems.add(new SelectOption('Database Copy', 'Database Copy'));
        requestTypeItems.add(new SelectOption('Upgrade', 'iTrent Upgrade'));
        /*if(IS_CONSOLE == 'NO') { //only show for customers - not internal            
            if(allowAuthoriserRequests) { //only if the thing is enabled
                if(!hasPerm()) { //only if they don't have the permissions
                    requestTypeItems.add(new SelectOption('Request Authoriser Status', 'Request Authoriser Status'));
                }
            }
        }*/
    }
    
    public PageReference pageContinue() {
    
        PageReference responsePage;
        
        PageReference refIntegrity = Page.community_ServiceRequestAuth; //only exists to ensure the ServiceRequestAuth page cannot be deleted.
    
        checkSaveReady();
        if(readyToSave == false) {
            debug('Error saving page - not ready');
            validationMessage = 'There was an error when attempting to save this page. Please try again later. If this issue persists, please contact the HRO IT Operations Team on 0115 977 6749.';
            return null;
        }
        
        //set 'readyToSave' to false here to hide the button
        readyToSave = false; //this will hide the button
        
        Boolean stillValid = true;
        
        //before we start saving, let's do some checks.
        if(input_TypeRequested == 'Upgrade') {
            //This is an upgrade. Do they already have one booked for this environment, for this version?
        
            Integer count = database.countQuery('SELECT count() FROM Hosted_Service_Request__c WHERE srEnvironment__c = : input_TargetEnvironment AND upg_TrentVersion__c = : trentVersion AND srStatus__c != \'Rejected\' AND srStatus__c != \'Cancelled\' AND srStatus__c != \'Rejected by Customer\'');
        
            if(count > 0) {    
                Hosted__c tmpEnv = [SELECT Environment_Name__c FROM Hosted__c WHERE ID = : input_TargetEnvironment];
                validationMessage = 'There is already a Service Request to have your ' + tmpEnv.Environment_Name__c + ' environment upgraded to iTrent version ' + trentVersion + '. You cannot book another.';
                
                stillValid = false;
            }
        }    
        
        if(!stillValid) {
            return null; 
        }        
        
        Hosted_Service_Request__c newServiceRequest = new Hosted_Service_Request__c();
        newServiceRequest.srType__c = input_TypeRequested;
        newServiceRequest.srStatus__c = 'Pending Approval';
        newServiceRequest.srDate__c = input_ServiceDate;
        newServiceRequest.srEnvironment__c = input_TargetEnvironment;
        newServiceRequest.srCustomer__c = customerID;
        
        try {
            User tmpAuth = [SELECT Contact.ID FROM User WHERE ID = : input_Authoriser LIMIT 1];
            newServiceRequest.srApprover__c = tmpAuth.Contact.ID;
        } catch (Exception e) {
            //This is allowed to fail, they won't set one on the customer portal. More importantly, validation stops forms showing if they're on the internal page.
        }
        
        if(input_TypeRequested == 'Patch') {
            newServiceRequest.pat_Type__c = input_PatchType;
            if(input_PatchType == 'Patch to Match') newServiceRequest.pat_MatchEnvironment__c = input_SourceEnvironment;
            calculateTrentVersionOnDate(input_ServiceDate);
            newServiceRequest.srTermsAndConditions__c = patchTerms.replace('!!DO_TRENT_VERSION!!', trentVersion);
            newServiceRequest.srTime__c = input_TimeSlot;
        } else if(input_TypeRequested == 'Database Copy') {
            newServiceRequest.cop_SourceEnvironment__c = input_SourceEnvironment;
            if(input_DBPIT == 'PIT') {
                newServiceRequest.cop_PIT__c = true;
                newServiceRequest.cop_PITDT__c = DateTime.parse(input_DBPITDate + ' ' + input_DBPITHour + ':' + input_DBPITMins);
            }
            newServiceRequest.srTime__c = input_TimeSlot;
            calculateTrentVersionOnDate(input_ServiceDate);
            newServiceRequest.srTermsAndConditions__c = copyTerms.replace('!!DO_TRENT_VERSION!!', trentVersion);
        } else if(input_TypeRequested == 'Upgrade') {
            newServiceRequest.upg_Copy__c = input_UpgCopyRequired;
            newServiceRequest.upg_TrentVersion__c = trentVersion;
            newServiceRequest.srTermsAndConditions__c = upgradeTerms.replace('!!DO_TRENT_VERSION!!', trentVersion);
        } else {
            //should never happen
        }
        
        try {
            insert newServiceRequest;
            
            Hosted_Service_Request__c tmpSR = [SELECT Name from Hosted_Service_Request__c WHERE ID = : newServiceRequest.ID];
            tmpSR.srRealName__c = tmpSR.Name;
            update tmpSR;
            
           
            if(IS_CONSOLE == 'YES') {
                responsePage = New PageReference('/apex/community_ServiceRequestInternalComplete?type=SUC&sr=' + newServiceRequest.ID);
            } else {
                responsePage = New PageReference('/ServiceDesk/community_ServiceRequestAuth?sr=' + newServiceRequest.ID + '&thisPage=' + thisPage);
            }
        } catch(Exception ex) {
            if(IS_CONSOLE == 'YES') {
                responsePage = New PageReference('/apex/community_ServiceRequestInternalComplete?type=ERR&sr=' + newServiceRequest.ID);
            } else {
                responsePage = New PageReference('/ServiceDesk/community_ServiceRequestList?prompt=Failed&highlight=' + newServiceRequest.ID);
            }
        }
        
        return responsePage;
    }
    
    public void srCustomerCheck() {
        //is it a valid customer?
        Account customerAcc = null;
        try {
            customerAcc  = [SELECT Name, ID FROM Account WHERE Name = : input_Customer];
        } catch(Exception e) {
            //Invalid customer - don't do anything.
            type_ShowList = false;
            return;
        }
        
        type_ShowAuth = true;
        type_ShowList = false;
        //if(customerID != customerAcc.ID) {
            clearForm();
        //}
        customerID = customerAcc.ID;
        customerName = customerAcc.Name;
        
        requestApproverList.clear();
        List<User> approvers = [SELECT ID, Name FROM User WHERE Contact.AccountID = : customerID];
        
        requestApproverList.add(new SelectOption('-- None --', '-- None --'));
        for(User aps : approvers) {
            if(userHasPerm(aps.ID)) {
                requestApproverList.add(new SelectOption(aps.ID, aps.Name));
            }
        }
    }
    
    public void srApproverCheck() {
        type_ShowList = false;

        debug('approver is' + input_CustomerApprover);

        if(input_CustomerApprover != '-- None --') {
            type_ShowList = true;
        } else {
            clearForm();
        }
    }
    
    public void clearForm() {
        pat_ShowForm = false;
        cop_ShowForm = false;
        upg_ShowForm = false;
        targetEnvironments.Clear();
        targetEnvironments.add(new SelectOption('NONE_SELECTED', 'Please select an environment'));
        sourceEnvironments.Clear();
        sourceEnvironments.add(new SelectOption('NONE_SELECTED', 'Please select an environment'));
        serviceDates.clear();
        serviceDates.add(new SelectOption('01/01/1970', 'Please select a date'));
        serviceDateList = '';
        
        //input_TypeRequested = ''; DO NOT OVERWRITE THE SELECTED TYPE. THAT WOULD BE SILLY NOW WOULDN'T IT.
        input_TargetEnvironment = '';
        input_SourceEnvironment = '';
        input_ServiceDate = Date.parse('01/01/1970');
        input_TimeSlot = 'AM';
        
        input_UpgCopyRequired = false;
        input_PatchType = '';
        
        input_DBPIT = '';
        input_DBPITDate = '';
        input_DBPITHour = '';
        input_DBPITMins = '';
        
        nopeMessage= '';
        
        pat_ShowForm = false;
        pat_ShowPatchTypes = false;
        pat_ShowMatchEnvironment = false;
        cop_ShowForm = false;
        cop_ShowTargets = false;
        cop_ShowPIT = false;
        cop_ShowPITOptions = false;
        upg_ShowForm = false;
        upg_IfNotLive = false;
        upgNoLives.clear();
        showServiceTimes = false;
    }
    
    public void srTypeCheck() {
        //called when a user selects a type
        
        input_TypeRequested = ApexPages.currentPage().getParameters().get('srType');
        
        nopeMessage = '';
        isLastMandatory = true;
        
        clearForm();
        
        DateTime REALdateToday = DateTime.now();
        DateTime dateToday = DateTime.now();
        dateToday = DateTime.newInstanceGmt(dateToday.year(), dateToday.month(), 00);
        serviceStartDate = dateToday.format('dd/MM/yy');
        DateTime dateLimit = DateTime.newInstanceGmt(maxEndDate.year(), maxEndDate.month(), maxEndDate.day());

        Long daysBetween = 0;        
        if(input_TypeRequested == 'Upgrade') {
            daysBetween = (((((dateLimit.getTime() - dateToday.getTime()) / 1000) / 60) / 60) / 24);
        } else {
            DateTime futureDate = dateToday.addMonths(3);
            daysBetween = (((((futureDate.getTime() - dateToday.getTime()) / 1000) / 60) / 60) / 24);
        }
        Long currentDay = 0;
        
        if(input_TypeRequested == 'Patch') {
            pat_ShowForm = true; 
            for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
                for(Hosted__c env : environment) {
                    targetEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));
                }
            }
            for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
                for(Hosted__c env : environment) {
                    sourceEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));
                }
            }
            
            List<Hosted_Service_Request__c> existingSR = [SELECT srDate__c, srTime__c FROM Hosted_Service_Request__c WHERE srType__c = 'Patch' AND srStatus__c != 'Rejected' AND srStatus__c != 'Cancelled' AND srStatus__C != 'Rejected by Customer'];
            
            debug('There are currently ' + existingSR.size() + ' existing patches.');
            
            DateTime currentDate = dateToday;
            while(currentDay <= daysBetween) {
                currentDate = currentDate.addDays(1);
                currentDay ++;
                
                String dateString = String.valueOf(currentDate.format('dd/MM/yyyy'));
                if(currentDate.format('E') == 'Sat' || currentDate.format('E') == 'Sun') continue;
                //select this date from the bank holidays object. if it returns a row, do not show the date.
                Boolean validDate = true;
                for(Date bankHol : bankHolidayDates) {
                    if(bankHol == currentDate.date()) {
                        validDate = false;
                    }
                }
                if(!validDate) continue;

                Integer srOnThisDay_AM = 0;
                Integer srOnThisDay_PM = 0;
                for(Hosted_Service_Request__c thisSR : existingSR) {
                    if(thisSR.srDate__c == currentDate.date()) {
                        if(thisSR.srTime__c == 'AM') {
                            srOnThisDay_AM ++;
                        } else {
                            srOnThisDay_PM ++;
                        }
                    }
                }
                
                //serviceRequestMax 
                
                Date closestDate = date.newInstance(1970, 1, 1);
                Decimal maxSRAM = 0;
                Decimal maxSRPM = 0;
                for(Service_Request_Availability_Schedule__c thisAva : serviceRequestMax) {
                    if(thisAva.sra_EffectiveDate__c > closestDate && thisAva.sra_EffectiveDate__c < currentDate.date()) {
                        //we have a new contender for the title of 'closest date'!
                        closestDate = thisAva.sra_EffectiveDate__c;
                        maxSRAM = thisAva.sra_PatchAM__c;
                        maxSRPM = thisAva.sra_PatchPM__c;
                    }
                }
                
                if(currentDate < REALdateToday) {
                    debug(' === Ignoring date ' + currentDate + ' as it is in the past');
                    continue; //this is in the past
                }    
                
                if(srOnThisDay_AM + srOnThisDay_PM >= maxSRAM + maxSRPM) {
                    //no slots available on this day at all
                    continue;
                } 
                
                serviceDates.add(new SelectOption(dateString, dateString + ' (AM Slots: ' + (maxSRAM - srOnThisDay_AM) + ' | PM Slots: ' + (maxSRPM - srOnThisDay_PM) + ')'));
                serviceDateList = serviceDateList + dateString + ',';
            }
            
            serviceEndDate = currentDate.format('dd/MM/yyyy');
            
        } else if(input_TypeRequested == 'Database Copy') {
            cop_ShowForm = true;
            for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
                for(Hosted__c env : environment) {
                    if(env.Environment_Type__c == 'Live') continue;
                    targetEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));
                }
            }
            for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
                for(Hosted__c env : environment) {
                    sourceEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));
                }
            }
            
            copPITOptions.clear();
            copPITOptions.add(new SelectOption('NOW', 'Use data at the time of the copy'));
            copPITOptions.add(new SelectOption('PIT', 'Use data from a specific date and time'));
            
            input_DBPIT = 'NOW';
            
            List<Hosted_Service_Request__c> existingSR = [SELECT srDate__c, srTime__c FROM Hosted_Service_Request__c WHERE srType__c = 'Database Copy' AND srStatus__c != 'Rejected' AND srStatus__c != 'Cancelled' AND srStatus__c != 'Rejected by Customer' ];
            
            debug('There are currently ' + existingSR.size() + ' existing copies.');
            
            DateTime currentDate = dateToday;
            while(currentDay <= daysBetween) {
                currentDate = currentDate.addDays(1);
                currentDay ++;
                
                String dateString = String.valueOf(currentDate.format('dd/MM/yyyy'));
                if(currentDate.format('E') == 'Sat' || currentDate.format('E') == 'Sun') continue;
                //select this date from the bank holidays object. if it returns a row, do not show the date.
                Boolean validDate = true;
                for(Date bankHol : bankHolidayDates) {
                    if(bankHol == currentDate.date()) {
                        validDate = false;
                    }
                }
                if(!validDate) continue;

                Integer srOnThisDay_AM = 0;
                Integer srOnThisDay_PM = 0;
                for(Hosted_Service_Request__c thisSR : existingSR) {
                    if(thisSR.srDate__c == currentDate.date()) {
                        if(thisSR.srTime__c == 'AM') {
                            srOnThisDay_AM ++;
                        } else {
                            srOnThisDay_PM ++;
                        }
                    }
                }
                
                //serviceRequestMax 
                
                Date closestDate = date.newInstance(1970, 1, 1);
                Decimal maxSRAM = 0;
                Decimal maxSRPM = 0;
                for(Service_Request_Availability_Schedule__c thisAva : serviceRequestMax) {
                    if(thisAva.sra_EffectiveDate__c > closestDate && thisAva.sra_EffectiveDate__c < currentDate.date()) {
                        //we have a new contender for the title of 'closest date'!
                        closestDate = thisAva.sra_EffectiveDate__c;
                        maxSRAM = thisAva.sra_CopyAM__c;
                        maxSRPM = thisAva.sra_CopyPM__c;
                    }
                }
                
                if(currentDate < REALdateToday) {
                    debug(' === Ignoring date ' + currentDate + ' as it is in the past');
                    continue; //this is in the past
                }
                
                if(srOnThisDay_AM + srOnThisDay_PM >= maxSRAM + maxSRPM) {
                    //no slots available on this day at all
                    continue;
                } 
                
                serviceDates.add(new SelectOption(dateString, dateString + ' (AM Slots: ' + (maxSRAM - srOnThisDay_AM) + ' | PM Slots: ' + (maxSRPM - srOnThisDay_PM) + ')'));
                serviceDateList = serviceDateList + dateString + ',';
            }
            
            serviceEndDate = currentDate.format('dd/MM/yyyy');
        } else if(input_TypeRequested == 'Upgrade') {
            upg_ShowForm = true;
            
            String lastMandatory = getLastMandatory();
            
            for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c, Environment_Version__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
                for(Hosted__c env : environment) {
                    if(Integer.valueOf(lastMandatory.substring(3)) <= Integer.valueOf(env.Environment_Version__c.subString(3))) {
                        //This environment is valid.
                        debug('environment ' + env.Environment_Name__c + ' is valid (version ' + env.Environment_Version__c + ')');
                    } else {
                        isLastMandatory = false;
                    }
                }
            }
            
            /* COMMENTED OUT. SEE BELOW FOR MODIFICATION.
            
            //Is this customer at the current, mandatory release (or higher)?
            //Let's get the customers LOWEST iTrent version. Disallow them from upgrading if they have an environment that does not report it is the latest mandatory.
            if(isLastMandatory) {
                //They have all environments at the latest mandatory release of iTrent. Good boys and girls.
                debug('all environments at latest mandatory: ' + getLastMandatory());
            } else {
                //They have an environment that is not marked as the latest version of iTrent. That's sad news.
                debug('Not all environments are latest. Altering date picker limits...');
                DateTime endOfMarch = DateTime.newInstanceGmt(DateTime.now().year(), 4, 1).addDays(-1);
                daysBetween = (((((endOfMarch.getTime() - dateToday.getTime()) / 1000) / 60) / 60) / 24);
                
                //enforce trent version...
            }*/
            
            //Is this customer at the current, mandatory release (or higher)?
            //Let's get the customers LOWEST iTrent version. Disallow them from upgrading if they have an environment that does not report it is the latest mandatory.
            if(isLastMandatory) {
                //They have all environments at the latest mandatory release of iTrent. Good boys and girls.
                debug('all environments at latest mandatory: ' + getLastMandatory());
            } else {
                //It's OK that they're not at the latest mandatory yet, because we're not near the end of this cycle.
                if(DateTime.now().month() <= 3 && DateTime.now().month() > 1) {
                    
                    //They have an environment that is not marked as the latest version of iTrent. That's sad news.
                    debug('Not all environments are latest, and we\'re at the end of the mandatory cycle. Altering date picker limits...');
                    DateTime endOfMarch = DateTime.newInstanceGmt(DateTime.now().year(), 4, 1).addDays(-1);
                    daysBetween = (((((endOfMarch.getTime() - dateToday.getTime()) / 1000) / 60) / 60) / 24);
                    
                    //enforce trent version...
                    
                }
            }
            
            for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c, Environment_Version__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
                for(Hosted__c env : environment) {
                    if(!isLastMandatory) {
                        //One (or many) of you does not belong. Identify yourself.
                        if(env.Environment_Version__c.substring(3) >= getLastMandatory().substring(3)) {
                            continue;
                            //This environment is last mandatory or greater, and should not be shown in the list.
                        }
                    }
                    targetEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));
                }
            }
            
            List<Hosted_Service_Request__c> existingSR = [SELECT srDate__c FROM Hosted_Service_Request__c WHERE srType__c = 'Upgrade' AND srStatus__c != 'Rejected' AND srStatus__c != 'Cancelled' AND srStatus__C != 'Rejected by Customer'];
            
            debug('There are currently ' + existingSR.size() + ' existing upgrades.');
            
            DateTime currentDate = dateToday;
            Integer marginValue = 0;
            Integer lastMonth = 0;
            while(currentDay < daysBetween) {
                currentDate = currentDate.addDays(1);
                currentDay ++;
                
                if(lastMonth != currentDate.month()) {
                    marginValue = 0;
                    lastMonth = currentDate.month();
                }
                
                String dateString = String.valueOf(currentDate.format('dd/MM/yyyy'));
                if(currentDate.format('E') == 'Sat' || currentDate.format('E') == 'Sun') continue;
                //select this date from the bank holidays object. if it returns a row, do not show the date.
                Boolean validDate = true;
                for(Date bankHol : bankHolidayDates) {
                    if(bankHol == currentDate.date()) {
                        validDate = false;
                    }
                }
                if(!validDate) continue;
                

                Integer srOnThisDay = 0;
                for(Hosted_Service_Request__c thisSR : existingSR) {
                    if(thisSR.srDate__c == currentDate.date()) {
                        srOnThisDay ++;
                    }
                }
                
                //serviceRequestMax 
                
                Date closestDate = date.newInstance(1970, 1, 1);
                Decimal maxSR = 0;
                for(Service_Request_Availability_Schedule__c thisAva : serviceRequestMax) {
                    if(thisAva.sra_EffectiveDate__c > closestDate && thisAva.sra_EffectiveDate__c < currentDate.date()) {
                        //we have a new contender for the title of 'closest date'!
                        closestDate = thisAva.sra_EffectiveDate__c;
                        maxSR = thisAva.sra_Upgrades__c;
                    }
                }
                
                marginValue ++;
                
                if(srOnThisDay >= maxSR) {
                    //no slots available
                    continue;
                } 
                
                if(currentDate < REALdateToday) {
                    debug(' === Ignoring date ' + currentDate + ' as it is in the past');
                    continue; //this is in the past
                }
                
                if(isReleaseMonth(currentDate.month()) && isLastMandatory) { //do not bother with this if they haven't bothered to upgrade to latest mandatory. we need to get them upgraded asap.
                    //This is a release month. Let's make sure we're adding the appropriate margins.
                    debug(currentDate.month() + ' is a release month');
                    debug(' when checking ' + currentDate);
                    if(marginValue <= upgradeMargin) {
                        debug('### SKIPPING (upg margin: ' + upgradeMargin + ' | marginValue: ' + marginValue);
                        continue;
                    }
                    
                    /*if(marginValue > upgradeMargin && marginValue < upgradeNonLiveOnlyMargin) {
                        //upgNoLives 
                        upgNoLives.add(currentDate.date());
                    }*/
                }
                
                input_TimeSlot = 'AM';
                
                serviceDates.add(new SelectOption(dateString, dateString + ' (' + (maxSR - srOnThisDay) + ' slots remaining)'));
                serviceDateList = serviceDateList + dateString + ',';
            }
            serviceEndDate = currentDate.format('dd/MM/yyyy');
            
        } else if(input_TypeRequested == 'Request Authoriser Status') {
            addAuth_ShowForm = true;            
        } else {
            pat_ShowForm = false;
            cop_ShowForm = false;
            upg_ShowForm = false;
            addAuth_ShowForm = false;
        }
        
        checkSaveReady();
    }
    
    public void serviceUpgCheckEnv() {
        //Get the environment type from the DB
        input_TargetEnvironment = ApexPages.currentPage().getParameters().get('inputTargetEnvironment');
        
        upg_IfNotLive = true;
        
        if(input_TargetEnvironment == 'NONE_SELECTED') {
            upg_IfNotLive = false;
            return;
        }
        
        Hosted__c environment = [SELECT Environment_Type__c, Environment_Version__c FROM Hosted__c WHERE ID = : input_TargetEnvironment];
        if(environment.Environment_Type__c == 'Live') {
            upg_IfNotLive = false;
            input_UpgCopyRequired = false;
        }
        
        if(upg_IfNotLive == true) {
            //Get Live, see if it's same version.
            Integer count = database.countQuery('SELECT count() FROM Hosted__c WHERE Customer__c = : customerID AND Environment_Type__c = \'Live\'');
            if(count > 0) {
                Hosted__c live = [SELECT Environment_Type__c, Environment_Version__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_Type__c = 'Live'];
                if(live.Environment_Version__c != environment.Environment_Version__c) {
                    upg_IfNotLive = false;
                    input_UpgCopyRequired = false;
                    //it's not, don't show the box!
                }
            } else {
                upg_IfNotLive = false;
                input_UpgCopyRequired = false;
            }
        }
        
        checkSaveReady();
    }
    
    public void serviceUpgDate() {
       //When the date changes... update the Trent version calculator
       input_ServiceDate = Date.parse(ApexPages.currentPage().getParameters().get('inputServiceDate'));
       
       calculateTrentVersionOnDate(input_ServiceDate);
       
       //Are they up to the last mandatory version?
        Boolean isLastMandatory = true;
        
        String lastMandatory = getLastMandatory();
        
        for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c, Environment_Version__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
            for(Hosted__c env : environment) {
                if(Integer.valueOf(lastMandatory.substring(3)) <= Integer.valueOf(env.Environment_Version__c.subString(3))) {
                    //This environment is valid.
                    debug('environment ' + env.Environment_Name__c + ' is valid (version ' + env.Environment_Version__c + ')');
                } else {
                    isLastMandatory = false;
                }
            }
        }
       
       if(input_ServiceDate == Date.parse('01/01/1970')) {
           trentVersionString = 'Once a date has been selected, this text will display the iTrent version that will be installed.';
       } else {
           if(isLastMandatory) {
               trentVersionString = 'On the date selected, the chosen environment will be upgraded to version <strong>' + trentVersion + '</strong>.';
           } else {
               trentVersionString = 'On the date selected, the chosen environment will be upgraded to version <strong>' + getLastMandatory() + '</strong>. You cannot proceed to a more recent version of iTrent in any environment until all environments are the latest <em>mandatory</em> version of iTrent.';
               trentVersion = getLastMandatory();
           }
       }
       
       //upg_ShowNoLiveUpgradeMsg 
       
       
       input_TimeSlot = 'AM';
       
       checkSaveReady();
    }
    
    public void servicePatEnvCheck() {
        input_TargetEnvironment = ApexPages.currentPage().getParameters().get('inputPatchEnvironment');
        
        pat_ShowPatchTypes = false;
        pat_ShowMatchEnvironment = false;
        input_PatchType = 'Up to Date';
        
        if(input_TargetEnvironment == 'NONE_SELECTED') {
            input_SourceEnvironment = '';
        } else {
            pat_ShowPatchTypes = true;
            input_PatchType = 'Up to Date';
            input_SourceEnvironment = '';
        }
        
        checkSaveReady();
    }
    
    public void servicePatDate() {
        input_ServiceDate = Date.parse(ApexPages.currentPage().getParameters().get('inputPatchDate'));
        
        if(input_ServiceDate == Date.parse('01/01/1970')) {
            showServiceTimes = false;
            //input_TimeSlot = '';
        } else {
            showServiceTimes = true;
            serviceTimes.clear();
            
            List<Hosted_Service_Request__c> existingSR = [SELECT srDate__c, srTime__c FROM Hosted_Service_Request__c WHERE srType__c = 'Patch' AND srDate__c = : input_ServiceDate  AND srStatus__c != 'Rejected' AND srStatus__c != 'Cancelled' AND srStatus__C != 'Rejected by Customer'];
            
            Integer srOnThisDay_AM = 0;
            Integer srOnThisDay_PM = 0;
            for(Hosted_Service_Request__c thisSR : existingSR) {
                if(thisSR.srDate__c == input_ServiceDate) {
                    if(thisSR.srTime__c == 'AM') {
                        srOnThisDay_AM ++;
                    } else {
                        srOnThisDay_PM ++;
                    }
                }
            }
            
            Date closestDate = date.newInstance(1970, 1, 1);
            Decimal maxSRAM = 0;
            Decimal maxSRPM = 0;
            for(Service_Request_Availability_Schedule__c thisAva : serviceRequestMax) {
                if(thisAva.sra_EffectiveDate__c > closestDate && thisAva.sra_EffectiveDate__c < input_ServiceDate) {
                    //we have a new contender for the title of 'closest date'!
                    closestDate = thisAva.sra_EffectiveDate__c;
                    maxSRAM = thisAva.sra_PatchAM__c;
                    maxSRPM = thisAva.sra_PatchPM__c;
                }
            }
            
            input_TimeSlot = '';
            if(maxSRAM - srOnThisDay_AM > 0) {
                serviceTimes.add(new SelectOption('AM', 'AM'));
                input_TimeSlot = 'AM';
            }
            
            if(maxSRPM - srOnThisDay_PM > 0) {
                serviceTimes.add(new SelectOption('PM', 'PM'));
                if(input_TimeSlot == '') input_TimeSlot = 'PM';
            }
        }
        
        checkSaveReady();
    }
    
    public void servicePatType() {
        input_PatchType = ApexPages.currentPage().getParameters().get('inputPatchType');

        //pat_ShowMatchEnvironment
        if(input_PatchType == 'Patch to Match') {
            pat_ShowMatchEnvironment = true;
            
            //we're going to match something.
            
            Hosted__c targetEnvironment = [SELECT Environment_Version__c FROM Hosted__c WHERE ID = : input_TargetEnvironment];
            
            sourceEnvironments.clear();
            sourceEnvironments.add(new SelectOption('NONE_SELECTED', 'Please select an environment'));
            for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Version__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
                for(Hosted__c env : environment) {
                    if(env.ID == input_TargetEnvironment) continue;
                    if(env.Environment_Version__c == targetEnvironment.Environment_Version__c) {
                        sourceEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));
                    }
                }
            }
            
            if(sourceEnvironments.size() == 1) {
                //Only the header...
                sourceEnvironments.clear();
                sourceEnvironments.add(new SelectOption('NONE_SELECTED', '(Unavailable)', false));
                
                calculateTrentVersionOnDate(Date.today());
                
                nopeMessage = 'There are no other environments on the same major release version (eg. ' + trentVersion.left(2) + '.<u>' + trentVersion.right(2) + '</u>) as your selected environment. Environments must be on the same major version in order to complete a \'Patch to Match\' operation.';
            } else {
                nopeMessage = '';
            }
            
        } else {
            pat_ShowMatchEnvironment = false;
        }
        
        checkSaveReady();
    }
    
    public void serviceCopEnvCheck() {
        input_SourceEnvironment = ApexPages.currentPage().getParameters().get('inputCopySource');
        
        if(input_SourceEnvironment == 'NONE_SELECTED') {
            cop_ShowTargets = false;
            cop_ShowPIT = false;
            cop_ShowPITOptions = false;
            return;
        }
        
        Hosted__c sourceEnv = [SELECT Environment_Version__c FROM Hosted__c WHERE ID = : input_SourceEnvironment];
        
        Boolean envLiveErr = false;
        
        targetEnvironments.clear();
        targetEnvironments.add(new SelectOption('NONE_SELECTED', 'Please select an environment'));
        for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c, Environment_Version__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c != TRUE]) {
            for(Hosted__c env : environment) {
                if(env.Environment_Type__c == 'Live') {
                    envLiveErr = true;
                    continue; //copies to Live are disallowed.
                }    
                if(env.Environment_Version__c != sourceEnv.Environment_Version__c) continue; //not same major version - cannot copy here
                if(env.ID == sourceEnv.ID) continue; //yeah, no. no copies to the same env.
                targetEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));
            }
        }
        
        if(targetEnvironments.size() == 1) {
            targetEnvironments.clear();
            //targetEnvironments.add(new SelectOption('NONE_SELECTED', 'There are no other environments that are compatible with the selected environments major version.', false));
            targetEnvironments.add(new SelectOption('NONE_SELECTED', '(Unavailable)', false));
            
            calculateTrentVersionOnDate(Date.today());
            
            Hosted__c tmpEnv = [SELECT Environment_Name__c, Environment_Version__c FROM Hosted__c WHERE ID = : input_SourceEnvironment];
            
            nopeMessage = 'The source environment \'' + tmpEnv.Environment_Name__c + '\' is on release version ' + tmpEnv.Environment_Version__c.left(2) + '.' + tmpEnv.Environment_Version__c.right(2) + '. There are no available target environments which match this release version.<br />In addition to this, you cannot use this service to schedule a copy of a Non-Live environment into a Live environment, as a safeguard to maintain the integrity of your Live environment data.';
            
        } else {
            nopeMessage = '';
        }
        
        cop_ShowTargets = true;
        
        checkSaveReady();
    }
    
    /*public serviceCopTarget() {
        input_TargetEnvironment = ApexPages.currentPage().getParameters().get('inputCopyTarget');
        
        if(input_TargetEnvironment == 'NONE_SELECTED') {
            return;
        }
    }*/    
    
    public void serviceCopDate() {
        input_ServiceDate = Date.parse(ApexPages.currentPage().getParameters().get('inputCopyDate'));
        
        if(input_ServiceDate == Date.parse('01/01/1970')) {
            showServiceTimes = false;
            cop_ShowPITOptions = false;
        } else {
            showServiceTimes = true;
            cop_ShowPITOptions = true;
            serviceTimes.clear();
            
            List<Hosted_Service_Request__c> existingSR = [SELECT srDate__c, srTime__c FROM Hosted_Service_Request__c WHERE srType__c = 'Database Copy' AND srDate__c = : input_ServiceDate  AND srStatus__c != 'Rejected' AND srStatus__c != 'Cancelled' AND srStatus__C != 'Rejected by Customer'];
            
            Integer srOnThisDay_AM = 0;
            Integer srOnThisDay_PM = 0;
            for(Hosted_Service_Request__c thisSR : existingSR) {
                if(thisSR.srDate__c == input_ServiceDate) {
                    if(thisSR.srTime__c == 'AM') {
                        srOnThisDay_AM ++;
                    } else {
                        srOnThisDay_PM ++;
                    }
                }
            }
            
            Date closestDate = date.newInstance(1970, 1, 1);
            Decimal maxSRAM = 0;
            Decimal maxSRPM = 0;
            for(Service_Request_Availability_Schedule__c thisAva : serviceRequestMax) {
                if(thisAva.sra_EffectiveDate__c > closestDate && thisAva.sra_EffectiveDate__c < input_ServiceDate) {
                    //we have a new contender for the title of 'closest date'!
                    closestDate = thisAva.sra_EffectiveDate__c;
                    maxSRAM = thisAva.sra_CopyAM__c;
                    maxSRPM = thisAva.sra_CopyPM__c;
                }
            }
            
            input_TimeSlot = '';
            
            if(maxSRAM - srOnThisDay_AM > 0) {
                serviceTimes.add(new SelectOption('AM', 'AM'));
                input_TimeSlot = 'AM';
            }
            
            if(maxSRPM - srOnThisDay_PM > 0) {
                serviceTimes.add(new SelectOption('PM', 'PM'));
                
                if(input_TimeSlot == '') input_TimeSlot = 'PM';
            }
            
        }
        
        serviceCopPIT(); //check this too...
        
        checkSaveReady();
    }
    
    public void serviceCopPIT() {
        input_DBPIT = ApexPages.currentPage().getParameters().get('inputCopyPIT');
        
        debug(input_DBPIT);
        
        if(input_DBPIT != 'PIT') {
            cop_ShowPIT = false;
        } else {
            cop_ShowPIT = true;
            DateTime currentDate = input_serviceDate;
            DateTime startDate = currentDate.addDays(-6);
            
            debug('Got currentDate as ' + String.valueOf(currentDate.format('dd/MM/yyyy')) + ' and startDate as ' + String.valueOf(startDate.format('dd/MM/yyyy')));
            
            copPITDateSelect.clear();
            copPITDateSelect.add(new SelectOption('NONE', 'DD/MM/YYYY'));
            while(startDate < currentDate) {
                String dateString = String.valueOf(startDate.format('dd/MM/yyyy'));
                copPITDateSelect.add(new SelectOption(dateString , dateString));
                startDate = startDate.addDays(1);
            }
            
            input_DBPITDate = 'NONE';
            input_DBPITHour = 'NONE';
            input_DBPITMins = 'NONE'; 
            
            copPITTime_Hour.clear();
            copPITTime_Hour.add(new SelectOption('NONE', 'HH'));
            for(Integer I = 0; I < 24; I++) {
                String hourValue = String.valueOf(I);
                if(I < 10) {
                    hourValue = '0' + hourValue;
                }
                copPITTime_Hour.add(new SelectOption(hourValue, hourValue));
            }
            
            copPITTime_Mins.clear();
            copPITTime_Mins.add(new SelectOption('NONE', 'MM'));
            copPITTime_Mins.add(new SelectOption('00', '00'));
            copPITTime_Mins.add(new SelectOption('15', '15'));
            copPITTime_Mins.add(new SelectOption('30', '30'));
            copPITTime_Mins.add(new SelectOption('45', '45'));
            //copPITDateTimeSelect 
        }
        
        checkSaveReady();
    }
    
    //############## Functions
    
    public void checkSaveReady() {
        readyToSave = false;
        
        //all based on type...
        if(input_TypeRequested == 'Patch') {
            if(input_TypeRequested != 'NONE_SELECTED' && input_TypeRequested != '') {
                if(input_ServiceDate != Date.parse('01/01/1970')) {
                    if(input_TimeSlot != '') {
                        //everything good. if they have selected patch to match we need to make sure a source environment is selected.
                        if(input_PatchType != '') {
                            if(input_PatchType == 'Patch to Match') {
                                if(input_SourceEnvironment != 'NONE_SELECTED' && input_SourceEnvironment != '') {
                                    readyToSave = true;
                                    //everything that is required is done
                                }
                            } else if (input_PatchType == 'Up to Date') {
                                readyToSave = true;
                            }
                        }
                    }
                }
            }
        } else if(input_TypeRequested == 'Database Copy') {
            if(input_SourceEnvironment != 'NONE_SELECTED'  && input_SourceEnvironment != '') {
                if(input_TargetEnvironment != 'NONE_SELECTED'  && input_TargetEnvironment != '') {
                    if(input_ServiceDate != Date.parse('01/01/1970')) {
                        //let's validate...
                        debug('requesting source forecast');
                        String sourceVersionAtDate = getTrentVersionAtDate(input_SourceEnvironment, input_ServiceDate);
                        debug('requesting target forecast');
                        String targetVersionAtDate = getTrentVersionAtDate(input_TargetEnvironment, input_ServiceDate);            
                                 
                        if(sourceVersionAtDate == targetVersionAtDate) {
                            if(input_TimeSlot != '') {
                                //all good. are we pit?
                                if(input_DBPIT == 'PIT') {
                                    if(input_DBPITDate != 'NONE') {
                                        if(input_DBPITHour != 'NONE') {
                                            if(input_DBPITMins != 'NONE') {
                                                //ready to save! :D
                                                readyToSave = true;
                                            }
                                        }
                                    }
                                } else if(input_DBPIT == 'NOW') {
                                    readyToSave = true;
                                } else {
                                    readyToSave = false;
                                }
                            }
                            nopeMessage = '';
                        } else {
                            //trent versions will not match on the service date specified
                            nopeMessage = 'Unfortunately this copy cannot go ahead due to a forecasted version mis-match on the Service Date you requested for your Source and Target environments.';
                        }
                    }
                }
            }
        } else if(input_TypeRequested == 'Upgrade') {
            if(input_TargetEnvironment != 'NONE_SELECTED'  && input_TargetEnvironment != '') {
                //This is ok...
                if(input_ServiceDate != Date.parse('01/01/1970')) {
                    //Can save! Everything has been selected.
                    
                    // 20-11-2018: But wait, are they on a credit stop?
                    hsr_CreditStop_ShowMessage = false;
                    Account thisAccount = [SELECT Credit_Hold__c FROM Account WHERE ID = : customerID];
                    if(thisAccount.Credit_Hold__c) {
                        //Is it a mandatory? If so, prevent their upgrade. If not, they can pass this time...
                        if(isTrentVersionMandatory(trentVersion)) {
                            hsr_CreditStop_ShowMessage = true;
                        } else {
                            readyToSave = true;
                        }
                    } else {
                        readyToSave = true;
                    }
                }
            }
        } else if(input_TypeRequested == 'Request Authoriser Status') {
            readyToSave = true;
            //immediately ready to save... it's just some info on display
        } else {
            readyToSave = false;
        }
    }
    
    private void calculateTrentVersionOnDate(DateTime inputDate) {
        /*DateTime startDate = DateTime.newInstanceGmt(2016, 5, 31); //release of 10.20 - DO NOT CHANGE THIS AS IT WILL SCREW EVERYTHING
        Integer baseVersion = 20;
        DateTime endDate = startDate.addMonths(3); //release of 10.21 / when we stop installing 10.20
        
        DateTime currentVersionStart = startDate;
        Integer currentVersion = baseVersion;
        DateTime currentVersionEnd = endDate;
        
        while(inputDate > currentVersionEnd) {
            currentVersionStart = currentVersionStart.addMonths(3);
            currentVersionEnd = currentVersionEnd.addMonths(3);
            currentVersion = currentVersion + 1;
        }
        
        trentVersion = '10.' + currentVersion;*/
        //preserve old functionality...
        
        trentVersion = func_calculateTrentVersionOnDate(inputDate);
    }   
    
    private String func_calculateTrentVersionOnDate(DateTime inputDate) {
        DateTime startDate = DateTime.newInstanceGmt(2016, 5, 31); //release of 10.20 - DO NOT CHANGE THIS AS IT WILL SCREW EVERYTHING
        Integer baseVersion = 20;
        DateTime endDate = startDate.addMonths(3); //release of 10.21 / when we stop installing 10.20
        
        DateTime currentVersionStart = startDate;
        Integer currentVersion = baseVersion;
        DateTime currentVersionEnd = endDate;
        
        while(inputDate > currentVersionEnd) {
            currentVersionStart = currentVersionStart.addMonths(3);
            currentVersionEnd = currentVersionEnd.addMonths(3);
            currentVersion = currentVersion + 1;
        }
        
        return '10.' + currentVersion;
    }   
    
    public boolean isReleaseMonth(Integer month) {
        Integer[] releaseMonths = new Integer[]{3, 6, 9, 12};
        
        for(Integer m : releaseMonths) {
            if(m == month) return true;
        }
        
        return false;
    }
    
    private boolean hasPerm() {
        Boolean showServiceRequest = false;
        for(List<PermissionSetAssignment> PSA : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'Community_Create_Service_Request']) {
            if (!PSA.isEmpty()) {
                showServiceRequest = true;
            }
        }
        
        return showServiceRequest;
    }
    
    private boolean userHasPerm(String userid) {
        Boolean showServiceRequest = false;
        for(List<PermissionSetAssignment> PSA : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= : userid AND PermissionSet.Name = 'Community_Create_Service_Request']) {
            if (!PSA.isEmpty()) {
                showServiceRequest = true;
            }
        }
        
        return showServiceRequest;
    }    
    
    public string getTrentVersionAtDate(String env, Date serviceDate) {
        Hosted__c environment = [SELECT Environment_Version__c FROM Hosted__c WHERE ID = : env];
        String returnVersion = environment.Environment_Version__c;
    
        Date today = Date.today();
        
        List<Hosted_Service_Request__c> existingRequests = [SELECT srRealName__c, srType__c, upg_TrentVersion__c, srDate__c FROM Hosted_Service_Request__c WHERE srEnvironment__c = : env AND srCustomer__c = : customerID AND srType__c = 'Upgrade' AND srDate__c >= : today AND srDate__c <= : serviceDate ORDER BY srDate__c ASC];
        for(Hosted_Service_Request__c request : existingRequests) {
            //If this ever runs, there IS an upgrade that will effect trent version...
            //the list is sorted in DATE ASCENDING order, so we can iteratively assign the version to 'returnVersion' and the latest version that will exist will be in that var.
            returnVersion = request.upg_TrentVersion__c;
            debug('[' + env + '] trent version will be as part of ' + request.srRealName__c + ' ' + returnVersion);
        }
        
        return returnVersion;
    }
    
    public boolean isTrentVersionMandatory(String version) {
        Integer intMandatoryVers = 18;
        Integer intVersion = Integer.valueOf(version.substring(3));
        
        while(intVersion >= intMandatoryVers) {
//            debug('intMandatoryVers: ' + intMandatoryVers + ' | intVersion: ' + intVersion);
            if(intVersion == intMandatoryVers) {
                return true;
            }
            intMandatoryVers += 4;
        }
        
        
        return false;
    }
    
    public string getLastMandatory() {
        Integer currentVers = Integer.valueOf(func_calculateTrentVersionOnDate(DateTime.now()).substring(3));
        Boolean isMandatory = isTrentVersionMandatory('10.' + currentVers); //This version could be mandatory, and this would be OK.
        while(!isMandatory) {
            currentVers --;
            isMandatory = isTrentVersionMandatory('10.' + currentVers);
        }
        
        return '10.' + currentVers;
    }
    
    private void debug(String msg) {
        String line = '[' + DateTime.now() + '] ' + msg + '<br />';
        if(debugString != null) {
            debugString = debugString + line;
        } else {
            debugString = line;
        }
    }
}