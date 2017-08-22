/*
 * 
 * Purpose : Test class for SPComN_CatalogProductPageCntrl page
 * 
 */
@isTest
public class SPComN_CatalogProductPageCntrlTest {
    
    @TestSetUp
    private static void createSetupData(){
        
        //call method from SPComN_DoorProductDetailCntrlTest class to get relevant data.
        SPComN_DoorProductDetailCntrlTest.createTestSetupData();
        
        
        INSERT new bthousetracker__BBNA_Supplier__c(bthousetracker__Supplier__c = 'Supplier'); 
    }
    
    @isTest
    public static void testRecord(){

		    
        
        User userObj = [SELECT Id, FirstName
                        FROM User
                        WHERE FirstName =: 'Tony'
                        LIMIT 1];
        
        Account accountRecord = [SELECT Id, Name
                                 FROM Account
                                 WHERE Name = 'Buildertek'
                                 LIMIT 1];
        
        bthousetracker__Supplier_Product_Catalog__c newSupplierProductCatalog = [SELECT Id, Name 
                                                                                 FROM bthousetracker__Supplier_Product_Catalog__c 
                                                                                 LIMIT 1];
        
        List<bthousetracker__Supplier_Door_Products__c> listsuppplierDoorProductRecord = [SELECT Id, Name, bthousetracker__Supplier__c, bthousetracker__Door_Description__c, 
                                                                                          bthousetracker__Status__c, bthousetracker__Supplier_Part__c
                                                                                          FROM bthousetracker__Supplier_Door_Products__c
                                                                                          WHERE Name LIKE 'Supplier%'];
       
       
        bthousetracker__Supplier_Component_Types__c supplieComponentTypeRecord = [SELECT Id
                                                                                  FROM bthousetracker__Supplier_Component_Types__c
                                                                                  LIMIT 1];
        
        SPComN_Wrapper.Response catalogProductPageObj;
        bthousetracker__Supplier_Door_Products__c suppplierDoorProduct;
        PageReference pageRef = Page.SPComN_CatalogProductPage;
        
        
        Test.startTest();
        

        	
        
            //getCatalogProducts
            catalogProductPageObj = SPComN_CatalogProductPageCntrl.getCatalogProducts(accountRecord.Id,newSupplierProductCatalog.Id);
            System.assertEquals('Successfully fetched the data', catalogProductPageObj.MessagingStr);
            System.assertEquals(true, catalogProductPageObj.isSuccess);
            
            catalogProductPageObj = SPComN_CatalogProductPageCntrl.getCatalogProducts('','');
            //System.assertEquals('Error while fetching records', catalogProductPageObj.MessagingStr);
            System.assertEquals(false, catalogProductPageObj.isSuccess);
        
            
            //getComponetTypes
            catalogProductPageObj = SPComN_CatalogProductPageCntrl.getComponetTypes(accountRecord.Id);
            System.assertEquals('Successfully fetched the data', catalogProductPageObj.MessagingStr);
            System.assertEquals(true, catalogProductPageObj.isSuccess);    
            System.assertEquals(null, catalogProductPageObj.record);  
        
        	
        	//getImpactedOrders
        	catalogProductPageObj = SPComN_CatalogProductPageCntrl.getImpactedOrders();
            System.assertEquals('Successfully fetched the data', catalogProductPageObj.MessagingStr);
            System.assertEquals(true, catalogProductPageObj.isSuccess);    
            System.assertEquals(null, catalogProductPageObj.record);
        
        
        	//requestForDelete
            String JsonData = '{ "recordId":"'+listsuppplierDoorProductRecord[0].Id+'", "deactivateDate":"07/11/2017", "reasonToDelete":"testReason",  "reasonForNotFulfulling":"reasonNotFullfiltest", "fulfilOrders":"no"}';
           
            catalogProductPageObj = SPComN_CatalogProductPageCntrl.requestForDelete(listsuppplierDoorProductRecord[0].Id, JsonData);
            catalogProductPageObj = SPComN_CatalogProductPageCntrl.requestForDelete(listsuppplierDoorProductRecord[1].Id, JsonData);
        	System.assertEquals('Request has been submitted!', catalogProductPageObj.MessagingStr);
            System.assertEquals(true, catalogProductPageObj.isSuccess);    
            System.assertEquals(null, catalogProductPageObj.record);
        
            
            //getCurrentProduct
            suppplierDoorProduct = SPComN_CatalogProductPageCntrl.getCurrentProduct(listsuppplierDoorProductRecord[0].Id);
        
        
        	//redirectToCatCompPage & redirectToProDetailPage
            pageRef.getParameters().put('status','Pending');
            pageRef.getParameters().put('catalogId1',newSupplierProductCatalog.Id);
            pageRef.getParameters().put('componentTypeId',supplieComponentTypeRecord.Id);
            pageRef.getParameters().put('productId',listsuppplierDoorProductRecord[0].Id);

            Test.setCurrentPage(pageRef);
        	
            SPComN_CatalogProductPageCntrl catalogProductPageObject = new SPComN_CatalogProductPageCntrl();
            catalogProductPageObject.catalogName = newSupplierProductCatalog.Name;
        	catalogProductPageObject.componentTypeId = supplieComponentTypeRecord.Id;
            SPComN_CatalogProductPageCntrl.redirectToCatCompPage();
            catalogProductPageObject.redirectToProDetailPage();
        Test.stopTest();
            
    }

}