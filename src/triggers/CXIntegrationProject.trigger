trigger CXIntegrationProject on pse__Proj__c (before update)
{
    Integer idx = 0;    
    for(pse__Proj__c ProjList : Trigger.new)
    {
        pse__Proj__c OldProjList = Trigger.old[idx];
        
        // adjust for when triggers can run against projects from (based on Project Initiation Meeting Date & End Date)
        Date runCodeFrom = date.newInstance(2017,08,18);
        
        IF(ProjList.Client_Project_Manager__c != null && ProjList.pse__Account__c != null)
        {
            Account tmpAccount = [SELECT Name, Hosted_Midland__c, ID FROM Account WHERE ID = : ProjList.pse__Account__c];
            Contact tmpContact = [SELECT FirstName, LastName, Email FROM Contact WHERE ID = : ProjList.Client_Project_Manager__c];
            Contact tmpProjMan;
            IF(ProjList.pse__Project_Manager__c != null)
            {
                tmpProjMan = [SELECT Name FROM Contact WHERE ID = : ProjList.pse__Project_Manager__c];
            } ELSE {
                tmpProjMan = NEW Contact();
                
                 tmpProjMan.Salutation = 'Mr.';
                tmpProjMan.FirstName = 'Project';
                tmpProjMan.LastName = 'Manager';
            }
            
            List<Contact> tmpContactList = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = : ProjList.pse__Account__c AND Include_in_Surveys__c = TRUE AND ID <> : ProjList.Client_Project_Manager__c];
            
            IF(ProjList.pse__Project_Type__c == 'Strategic Customer Project') 
            {
                //Professional Services (Strategic) - Project Initiation survey
                IF(ProjList.CX_Sent_Initiation__c == False && ProjList.CX_Start__c == True && ProjList.pse__Stage__c == 'Start Up' && ProjList.Project_Initiation_Meeting_Date__c >= runCodeFrom)
                {
                    ProjList.CX_Sent_Initiation__c = True;
                    CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/6078617bc9541f70/replies', 'sKBoZy29o7dk32RFrtKf5m16', tmpContact.Email, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);
                    for(Contact c : tmpContactList){CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/6078617bc9541f70/replies', 'sKBoZy29o7dk32RFrtKf5m16', c.Email, c.FirstName, c.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);}  
                }
                //Professional Services (Strategic) - Mid-Project
                IF(ProjList.CX_Sent_UAT__c == False && ProjList.pse__Stage__c == 'UAT')
                {
                    ProjList.CX_Sent_UAT__c = True;
                    CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/a4a31c79e776223f/replies', 'M7esscJsdEpEjhkKJ4jtyeqk', tmpContact.Email, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);
                    for(Contact c : tmpContactList){CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/a4a31c79e776223f/replies', 'M7esscJsdEpEjhkKJ4jtyeqk', c.Email, c.FirstName, c.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);}
                }
                //Professional Services (Strategic) - Project Closedown
                IF(ProjList.CX_Sent_BAU__c == False && ProjList.pse__Stage__c == 'Go-Live')
                {
                    ProjList.CX_Sent_BAU__c = True;
                    CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/e377c12e7cbfa04d/replies', 'gBgTuTAcYjZtWtVy1wkXivhB', tmpContact.Email, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);
                    for(Contact c : tmpContactList){CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/e377c12e7cbfa04d/replies', 'gBgTuTAcYjZtWtVy1wkXivhB', c.Email, c.FirstName, c.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);}
                }
            }
            ELSE IF(ProjList.pse__Project_Type__c == 'SD - Customer Project')
            {        
                //Implementation: Project Initiation Meeting
                IF(ProjList.CX_Sent_Initiation__c == False && ProjList.CX_Start__c == True && ProjList.Project_Initiation_Meeting_Date__c >= runCodeFrom)
                {
                    ProjList.CX_Sent_Initiation__c = True;
                    CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/163380ae71150efc/replies', 'YBaaQiz1Jzr9dNxpVvp6swZJ', tmpContact.Email, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);
                    for(Contact c : tmpContactList){CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/163380ae71150efc/replies', 'YBaaQiz1Jzr9dNxpVvp6swZJ', c.Email, c.FirstName, c.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);}  
                }
                
                //Implementation: Design Sign-off survey
                IF(ProjList.CX_Sent_Design__c == False && OldProjList.pse__Stage__c == 'System Design' && ProjList.pse__Stage__c != 'Start Up' && ProjList.pse__Stage__c != 'System Design')
                {
                    ProjList.CX_Sent_Design__c = True;
                    CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/8ebb09baf060f058/replies', 'nNBszQxvGyhmBm9YTNhpPzdp', tmpContact.Email, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);
                    for(Contact c : tmpContactList){CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/8ebb09baf060f058/replies', 'nNBszQxvGyhmBm9YTNhpPzdp', c.Email, c.FirstName, c.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);}
                }
                
                //Implementation: Data/UAT survey
                IF(ProjList.CX_Sent_UAT__c == False && OldProjList.pse__Stage__c == 'UAT' && (ProjList.pse__Stage__c == 'Parallel Run 1' || ProjList.pse__Stage__c == 'Parallel Run 2' || ProjList.pse__Stage__c == 'Go-Live'))
                {
                    ProjList.CX_Sent_UAT__c = True;
                    CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/f40f90cc5f4d4b96/replies', 'Q4yzhM9aZuaBApuMwHgsmDqi', tmpContact.Email, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);
                    for(Contact c : tmpContactList){CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/f40f90cc5f4d4b96/replies', 'Q4yzhM9aZuaBApuMwHgsmDqi', c.Email, c.FirstName, c.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);}
                }
                
                //Implementation: BAU Handover survey
                IF(ProjList.CX_Sent_BAU__c == False && ProjList.pse__Stage__c == 'Project Closed' && ProjList.pse__End_Date__c >= runCodeFrom)
                {
                    ProjList.CX_Sent_BAU__c = True;
                    CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/7e70baabe8dbc94c/replies', 'rEK8bFd1Cm2FyjAV1BPRL4bD', tmpContact.Email, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);
                    for(Contact c : tmpContactList){CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/7e70baabe8dbc94c/replies', 'rEK8bFd1Cm2FyjAV1BPRL4bD', c.Email, c.FirstName, c.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), tmpProjMan.Name, ProjList.Business_Development_Manager__c, '', '', '', '', '', ProjList.ProjectManagerTeam__c);}
                }
            }
        }
        idx ++;
    }
}