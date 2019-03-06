@isTest 
public class TestCX2 
{

    @isTest static void TestingCX()
    {   
    	//Create Account
        Account acct = new Account();
        acct.name='TestTriggers';
        acct.Type = 'Customer';
        //acct.Project_Manager__c = 'Testing PM';
        //acct.Business_Development_Manager__c = 'Testing BDM';
        insert acct;
        Account mhrAcct = new Account();
        mhrAcct.Name='MHR';
        mhrAcct.Type = 'Customer';
        insert mhrAcct;
        //Create Contact;
        Contact cont = new Contact();
        cont.Salutation = 'Mr.';
        cont.FirstName = 'Test_FirstName';
        cont.LastName = 'Test_LastName';
        cont.email = 'test@test.co.uk';
        cont.Phone = '0';
        cont.AccountId = mhrAcct.Id;                            
        insert cont;
        
                //Create Contact with surveys;
        Contact contwith = new Contact();
        contwith.Salutation = 'Mr.';
        contwith.FirstName = 'withSurvey1FN';
        contwith.LastName = 'withSurvey1LN';
        contwith.email = 'withsurvey@test.co.uk';
        contwith.Phone = '0';
        contwith.Include_in_Surveys__c = true;
        contwith.AccountId = acct.Id;                            
        insert contwith;     
                //Create Contact without surveys;
        Contact contNone = new Contact();
        contNone.Salutation = 'Mr.';
        contNone.FirstName = 'withoutSurvey1FN';
        contNone.LastName = 'withoutSurvey1LN';
        contNone.email = 'withoutsurvey@test.co.uk';
        contNone.Phone = '0';
        contNone.AccountId = acct.Id;                            
        insert contNone;     
        //Create hosted service request
        Hosted_Service_Request__c hsr = new Hosted_Service_Request__c();
        hsr.srStatus__c = 'Pending Approval';
        hsr.srDate__c = date.newInstance(2017,08,18);
        hsr.srCustomer__c = acct.id;
        hsr.srApprover__c = cont.id;
        hsr.srType__c = 'Upgrade';
        insert hsr;
        hsr.srOwner__c = '005b0000003gwdn';
        hsr.srStatus__c = 'Complete';
        update hsr;
        //Create a project
        pse__proj__c Proj = new pse__proj__c();
        Proj.Name = 'RGHTestInsert';
        Proj.pse__Project_Phase__c = 'Phase 1';
        Proj.pse__Project_Type__c = 'SD - Customer Project';
        Proj.pse__is_active__c = True;
        Proj.pse__Account__c = acct.id;
        Proj.Client_Project_Manager__c = cont.id;
        Proj.pse__Project_Manager__c = cont.id;
        Proj.Project_Initiation_Meeting_Date__c = date.newInstance(2017,08,18);
        insert Proj;
        Proj.CX_Start__c = True;
		Proj.pse__Stage__c = 'System Design';
		update Proj;  
        Proj.pse__Stage__c = 'UAT';
        update Proj;  
        Proj.pse__Stage__c = 'Parallel Run 1';      
		update Proj;
        Proj.pse__Stage__c = 'Project Closed';
        Proj.pse__End_Date__c = date.newInstance(2017,08,18);
        update Proj;
         //Create a project (strategic)
        pse__proj__c Proj2 = new pse__proj__c();
        Proj2.Name = 'RGHTestInsert2';
        Proj2.pse__Project_Phase__c = 'Phase 1';
        Proj2.pse__Project_Type__c = 'Strategic Customer Project';
        Proj2.pse__is_active__c = True;
        Proj2.pse__Account__c = acct.id;
        Proj2.Client_Project_Manager__c = cont.id;
        Proj2.pse__Project_Manager__c = cont.id;
        Proj2.Project_Initiation_Meeting_Date__c = date.newInstance(2017,08,18);
        insert Proj2;
        Proj2.CX_Start__c = True;
		Proj2.pse__Stage__c = 'Start Up';
		update Proj2;  
        Proj2.pse__Stage__c = 'UAT';
        update Proj2;  
        Proj2.pse__Stage__c = 'Go-Live';      
		update Proj2;
        Proj2.pse__Stage__c = 'Project Closed';
        Proj2.pse__End_Date__c = date.newInstance(2017,08,18);
        update Proj2;   
    }
}