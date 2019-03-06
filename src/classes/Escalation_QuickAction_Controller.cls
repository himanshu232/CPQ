///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Class: Escalation_QuickAction_Controller
    // - Related VF Page: Escalation_QuickAction
    // - Author: AHA 𝝺
    // - Company: Oegen Ltd
    // - Created: 12/09/2017
    // - Description: This controller passes the VF page on load data and handles submission of Escalations from the quick action
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
public class Escalation_QuickAction_Controller {
 	// - Variables shared between the VF page and the controller
    public Escalation__c esc { get; set; }
    public Case linkedCase { get; set; }
    public Boolean alreadyExists { get; set; }
    public Boolean errorMessage { get; set; }
    public Boolean completeMessage { get; set; }
    
    // - Constructor for the VF page, this code executes on load of the VF page
    public Escalation_QuickAction_Controller(ApexPages.StandardController acon){
        
        // - Additional fields are added to the standard controller
        List<String> fieldstoAdd = new List<String>(); 
        fieldstoAdd.add('AccountId');
        fieldstoAdd.add('Escalation_Related_Department__c');
        fieldstoAdd.add('Case_Owner_for_Escalations__c');
        fieldstoAdd.add('ContactId');
        if(Test.isRunningTest() == false){
        	acon.addFields(fieldstoAdd);
        }
        
        // - The currently selected Case is loaded into the controller
        this.linkedCase = (Case) acon.getRecord();
        
        // - Check is performed for any existing escalations in the system for this case
        List<Escalation__c> escCheck = new List<Escalation__c>([SELECT Id FROM Escalation__c WHERE Case__c = :LinkedCase.Id]);
        
        if(escCheck.size() == 0){
            String userid = UserInfo.getUserId();
            User u = [SELECT Id, contactId FROM User WHERE Id = :userid LIMIT 1]; 
        
            // - New escalation is created
            this.esc = new Escalation__c();
            this.esc.Account__c = linkedCase.AccountId;
            this.esc.Case__c = linkedCase.Id;
            this.esc.Related_Department__c = linkedCase.Escalation_Related_Department__c;
            this.esc.Status__c = 'Open';
            this.esc.Owner__c = linkedCase.Case_Owner_for_Escalations__c;
            this.esc.Contact__c = linkedCase.contactId;
            this.esc.Escalated_By__c = u.contactId;
            
            this.alreadyExists = false;
        }
        else{
            this.alreadyExists = true;
        }
    }
    
    // - This method saves the escalation that was initialised on load - (fired by button on VF Page)
    public void saveEscalation(){
        try{
            insert esc;
            errorMessage = false;
            completeMessage = true;
            alreadyExists = true;
        }
        catch(exception e){
            System.debug('AHA - Debug - ' + e);
            errorMessage = true;
            alreadyExists = false;
        }
    }
    
    // - Redirects the User to an external link
    public PageReference redirectToLink(){
        String newPageUrl = '/apex/Escalation_Process?sfdc.tabName=01rb0000000I8M4';
        PageReference newPage = new PageReference(newPageUrl);
        newPage.setRedirect(true);
        return newPage;
        
    }
    
}