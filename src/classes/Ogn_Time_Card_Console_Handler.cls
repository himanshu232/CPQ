///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Class: Ogn_Time_Card_Console_Handler
    // Unit Test: Ogn_Time_Card_Console_Handler_Test
    // - Author: AHA 𝝺
    // - Company: Oegen Ltd
    // - Created: 20/03/2018
    // - Description:
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
    
public class Ogn_Time_Card_Console_Handler {
    
    // - AHA - Declaration of variables
    public List<Time_Card__c> stillRunningTimeCards { get; set; }
    public List<Time_Card__c> timeCards { get; set; }
    public List<Time_Card__c> currnetTimeCards { get; set; }
    public String currentActivity { get; set; }
    public String ActivityName { get; set; }
    public String EndDatetime { get; set; }
    public String CustomerName { get; set; }
    public String StageName { get; set; }
    public String ScheduleName { get; set; }
    public Boolean runningTimecard { get; set; }
    public Boolean notRunningTimecard { get; set; }
    public Time_Card__c timeC { get; set; }
    public String timeCId { get; set; }
    public String timeCStart { get; set; } 
    public String timeCEnd { get; set; }
    
    // - AHA - Constructor
    public Ogn_Time_Card_Console_Handler(ApexPages.StandardController controller){
        
        // - AHA - Fields are added to the standard controller to be available in the rest of the class.
        if(!Test.isRunningTest()){
        	controller.addFields(new List<String>{'Activity__c', 'Account__c', 'Payroll_Stage__r.Stage__c', 'Schedule_Name__c', 'End_Date_Time__c'});
        }
        
        // - AHA - Retrieve the current activity
        Payroll_Activities__c act = (Payroll_Activities__c)Controller.getRecord();
        
        // - AHA - Assign Local variables
        currentActivity = act.Id;
        ActivityName = act.Activity__c;
        CustomerName = act.Account__c;
        Datetime endPreProcess = act.End_Date_Time__c;
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
        EndDatetime = day + '-' + month + '-' + endPreProcess.year() + ' at ' + hour + ':' + min; 
        StageName = act.Payroll_Stage__r.Stage__c;
        ScheduleName = act.Schedule_Name__c;
        String currentUser = UserInfo.getUserId();
        
        // - AHA - Use SOQL to retrieve in progress and closed timecards for display in the VF page
        stillRunningTimeCards = [SELECT Id, Activity__c, Start__c, End__c, Time_Card_Duration__c, Name, Start_Text__c, Account__c, Activity__r.Schedule_Name__c, Mentored_Activity__c, Re_work__c, Has_Notes__c, Activity__r.Activity__c, Activity__r.Payroll_Stage__r.Stage__c FROM Time_Card__c WHERE Start__c != null AND LastModifiedById = :currentUser AND End__c = null AND Activity__c != :currentActivity];
        timeCards = [SELECT Id, Activity__c, Start__c, End__c, Time_Card_Duration__c, Name, Start_Text__c, Account__c, Activity__r.Schedule_Name__c, Mentored_Activity__c, Re_work__c, Has_Notes__c, Activity__r.Activity__c, Activity__r.Payroll_Stage__r.Stage__c FROM Time_Card__c WHERE Start__c != null AND LastModifiedById = :currentUser AND End__c != null ORDER BY Start__c DESC LIMIT 25];
        currnetTimeCards = [SELECT Id, Activity__c, Start__c, End__c, Time_Card_Duration__c, Name, Start_Text__c, Account__c, Activity__r.Schedule_Name__c, Mentored_Activity__c, Re_work__c, Has_Notes__c, Activity__r.Activity__c, Activity__r.Payroll_Stage__r.Stage__c FROM Time_Card__c WHERE Start__c != null AND LastModifiedById = :currentUser AND End__c = null AND Activity__c = :currentActivity];
       
        
        
        If(!stillRunningTimeCards.isEmpty()){
            runningTimecard = true;
            notRunningTimecard = false;
        }
        else{ 
            runningTimecard = false;
            notRunningTimecard = true;
        }
        
        If(!currnetTimeCards.isEmpty()){
            runningTimecard = true;
            notRunningTimecard = false;
        }
    }
    
    // - AHA - This is used to stop the current timecard using the 'Stop' Button
    public PageReference stopTimecard(){
        
        Time_Card__c tcc = new Time_Card__c(id=timeCId);
        Datetime dt = Datetime.now();
        System.debug('AHA - Debug - StartTime of Timecard being stopped: - ' + tcc.Start__c);
        tcc.End__c = DateTime.newInstance(dt.year(), dt.month(), dt.day(), dt.hour(), dt.minute(), 59);
        System.debug('AHA - Debug - EndTime of Timecard being stopped: - ' + tcc.End__c);
        update tcc;   
        
        PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(true);
        return tempPage;
    }
     
    
    public PageReference saveTC(){ 
        Time_Card__c tcc = new Time_Card__c(id=timeCId);
        //Timezone is Currently in BST
        if(Datetime.now().time() != Datetime.now().timeGMT()){
            Datetime dt = Datetime.valueofGMT(timeCStart);
        	tcc.Start__c= DateTime.newInstancegmt(dt.yeargmt(), dt.monthgmt(), dt.daygmt(), dt.hourgmt(), dt.minutegmt(), 00);
            if(timeCEnd != null && timeCEnd != ''){
                tcc.End__c=DateTime.valueofGMT(timeCEnd);
            }
            update tcc;
            PageReference tempPage = ApexPages.currentPage();            
            tempPage.setRedirect(true);
            return tempPage;
        }
        //Timezone is Currently in GMT
        else{
            Datetime dt = Datetime.valueof(timeCStart);
        	tcc.Start__c = DateTime.newInstance(dt.year(), dt.month(), dt.day(), dt.hour(), dt.minute(), 00);
            if(timeCEnd != null && timeCEnd != ''){
                tcc.End__c=DateTime.valueof(timeCEnd);
            }
            update tcc;
            PageReference tempPage = ApexPages.currentPage();            
            tempPage.setRedirect(true);
            return tempPage;
        }
        
    }
    
    public void donothing2(){
        
    }
    
    public PageReference createTimecard(){
        Time_Card__c tcToIns = new Time_Card__c();
        tcToIns.Start__c = Datetime.now();
        tcToIns.Activity__c = currentActivity;
        if(tcToIns.Activity__c != null && tcToIns.Start__c != null){
        	insert tcToIns;
        }
        PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(true);
        return tempPage;
    }
}