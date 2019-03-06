@istest (SeeAllData=true)
public class testSuperSort_oegen {
        public static testMethod void sortAscendingTest(){
        
        List<Opportunity> opps = new List<Opportunity>();
        for(integer i = 0; i<1000; i++){
            opps.add(new Opportunity(Name = 'test' + i, Amount = 1000 * Math.random()));
        }
        
        Test.startTest();
        Long start = system.currentTimeMillis();
        superSort.sortList(opps,'Amount','asc');
        system.debug(system.currentTimeMillis() - start);
        Test.stopTest();
        
        //Assert the list was sorted correctly
        Decimal assertValue = -1;
        for(Opportunity o : opps) {
            System.debug('Opp value: ' + o.amount);
            System.assert(assertValue <= o.amount);
            assertValue = o.amount;
        }  
    }
    
    public static testMethod void sortDescendingReferenceTest(){
        
        Account a = new Account(Name = 'Test Account 1', Account_Reference__c = 'Ref1', Customer_Code__c = 'Code1');
        Account a2 = new Account(Name = 'Test Account 2',Account_Reference__c = 'Ref2', Customer_Code__c = 'Code2');
        insert a;
        insert a2;
        
        List<Opportunity> opps = new List<Opportunity>();
        
        opps.add(new Opportunity(Name = 'Test', AccountId = a.Id, Amount = 1000 * Math.random()));
        
        opps.add(new Opportunity(Name = 'Test', AccountId = a2.Id, Amount = 1000 * Math.random()));
        
        Test.startTest();
        superSort.sortList(opps,'AccountId','desc');
        Test.stopTest(); 
    }
}