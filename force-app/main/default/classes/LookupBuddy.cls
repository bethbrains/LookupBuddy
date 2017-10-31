public class LookupBuddy {

    public static void fillAllLookups(List<sObject> recs){
        //find all MDTs for the primary object
        String obj = String.valueof(recs[0].getSObjectType());
        system.debug(obj);
        List<LookupBuddy__mdt> buddies = [SELECT Primary_Object__c 
                                          , Lookup_A_Field__c 
                                          , Lookup_A_Field__r.QualifiedAPIName
                                          , Lookup_B_Field__c 
                                          , Lookup_B_Field__r.QualifiedAPIName
                                          , Lookup_A_to_B_Field__c 
                                          , Lookup_A_to_B_Field__r.QualifiedAPIName
                                          FROM LookupBuddy__mdt
                                          WHERE Primary_Object__c = :obj];
        System.debug(buddies);
        
        //find full info from all IDs with
        //dynamic soql assembling fields defined in buddy MDT
        String query = buildPrimaryObjectQueryString(buddies,recs)+' WHERE Id IN :recs';
        List<sObject> records = Database.query(query);
        system.debug(records);
        
        Map<Id, sObject> recordsToUpdate = new Map<Id, sObject>();
        //for each buddy, pass to matchPicklist
        for(LookupBuddy__mdt b : buddies){
            for(sObject rec : fillLookup(b, records)){
                recordsToUpdate.put(rec.Id,rec);
            }
        }
        system.debug(recordsToUpdate);
        update recordsToUpdate.values();
    }
    
    public static List<sObject> fillLookup(LookupBuddy__mdt b, List<sObject> records){
        system.debug(b);
        system.debug(records);
        List<sObject> recordsToUpdate = new List<sObject>();
        String lookupARel = getLookupARelationshipName(b);
        system.debug(lookupARel+'.'+b.Lookup_A_to_B_Field__r.QualifiedAPIName);
        system.debug(b.Lookup_A_to_B_Field__r.QualifiedAPIName);
        //for each record
        for(sObject rec : records){
            rec.put(b.Lookup_B_Field__r.QualifiedAPIName, (String)rec.getSobject(lookupARel).get(b.Lookup_A_to_B_Field__r.QualifiedAPIName));
            recordsToUpdate.add(rec);
            system.debug(rec);
        }
        return recordsToUpdate;
    }
        
    public static String buildPrimaryObjectQueryString(List<LookupBuddy__mdt> buddies, List<sObject> recs){
        String obj = recs[0].getSObjectType().getDescribe().getName();
        // to avoid issues with the same field being used in multiple rules, add to a set to dedupe
        Set<String> fields = new Set<String> {'Id', 'Name'};
        for (LookupBuddy__mdt b : buddies) {
            fields.add(b.Lookup_A_Field__r.QualifiedAPIName);
            fields.add(b.Lookup_B_Field__r.QualifiedAPIName);
            String lookupAObject = getLookupARelationshipName(b);
            fields.add(lookupAObject+'.'+b.Lookup_A_to_B_Field__r.QualifiedAPIName);
        }
        // there is a possibility that there could be fields not populated in the metadata, so remove the null entry
        fields.remove(null);
        //build query string
        String query = 'SELECT ' + String.join(new List<String>(fields), ',') +  ' FROM ' + obj;
        system.debug('QUERY STRING: '+query);
        return query;
    }
    
    public static String getLookupARelationshipName(LookupBuddy__mdt b){
        if(b.Lookup_A_Field__r.QualifiedAPIName.right(3) == '__c'){
            return b.Lookup_A_Field__r.QualifiedAPIName.replace('__c','__r');
        } else {
            return b.Lookup_A_Field__r.QualifiedAPIName.removeEnd('Id');
        }
    }
    
    public static String getString(sObject rec, String fieldName){
        system.debug(rec);
        system.debug(fieldName);
        return (String)rec.get(fieldName);
    }
      
}