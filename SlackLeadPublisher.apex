// Class to send message to SLACK on Creating of LEAD Record
// Create a PROCESS to run the class from PROCESS BUILDER on creation of a LEAD record.
public with sharing class SlackLeadPublisher {
    
    private static final String slackURL = 'https://hooks.slack.com/services/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';
    
    @InvocableMethod(label='Post to Slack For Lead Created')
    public static void postToSlack(List<Id> leadId) {
        Id lead_id = leadId[0]; // If bulk, only post first to avoid overloading Slack channel
        Lead lead = [SELECT Name, Status  from Lead WHERE Id=:lead_id];
		
        // **************  	Changing the Wrapper into JSON for Opportunity Owner update 	***************
        
		//	Using the Wrapper to create JSON for BODY  

        List<attachments> attachmentsList = new List<attachments>();
        List<actions> actionList = new List<actions>();
            actions actions = new actions();
            actions.name = 'user';
            actions.type = 'button';
            actions.value = 'Claim';
            actions.text = 'Claim';
            actionList.add(actions);
        
        attachments attachments = new attachments();
        attachments.color = '#3AA3E3';
        attachments.callback_id = lead.id;
        attachments.attachment_type = 'default';
        attachments.fallback = 'You are unable to change user';
        attachments.actions = actionList;
        attachments.text = 'Click on the buttom to become Owner of Lead mentioned above';
        attachmentsList.add(attachments);
        
        JsonParser JsonParser = new JsonParser();
        JsonParser.text = 'The following lead has been created:\n*' + lead.Name + '*\nWith Status : *' + lead.Status+ '*\nWith Lead Id : *' + lead.Id+ '*.';
        JsonParser.attachments = attachmentsList;
        
        String body = JSON.serialize(JsonParser);
		System.enqueueJob(new QueueableSlackCall(slackURL, 'POST', body));
    }
    
    public class QueueableSlackCall implements System.Queueable, Database.AllowsCallouts {
        
        private final String url;
        private final String method;
        private final String body;
        
        public QueueableSlackCall(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
        
        public void execute(System.QueueableContext ctx) {
            HttpRequest req = new HttpRequest();
            req.setMethod(method);
            req.setBody(body);
            Http http = new Http();
            HttpResponse res;
            if (!Test.isRunningTest()) {
	            req.setEndpoint(url);
            	res = http.send(req);
                System.debug('SlackOpportunityPublisher Class - Response'+res);
            }
        }

    }
    
    /* 
     * #
     * # #	Wrapper Class
     * #
     */
    
    public class JsonParser{
        public list<attachments> attachments{get;set;}
        public String text{get;set;}
    }    
    public class attachments{
        public String color{get;set;}
        public String callback_id{get;set;}
        public String attachment_type{get;set;}
        public String fallback{get;set;}
        public list<actions> actions{get;set;}
        public String text{get;set;}
    }
    public class actions{
        public String name{get;set;}
        public String type{get;set;}
        public String value{get;set;}
        public String text{get;set;}
    }
   
}