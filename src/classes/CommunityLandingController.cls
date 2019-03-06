public with sharing class CommunityLandingController {

    public boolean showServiceRequest {get;set;}
    public string nextMandatory {get;set;}
    public Integer customerEnvironmentCount {get;set;}
    public Integer environmentsToBookCount {get;set;}
    public List<SelectOption> targetEnvironments {get;set;}
    public List<String> environmentsToBook {get;set;}
    private String customerID = '';
    private string debugString = '';
    public string serviceDateList {get;set;}
    public SelectOption [] serviceDates {get;set;}
    public String bookingString {get;set;}
    public String upgradeMiniTerms {get;set;}
    public String hsrUpg_Status {get;set;}
    
    public boolean hsr_CreditStop {get;set;}
    
/*------------  Retired 23-12-2015 ------------ */
/*    
    // Return a list of data points for a chart
    
    public class CaseAges {
        Integer n0to1 {get;set;}
        Integer n2to5 {get;Set;}
        Integer n6to15 {get;Set;}
        Integer n16to30 {get;Set;}
        Integer n31to60 {get;Set;}
        Integer n61to120 {get;Set;}
        Integer n121plus {get;Set;}
        
        public CaseAges () {
                n0to1 = 0;
                n2to5 = 0;
                n6to15 = 0;
                n16to30 = 0;
                n31to60 = 0;
                n61to120 = 0;
                n121plus = 0;
        }
    }
*/    

    public CommunityLandingController() {
        showServiceRequest = false;
        
        try {
            hsrUpg_Status = ApexPages.currentPage().getParameters().get('hsrUpg');
        } catch(Exception e) {
            hsrUpg_Status = '';
        }
                
        try {
            User thisUser = [SELECT ContactID FROM User WHERE ID = : UserInfo.getUserID()];
            Contact thisContact = [SELECT Account.Name, Account.ID FROM Contact WHERE ID = : thisUser.ContactID];
            customerID = thisContact.Account.ID;
            Integer totalCustomerEnvs = database.countQuery('SELECT COUNT() FROM Hosted__c WHERE Customer__c = \'' + customerID + '\'');
            if(totalCustomerEnvs > 0) {
                showServiceRequest = true;
                customerEnvironmentCount = totalCustomerEnvs;
    
                nextMandatory = '10.30';
                prepUpgradeBox();
                
                //They're hosted, but are they on credit stop?
                Account thisAccount = [SELECT Credit_Hold__c FROM Account WHERE ID = : customerID];
                if(thisAccount.Credit_Hold__c) {
                    hsr_CreditStop = true;
                }
//                environmentsToBookCount = 0;
            }
        } catch(Exception e) {
            //getting hsr stuff failed
            showServiceRequest = false;
        }
        
        /*for(List<PermissionSetAssignment> PSA : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'Community_Create_Service_Request']) {
            if (!PSA.isEmpty()) {
                showServiceRequest = true;
            }
            
        }*/
    }
    
    public static string getCustomerName() {    
        system.debug('Customer Name User Type ['+UserInfo.getUserType()+'] user ID ['+UserInfo.getUserId() +']');
        if (UserInfo.getUserType() != 'Standard') {
                list<User> user = [Select u.Id, u.ContactID From User u where id = : UserInfo.getUserId() limit 1 ];
                if (!user.IsEmpty()) {
                        list<Contact> contact = [Select c.Id, c.Account.Name From Contact c where id = : user[0].ContactID limit 1]; 
                        if (!contact.IsEmpty()) {
                                return contact[0].Account.Name; 
                        } else {
                                return '';
                        }                       
                } else  {
                        return '';
                }
        } else {
                return '';
        }       
    }
    
    public Decimal getReferencePoint()
    {
        if (UserInfo.getUserType() != 'Standard') {
            List<User> user = [ SELECT Id, ContactId from User where Id = :Userinfo.getUserId() Limit 1 ];
            if(!user.isEmpty())
            {
                List<Contact> contact = [Select /*Account.Reference_Points__c, */ Account.Reference_Balance__c From Contact where id = : user[0].ContactID limit 1]; 
                if (!contact.IsEmpty()) 
                {
                    /*if (contact[0].Account.Reference_Points__c == null || contact[0].Account.Reference_Points__c == 0) {
                        return 0.0;
                    }
                    else {
                        return contact[0].Account.Reference_Points__c;
                    }*/
                    return contact[0].Account.Reference_Balance__c;
                } 
                else 
                {
                    return 0.0;
                }
            }
            else
            {
                return 0.0;
            } 
        }
        return 0.0;
    }
    
    public string getCustomer() {
        return CommunityLandingController.getCustomerName();
    }
    
/*------------  Retired 23-12-2015 ------------ */
/*
    public List<Data> getC1Data() {
        return CommunityLandingController.getChart1Data();
    }
    
    public List<Data> getC2Data() {
        return CommunityLandingController.getChart2Data();
    }
    
    // Make the chart data available via JavaScript remoting
    @RemoteAction
    public static List<Data> getRemoteData() {
        return CommunityLandingController.getChart1Data();
    }
    
    public static CaseAges calculateChartDataOpen() {
        CaseAges caseAges = new CaseAges();  
        for (Case theCase : [select id, Case_Age__c, Status from Case where Status != 'Closed' and CreatedDate > : system.today().addMonths(-12)  ] ) {
                if (theCase.Case_Age__c < 2) {
                        caseAges.n0to1++;
                } else if (theCase.Case_Age__c >= 2 && theCase.Case_Age__c <= 5) {
                        caseAges.n2to5++;
                } else if (theCase.Case_Age__c >= 6 && theCase.Case_Age__c <= 15) {
                        caseAges.n6to15++;
                } else if (theCase.Case_Age__c >= 16 && theCase.Case_Age__c <= 30) {
                        caseAges.n16to30++;
                } else if (theCase.Case_Age__c >= 31 && theCase.Case_Age__c <= 60) {
                        caseAges.n31to60++;
                } else if (theCase.Case_Age__c >= 61 && theCase.Case_Age__c <= 120) {
                        caseAges.n61to120++;
                } else {
                        caseAges.n121plus++;
                }
        }
        return caseAges; 
    }
    
    
    public static CaseAges calculateChartDataClosed() {
        CaseAges caseAges = new CaseAges();  
        for (Case theCase : [select id, Case_Age__c from Case where Status = 'Closed' and  CreatedDate > : system.today().addMonths(-12) ] ) {
                if (theCase.Case_Age__c < 2) {
                        caseAges.n0to1++;
                } else if (theCase.Case_Age__c >= 2 && theCase.Case_Age__c <= 5) {
                        caseAges.n2to5++;
                } else if (theCase.Case_Age__c >= 6 && theCase.Case_Age__c <= 15) {
                        caseAges.n6to15++;
                } else if (theCase.Case_Age__c >= 16 && theCase.Case_Age__c <= 30) {
                        caseAges.n16to30++;
                } else if (theCase.Case_Age__c >= 31 && theCase.Case_Age__c <= 60) {
                        caseAges.n31to60++;
                } else if (theCase.Case_Age__c >= 61 && theCase.Case_Age__c <= 120) {
                        caseAges.n61to120++;
                } else {
                        caseAges.n121plus++;
                }
        }
        return caseAges; 
    }
    
    
    public static integer calculateChartData2() {
        integer caseCount = 0; 
        for (Case theCase : [select id, Case_Age__c from Case where CreatedDate < : system.today().addMonths(-12) ] ) {
                caseCount++;
        }       
        return caseCount; 
    }  

    // The actual chart data; needs to be static to be
    // called by a @RemoteAction method
    public static List<Data> getChart1Data() {
        
        CaseAges theCaseAgesOpen = new CaseAges();
        CaseAges theCaseAgesClosed = new CaseAges();
        
        theCaseAgesOpen = calculateChartDataOpen();
        theCaseAgesClosed = calculateChartDataClosed();    
        
        List<Data> data = new List<Data>();  
         
        data.add(new Data('0-1', 0, theCaseAgesClosed.n0to1, theCaseAgesOpen.n0to1));
        data.add(new Data('2-5', 0, theCaseAgesClosed.n2to5, theCaseAgesOpen.n2to5));
        data.add(new Data('6-15', 0, theCaseAgesClosed.n6to15, theCaseAgesOpen.n6to15));
        data.add(new Data('16-30', 0, theCaseAgesClosed.n16to30, theCaseAgesOpen.n16to30));
        data.add(new Data('31-60', 0, theCaseAgesClosed.n31to60, theCaseAgesOpen.n31to60));
        data.add(new Data('61-120', 0, theCaseAgesClosed.n61to120, theCaseAgesOpen.n61to120));
        data.add(new Data('> 120', 0, theCaseAgesClosed.n61to120, theCaseAgesOpen.n61to120));
       
        return data;
    }
    
    public static List<Data> getChart2Data() { 
        List<Data> data = new List<Data>();        
            data.add(new Data('> 1 Year', 0, 0, calculateChartData2()));
        return data;
    }
    
    // Wrapper class
    public class Data {
        public String name { get; set; }
        public Integer data1 { get; set; }
        public Integer data2 { get; set; }
        public Integer data3 { get; set; }
        public Data(String name, Integer data1, Integer data2, Integer data3) {
            this.name = name;
            this.data1 = data1;
            this.data2 = data2;
            this.data3 = data3;
        }
    }
*/
    
    /** oe:gen 23-12-2015 **/
    public static List<Case> getCases() {
        List<Case> cases = new List<Case>();
        if (UserInfo.getUserType() != 'Standard') {
            // get the User's AccountId via the User's Contact record
            List<User> user = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(!user.isEmpty())
            {
                // get a list of cases related to the User's Account
                cases = [SELECT Id, CaseNumber, Subject FROM Case WHERE IsClosed = False AND AccountId = :user[0].Contact.AccountId ORDER BY CaseNumber DESC LIMIT 10];
            }
        }
        return cases;
    }
    
    public Date serviceDate {get;set;}
    public String upg_Start_Date {get;set;}
    public String upg_End_Date {get;set;}
    
    //Mandatory Upgrades - Hosted Service Requests
    public PageReference bookMandatoryUpgrades() {
        //serviceDate = Date.parse(ApexPages.currentPage().getParameters().get('upgDate'));
        
        PageReference returnPage = ApexPages.currentPage();
        Boolean isFault = false;
        
        try {
            for(SelectOption thisEnv : targetEnvironments) {
                Hosted_Service_Request__c thisRequest = New Hosted_Service_Request__c();
                thisRequest.srType__c = 'Upgrade';
                thisRequest.srStatus__c = 'Pending Approval';
                thisRequest.srDate__c = serviceDate;
                thisRequest.upg_TrentVersion__c = '10.30';
                thisRequest.srCustomer__c = customerID;
                thisRequest.srEnvironment__c = thisEnv.getValue();
                thisRequest.srTermsAndConditions__c = ' Cloud Services will upgrade the selected environment to major release 10.30. This involves upgrading both the application and database and propagating these changes to the web server, and then restoring any customisation – please note that due to changes in the file structures any previous customisation to language files (*.json) or css files (*.css) will not be carried over.<br><br>If this is the first environment to be upgraded it will be patched to include all released service packs and patches. Subsequent environments will be patched to match the first environment.<br>If applicable your Business Objects universe will also be updated to the latest release.<br><br>The upgrade will begin at 08:00 and will be offline for the entire working day. Following the upgrade Cloud Services will test connectivity to the environment; any other testing will be completed by the customer. <br><br>Upgrades scheduled for future upgrade cycles are subject to change and may require Cloud Services to contact you to reschedule should issues arise with your requested date.<br><br>(Please Note: where approval is given to perform a change in Live this will be taken as confirmation that the customer has either performed UAT in a non-live environment or has deemed UAT not applicable and accepts the change directly into Live)';
                insert thisRequest;
                
                Hosted_Service_Request__c tmpSR = [SELECT Name from Hosted_Service_Request__c WHERE ID = : thisRequest.ID];
                tmpSR.srRealName__c = tmpSR.Name;
                update tmpSR;
            }
        } catch(Exception e) {
            //there was a failure!!!
            returnPage.getParameters().put('hsrUpg', 'fault');
            isFault = true;
        }
        
        if(!isFault) {
            returnPage.getParameters().put('hsrUpg', 'complete');
        }
        
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    public void upgGrabDate() {
        //serviceDate = Date.parse(ApexPages.currentPage().getParameters().get('upgDate'));
        System.debug('got ' + serviceDate + ' as parameter');
    }
    
    public String upgBoxText {get;set;}    
    public void prepUpgradeBox() {
        upg_Start_Date = '06/12/2018';
        upg_End_Date = '28/02/2019';
    
        Custom_Settings__c settings = [SELECT settingSREnabled__c, settingCopyTC__c, settingPatchTC__c, settingUpgradeTC__c, settingNonLiveMargin__c, settingUpgradeMargin__c, settingEndDate__c FROM Custom_Settings__c WHERE settingIdentifier__c = 'HSR' LIMIT 1];
        Decimal upgradeMargin = settings.settingUpgradeMargin__c;
        Date maxEndDate = settings.settingEndDate__c;
        
        DateTime dateToday = DateTime.now();
        
        upgBoxText = 'iTrent ' + nextMandatory + ' is available from 01/12/2018. This is a mandatory release, required to be installed by 28/02/2019 for both continued support and legislative compliance.';
        
        if(dateToday.month() == 2 && dateToday.year() == 2019) {
            maxEndDate = maxEndDate.addMonths(1);
            upg_End_Date = '31/03/2019';
            upgBoxText = 'iTrent ' + getLastMandatory() + ' has been available since 01/12/2019. It is a mandatory release, required to ensure you can clear down into the next financial tax year. Bookings can now be made until the end of March.';
            upgBoxText = upgBoxText + ' 10.30 must be installed before the end of March.';
        }
        
        dateToday = DateTime.newInstanceGmt(dateToday.year(), dateToday.month(), 00);
        Long currentDay = 0;
        Long daysBetween = 0;
        DateTime dateLimit = DateTime.newInstanceGmt(maxEndDate.year(), maxEndDate.month(), maxEndDate.day());
        debugString += dateLimit.getTime() + '<br />';
        debugString += dateToday.getTime() + '<br />';
        daysBetween = (((((dateLimit.getTime() - dateToday.getTime()) / 1000) / 60) / 60) / 24);
        
        List<Date> bankHolidayDates;
        bankHolidayDates = new List<Date>();
        for(List<Bank_Holidays__c> bankHolidays : [SELECT Bank_Holiday_Date__c, Bank_Holiday_Name__c FROM Bank_Holidays__c]) {
            for(Bank_Holidays__c holiday : bankHolidays) {
                bankHolidayDates.add(holiday.Bank_Holiday_Date__c);
            }
        }
    
        targetEnvironments = new List<SelectOption>();
        serviceDates = new List<SelectOption>();
        
        for(List<Hosted__c> environment : [SELECT ID, Environment_Name__c, Environment_Type__c FROM Hosted__c WHERE Customer__c = : customerID AND Environment_OptOut__c = FALSE]) {
            for(Hosted__c env : environment) {
                //targetEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));
                //Is there a 10.22 upgrade csheduled for this env?
                Boolean addEnvironment = false;
                try {
                    Hosted_Service_Request__c thisUpg = [SELECT ID, upg_TrentVersion__c, srType__c, srStatus__c FROM Hosted_Service_Request__c WHERE srEnvironment__c = : env.ID AND upg_TrentVersion__c = '10.30' LIMIT 1];
                    if(thisUpg.srStatus__c == 'Complete' || thisUpg.srStatus__c == 'Scheduled' || thisUpg.srStatus__c == 'Approved' || thisUpg.srStatus__c == 'Pending Approval') {
                        //upgrade for this environment scheduled - ignore.
                    } else {
                        addEnvironment = true;
                    }
                } catch(Exception e) {
                    //If we get here, the select failed and there is no upgrade.
                    addEnvironment = true;
                }
                
                if(addEnvironment) {
                    targetEnvironments.add(new SelectOption(env.ID, env.Environment_Name__c));    
                }
            }
        }
        environmentsToBookCount = 0;
        Boolean isLive = false;
        upgradeMiniTerms = 'The following environments will be upgraded to iTrent version 10.30 on the <span id="upg-date"></span>: <br /><ul>';
        for(SelectOption thisEnv : targetEnvironments) {
            Hosted__c thisE = [SELECT Environment_Name__c, Environment_Type__c FROM Hosted__c WHERE ID = : thisEnv.getValue()];
            if(thisE.Environment_Type__c == 'Live') {
                isLive = true;
            }
            upgradeMiniTerms += '<li>' + thisE.Environment_Name__c + '</li>';
            environmentsToBookCount ++;
        }
        upgradeMiniTerms += '</ul>';
        
        if(isLive) {
            upgradeMiniTerms += '<strong>These upgrades include a Live environment.</strong> By clicking the \'Book Upgrades\' button, it  will be taken as confirmation that ' + getCustomerName() + ' has either performed UAT in a non-live environment or has deemed UAT not applicable and accepts the change directly into Live.';
        }
        
        bookingString = '';
        if(environmentsToBookCount == customerEnvironmentCount) {
            bookingString = 'Use the form below to book all ' + environmentsToBookCount + ' environments';
        } else {
            bookingString = 'Use the form below to book your remaining ' + environmentsToBookCount + ' environment';
            if(environmentsToBookCount > 1) bookingString += 's';
        }
        
        Date cDate = Date.newInstance(dateToday.year(), dateToday.month(), dateToday.day());
        List<Hosted_Service_Request__c> existingSR = [SELECT srDate__c FROM Hosted_Service_Request__c WHERE srDate__c >= : cDate AND srType__c = 'Upgrade' AND srStatus__c != 'Rejected' AND srStatus__c != 'Cancelled'];
        
        DateTime REALdateToday = DateTime.now();
        List<Service_Request_Availability_Schedule__c> serviceRequestMax;        
        serviceRequestMax = new List<Service_Request_Availability_Schedule__c>();
        serviceRequestMax = [SELECT sra_CopyAM__c, sra_CopyPM__c, sra_EffectiveDate__c, sra_PatchAM__c, sra_PatchPM__c, sra_Upgrades__c FROM Service_Request_Availability_Schedule__c WHERE sra_EffectiveDate__c < : maxEndDate];
        
        debugString += 'There are currently ' + existingSR.size() + ' existing upgrades.';
        
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
            
            if((maxSR - srOnThisDay) < environmentsToBookCount) {
                //not enough slots available
                continue;
            } 
            
            if(currentDate < REALdateToday) {
                debugString = debugString + ' === Ignoring date ' + currentDate + ' as it is in the past<br />';
                continue; //this is in the past
            }
            
            if(isReleaseMonth(currentDate.month())) {
                //This is a release month. Let's make sure we're adding the appropriate margins.
                debugString = debugString + '<br />' + currentDate.month() + ' is a release month';
                debugString = debugString + ' when checking ' + currentDate;
                if(marginValue <= upgradeMargin) {
                    debugString = debugString + '<br />### SKIPPING (upg margin: ' + upgradeMargin + ' | marginValue: ' + marginValue + ')';
                    continue;
                }
            }
            
            serviceDates.add(new SelectOption(dateString, dateString + ' (' + (maxSR - srOnThisDay) + ' slots remaining)'));
            serviceDateList = serviceDateList + dateString + ',';
        }      
    }
    
    private boolean isReleaseMonth(Integer month) {
        Integer[] releaseMonths = new Integer[]{3, 6, 9, 12};
        
        for(Integer m : releaseMonths) {
            if(m == month) return true;
        }
        
        return false;
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
}