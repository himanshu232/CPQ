public with sharing class community_ServiceRequestController {

    public community_ServiceRequestController() {
        redirect();
    }
    
    public PageReference redirect() {
        PageReference pageRef = new PageReference('/apex/community_ServiceRequestCreate');
         return pageRef.setRedirect(true);
    }
   
}