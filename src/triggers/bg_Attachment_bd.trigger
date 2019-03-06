trigger bg_Attachment_bd on Attachment (before delete) {
	
	Attachment_Permissions__c attachmentPermissions = Attachment_Permissions__c.getInstance();
	
	if (!attachmentPermissions.Delete_Attachment__c) {
		for (Attachment attch : trigger.old) {
			attch.addError('You cannot delete an Attachment.');
		} 
	} 
}