@isTest
public class SlackLeadPublisherTest {
    @isTest
    public static void createLead(){
        
        List<Id> leadList = new List<Id>();
        
        Lead lead = new Lead();
        lead.LastName = 'testLead';
        lead.Company = 'testLeadCompany';
        lead.Status = 'Open - Not Contacted';
        insert lead;
        leadList.add(lead.Id);
        
        SlackLeadPublisher.postToSlack(leadList);
        
    }

}