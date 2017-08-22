/*
@ Purpose : Test class for SPComN_ComponentDetailCntrl.
@ Created Date : 01-Aug-2017.

*/
@isTest
public class SPComN_ComponentDetailCntrlTest {
    
    @TestSetup
    private static void createTestSetup(){
        
        //get Supplier Product component records for wrapper class testing.  
        SPComN_DoorProductDetailCntrlTest.createTestSetupData();
        
        Account accountRecord = [SELECT Id
                                 FROM Account
                                 LIMIT 1];
        
        bthousetracker__Supplier_Components__c supplierComponentsRecord = new bthousetracker__Supplier_Components__c(Name = 'Supplier Component 1',
                                                                                                                     bthousetracker__Component_Part__c = 'testPart',
                                                                                                                     bthousetracker__Status__c = 'Pending');
        
        INSERT supplierComponentsRecord;
        
        bthousetracker__Supplier_Components__c supplierComponentsRecord2 = new bthousetracker__Supplier_Components__c(Name = 'Supplier Component 2',
                                                                                                                     bthousetracker__Component_Part__c = 'testPart',
                                                                                                                     bthousetracker__Status__c = 'Active');
        
        INSERT supplierComponentsRecord2;
        
        bthousetracker__Lead_Time__c leadTime = new bthousetracker__Lead_Time__c();
            leadTime.bthousetracker__Supplier_Component__c = supplierComponentsRecord.Id;
            leadTime.bthousetracker__Man_Lead_Time__c = 15; 
            leadTime.bthousetracker__Lead_Time__c = 10; 
            leadTime.bthousetracker__Sourcing_Facility_Single__c = 'Chicago';
        INSERT leadTime;
        
        bthousetracker__Supplier_Pricing_Table__c supplierPricingTable =  new bthousetracker__Supplier_Pricing_Table__c(); 
            supplierPricingTable.bthousetracker__Supplier__c = accountRecord.Id;
            supplierPricingTable.bthousetracker__Cost__c = 10;
            supplierPricingTable.bthousetracker__Type__c = 'Component';
            supplierPricingTable.bthousetracker__Supplier_Component__c = supplierComponentsRecord.Id;
            supplierPricingTable.bthousetracker__Status__c = 'Pending';
            supplierPricingTable.bthousetracker__isDelete__c = False;
        INSERT supplierPricingTable;
    }
    
    @isTest()
    private static void testRecord(){
        
        bthousetracker__Supplier_Components__c newSupplierComponentRecord = [SELECT Id, Name, bthousetracker__Component_Part__c, bthousetracker__Status__c
                                                                             FROM bthousetracker__Supplier_Components__c 
                                                                             WHERE Name = 'Supplier Component 1'
                                                                             LIMIT 1];
        
        
        bthousetracker__Supplier_Components__c newSupplierComponentRecord2 = [SELECT Id, Name, bthousetracker__Component_Part__c, bthousetracker__Status__c
                                                                             FROM bthousetracker__Supplier_Components__c 
                                                                             WHERE Name = 'Supplier Component 2'
                                                                             LIMIT 1];
        
        System.debug('newSupplierComponentRecord'+newSupplierComponentRecord);
        bthousetracker__Lead_Time__c leadTimerRecord = [SELECT Id
                                                        FROM bthousetracker__Lead_Time__c
                                                        LIMIT 1]; 
        
        
        Account accountRecord = [SELECT Id
                                 FROM Account
                                 LIMIT 1];
        
        
        bthousetracker__Supplier_Products_Components__c supplierProductComponentObj = [SELECT Id, bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c, 
                                                                                       			  bthousetracker__Supplier_Product__r.bthousetracker__Door_Description__c
                                                                                       FROM bthousetracker__Supplier_Products_Components__c
                                                                                       LIMIT 1];
        
        bthousetracker__Supplier_Product_Catalog__c newSupplierProductCatalogobj = [SELECT Id 
                                                                                    FROM bthousetracker__Supplier_Product_Catalog__c 
                                                                                    LIMIT 1];
        
        bthousetracker__Supplier_Component_Types__c supplierComponentTypeObj = [SELECT Id 
                                                                                FROM bthousetracker__Supplier_Component_Types__c 
                                                                                LIMIT 1];
        
        PageReference pageRef = Page.SPComN_ComponentDetailPage;
        
        SPComN_Wrapper.Response componentDetailCntrlResponceObj;
        
        Test.startTest();
        	
        	//getComponentDetails
            componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getComponentDetails(newSupplierComponentRecord.Id);
            System.assertEquals('Success: In fetching component details', componentDetailCntrlResponceObj.MessagingStr);
            System.assertEquals(true, componentDetailCntrlResponceObj.isSuccess );
            
            componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getComponentDetails('');
            System.assertEquals('Error: In fetching component details', componentDetailCntrlResponceObj.MessagingStr);
            System.assertEquals(false, componentDetailCntrlResponceObj.isSuccess );
        	
        
        	//getLeadTime
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getLeadTime(accountRecord.Id, newSupplierComponentRecord.Id);
        	System.assertEquals('Successfully fetched the data', componentDetailCntrlResponceObj.MessagingStr);
            System.assertEquals(true, componentDetailCntrlResponceObj.isSuccess );
        
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getLeadTime('','');
        	System.assertEquals('Error: In fetching Lead time details', componentDetailCntrlResponceObj.MessagingStr);
            System.assertEquals(false, componentDetailCntrlResponceObj.isSuccess );
        	
        
        	//getPricings
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getPricings(accountRecord.Id, newSupplierComponentRecord.Id);
        	System.assertEquals('Successfully fetched the data', componentDetailCntrlResponceObj.MessagingStr);
            System.assertEquals(true, componentDetailCntrlResponceObj.isSuccess );
        
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getPricings('', '');
        	System.assertEquals('Error while fetching records', componentDetailCntrlResponceObj.MessagingStr);
            System.assertEquals(false, componentDetailCntrlResponceObj.isSuccess );
				
			
        	//requestForDelete
        	String JsonData = '{"recordId":"'+newSupplierComponentRecord.Id+'","deactivateDate":"07/11/2017","reasonToDelete":"test delete","fulfilOrders":true}';
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.requestForDelete(newSupplierComponentRecord.Id, JsonData);
        	System.assertEquals('This is the only component for this null. Please add another component before deleting this one.',componentDetailCntrlResponceObj.MessagingStr);
        	System.assertEquals(false,componentDetailCntrlResponceObj.isSuccess);
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.requestForDelete(newSupplierComponentRecord2.Id, JsonData);
			System.assertEquals('Request has been submitted!',componentDetailCntrlResponceObj.MessagingStr);
        	System.assertEquals(true,componentDetailCntrlResponceObj.isSuccess);        
				        
        	//getProductRules
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getProductRules(accountRecord.Id, newSupplierComponentRecord.Id);
        	System.assertEquals('Success: In fetching Assigned Products', componentDetailCntrlResponceObj.MessagingStr);
            System.assertEquals(true, componentDetailCntrlResponceObj.isSuccess );
        
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getProductRules('', '');
        	System.assertEquals('Error: In fetching Assigned Products', componentDetailCntrlResponceObj.MessagingStr);
            System.assertEquals(false, componentDetailCntrlResponceObj.isSuccess );
        	
        
        	//getImpactedOrders
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getImpactedOrders();
        	System.assertEquals('Successfully fetched the data', componentDetailCntrlResponceObj.MessagingStr);
        	System.assertEquals(true, componentDetailCntrlResponceObj.isSuccess );
        	System.assertEquals(null, componentDetailCntrlResponceObj.record );
        	
        
        	//getComponetTypes
        	componentDetailCntrlResponceObj = SPComN_ComponentDetailCntrl.getComponetTypes(accountRecord.Id);
        	System.assertEquals('Successfully fetched the data', componentDetailCntrlResponceObj.MessagingStr);
        	System.assertEquals(true, componentDetailCntrlResponceObj.isSuccess );
        	System.assertEquals(null, componentDetailCntrlResponceObj.record );
			
        	//redirectToCatCompPage()
        	
            pageRef.getParameters().put('status','Pending');
            pageRef.getParameters().put('catalogId',newSupplierProductCatalogObj.Id);
            pageRef.getParameters().put('componentTypeId',supplierComponentTypeObj.Id); 
            
            Test.setCurrentPage(pageRef);
            
            SPComN_ComponentDetailCntrl componentDetailObject = new SPComN_ComponentDetailCntrl();
            SPComN_ComponentDetailCntrl.redirectToCatCompPage();
            componentDetailObject.redirectToCatProductPage();

        
        	//ProductRuleWrapper Wrapper Class
        	SPComN_ComponentDetailCntrl.ProductRuleWrapper productRuleWrapper = new SPComN_ComponentDetailCntrl.ProductRuleWrapper(supplierProductComponentObj);
        	
        	
        Test.stopTest();
	
    
    }

}