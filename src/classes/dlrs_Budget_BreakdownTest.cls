/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Budget_BreakdownTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Budget_BreakdownTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Budget_Breakdown__c());
    }
}