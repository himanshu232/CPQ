global with sharing class CustomLogin_ServiceDesk_Controller {

    //constructor
    global CustomLogin_ServiceDesk_Controller (){
    }
    
    global string userName{get;set;}
    global string password{get;set;}
    
    global string debugInfo{get;set;}
    global string errorMsg{get;set;}

    global pageReference LoginCheck(){
        debugInfo = userName + '-'+ password;
        return null;
    }
    
    global PageReference forwardToCustomAuthPage() {
        return null;//new PageReference( '/CustomLogin_1');
    }
    
    global PageReference login() {
        pagereference chk = Site.login(username, password, null);
        //debugInfo = userName + '-'+ password + '-' + chk;
        if (chk!=null){
            list<User> user = [select id,Suspended_From_Portal__c from User where username =: username limit 1];
            if (user!=null && user.size()>0){
                if (user[0].Suspended_From_Portal__c==true){
                     //errorMsg = 'Access denied. You are suspended from portal access. Please contact administrator.';
                     errorMsg = Label.Service_Desk_User_Suspended;
                     return null;
                }
            }
        }else{
            //errorMsg = 'Your login attempt has failed. The username or password may be incorrect, or your location or login time may be restricted. Please contact the administrator at your company for help.';
            errorMsg = Label.Service_Desk_Login_Failed;
        }
        
        return Site.login(username, password, null);
    }

    global PageReference userSuspendedCheck() {
        return null;
    }
    
    
    
    public PageReference UserInput() {

    String BU_v = Apexpages.currentPage().getParameters().get('BU_v');
    
    // run the query again
    GO();
    
    return null;
    }
    
    
    public Void GO()
    
    {
         debugInfo = 'value from html input tag';   
    }
    
    
    

}