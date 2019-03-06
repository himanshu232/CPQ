global class CXReplyPayload{

  Integer id;
  public Integer getId(){return id;}
  public void setId(Integer i){ id = i;}

  String token;
  public String getToken(){return token;}
  public void setToken(String t){ token = t;}

  String name;
  public String getName(){return name;}
  public void setName(String n){name = n;}

  String email;
  public String getEmail(){return email;}
  public void setEmail(String e){email = e;}

  DateTime answered_at;
  public DateTime getAnsweredAt(){return answered_at;}
  public void setAnsweredAt(DateTime a){answered_at = a;}

  Integer nps;
  public Integer getNps(){return nps;}
  public void setNps(Integer n){nps = n;}

  String nps_reason;
  public String getNpsReason(){return nps_reason;}
  public void setNpsReason(String n){nps_reason = n;}

  String reply_url;
  public String getReplyUrl(){return reply_url;}
  public void setReplyUrl(String r){reply_url = r;}

  Integer questions_answered;
  public Integer getQuestionsAnswered(){return questions_answered;}
  public void setQuestionsAnswered(Integer q){questions_answered = q;}

  String survey_name;
  public String getSurveyName(){return survey_name;}
  public void setSurveyName(String s){survey_name = s;}

  String region;
  public String getRegion(){return region;}
  public void setRegion(String r){region = r;}

  String country_code;
  public String getCountryCode(){return country_code;}
  public void setCountryCode(String c){country_code = c;}

  String sentiment;
  public String getSentiment(){return sentiment;}
  public void setSentiment(String s){sentiment = s;}

}