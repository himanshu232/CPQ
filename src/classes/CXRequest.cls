public class CXRequest {
    @future (callout=true)
    public static void requestToCX(string endpoint, string token, string email, string firstName, string lastName, string accountName, string hosted, string PM, string BDM, string caseNo, string caseOwner, string SRNo, string Team, string SRType, string PMTeam)
    {
        if(!email.contains('@mhr.co.uk') && !email.contains('@midlandhr.co.uk'))
        {
            try
            {
                string bodyText = '';
                bodyText = '{"person": {';
                if(email != '' && email != null){bodyText = bodyText + '"email": "'+ email + '",';}
                if(firstName != '' && firstName != null){bodyText = bodyText + '"first_name": "'+firstName + '",';}
                if(lastName != '' && lastName != null){bodyText = bodyText + '"last_name": "'+lastName +'",';}
                bodyText = bodyText + '"fields": {';
                if(BDM != '' && BDM != null){bodyText = bodyText + '"BDM": ["'+BDM + '"]';}
                if(BDM != '' && BDM != null && ((hosted != '' && hosted != null)|| (PM != '' && PM != null)|| (PMTeam != '' && PMTeam != null) || (SRType != '' && SRType != null))){bodyText = bodyText + ',';}
                if(hosted != '' && hosted != null){bodyText = bodyText + '"Hosted": ["'+hosted + '"]';}  
                if(hosted != '' && hosted != null && ((PM != '' && PM != null) || (PMTeam != '' && PMTeam != null) || (SRType != '' && SRType != null))){bodyText = bodyText + ',';}
                if(PM != '' && PM != null){bodyText = bodyText + '"Project Manager": ["'+PM + '"]';}
                if(PM != '' && PM != null && ((PMTeam != '' && PMTeam != null) || (SRType != '' && SRType != null))){bodyText = bodyText + ',';}
                if(PMTeam != '' && PMTeam != null){bodyText = bodyText + '"Project Manager Team": ["'+PMTeam + '"]';}
                if(PMTeam != '' && PMTeam != null && SRType != '' && SRType != null) {bodyText = bodyText + ',';}
                if(SRType != '' && SRType != null){bodyText = bodyText + '"Type": ["'+SRType + '"]';}                            
                bodyText = bodyText + '}}, "account": {"name": "' + accountName + '"}';
                if((caseNo != '' && caseNo != null) || (caseOwner != '' && caseOwner != null) || (SRNo != '' && SRNo != null) || (Team != '' && Team != null)){bodyText = bodyText + ',"facets": {';}
                if(caseNo != '' && caseNo != null){bodyText = bodyText + '"Case No.": "'+caseNo + '"';}
                if(caseNo != '' && caseNo != null && ((caseOwner != '' && caseOwner != null) || (SRNo != '' && SRNo != null) || (Team != '' && Team != null))){bodyText = bodyText + ',';}
                if(caseOwner != '' && caseOwner != null){bodyText = bodyText + '"Case Owner": "'+caseOwner + '"';}
                if(caseOwner != '' && caseOwner != null && ((SRNo != '' && SRNo != null) || (Team != '' && Team != null))){bodyText = bodyText + ',';}
                if(SRNo != '' && SRNo != null){bodyText = bodyText + '"SR No.": "'+SRNo + '"';}
                if(SRNo != '' && SRNo != null && Team != '' && Team != null){bodyText = bodyText + ',';}
                if(Team != '' && Team != null){bodyText = bodyText + '"Team": "'+Team + '"';}
                if((caseNo != '' && caseNo != null) || (caseOwner != '' && caseOwner != null) || (SRNo != '' && SRNo != null) || (Team != '' && Team != null)){bodyText = bodyText + '}';}
                bodyText = bodyText + '}';
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Token token='+ token);
                req.setBody(bodyText);
                res = http.send(req);
                System.debug(System.LoggingLevel.ERROR,'Body sent = ' + bodyText);
                System.debug(System.LoggingLevel.ERROR,res.getBody());
            }
            Catch(exception e)
            {
                System.debug(System.LoggingLevel.ERROR,e.getMessage());
                System.debug(System.LoggingLevel.ERROR,e.getLineNumber());
            }
        }
    }
}