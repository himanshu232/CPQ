trigger QualtricsProjectsSurveys on pse__Proj__c (before update)
{
    Integer ClientProjManExists = 0;
    Contact tmpContact;
    Integer ProjManExists = 0;
    Integer idx = 0;    
    for(pse__Proj__c ProjList : Trigger.new)
    {
        pse__Proj__c OldProjList = Trigger.old[idx];
        
        // adjust for when triggers can run against projects from (based on Project Initiation Meeting Date & End Date)
        Date runCodeFrom = date.newInstance(2017,08,18);
        
        IF( ProjList.pse__Account__c != null)
        {
            Account tmpAccount = [SELECT Name, Hosted_Midland__c, ID FROM Account WHERE ID = : ProjList.pse__Account__c];
            IF(ProjList.Client_Project_Manager__c != null){
             tmpContact = [SELECT FirstName, LastName, Email FROM Contact WHERE ID = : ProjList.Client_Project_Manager__c];
            }
            Contact tmpProjMan;
            
            IF(ProjList.pse__Project_Manager__c != null)
            {
                tmpProjMan = [SELECT Name FROM Contact WHERE ID = : ProjList.pse__Project_Manager__c];
                ProjManExists = 1;
            } ELSE {
                ProjManExists = 0;
                
            }
              IF(ProjList.Client_Project_Manager__c != null)
            {
                
                ClientProjManExists = 1;
            } ELSE {
                ClientProjManExists = 0;
                
            }
            
            List<Contact> tmpContactList = [SELECT FirstName, LastName, Email FROM Contact WHERE AccountId = : ProjList.pse__Account__c AND Include_in_Surveys__c = TRUE AND ID <> : ProjList.Client_Project_Manager__c];
            
            IF(ProjList.pse__Project_Type__c == 'Strategic Customer Project') 
            {
                //Professional Services (Strategic) - Project Initiation survey
                IF(ProjList.CX_Sent_Initiation__c == False && ProjList.CX_Start__c == True && ProjList.pse__Stage__c == 'Start Up' && ProjList.Project_Initiation_Meeting_Date__c >= runCodeFrom)
                {
                    ProjList.CX_Sent_Initiation__c = True;
                    IF(ClientProjManExists == 1){ tmpContact.SendServicesPIMSurvey__c = True;
                                                 IF(tmpContact.id != ProjList.pse__Project_Manager__c){
                                                     tmpContact.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;
                                                 	 tmpContact.Include_in_Programme_Portfolio__c = ProjList.Include_in_Programme_Portfolio__c;
                                                 }
                    update tmpContact;
                    }
                    for(Contact c : tmpContactList){
                    c.SendServicesPIMSurvey__c = True;
                        c.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;
                        c.Include_in_Programme_Portfolio__c = ProjList.Include_in_Programme_Portfolio__c;
                    update c;
                                        }  
                }
                //Professional Services (Strategic) - Mid-Project
                IF(ProjList.CX_Sent_UAT__c == False && ProjList.pse__Stage__c == 'UAT' )
                {
                    ProjList.CX_Sent_UAT__c = True;
                    IF(ClientProjManExists == 1){ tmpContact.SendServicesUATSurvey__c = True;
                                                 IF(tmpContact.id != ProjList.pse__Project_Manager__c){
                                                     tmpContact.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                    update tmpContact;
                    }
                    
                    for(Contact c : tmpContactList){
                    c.SendServicesUATSurvey__c = True;
                        if (c.id != ProjList.pse__Project_Manager__c){ 
                            c.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                        update c;
                    }
                }
                //Professional Services (Strategic) - Project Closedown
                IF(ProjList.CX_Sent_BAU__c == False && ProjList.pse__Stage__c == 'Project Closed')
                {
                    ProjList.CX_Sent_BAU__c = True;
                    IF(ClientProjManExists == 1){ tmpContact.SendServicesBAUSurvey__c = True;
                                                 IF(tmpContact.id != ProjList.pse__Project_Manager__c){
                                                     tmpContact.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                                                 update tmpContact;
                    }
                    
                    for(Contact c : tmpContactList){
                    c.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;
                    c.SendServicesBAUSurvey__c = True;
                    update c;
                    }
                }
            }
            ELSE IF(ProjList.pse__Project_Type__c == 'SD - Customer Project')
            {        
                //Implementation: Project Initiation Meeting
                IF(ProjList.CX_Sent_Initiation__c == False && ProjList.CX_Start__c == True && ProjList.Project_Initiation_Meeting_Date__c >= runCodeFrom)
                {
                    ProjList.CX_Sent_Initiation__c = True;
                    IF(ClientProjManExists == 1){ tmpContact.SendProjectsPIMSurvey__c = True;
                                                 IF(tmpContact.id != ProjList.pse__Project_Manager__c){
                                                      tmpContact.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                                                 update tmpContact;
                    }
                    
                    for(Contact c : tmpContactList){
                        IF (c.id != ProjList.pse__Project_Manager__c){
                            c.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                    c.SendProjectsPIMSurvey__c = True;
                    update c;
                    }  
                }
                
                //Implementation: Design Sign-off survey
                IF(ProjList.CX_Sent_Design__c == False && OldProjList.pse__Stage__c == 'System Design' && ProjList.pse__Stage__c != 'Start Up' && ProjList.pse__Stage__c != 'System Design')
                {
                    ProjList.CX_Sent_Design__c = True;
                    IF(ClientProjManExists == 1){ tmpContact.SendProjectsDesignSurvey__c = True;
                                                 IF(tmpContact.id != ProjList.pse__Project_Manager__c){
                                                     tmpContact.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                                                 update tmpContact;
                    }
                    for(Contact c : tmpContactList){
                        IF (c.id != ProjList.pse__Project_Manager__c){ 
                            c.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                    c.SendProjectsDesignSurvey__c = True;
                    update c;
                    }
                }
                
                //Implementation: Data/UAT survey
                IF(ProjList.CX_Sent_UAT__c == False && OldProjList.pse__Stage__c == 'UAT' && (ProjList.pse__Stage__c == 'Parallel Run 1' || ProjList.pse__Stage__c == 'Parallel Run 2' || ProjList.pse__Stage__c == 'Go-Live'))
                {
                    ProjList.CX_Sent_UAT__c = True;
                    IF(ClientProjManExists == 1){ tmpContact.SendProjectsUATSurvey__c = True;
                                                 IF(tmpContact.id != ProjList.pse__Project_Manager__c){
                                                     tmpContact.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                                                 update tmpContact;
                    }               
                    for(Contact c : tmpContactList){
                        IF(c.Id != ProjList.pse__Project_Manager__c){
                            c.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                    c.SendProjectsUATSurvey__c = True;
                    update c;
                    }
                }
                
                //Implementation: BAU Handover survey
                IF(ProjList.CX_Sent_BAU__c == False && ProjList.pse__Stage__c == 'Project Closed' && ProjList.pse__End_Date__c >= runCodeFrom)
                {
                    ProjList.CX_Sent_BAU__c = True;
                    IF(ClientProjManExists == 1){ tmpContact.SendProjectsBAUSurvey__c = True;
                                                 IF(tmpContact.Id != ProjList.pse__Project_Manager__c){
                                                     tmpContact.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
                                                 update tmpContact;
                                }               
            for(Contact c : tmpContactList){
                IF (c.Id != ProjList.pse__Project_Manager__c){
                    c.Current_Project_Manager__c = ProjList.pse__Project_Manager__c;}
            c.SendProjectsBAUSurvey__c = True;
            update c;
                    }
                    
                    
                }
            }
        }
        idx ++;
        if (idx > 3){
            break;
        }
    }
}