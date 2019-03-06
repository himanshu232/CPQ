///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Class: 
    // Unit Test:
    // - Author: AHA 𝝺
    // - Company: Oe:gen Ltd
    // - Created: 05/07/2018
    // - Description:
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
public class ActivitiesNewTab_Controller_Extension {

    public List<Payroll_Activities__c> sortedPayroll {get; set;}
    public String selectedFilterId { get; set; }
    public List<SelectOption> filters { get; private set; }
    public List<SelectOption> filters2 { get; set; }
    
    public ActivitiesNewTab_Controller_Extension(ApexPages.StandardSetController controller){
        
        // - AHA - Fields are added to the standard controller to be available in the rest of the class.
        if(!Test.isRunningTest()){
            controller.addFields(new List<String>{'Activity__c', 'Account__c', 'Payroll_Stage__r.Stage__c', 'Schedule_Name__c', 'End_Date_Time__c'});
        }
        
        // - AHA - Retrieve the current activity
        System.debug('AHA - Debug - TESTER: - ' + Controller.getRecords());
        //Payroll_Activities__c[] act = (Payroll_Activities__c)Controller.getRecords();
        
        List<Id> payrollIds = new List<Id>();
        
        //for(Payroll_Activities__c pra : act){
            //payrollIds.add(pra.Id);
        //}

        Map<String, String> listMap = new Map<String, String>();
        List<String> stringList = new List<String>(); 
        List<SelectOption> filters3 = new List<SelectOption>();

        filters = controller.getListViewOptions();
        for(SelectOption s : filters){
            if(s.getLabel() != null && s.getValue() != null){
                listMap.put(s.getLabel(), s.getValue());
                stringList.add(s.getLabel());
            }
        }
        
        if(stringList.size() > 0){
          	stringList.sort();
            for(string ss : stringList){
                if(listMap.get(ss) != null){
                    System.debug('AHA - ' + ss);
                    System.debug('AHA2 - ' + listMap.get(ss));
                    SelectOption SO = new SelectOption(listMap.get(ss),ss);
                    filters3.add(SO);
                    filters2 = filters3;
                }
            }
        }
        
        selectedFilterId = controller.getFilterId();
        
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Payroll_Activities__c');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('Fields_to_include_in_New_Activity_Tab');
        
        Schema.FieldSetMember[] see = fieldSetObj.getFields();
        List<String> fields = new List<String>();
        for(Schema.FieldSetMember fsm : see){
            fields.add(fsm.getFieldPath());
        }
        String subString;
        
        for(String s : fields){
            if(subString == null){
                substring = s;
            }
            else{
                substring = substring + ', ' + s;
            }
        }
        
        String query = 'SELECT Id, ' + subString + ' FROM  Payroll_Activities__c WHERE Id IN :payrollIds ORDER BY Activity_Start__c DESC';
        
        
        
        sortedPayroll = Database.query(query);
        
        
    }
}