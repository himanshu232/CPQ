global with sharing class PS_BudgetsListController {
    global string customerID {get;set;}
    global List<pse__Budget__c> existingBudgets {get;set;}
    public PS_BudgetsListController() {
        existingBudgets = new list<pse__Budget__c>();
        existingBudgets = [SELECT NAME,OA_Number__c,Sales_Price__c,Total_Days__c,Days_Planned_in_Schedule_2__c,	Days_Remaining_to_be_Used__c 
                           FROM pse__Budget__c  WHERE pse__Account__c = : customerID];
        
        
    }
}