@isTest(SeeAllData=true)
public class RHX_TEST_pse_Project_Task_Assignment {
	static testMethod void RHX_Testmethod() {
        Contact cc = new Contact();
        cc.LastName = 'Test';
        insert cc;
        pse__Proj__c y = new pse__Proj__c();
        y.Name = 'test';
        y.pse__Is_Active__c = true; 
        insert y;
        pse__Region__c r = new pse__Region__c();
        r.Name = 'UK';
        insert r;
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.pse__User__c = System.Userinfo.getUserId();
        pc.pse__Resource__c = cc.Id;
        pc.pse__Resource_Request_Entry__c = true;
        
        pse__Permission_Control__c pc2 = new pse__Permission_Control__c();
        pc2.pse__User__c = System.Userinfo.getUserId();
        pc2.pse__Region__c = r.id;
        pc2.pse__Resource_Request_Entry__c = true;
        
        pse__Permission_Control__c pc3 = new pse__Permission_Control__c();
        pc3.pse__User__c = System.Userinfo.getUserId();
        pc3.pse__Project__c = y.Id;
        pc3.pse__Resource_Request_Entry__c = true;
        insert pc;
        insert pc2;
        insert pc3;
        pse__Resource_Request__c b = new pse__Resource_Request__c();
     
        pse__Budget__c x = new pse__Budget__c(pse__Project__c = y.Id);
        insert x;
       
        b.Budget__c = x.Id;
        b.pse__End_Date__c = system.today();
        b.pse__SOW_Hours__c = 1;
        b.pse__Start_Date__c = system.today();
        b.pse__Project__c = y.Id;
        b.pse__Region__c = r.Id;
        
        insert b;
        pse__Project_Task__c c = new pse__Project_Task__c();
        c.Budget__c = x.Id;
        c.pse__Project__c = y.Id;
        c.Resource__c = cc.Id;
        insert c;
        List<sObject> sourceList = [SELECT Id 
			FROM pse__Project_Task_Assignment__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new pse__Project_Task_Assignment__c(pse__Resource__c = cc.Id, pse__Project_Task__c = c.Id)
                
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
    static testMethod void Oegen_Testmethod() {
        
        pse__Region__c r = new pse__Region__c();
        r.Name = 'UK';
        insert r;
        
        Contact cc = new Contact();
        cc.LastName = 'Test';
        insert cc;
        
        pse__Proj__c y = new pse__Proj__c();
        y.Name = 'test';
        y.pse__Is_Active__c = true; 
        insert y;
        
        pse__Budget__c x = new pse__Budget__c(pse__Project__c = y.Id);
        insert x;
        
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.pse__User__c = System.Userinfo.getUserId();
        pc.pse__Resource__c = cc.Id;
        pc.pse__Resource_Request_Entry__c = true;
        
        pse__Permission_Control__c pc2 = new pse__Permission_Control__c();
        pc2.pse__User__c = System.Userinfo.getUserId();
        pc2.pse__Region__c = r.id;
        pc2.pse__Resource_Request_Entry__c = true;
        
        pse__Permission_Control__c pc3 = new pse__Permission_Control__c();
        pc3.pse__User__c = System.Userinfo.getUserId();
        pc3.pse__Project__c = y.Id;
        pc3.pse__Resource_Request_Entry__c = true;
        insert pc;
        insert pc2;
        insert pc3;
        
        pse__Resource_Request__c b = new pse__Resource_Request__c();
        b.pse__End_Date__c = system.today();
        b.pse__SOW_Hours__c = 1;
        b.pse__Start_Date__c = system.today();
        b.pse__Project__c = y.Id;
        b.pse__Region__c = r.Id;
        insert b;
        
        pse__Project_Task__c c = new pse__Project_Task__c();
        c.Budget__c = x.Id;
        c.pse__Project__c = y.Id;
        c.Resource__c = cc.Id;
        insert c;
        
        pse__Project_Task_Assignment__c a = new pse__Project_Task_Assignment__c();
        a.pse__Resource__c = cc.Id;
        a.pse__Project_Task__c = c.Id;
        a.pse__Resource_Request__c = b.Id;
        b.Budget__c = null;
        insert a;
        
        b.Budget__c = null;
        update a;
    }
}