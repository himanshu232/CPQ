/*
    * FinancialForce.com, inc. claims copyright in this software, its screen display designs and
    * supporting documentation. FinancialForce and FinancialForce.com are trademarks of FinancialForce.com, inc.
    * Any unauthorized use, copying or sale of the above may constitute an infringement of copyright and may
    * result in criminal or other legal proceedings.
    *
    * Copyright FinancialForce.com, inc. All rights reserved.
    * Created by Uves Ravat
*/

public with sharing class CustomSINLineSorter3
{
    private List<InvoiceLine> sortedLines;
  private boolean TravelTimeIncluded;
    public c2g__codaInvoice__c InvoiceLinesAttr
    {
        get;
        set
        {
            this.InvoiceLinesAttr = value;
            system.debug('MJS : setting attribute:' +  this.InvoiceLinesAttr);
            getSortedLines();
        }
    }

    

    public List<InvoiceLine> getSortedLines()
    {
        if (sortedLines != null) return sortedLines;

        sortedLines = new List<InvoiceLine>();
    		TravelTimeIncluded = false;
        Set<id> timecardSplitIds = new Set<id>();

        for (c2g__codaInvoiceLineItem__c line : InvoiceLinesAttr.c2g__InvoiceLineItems__r)
        {
            system.debug('MJS: invoice lines passed in:' +  line);
            pse__Billing_Event_Item__c billingEvent = line.ffpsai__BillingEventItem__r;

            if(billingEvent != null  && billingEvent.pse__Timecard_Split__c != null)
            {
                timecardSplitIds.add(billingEvent.pse__Timecard_Split__c);
            }
        }

        List<c2g__codaInvoiceLineItem__c> nonTimecardLines = new List<c2g__codaInvoiceLineItem__c>();

        List<InvoiceLineSorter> invLines = new List<InvoiceLineSorter>();
     
        for (c2g__codaInvoiceLineItem__c line : InvoiceLinesAttr.c2g__InvoiceLineItems__r)
        {
            system.debug('MJS: line:' +  line);
            pse__Billing_Event_Item__c billingEvent = line.ffpsai__BillingEventItem__r;
            system.debug('MJS: billingEvent:' +  billingEvent);
            if (billingEvent != null && billingEvent.ffps_BillTrav__Is_BillableTravel_Item__c == true)
            {
                TravelTimeIncluded = true;
            }
        
            if(line.c2g__NetValue__c != 0)
            {
                invLines.add(new InvoiceLineSorter(line));
                system.debug('MJS: added invoice line'+line);
            }
            
        }
        
    		if(TravelTimeIncluded)
        {
            system.debug('MJS: invLines before sort:' + invLines);

        

            if(!invLines.isEmpty())
            {
                invLines.sort();
            }
            system.debug('MJS: invLines after sort:' + invLines);
            
            for (InvoiceLineSorter sorted : (List<InvoiceLineSorter>)invLines)
            {
                sortedLines.add(new InvoiceLine(sorted.line));
            }
        }
        else
        {
      system.debug('MJS: invLines before sort:' + invLines);
            if(!invLines.isEmpty())
            {
                invLines.sort();
            }
            system.debug('MJS: invLines after sort:' + invLines);
            
            for (InvoiceLineSorter sorted : (List<InvoiceLineSorter>)invLines)
            {
                sortedLines.add(new InvoiceLine(sorted.line));
            }
    
    
        }
        
        
        
        return sortedLines;
    }

    public class InvoiceLine
    {
        public c2g__codaInvoiceLineItem__c invLine {get; set;}
        public pse__Time_Date__c timeDateline {get; set;}
        public Boolean showTimeDate {get; set;}

        public InvoiceLine(c2g__codaInvoiceLineItem__c invLine)
        {
            this.invLine = invLine;
            this.showTimeDate = false;
        }

        public InvoiceLine(c2g__codaInvoiceLineItem__c invLine, pse__Time_Date__c timeDateline)
        {
            this.invLine = invLine;
            this.timeDateline = timeDateline;
            this.showTimeDate = true;
        }

    }
    
    public class InvoiceLineSorter implements Comparable
    {
        public c2g__codaInvoiceLineItem__c line {get;set;}

        public InvoiceLineSorter(c2g__codaInvoiceLineItem__c line)
        {
            this.line = line;
        }

        public Integer compareTo(Object comparedTo)
        {
            c2g__codaInvoiceLineItem__c otherLine = ((InvoiceLineSorter)comparedTo).line;

            Date thisToDate = (Date)this.line.get('Period_To__c') != null ? (Date)this.line.get('Period_To__c') : Date.today();
            Date otherToDate = (Date)otherLine.get('Period_To__c') != null ? (Date)otherLine.get('Period_To__c') : Date.today();
            Date thisFromDate = (Date)this.line.get('Period_From__c') != null ? (Date)this.line.get('Period_From__c') : Date.today();
            Date otherFromDate = (Date)otherLine.get('Period_From__c') != null ? (Date)otherLine.get('Period_From__c') : Date.today();
            String thisDescription = this.line.c2g__LineDescription__c != '' ? this.line.c2g__LineDescription__c :'';
            String otherDescription = otherLine.c2g__LineDescription__c != '' ? otherLine.c2g__LineDescription__c : '';

            id thisId = this.line.id;
            id otherId = otherLine.id;
            
            Integer toDate = thisToDate > otherToDate ? 1 : thisToDate < otherToDate ? -1 : 0;
            Integer fromDate = thisFromDate > otherFromDate ? 1 : thisFromDate < otherFromDate ? -1 : 0;
            Integer description = thisDescription > otherDescription ? 1 : thisDescription < otherDescription ? -1 : 0;
            
            Integer idsort = thisID > otherId ? 1 : thisId < otherId ? -1 : 0;

            return fromDate == 1 ? 1 : fromDate == -1 ? -1 : toDate == 1 ? 1 : toDate == -1 ? -1 : description ;
            //return  idsort;
        }
    }

}