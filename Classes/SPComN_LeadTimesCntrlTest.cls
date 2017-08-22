@isTest
public class SPComN_LeadTimesCntrlTest {
    
    @TestSetup
    private static void createTestRecords(){
        
        SPComN_DoorProductDetailCntrlTest.createTestSetupData();
        
        
    }
    
    @isTest
    private static void testData(){

        bthousetracker__Supplier_Product_Catalog__c supplierProductCatalogRecord = [SELECT Id, bthousetracker__Supplier__c
                                                                                    FROM bthousetracker__Supplier_Product_Catalog__c
                                                                                    LIMIT 1];
        
        bthousetracker__Supplier_Door_Products__c supplierDoorProductRecord = [SELECT Id, Name
                                                                               FROM bthousetracker__Supplier_Door_Products__c
                                                                               LIMIT 1];
        
        System.debug('supplierDoorProductRecord=='+supplierDoorProductRecord);
        
        SPComN_LeadTimesCntrl leadTimeClassObj = new SPComN_LeadTimesCntrl();
        SPComN_Wrapper.Response wrapperResponseObj = new SPComN_Wrapper.Response();
        
        //getPartsIds
        Set<Id> getPartsIds = SPComN_LeadTimesCntrl.getPartsIds(supplierProductCatalogRecord.Id);
        System.assertEquals(2, getPartsIds.size());
        
        getPartsIds = SPComN_LeadTimesCntrl.getPartsIds('');
        System.assertEquals(null, getPartsIds);
        
        //getLeadTimes
        String jsonString = '{"catalogId":"'+supplierProductCatalogRecord.Id+'"}';
        
        wrapperResponseObj = SPComN_LeadTimesCntrl.getLeadTimes(jsonString);
        System.assertEquals(null, wrapperResponseObj.MessagingStr);
        System.assertEquals(true, wrapperResponseObj.isSuccess);
        
      
        List<bthousetracker__Lead_Time__c> leadTime = [SELECT Id, bthousetracker__Man_Lead_Time__c, bthousetracker__Supplier_Door_Product__r.bthousetracker__Supplier_Part__c,
                                                              bthousetracker__Sourcing_Facility_Single__c, bthousetracker__Supplier_Door_Product__r.Name 
                                                       FROM bthousetracker__Lead_Time__c];
        
        SPComN_LeadTimesCntrl.CatalogLeadTimeWrraper leadTimewrap = new SPComN_LeadTimesCntrl.CatalogLeadTimeWrraper(leadTime[0]);

        //updateLeadTime	
        List<SPComN_LeadTimesCntrl.CatalogLeadTimeWrraper> listWrap = new List<SPComN_LeadTimesCntrl.CatalogLeadTimeWrraper>{leadTimewrap};
            
        String leadTimeJson = JSON.serialize(listWrap);                            
        Map<String, String> jsonMap = new Map<String, String>{'catalogId' => supplierProductCatalogRecord.id , 'leadTimeJson' => leadTimeJson};
        String paramJson = JSON.serialize(jsonMap);    
        wrapperResponseObj = SPComN_LeadTimesCntrl.updateLeadTime(paramJson);
        System.assertEquals('Data is saved successfully', wrapperResponseObj.MessagingStr);
        System.assertEquals(true, wrapperResponseObj.isSuccess);
        
       
        //getCatalogProducts
        wrapperResponseObj = SPComN_LeadTimesCntrl.getCatalogProducts(supplierProductCatalogRecord.Id, supplierProductCatalogRecord.bthousetracker__Supplier__c);
        System.assertEquals('Successfully fetched the data', wrapperResponseObj.MessagingStr);
        System.assertEquals(true, wrapperResponseObj.isSuccess);
        
        //createLeadTime
        String jsonData =  '{"leadTime":"10","parts":[{ "id":"'+supplierDoorProductRecord.Id+'", "sourcing":"Chicago"}]}';
        wrapperResponseObj = SPComN_LeadTimesCntrl.createLeadTime(supplierProductCatalogRecord.bthousetracker__Supplier__c, jsonData);
        System.assertEquals('Success: In creating LeadTime', wrapperResponseObj.MessagingStr);
        System.assertEquals(true, wrapperResponseObj.isSuccess);
        
        //deleteLeadTime
        wrapperResponseObj = SPComN_LeadTimesCntrl.deleteLeadTime(leadTime[0].Id);
        System.assertEquals('Success: In deleting record', wrapperResponseObj.MessagingStr);
        System.assertEquals(true, wrapperResponseObj.isSuccess);
        
        wrapperResponseObj = SPComN_LeadTimesCntrl.deleteLeadTime('');
        System.assertEquals('Error: In deleting record', wrapperResponseObj.MessagingStr);
        System.assertEquals(false, wrapperResponseObj.isSuccess);
    }

}