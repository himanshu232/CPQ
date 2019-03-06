public with sharing class bg_Case_Helper {
    
    class TeamDepartmentTransporter {
        String Team {get;Set;}
        String Department {get;Set;}
        
        public TeamDepartmentTransporter(String team, String department) {
            this.Team = team;
            this.Department = department;
        }
    }   
    
            
    public static void SetDepartmentAndTeamForCase(LIST<Id> caseIdList) {
    

        if (!caseIdList.isEmpty()) {
            // class to hold the role to team and department map
            // create the map
            Map<String, TeamDepartmentTransporter> transporterByRoleName = new Map<String, TeamDepartmentTransporter>();
            
            // loop the custom setting records and create the map
            for (Team_Mapping__c team : [select Name, Department__c, Roles__c from Team_Mapping__c]) {
            
                System.debug('team [' + team + ']');
                LIST<String> roles = team.Roles__c.split(',');
                
                System.debug('roles [' + roles + ']');
                
                // loop the roles
                for (String role : roles) {
                
                // create a new transporter value against the role
                // teams starting with - mean there is no team so set to empty string
                transporterByRoleName.put(role, new TeamDepartmentTransporter(team.Name.startsWith('-') ? '' : team.Name, team.Department__c));         
                }       
            }

            System.debug('transporterByRoleName [' + transporterByRoleName + ']');
            
            LIST<Case> updatedCases = new LIST<Case>();
            
            for (Case ownerCase : [select Department__c, Team__c, Owner.UserRole.Name, Owner.Name, Owner.type from Case where Id in : caseIdList]) {
            
                if (ownerCase.Owner.UserRole.Name != null) {
                    System.debug('Owner.UserRole.Name [' + ownerCase.Owner.UserRole.Name + ']');
                    // set the correct team and department based on rolename
                    ownerCase.Team__c = '';
                    ownerCase.Department__c = '';
                    ownerCase.Team__c = transporterByRoleName.containsKey(ownerCase.Owner.UserRole.Name)?transporterByRoleName.get(ownerCase.Owner.UserRole.Name).Team: ownerCase.Team__c;
                    ownerCase.Department__c = transporterByRoleName.containsKey(ownerCase.Owner.UserRole.Name)?transporterByRoleName.get(ownerCase.Owner.UserRole.Name).Department: ownerCase.Department__c;        
                    
                    System.debug('ownerCase [' + ownerCase + ']');
                    
                    updatedCases.add(ownerCase);
                } else if (ownerCase.Owner.type=='Queue') {
                    System.debug('Owner.Name [' + ownerCase.Owner.Name+ ']');
                    // set the correct team and department based on queuename
                    ownerCase.Team__c = '';
                    ownerCase.Department__c = '';
                    ownerCase.Team__c = transporterByRoleName.containsKey(ownerCase.Owner.Name)?transporterByRoleName.get(ownerCase.Owner.Name).Team: ownerCase.Team__c;
                    ownerCase.Department__c = transporterByRoleName.containsKey(ownerCase.Owner.Name)?transporterByRoleName.get(ownerCase.Owner.Name).Department: ownerCase.Department__c;      
                    
                    System.debug('ownerCase [' + ownerCase + ']');
                    
                    updatedCases.add(ownerCase);
                }
            }
            
            if (!updatedCases.isEmpty()) {
                update updatedCases;
            }
        }           
    }
}