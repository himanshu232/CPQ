/** oe:gen 23-12-2015 **/
@isTest
public class TestUtils {
	public static User getCommunityUser(Contact c, string profileId){
    //Get a customer portal profile
    Profile p = [select Id from Profile where Id =:profileId LIMIT 1];
    //Create the User and set defaults
    User u = new User();
    u.LastName = c.LastName;
    u.Title = c.Title;
    u.Alias = 'cpdum123';
    u.Email = 'cpdummy123@d.com';
    u.Username = 'dummy123'+datetime.now().millisecond()+'@test.com';
    u.ProfileId = p.Id;
    u.ContactId = c.Id;
    u.TimeZoneSidKey = 'Europe/London';
    u.LocaleSidKey = 'en_US';
    u.EmailEncodingKey = 'ISO-8859-1';
    u.LanguageLocaleKey = 'en_US';
    
    insert u;
    return u;
  }
}