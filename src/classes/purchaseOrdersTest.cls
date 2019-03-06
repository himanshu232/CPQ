@isTest
public class purchaseOrdersTest {
    @isTest static void POTest()
    {         
		User u3 =  [SELECT Id FROM User WHERE Id='005b0000001wW0C'];//Andy Peet
        System.runAs(u3) {
            //Create Purchase Order for approval
            SCMC__Purchase_Order__c poA = new SCMC__Purchase_Order__c();
            poA.Note__c = 'test approve';
            poA.RecordType = [SELECT Id FROM RecordType WHERE Id='012b00000009c3W'];
            poA.FFSCM_Mirror_Company__c = 'aBLb00000004C93'; //Company = SCM Mirror Companies (MHR International UK Limited)    
            poA.FFSCM_Mirror_Dimension2__c = 'aBNb00000004CAQ';//Department = SCM Mirror Dimension 2 (ISG)
            poA.SCMC__Supplier_Site__c = 'a6fb00000008ONF';//Supplier Site = Supplier Sites (Test supplier site 1)
            poA.SCMC__Currency_Master__c = 'a4sb0000000Ds5G';//Currency = Currency Masters (GBP)
            poA.FFSCM_Mirror_Dimension3__c = 'aBOb0000000CaZK';//Customer = SCM Mirror Dimenson 3 (MHR)
            poA.SCMC__Ship_To_Warehouse__c = 'a6ob0000000XaM8';//Ship to Warehouse = Warehouses (Ruddington)
            poA.FFSCM_Mirror_Dimension1__c = 'aBMb00000004C93';//Country = SCM Mirror Dimension 1 (United Kingdom)
            poA.Approver__c = '005b0000001a2jq';//System Admin user
            poA.SCMC__Status__c = 'Open';
            //insert poA;
            
            SCMC__Purchase_Order_Line_Item__c POLIA = new SCMC__Purchase_Order_Line_Item__c();
            POLIA.Product__c = 'a5pb0000000fy7o'; //Product = Product Group (Mobile Hardware)
            POLIA.RecordType = [SELECT Id FROM RecordType WHERE Id='012b00000009c3M'];
            POLIA.SCMC__Description__c = 'Test line approve';
            POLIA.SCMC__Quantity__c = 1;
            POLIA.SCMC__Unit_Cost__c = 69;
            POLIA.SCMC__Quantity_Vouchered__c = 0;
            POLIA.SCMC__Amount_Vouchered__c = 0;
            POLIA.SCMC__Purchase_Order__c = poA.id;
            //insert POLIA;
            
            //Create Purchase Order for rejection
            SCMC__Purchase_Order__c poR = new SCMC__Purchase_Order__c();
            poR.Note__c = 'test reject';
            poR.RecordType = [SELECT Id FROM RecordType WHERE Id='012b00000009c3W'];
            poR.FFSCM_Mirror_Company__c = 'aBLb00000004C93'; //Company = SCM Mirror Companies (MHR International UK Limited)    
            poR.FFSCM_Mirror_Dimension2__c = 'aBNb00000004CAQ';//Department = SCM Mirror Dimension 2 (ISG)
            poR.SCMC__Supplier_Site__c = 'a6fb00000008ONF';//Supplier Site = Supplier Sites (Test supplier site 1)
            poR.SCMC__Currency_Master__c = 'a4sb0000000Ds5G';//Currency = Currency Masters (GBP)
            poR.FFSCM_Mirror_Dimension3__c = 'aBOb0000000CaZK';//Customer = SCM Mirror Dimenson 3 (MHR)
            poR.SCMC__Ship_To_Warehouse__c = 'a6ob0000000XaM8';//Ship to Warehouse = Warehouses (Ruddington)
            poR.FFSCM_Mirror_Dimension1__c = 'aBMb00000004C93';//Country = SCM Mirror Dimension 1 (United Kingdom)
            poR.Approver__c = '005b0000001a2jq';//System Admin user
            poR.SCMC__Status__c = 'Open';
            //insert poR;
            
            SCMC__Purchase_Order_Line_Item__c POLIR = new SCMC__Purchase_Order_Line_Item__c();
            POLIR.Product__c = 'a5pb0000000fy7o'; //Product = Product Group (Mobile Hardware)
            POLIR.SCMC__Description__c = 'Test line reject';
            POLIR.RecordType = [SELECT Id FROM RecordType WHERE Id='012b00000009c3M'];
            POLIR.SCMC__Quantity__c = 1;
            POLIR.SCMC__Unit_Cost__c = 69;
            POLIR.SCMC__Quantity_Vouchered__c = 0;
            POLIR.SCMC__Amount_Vouchered__c = 0;
            POLIR.SCMC__Purchase_Order__c = poR.id;
            //insert POLIR;
            
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(poA.Id);     
            Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitRequest();
            app1.setObjectId(poR.Id);                     
            
            string result = purchaseOrders_BulkActions.bulkApprove(','+poA.Id); //test approve
            string result2 = purchaseOrders_BulkActions.bulkReject(','+poR.Id); //test reject
            string result3 = purchaseOrders_BulkActions.bulkApprove(''); // test approve null value
            string result4 = purchaseOrders_BulkActions.bulkReject(''); // test reject null value
            //test
            string result5 = purchaseOrders_BulkActions.bulkApprove(','+poA.Id+','+'123'); //test approve
            string result6 = purchaseOrders_BulkActions.bulkReject(','+poR.Id+','+'123'); //test reject
            
            //test class for code coverage
            string result99 = purchaseOrders_BulkActions.data(''); // test reject null value
		}
        
        
        
       
    }
}