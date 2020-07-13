@RestResource(urlMapping='/SlackButtonClickRespose/*')
global class SlackButtonClickRespose {
    
    public SlackButtonClickRespose(){
        
    }
    
    @HttpPost
    global static String callbackHandler(){
        
        RestRequest req = RestContext.request;
        
        Map<String,Object> responseMap = new Map<String,Object>();
        responseMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(req.params));
        Lead lead = [Select id,description from lead where id='00Q2x000009SSZZEA4'];
        lead.description = responseMap+'test';
        update lead;
        Map<String,Object> slackObjMap = new Map<String,Object>();
        slackObjMap = (Map<String,Object>)JSON.deserializeUntyped((String)responseMap.get('payload'));
		
        String slackUser = String.valueOf(slackObjMap.get('user'));       
        slackUser = slackUser.substringBetween('name=', '}');
		slackUser = slackUser+'%';
        
        String recordId = String.valueOf(slackObjMap.get('callback_id'));   
                
        List<User> userDetails = [SELECT Id, Name, IsActive FROM User WHERE Email LIKE :slackUser AND IsActive=TRUE LIMIT 1];	
        List<Lead> leadsList = [SELECT Id, OwnerId FROM Lead WHERE Id=:recordId];
        
        if(userDetails.size()>0 && leadsList.size()>0){
            
            leadsList[0].OwnerId = userDetails[0].Id;
            update leadsList;
            
            return 'Lead Owner changed successfully!';
        }
        else{
            return 'Lead Owner could not change due to an error';
        } 
    }
}