public with sharing class LocationTreeController {
    @AuraEnabled(cacheable=true)
    public static Id getNaceIdByExternalId(String externalIdValue) {
        // Use dynamic SOQL to find the record by External ID
        Nace_sectors__c naceRecord = [
            SELECT Id 
            FROM Nace_sectors__c 
            WHERE External_Id__c = :externalIdValue 
            LIMIT 1
        ];
        System.debug('LocationTreeController: Nace Id is ' + naceRecord.Id);
        //return naceRecord.Id;);
        return naceRecord.Id;
    }

    @AuraEnabled
    public static Result getHierarchy(Id recordId) {

        // Dynamically querying the fields to account for any orgs without the wkcc__Status__c custom field
        //String queryFields = 'SELECT Id, ParentLocationId, RootLocationId, Name, LocationLevel, LocationType';
        String queryFields = 'SELECT Id, Parent_Code__c, RootLocationId__c, Name, Level__c, Description__c';
        //if (Schema.Location.sObjectType.getDescribe().fields.getMap().containsKey('wkcc__Status__c')) {
        //    queryFields +=', wkcc__Status__c';
        //}

        Schema.Nace_sectors__c originalLoc = Database.query(queryFields +' FROM Nace_sectors__c WHERE Id =: recordId');

        List<Id> currentParentIds = new List<Id>{originalLoc.RootLocationId__c};
        List<Map<Id, List<Schema.Nace_sectors__c>>> masterList = new List<Map<Id, List<Schema.Nace_sectors__c>>>();

        while (!currentParentIds.isEmpty()) {
            List<Schema.Nace_sectors__c> currentList = Database.query(queryFields +' FROM Nace_sectors__c WHERE Parent_Code__c IN: currentParentIds');
            currentParentIds.clear();

            Map<Id, List<Schema.Nace_sectors__c>> locationMap = new Map<Id, List<Schema.Nace_sectors__c>>();

            for (Schema.Nace_sectors__c currentLoc : currentList) {
                currentParentIds.add(currentLoc.Id);
                List<Schema.Nace_sectors__c> tempList = locationMap.containsKey(currentLoc.Parent_Code__c) ? locationMap.get(currentLoc.Parent_Code__c) : new List<Schema.Nace_sectors__c>();
                tempList.add(currentLoc);
                locationMap.put(currentLoc.Parent_Code__c, tempList);
            }
            if (!locationMap.isEmpty())
                masterList.add(locationMap);
        }
        Result res = new Result();
        res.originalLevel = Integer.valueOf(originalLoc.Level__c);
        res.masterList = masterList;
        res.originalId = recordId;
        res.rootLocation = Database.query(queryFields +' FROM Nace_sectors__c WHERE  Id = \''+ originalLoc.RootLocationId__c+'\'');
        return res;    
    }  
    
    public class Result {
        @AuraEnabled public Integer originalLevel;
        @AuraEnabled public List<Map<Id, List<Schema.Nace_sectors__c>>> masterList;
        @AuraEnabled public Schema.Nace_sectors__c rootLocation;
        @AuraEnabled public Id originalId;
    }     
}