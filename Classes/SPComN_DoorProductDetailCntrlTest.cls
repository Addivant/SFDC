/*
@ Purpose : Test class for SPComN_DoorProductDetailCntrl.
@ Created Date : 01-Aug-2017.

*/

@isTest
public class SPComN_DoorProductDetailCntrlTest {
    
    
    //used this method in following class 
    //1) SPComN_ComponentDetailCntrlTest class
    //2) SPComN_CatalogProductPageCntrlTest class
    //3) SPComN_CatalogDetailPageCntrlTest class
    @TestSetup
    public static void createTestSetupData(){
        
        //get Account testSetUp Records from SPComN_ProductCatalogCntrlTest class
        SPComN_ProductCatalogCntrlTest.testSetupRecord();
        
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Buildertek' LIMIT 1 ];
        
        Product2 product = new Product2(Name = 'test Product',
                                        CurrencyIsoCode = 'USD');
        
        INSERT product;
        
        
        
        bthousetracker__Supplier_Product_Catalog__c newSupplierProductCatalog = [SELECT Id FROM bthousetracker__Supplier_Product_Catalog__c LIMIT 1];
        
        bthousetracker__Supplier_Components__c supplierComponent = new bthousetracker__Supplier_Components__c(Name = 'test Supplier Component',
                                                                                                              bthousetracker__Component_Part__c = 'part1234',
                                                                                                              bthousetracker__Status__c = 'Pending',
                                                                                                              bthousetracker__Supplier_Product_Catalog__c = newSupplierProductCatalog.Id);
        
        INSERT supplierComponent;
        
        bthousetracker__Supplier_Component_Types__c supplierComponentTypes = new bthousetracker__Supplier_Component_Types__c(bthousetracker__BBNA_Product_Option__c = supplierComponent.Id,
                                                                                                                             bthousetracker__Description__c = 'Test Description',
                                                                                                                             bthousetracker__Supplier_Id__c = account.Id);
        
        INSERT supplierComponentTypes;
        
        List<bthousetracker__Supplier_Door_Products__c> listSupplierDoorProduct = new List<bthousetracker__Supplier_Door_Products__c>();
        
        for(Integer i=0;i<2;i++){
            
            bthousetracker__Supplier_Door_Products__c supplierDoorProduct;
            
            if(i==0){
                supplierDoorProduct = new bthousetracker__Supplier_Door_Products__c(Name = 'Supplier Door Product' + i,
                                                                                    bthousetracker__Lead_Time__c = 50,
                                                                                    bthousetracker__Supplier__c = account.Id,
                                                                                    bthousetracker__Supplier_Part__c = 'testPart',
                                                                                    bthousetracker__Supplier_Product_Catalog__c =  newSupplierProductCatalog.Id,
                                                                                    bthousetracker__Sourcing_Facility__c = 'Chicago;Dallas',
                                                                                    bthousetracker__Door_Description__c = '3070 Door - Fire',
                                                                                    bthousetracker__Status__c = 'Pending');
                listSupplierDoorProduct.add(supplierDoorProduct);
                
            }else{
                supplierDoorProduct = new bthousetracker__Supplier_Door_Products__c(Name = 'Supplier Door Product' + i,
                                                                                    bthousetracker__Lead_Time__c = 50,
                                                                                    bthousetracker__Supplier__c = account.Id,
                                                                                    bthousetracker__Supplier_Part__c = 'testPart1',
                                                                                    bthousetracker__Supplier_Product_Catalog__c =  newSupplierProductCatalog.Id,
                                                                                    bthousetracker__Sourcing_Facility__c = 'Chicago;Dallas',
                                                                                    bthousetracker__Door_Description__c = '3070 Door - Fire',
                                                                                    bthousetracker__Status__c = 'Active');
                listSupplierDoorProduct.add(supplierDoorProduct);
                
            }
            
            
        }
        
        
        INSERT listSupplierDoorProduct;
        System.debug('listSupplierDoorProduct=='+listSupplierDoorProduct);
        
        bthousetracker__Supplier_Pricing_Table__c supplierPricingTable =  new bthousetracker__Supplier_Pricing_Table__c(bthousetracker__Supplier__c = account.Id,
                                                                                                                        bthousetracker__Cost__c = 10,
                                                                                                                        bthousetracker__Type__c = 'Component',
                                                                                                                        bthousetracker__Supplier_Component__c = supplierComponent.Id,
                                                                                                                        bthousetracker__Supplier_Product__c = listSupplierDoorProduct[0].Id,
                                                                                                                        bthousetracker__Status__c = 'Pending',
                                                                                                                        bthousetracker__Supplier_Product_Catalog__c = newSupplierProductCatalog.Id,
                                                                                                                        bthousetracker__isDelete__c = False);
        
        INSERT supplierPricingTable;
        
        bthousetracker__Supplier_Products_Components__c supplierProductComponent = new bthousetracker__Supplier_Products_Components__c(bthousetracker__Product__c = product.Id,
                                                                                                                                       bthousetracker__Supplier_Component__c = supplierComponent.Id,
                                                                                                                                       bthousetracker__Supplier_Product__c = listSupplierDoorProduct[0].Id);
        
        
        INSERT supplierProductComponent;
        
        bthousetracker__Lead_Time__c leadTime = new bthousetracker__Lead_Time__c(bthousetracker__Supplier_Component__c = supplierComponent.Id,
                                                                                 bthousetracker__Supplier_Door_Product__c = listSupplierDoorProduct[0].Id,
                                                                                 bthousetracker__Man_Lead_Time__c = 10);
        
        INSERT leadTime;
        
    }
    
    
    
    @isTest
    private static void testRecord(){
        
        List<bthousetracker__Supplier_Door_Products__c> listSupplierDoorProduct = [SELECT Id FROM bthousetracker__Supplier_Door_Products__c];
        Account account = [SELECT Id From Account LIMIT 1];
        bthousetracker__Supplier_Product_Catalog__c newSupplierProductCatalog = [SELECT Id FROM bthousetracker__Supplier_Product_Catalog__c LIMIT 1];
        bthousetracker__Supplier_Component_Types__c supplierComponentTypes = [SELECT Id FROM bthousetracker__Supplier_Component_Types__c LIMIT 1];
        
        Test.startTest();
            //checkForRequiredInputs() method of SPComN_DoorProductDetailCntrl class.
            //Param : - Supplier Door Products record Id
            Boolean booleanSupplierDoorProductCheckTrue = SPComN_DoorProductDetailCntrl.checkForRequiredInputs(listSupplierDoorProduct[0].Id);
            Boolean booleanSupplierDoorProductCheckFalse = SPComN_DoorProductDetailCntrl.checkForRequiredInputs(listSupplierDoorProduct[1].Id);
            System.assertEquals(true, booleanSupplierDoorProductCheckTrue);
            System.assertEquals(false, booleanSupplierDoorProductCheckFalse);
            
            
            
            //getCurrentProduct() method of SPComN_DoorProductDetailCntrl class.
            //Param : - Supplier Door Products record Id and account Id.
            SPComN_Wrapper.Response currentProductResponsePositive = SPComN_DoorProductDetailCntrl.getCurrentProduct(listSupplierDoorProduct[0].Id, account.Id);
            
            System.assertEquals('Success in getting records', currentProductResponsePositive.MessagingStr);
            System.assertEquals(true, currentProductResponsePositive.isSuccess);
            
            SPComN_Wrapper.Response currentProductResponseNegative = SPComN_DoorProductDetailCntrl.getCurrentProduct('','');
            
            System.assertEquals('Error: in fetching product details..', currentProductResponseNegative.MessagingStr);
            System.assertEquals(false, currentProductResponseNegative.isSuccess);
            
            
            //getPricingTable() method of SPComN_DoorProductDetailCntrl class.
            //Param : - Supplier Door Products record Id and account Id.
            SPComN_Wrapper.Response pricingTableResponsePositive = SPComN_DoorProductDetailCntrl.getPricingTable(listSupplierDoorProduct[0].Id, account.Id);
            
            System.assertEquals('Success: In get Pricing Details', pricingTableResponsePositive.MessagingStr);
            System.assertEquals(true, pricingTableResponsePositive.isSuccess);
            
            SPComN_Wrapper.Response pricingTableResponseNegative = SPComN_DoorProductDetailCntrl.getPricingTable('', '');
            
            System.assertEquals('Error: in fetching Pricing details', pricingTableResponseNegative.MessagingStr);
            System.assertEquals(false,pricingTableResponseNegative.isSuccess);
            
            
            //getProductsNComponents() method of SPComN_DoorProductDetailCntrl class.
            //Param : - Supplier Door Products record Id and account Id.
            SPComN_Wrapper.Response productsNComponentsResponsePositive = SPComN_DoorProductDetailCntrl.getProductsNComponents(listSupplierDoorProduct[0].Id, account.Id);
            System.assertEquals('Success: In getting Assiggned Components Details', productsNComponentsResponsePositive.MessagingStr);
            System.assertEquals(true, productsNComponentsResponsePositive.isSuccess);
            
            SPComN_Wrapper.Response productsNComponentsResponseNegative = SPComN_DoorProductDetailCntrl.getProductsNComponents('', '');
            System.assertEquals('Error: in fetching Assiggned Components details', productsNComponentsResponseNegative.MessagingStr);
            System.assertEquals(false, productsNComponentsResponseNegative.isSuccess);
            
            
            //getLeadTimes() method of SPComN_DoorProductDetailCntrl class.
            //Param : - Supplier Door Products record Id and account Id.
            SPComN_Wrapper.Response leadTimesResponsePositive = SPComN_DoorProductDetailCntrl.getLeadTimes(listSupplierDoorProduct[0].Id);
            System.assertEquals('Success: In getting Lead Time Details', leadTimesResponsePositive.MessagingStr);
            System.assertEquals(true, leadTimesResponsePositive.isSuccess);
            
            SPComN_Wrapper.Response leadTimesResponseNegative = SPComN_DoorProductDetailCntrl.getLeadTimes('');
            System.assertEquals('Error: in fetching Lead Time details', leadTimesResponseNegative.MessagingStr);
            System.assertEquals(false, leadTimesResponseNegative.isSuccess);
            
            ///getImpactedOrders() method of SPComN_DoorProductDetailCntrl class.
            SPComN_Wrapper.Response impactedOrdersResponse = SPComN_DoorProductDetailCntrl.getImpactedOrders();
            System.assertEquals('Successfully fetched the data',impactedOrdersResponse.MessagingStr);
            System.assertEquals(true,impactedOrdersResponse.isSuccess);
            
            //requestForDelete() method of SPComN_DoorProductDetailCntrl class.
            //Param - Supplier Door Products record Id and JSONStr.
            String JSONStr = '{ "id":"'+listSupplierDoorProduct[0].Id +'", "name":"test", "activeDate":"07/11/2017" }';
            SPComN_Wrapper.Response requestForDeleteResponse = SPComN_DoorProductDetailCntrl.requestForDelete(listSupplierDoorProduct[0].Id, JSONStr);
            
            //getComponetTypes() method of SPComN_DoorProductDetailCntrl class.
            //Param:- AccountId
            SPComN_Wrapper.Response componetTypesResponse = SPComN_DoorProductDetailCntrl.getComponetTypes(account.Id);  
            System.assertEquals('Successfully fetched the data',componetTypesResponse.MessagingStr);
            System.assertEquals(true,componetTypesResponse.isSuccess);
            
            
            
            //SPComN_DoorProductDetailPage
            PageReference pageRef = Page.SPComN_DoorProductDetailPage;
            pageRef.getParameters().put('status','Pending');
            pageRef.getParameters().put('productId',listSupplierDoorProduct[0].Id);
            pageRef.getParameters().put('catalogId1',supplierComponentTypes.Id); 
            
            Test.setCurrentPage(pageRef);
            
            SPComN_DoorProductDetailCntrl doorProductDetailObject = new SPComN_DoorProductDetailCntrl();
            SPComN_DoorProductDetailCntrl.redirectToCatCompPage();
            doorProductDetailObject.redirectToCatProductPage();
            
            
            
            //sendProductForApproval() method of SPComN_DoorProductDetailCntrl class.
            //Param : - Supplier Door Products record Id and effective Date.
            SPComN_Wrapper.Response sendProductForApprovalResponcePositive = SPComN_DoorProductDetailCntrl.sendProductForApproval(listSupplierDoorProduct[0].Id, '07/11/2017');
            System.assertEquals('Request has been submitted', sendProductForApprovalResponcePositive.MessagingStr);
            System.assertEquals(true, sendProductForApprovalResponcePositive.isSuccess);
            
            SPComN_Wrapper.Response sendProductForApprovalResponceNegative = SPComN_DoorProductDetailCntrl.sendProductForApproval('', '');
            System.assertEquals('Product Id not present', sendProductForApprovalResponceNegative.MessagingStr);
            System.assertEquals(false, sendProductForApprovalResponceNegative.isSuccess);
        Test.stopTest();
        
    }
    
}