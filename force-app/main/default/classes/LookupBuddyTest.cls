@isTest
public class LookupBuddyTest {
	
    @isTest
    public static void testSimple() {
        
        Account a = new Account(Name='Acme');
        insert a;
        Campaign parentCampaign = new Campaign(Name='Parent Campaign');
        insert parentCampaign;
        Campaign childCampaign = new Campaign(Name='Child Campaign'
                                             , ParentId=parentCampaign.Id);
        insert childCampaign;
        Opportunity o = new Opportunity(Name='Test Oppty'
                                       , AccountId = a.Id
                                       , CampaignId = childCampaign.Id
                                       , StageName = 'Prospecting'
                                       , CloseDate = System.today());
        system.debug(o);
        insert o;
        o = [SELECT Id, Parent_Campaign__c FROM Opportunity WHERE Id = :o.Id];
        system.assertEquals(parentCampaign.Id,o.Parent_Campaign__c);
        
    }
    
}