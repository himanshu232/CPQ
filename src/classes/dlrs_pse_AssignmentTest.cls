/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_pse_AssignmentTest
{
    @IsTest
    private static void testTrigger()
    {
PsaTestHarness pth = new PsaTestHarness();

        User user = pth.newUserSysAdmin(true);

                System.runAs(user)
        {
            pse__Region__c region = pth.newRegionMaster(true);
            pse__Practice__c practice = pth.newPracticeMaster(true);

            pth.newPermissionControl(true, user.Id, region.Id, null, null, null, null, true);
            pth.newPermissionControl(true, user.Id, null, practice.id, null, null, null, true);

            Account account = pth.newAccount(true);

            pse__Work_Calendar__c work = pth.newWorkCalender(true);
            Contact resource = pth.newResource(true, account.Id, user.Id, region.Id, work.id);
            pse__Proj__c project = pth.newProject(true, region.Id, practice.Id, true, null);

            
            //pth.newPermissionControl(true, user.Id, null, null, null, project.id, null, true);
            //pth.newPermissionControl(true, user.Id, null, null, null, null, resource.id, true);

            pse__Schedule__c schedule = pth.newSchedule(true);

           // pse__Assignment_Settings__c.getInstance().Disable_Bill_Rate_Null_Check_in_Trigger__c

            pse__Assignment__c assignment = pth.newAssignment(false, project.Id, resource.Id, schedule.Id);
     
            insert assignment;
        }
    }
}