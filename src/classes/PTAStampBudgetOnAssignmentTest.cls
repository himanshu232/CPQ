@isTest
public class PTAStampBudgetOnAssignmentTest {
    @isTest static void TestPutAssignmentOnProjectTaskAssignment(){
        //Create work calendar
        Profile p = [SELECT ID FROM Profile WHERE NAME = 'System Administrator'];
        //Create Region
        pse__region__c parentRegion = new pse__Region__c(Name = 'UK');
        insert parentRegion;
        pse__Region__c region = new pse__Region__c(Name = 'Test') ;
        region.pse__parent_region__c = parentRegion.id;
        insert region;
        User u = new User(Alias = 'Test',email = 'test@mhr.co.uk',emailEncodingKey = 'UTF-8',LastName = 'Test',LanguageLocalekey = 'en_US',ProfileID = p.ID
                          ,userName = 'Test@mhr.co.uk'
                         );
        u.CommunityNickname = 'TestMHR';
        u.TimeZoneSidKey = 'Europe/London';
        u.LocaleSidKey = 'en_US';
        insert u;
        pse__Permission_Control__c PC = New pse__Permission_Control__c(pse__User__c = u.id,pse__Region__c = region.Id,pse__Staffing__c = True,pse__Cascading_Permission__c = True,
                                                                       pse__Resource_Request_Entry__c = True);
        insert PC;
        system.runAs(u){ pse__Work_Calendar__c wc = new pse__Work_Calendar__c();
                        System.debug('Current User: ' + UserInfo.getUserName());
                        wc.pse__Monday_Hours__c = 6;
                        wc.pse__Tuesday_Hours__c = 6;
                        wc.pse__Wednesday_Hours__c = 6;
                        wc.pse__Thursday_Hours__c = 6;
                        wc.pse__Friday_Hours__c = 6;
                        wc.name = 'UK 6 Hours';
                        insert wc; 
                        //Create Account
                        Account acct = new Account();
                        acct.name='TestTrigger';
                        acct.Type = 'Customer';
                        insert acct;
                        
                        //Create Contact;
                        Contact cont = new Contact();
                        cont.LastName = 'Test_LastName3';
                        cont.AccountId = acct.Id;
                        cont.Active__c = True;
                        cont.pse__Is_Resource__c = True;
                        cont.pse__Is_Resource_Active__c = True;
                        cont.pse__Work_Calendar__c = wc.id;
                        cont.pse__Region__c = region.id;
                        insert cont;
                        
                        //Create a project
                        pse__proj__c Proj = new pse__proj__c(Name = 'IAJTestInsert',pse__is_active__c = True);
                        proj.pse__work_calendar__c = wc.Id;
                        proj.pse__Region__c =  region.id;     
                        insert Proj;
                        
                        //Create Schedule
                        pse__Schedule__c Sched = new pse__Schedule__c(pse__Start_Date__c = date.parse('01/01/2017'),pse__End_Date__c = Date.parse('12/31/2017'),pse__Monday_Hours__c = 6,
                                                                      pse__Tuesday_Hours__c = 6,
                                                                      pse__Wednesday_Hours__c = 6,
                                                                      pse__Thursday_Hours__c = 6,
                                                                      pse__Friday_Hours__c = 6,
                                                                      pse__Saturday_Hours__c = 0,
                                                                      pse__Sunday_Hours__c = 0);
                        insert Sched;
                        //Create assignment
                        pse__Assignment__c Assignt = new pse__Assignment__c (Name ='IAJTest',pse__Resource__c = cont.id,pse__Schedule__c = Sched.ID,pse__Bill_Rate__c = 0
                                                                             ,pse__Project__c = Proj.ID);
                        insert Assignt;
                        //Add new budget
                        pse__Budget__c B = new pse__Budget__c(NAME = 'TestBudget',pse__project__c = proj.id);
                        B.Expiry_Date__c = Date.parse('01/01/2018');
                        B.Total_Days__c = 50;
                        insert B;
                        //Create a project task
                        pse__Project_Task__c PT = new pse__Project_Task__c(Name = 'IAJTest',pse__Project__c = Proj.ID);
                        PT.pse__Start_Date_Time__c = date.parse('06/06/2017');
                        PT.Budget__c = B.ID; 
                        PT.Resource__c = cont.id;
                        insert PT;
                        //Create Project Task Assignment
                        pse__Project_Task_Assignment__c PTA = new pse__Project_Task_Assignment__c(pse__Project_Task__c = PT.ID,pse__resource__c = cont.id);
                        PTA.Budget__c = B.ID;
                        test.startTest();
                        PTA.pse__Assignment__c = Assignt.ID;
                        insert PTA;
                        test.stopTest();
                        // add budget to Project Task
                        // PT.Budget__c= B.ID;
                        //update PT;
                       // PTA.Budget__c = B.id;
                        //PTA.pse__Assignment__c = Assignt.ID;
                        //update PTA;
                        
                       }                }
    
    
}