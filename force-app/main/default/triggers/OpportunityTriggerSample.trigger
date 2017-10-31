trigger OpportunityTriggerSample on Opportunity (after insert, after update) {

    if(Trigger.isInsert) {
        LookupBuddy.fillAllLookups(Trigger.new);
    }
    if(Trigger.isUpdate) {
        //another method to check for updates and then pass to fillAllLookups
    }
}