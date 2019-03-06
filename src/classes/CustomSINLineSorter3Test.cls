/********************************************************************
*  CustomSINLineSorterTest2
*
* Use: tests  CustomSINLineSorterTest3
* 
* 
* Author: Matthew Spinks
*
* Update Log:
* WHO        WHEN          WHAT
* MJS        28 Mar 2018   Initial Creation
********************************************************************/
@isTest(SeeAllData=true)
private class CustomSINLineSorter3Test
{
   
    private static id testCurrencyId = 'a7gb0000000fxSL';
    private static id testCompanyId = 'a20b0000000Uao0';

    // for coverage only
    @isTest(SeeAllData=true)
    public static void testBasics1()
    {
    		id testInvoiceId;
    		system.debug('MJS: ' + UserInfo.getOrganizationId());
    		if (UserInfo.getOrganizationId() == '00D8E0000000eCmUAI')
    		{
    			testInvoiceId = 'a2X8E0000009h0x';
    		}
    		else
    		{
    			testInvoiceId = 'a2X0N000001FxN6';
    		}
		system.debug('MJS: ' + testInvoiceId);
    		
        List<c2g__codaInvoice__c> invs = database.query('select id, name, '+
                                         '  (select id, name, '+
                                         '    c2g__UnitPrice__c, '+
                                         '        c2g__Invoice__c, '+
                                        '        c2g__LineDescription__c, '+
                                        '        c2g__TaxValueTotal__c, '+
                                        '        c2g__NetValue__c, '+
                                        '        c2g__TaxCode1__r.Name, '+
                                        '        Period_From__c, '+
                                        '        Period_To__c, '+
                                        '        ffpsai__BillingEventItem__r.pse__Timecard_Split__c, '+                     
                                        '        ffpsai__BillingEventItem__r.pse__Date__c, '+
                                        '        ffpsai__BillingEventItem__r.pse__Category__c, '+
                                        '        ffpsai__billingEventItem__r.ffps_BillTrav__Is_BillableTravel_Item__c '+
                                        '        from c2g__InvoiceLineItems__r) '+
                                        '    from c2g__codaInvoice__c WHERE id = :testInvoiceId  ');

		system.debug('MJS: ' + invs);
        Test.startTest();

        CustomSINLineSorter3 con = new CustomSINLineSorter3();
        con.InvoiceLinesAttr = invs[0];

        Test.stopTest();
    }
}