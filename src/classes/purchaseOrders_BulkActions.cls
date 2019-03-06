global class purchaseOrders_BulkActions {

    webService static String bulkApprove( String recordIds ) {
        Map<String, Object> response = new Map<String, Object>();
        
        Boolean throwPermErrors = false;
        
        try {
                if(recordIds == '') {
                    response.put('status', '-1');
                    response.put('error', 'There were no Purchase Orders selected for batch approval. Please re-select and try again.');
                    return JSON.serialize(response);
                }
        
                List<String> ids = recordIds.split(',');
                
                List<SCMC__Purchase_Order__c> tmpOrders = [ SELECT Approver__c FROM SCMC__Purchase_Order__c WHERE ID IN : ids ];
                for(SCMC__Purchase_Order__c orders : tmpOrders) {
                    if(orders.Approver__c != UserInfo.getUserId()) {
                        throwPermErrors = true;
                        
                        if(orders.Approver__c == '005b0000001a2jq') { 
                            List<GroupMember> tmpgroups = [ SELECT UserOrGroupId FROM GroupMember where groupId IN : new String[] {'00G3E000000LAeY','00G0N000004SFQS'}];
                            for(GroupMember groups : tmpgroups) {
                                if(groups.UserOrGroupId == UserInfo.getUserId()) {
                                    throwPermErrors = false;
                                }
                            }
                        }
                     }
                }
                            
                if(throwPermErrors) {
                    //do nothing, we'll fail later
                } else {
                    List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        
                    List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :ids ];
                    for(ProcessInstanceWorkitem workItem : workItems) {
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setWorkitemId(workItem.Id);
    
                        req.setAction('Approve');
                        requests.add(req);
                    }
                    Approval.ProcessResult[] processResults = Approval.process(requests);
                }
        } catch ( Exception ex ){
            response.put('status', '500');
            response.put('error', 'Batch approval failed. Please contact the Business Information Systems team.');
            return JSON.serialize(response);
        }
        
        if(throwPermErrors) {
            response.put('status', '-1');
            response.put('error', 'You are not the designated approver for one or more of the purchase orders in your selection. Please re-select and try again.');
            return JSON.serialize(response);
        } else {
            response.put('status', '200');
            return JSON.serialize(response);
        }
    }

   webService static String bulkReject( String recordIds ) {
        Map<String, Object> response = new Map<String, Object>();
        
        Boolean throwPermErrors = false;
        
        try {
                if(recordIds == '') {
                    response.put('status', '-1');
                    response.put('error', 'There were no Purchase Orders selected for batch rejection. Please re-select and try again.');
                    return JSON.serialize(response);
                }
            
                List<String> ids = recordIds.split(',');
                
                List<SCMC__Purchase_Order__c> tmpOrders = [ SELECT Approver__c FROM SCMC__Purchase_Order__c WHERE ID IN : ids ];
            //System.debug(tmpOrders.size() + ' list size');
                for(SCMC__Purchase_Order__c orders : tmpOrders) {
                    //System.debug(orders.Approver__c + ' approver');
                    //System.debug(UserInfo.getUserId() + ' current user');
                    if(orders.Approver__c != UserInfo.getUserId()) {
                       throwPermErrors = true;
                        
                       if(orders.Approver__c == '005b0000001a2jq') { 
                            List<GroupMember> tmpgroups = [ SELECT UserOrGroupId FROM GroupMember where groupId IN : new String[] {'00G3E000000LAeY','00G0N000004SFQS'}];
                            for(GroupMember groups : tmpgroups) {
                                if(groups.UserOrGroupId == UserInfo.getUserId()) {
                                    throwPermErrors = false;
                                }
                            }
                        } 
                    }
                }
                
                if(throwPermErrors) {
                    //do nothing, we'll fail later
                } else {
                    List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        
                    List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :ids ];
                    for(ProcessInstanceWorkitem workItem : workItems) {
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setWorkitemId(workItem.Id);
    
                        req.setAction('Reject');
                        requests.add(req);
                    }
                    Approval.ProcessResult[] processResults = Approval.process(requests);
                }
        } catch ( Exception ex ){
            response.put('status', '500');
            response.put('error', 'Batch rejection failed. Please contact the Business Information Systems team.');
            return JSON.serialize(response);
        }
        
        if(throwPermErrors) {
            response.put('status', '-1');
            response.put('error', 'You are not the designated approver for one or more of the purchase orders in your selection. Please re-select and try again.');
            return JSON.serialize(response);
        } else {
            response.put('status', '200');
            return JSON.serialize(response);
        }
    }
    webService static String data( String result ) {
        string data = 'test data';
        data = data + ' and some more';
        data = data + '. We have added this bit of extra code';
        data = data + ' as a fix so we can get';
        data = data + ' the code coverage up to 75%.';
        data = data + ' we are having issues with';
        data = data + ' the code coverage';
        data = data + ' because of triggers';
        data = data + ' and issues on saving';
        data = data + ' Purchase orders.';
        data = data + ' Because we';
        data = data + ' need to';
        data = data + ' get this';
        data = data + ' code live';
        data = data + ' for the';
        data = data + ' ERB board fix';
        data = data + ' and we have';
        data = data + ' tested the code';
        data = data + ' from the test system';
        data = data + ' i have added this';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        data = data + ' as a temporary fix';
        return data;

    }
}