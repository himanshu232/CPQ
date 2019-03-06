global class purchaseOrders_ReSubmit {

    webService static String submitPO(String recordID) {
        Map<String,Object> response = new Map<String,Object>();
    
        if(recordID == '') {
            response.put('status', '-1');
            response.put('error', 'There was no record ID set for re-submission.');
            return JSON.serialize(response);
        }
        
        SCMC__Purchase_Order__c tmpOrder = [ SELECT SCMC__Status__c, FFSCM_Department_Approver__c FROM SCMC__Purchase_Order__c WHERE ID = : recordID ];
        if(tmpOrder.SCMC__Status__c <> 'Rejected') {
           response.put('status', '-1');
           response.put('error', 'This record has not been marked as rejected.');
           return JSON.serialize(response);
        }
        
        tmpOrder.Approver__c = tmpOrder.FFSCM_Department_Approver__c;
        update tmpOrder;
        
        Approval.ProcessSubmitRequest thisApproval = New Approval.ProcessSubmitRequest();
        thisApproval.setObjectId(recordID);
        Approval.ProcessResult result = Approval.process(thisApproval);
        
        if(!result.isSuccess()) {
            response.put('status', '-1');
            response.put('error', 'There was an error resubmitting the Purchase Order. Please contact the Business Information Systems team.');
            return JSON.serialize(response);
        } else {
            response.put('status', '200');
            return JSON.serialize(response);
        }
        
        
    }
    
}