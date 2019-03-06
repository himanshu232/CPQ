/**
 * An apex page controller that exposes the site forgot password functionality
 */
public class ForgotPasswordController {
    public String username {get; set;}
    public Boolean error {get;set;}
    public ForgotPasswordController() {
        this.username='';
        error=false;
    }

  	public PageReference forgotPassword() {
        if(username==null || username=='' || username=='Username'){
            error=true;
            return null;
        }
        else{
            List<User> u = new List<User>([SELECT Id FROM User WHERE isActive=true AND Username =:username LIMIT 1]);
            if(u.size() == 0){
                error=true;
                return null;
            }
        }
        error=false;
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
  		pr.setRedirect(true);
        if(success){
            return pr;
        }
       	return null;
  	}
}