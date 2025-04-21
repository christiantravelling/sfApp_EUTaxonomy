@isTest(SeeAllData=true)
public with sharing class LocationTreeControllerTest {
    
    @isTest(SeeAllData=true)
    public static void doTest() {
        List<Nace_sectors__c> naceRootID = new List<Nace_sectors__c>([SELECT Id FROM Nace_sectors__c WHERE External_Id__c = 'extID-999999']);
        //System.debug(naceRootID);
        ID nrId = naceRootID[0].Id;
        //Id naceRootID = [SELECT Id FROM Nace_sectors__c WHERE External_Id__c = 'extID-999999' LIMIT 1].Id;
        //System.debug('CG:: ID is ' + naceRootID.to15());
        
        Schema.Nace_sectors__c loc = new Schema.Nace_sectors__c(
            Name='Test NACE',
            RootLocationId__c = naceRootID[0].Id,
            Parent_Code__c = naceRootID[0].Id
            );
        insert loc;
        LocationTreeController.getHierarchy(loc.id);
    }
    
}