public with sharing class community_DashboardsController {
    private User currentUser {get;set;}

    public community_DashboardsController() { 
        if (UserInfo.getUserType() != 'Standard') {
            this.currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        }
    }
    
    @RemoteAction
    public static List<donutData> getLoggedCaseStatusData(){
        Date lastThreeMonths = System.Today() - 90;
        List<Case> openCases = [SELECT Id FROM Case WHERE isClosed = false AND CreatedDate > :lastThreeMonths];
        List<Case> closedCases = [SELECT Id FROM Case WHERE isClosed = true AND CreatedDate > :lastThreeMonths];
        List<donutData> dataList = new List<donutData>();
        dataList.add(new donutData(openCases.size(), closedCases.size()));      
        return dataList;
    }
    
    @RemoteAction
    public static List<barData> getOpenCaseAgeData(){
        List<Case> allCases = new List<Case>();
        List<Case> band1 = new List<Case>();
        List<Case> band2 = new List<Case>();
        List<Case> band3 = new List<Case>();
        List<Case> band4 = new List<Case>();
        List<Case> band5 = new List<Case>();
        List<Case> band6 = new List<Case>();
        allCases = [SELECT Id, Age_service_desk__c  FROM Case WHERE isClosed = false];
        for(Case c : allCases)  {
            if(c.Age_service_desk__c == 'Same Day') {
                band1.add(c);
            }
            else if(c.Age_service_desk__c == '2-5') {
                band2.add(c);
            }
            else if(c.Age_service_desk__c == '6-15') {
                band3.add(c);
            }
            else if(c.Age_service_desk__c == '16-30') {
                band4.add(c);
            }
            else if(c.Age_service_desk__c == '31-120') {
                band5.add(c);
            }
            else if(c.Age_service_desk__c == '121+') {
                band6.add(c);
            }
        }
        
        List<barData> dataList = new List<barData>();
        dataList.add(new barData('Same Day', band1.size()));
        dataList.add(new barData('2-5', band2.size()));
        dataList.add(new barData('6-15', band3.size()));
        dataList.add(new barData('16-30', band4.size()));
        dataList.add(new barData('31-120', band5.size()));
        dataList.add(new barData('121+', band6.size()));
        return dataList;
    }
    
        
    /* We could've used an AggregateResult list if the Defect_Status__c field wasn't a formula field...
    @RemoteAction
    public static List<arDonutData> getAllDefectsLogged(){
        List<AggregateResult> arCaseList = [SELECT Count(Id) caseCount, Defect_Status__c status FROM Case
                                        GROUP BY Defect_Status__c];
        
        List<arDonutData> dataList = new List<arDonutData>();

        for(AggregateResult ar : arCaseList){
            Integer caseCount = Integer.valueOf(ar.get('caseCount'));
            String status = String.valueOf(ar.get('status'));
            dataList.add(new arDonutData(status, caseCount));
        }
        return dataList;
    }
    */
    
    @RemoteAction
    public static List<donutData> getAllDefectsLogged(){
        List<Case> allCases = new List<Case>();
        List<Case> outstanding = new List<Case>();
        List<Case> complete = new List<Case>();
        allCases = [SELECT Id, Defect__c, Defect_Status__c FROM Case WHERE Defect__c != null];
        for(Case c : allCases){
            if(c.Defect_Status__c == 'Outstanding') {
                outstanding.add(c);
            }
            else if(c.Defect_Status__c == 'Complete') {
                complete.add(c);
            }
        }
        List<donutData> dataList = new List<donutData>();
        dataList.add(new donutData(outstanding.size(), complete.size()));
        return dataList;
    }
    
    @RemoteAction
    public static List<barData> getClosedCaseAgeData(){
        Date twelveMonthsAgo = System.Today() - 365;
        List<Case> allCases = new List<Case>();
        List<Case> band1 = new List<Case>();
        List<Case> band2 = new List<Case>();
        List<Case> band3 = new List<Case>();
        List<Case> band4 = new List<Case>();
        List<Case> band5 = new List<Case>();
        List<Case> band6 = new List<Case>();
        allCases = [SELECT Id, Age_service_desk__c  FROM Case WHERE isClosed = true AND ClosedDate > :twelveMonthsAgo];
        for(Case c : allCases)  {
            if(c.Age_service_desk__c == 'Same Day') {
                band1.add(c);
            }
            else if(c.Age_service_desk__c == '2-5') {
                band2.add(c);
            }
            else if(c.Age_service_desk__c == '6-15') {
                band3.add(c);
            }
            else if(c.Age_service_desk__c == '16-30') {
                band4.add(c);
            }
            else if(c.Age_service_desk__c == '31-120') {
                band5.add(c);
            }
            else if(c.Age_service_desk__c == '121+') {
                band6.add(c);
            }
        }
        
        List<barData> dataList = new List<barData>();
        dataList.add(new barData('Same Day', band1.size()));
        dataList.add(new barData('2-5', band2.size()));
        dataList.add(new barData('6-15', band3.size()));
        dataList.add(new barData('16-30', band4.size()));
        dataList.add(new barData('31-120', band5.size()));
        dataList.add(new barData('121+', band6.size()));
        return dataList;
    }
    
   /* @RemoteAction
    public static List<arDonutData> getOld_Escalations(){
        List<AggregateResult> arEscalationList = [SELECT Count(Id) escalationCount, Status__c status FROM Old_Escalation__c
                                        GROUP BY Status__c];
        
        List<arDonutData> dataList = new List<arDonutData>();

        for(AggregateResult ar : arEscalationList){
            Integer escalationCount = Integer.valueOf(ar.get('escalationCount'));
            String status = String.valueOf(ar.get('status'));
            dataList.add(new arDonutData(status, escalationCount));
        }
        return dataList;
    }*/
    
    @RemoteAction
    public static List<barData> getFeedback(){
        List<Customer_Experience__c> allFeedback = new List<Customer_Experience__c>();
        List<Customer_Experience__c> rating1 = new List<Customer_Experience__c>();
        List<Customer_Experience__c> rating2 = new List<Customer_Experience__c>();
        List<Customer_Experience__c> rating3 = new List<Customer_Experience__c>();
        List<Customer_Experience__c> rating4 = new List<Customer_Experience__c>();
        List<Customer_Experience__c> rating5 = new List<Customer_Experience__c>();        
        
        allFeedback = [SELECT Id, Score__c FROM Customer_Experience__c WHERE Score__c != null];
        for(Customer_Experience__c ce : allFeedback){
            if(ce.Score__c == 'Very Satisfied') {
                rating1.add(ce);
            }
            else if(ce.Score__c == 'Satisfied') {
                rating2.add(ce);
            }
            else if(ce.Score__c == 'Neither Satisfied or Dissatisfied') {
                rating3.add(ce);
            }
            else if(ce.Score__c == 'Dissatisfied') {
                rating4.add(ce);
            }
            else if(ce.Score__c == 'Very Dissatisfied') {
                rating5.add(ce);
            }
        }
        
        List<barData> dataList = new List<barData>();
        dataList.add(new barData('Very Satisfied', rating1.size()));
        dataList.add(new barData('Satisfied', rating2.size()));
        dataList.add(new barData('Neither Satisfied or Dissatisfied', rating3.size()));
        dataList.add(new barData('Dissatisfied', rating4.size()));
        dataList.add(new barData('Very Dissatisfied', rating5.size()));
        return dataList;
        
        /* Superceded by the code above so that we always display all Score columns in the chart, even when there are zero Customer_Experience records with that Score.
        List<AggregateResult> arFeedbackList = [SELECT Count(Id) feedbackCount, Score__c rating FROM Customer_Experience__c
                                        GROUP BY Score__c];
        List<barData> dataList = new List<barData>();

        for(AggregateResult ar : arFeedbackList){
            Integer feedbackCount = Integer.valueOf(ar.get('feedbackCount'));
            String rating = String.valueOf(ar.get('rating'));
            dataList.add(new barData(rating, feedbackCount));
        }
        return dataList;
        */
            
        
    }
    
    public class barData{
        public String xAxisLabel {get;set;}
        public Integer Count {get;set;}
        public barData(String label, Integer count){
            this.xAxisLabel = label;
            this.Count = count;
        }
    }
    
    public class donutData{
        public Integer count1 {get;set;}
        public Integer count2 {get;set;}
        public donutData(Integer count1, Integer count2){
            this.count1 = count1;
            this.count2 = count2;
        }
    }
    
    public class arDonutData{
        public String Status {get;set;}
        public Integer Count {get;set;}
        public arDonutData(String status, Integer count){
            this.Status = status;
            this.Count = count;
        }
    }
    
    /*
    public static String monthFromInteger(Integer month){
        String s;
        s = month == 1 ? 'Jan' : s;
        s = month == 2 ? 'Feb' : s;
        s = month == 3 ? 'Mar' : s;
        s = month == 4 ? 'Apr' : s;
        s = month == 5 ? 'May' : s;
        s = month == 6 ? 'Jun' : s;
        s = month == 7 ? 'Jul' : s;
        s = month == 8 ? 'Aug' : s;
        s = month == 9 ? 'Sep' : s;
        s = month == 10 ? 'Oct' : s;
        s = month == 11 ? 'Nov' : s;
        s = month == 12 ? 'Dec' : s;
        return s;
    }
    */
}