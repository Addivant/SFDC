/*
 * 
 * 
*/


@isTest
public class SPComN_CatalogComponentsPageCntrlTest {
        @TestSetup
        public static void testSetupRecord(){
            
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Chatter External User' LIMIT 1];
        
            User newUser = new User(FirstName = 'Tony',
                                    LastName = 'Stark',
                                    Email = 'Tony@amamama.com',
                                    Username = 'tonystark@amam.com',
                                    CompanyName = 'TEST',
                                    Title = 'title',
                                    Alias = 'alias',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    EmailEncodingKey = 'UTF-8',
                                    LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US',
                                    ProfileId = profileId.Id);
            
            INSERT newUser;
            
            User getUser = [SELECT Id, Name FROM User WHERE FirstName = 'Tony' LIMIT 1];
            
            Account account = new Account(Name = 'TestAccount',
                                          Type = 'Owner',
                                          CurrencyIsoCode = 'USD',
                                          CAM__c = getUser.Id,
                                          Territory__c = 'North America',
                                          Physical_Country__c = 'United States');
            
            INSERT account;
            
            Product2 product = new Product2(Name = 'test Product',
                                            CurrencyIsoCode = 'USD');
            
            INSERT product;
            
    
            List<bthousetracker__Supplier_Product_Category__c>  listSupplierProductCategory = new List<bthousetracker__Supplier_Product_Category__c>();
    
        
            for(Integer i=0;i<2;i++){
                
                bthousetracker__Supplier_Product_Category__c newSupplierProductCategory;
                if(i/2==0){
                    newSupplierProductCategory = new bthousetracker__Supplier_Product_Category__c(Name='Supplier' + i,
                                                                                                  bthousetracker__Supplier__c = account.Id);
                    listSupplierProductCategory.add(newSupplierProductCategory);
                }else{
                    newSupplierProductCategory = new bthousetracker__Supplier_Product_Category__c(Name='Product' + i,
                                                                                                  bthousetracker__Supplier__c = account.Id);
                    listSupplierProductCategory.add(newSupplierProductCategory);
                }
            }
            
            INSERT listSupplierProductCategory;
            
            List<bthousetracker__Supplier_Product_Catalog__c> listsSupplierProductCatalog = new List<bthousetracker__Supplier_Product_Catalog__c>();
            
            bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog = new bthousetracker__Supplier_Product_Catalog__c(Name = 'testproduct'+1,
                                                                                                                                 bthousetracker__BBNA_Product_Category__c = listSupplierProductCategory[0].Id,
                                                                                                                                 bthousetracker__Status__c = 'Pending',
                                                                                                                                 bthousetracker__Activate_Date__c = System.today(),
                                                                                                                                 bthousetracker__Supplier__c = account.Id);
            
            listsSupplierProductCatalog.add(supplierProductCatalog);
            
            /*bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog1 = new bthousetracker__Supplier_Product_Catalog__c(Name = 'testproduct2'+2,
                                                                                                                                  bthousetracker__BBNA_Product_Category__c = listSupplierProductCategory[1].Id,
                                                                                                                                  bthousetracker__Status__c = 'Active',
                                                                                                                                  bthousetracker__Activate_Date__c = System.today(),
                                                                                                                                  bthousetracker__Supplier__c = account.Id);
            listsSupplierProductCatalog.add(supplierProductCatalog1);*/
            
            INSERT listsSupplierProductCatalog;
            
            bthousetracker__Supplier_Product_Catalog__c newSupplierProductCatalog = [SELECT Id FROM bthousetracker__Supplier_Product_Catalog__c LIMIT 1];
            
            List<bthousetracker__Supplier_Components__c> supplierComponentList = new List<bthousetracker__Supplier_Components__c>();
            
            bthousetracker__Supplier_Components__c supplierComponent;
            for(Integer i = 0; i < 2; i++){
                if(i==0){
                    supplierComponent = new bthousetracker__Supplier_Components__c(Name = 'test Supplier Component '+i,
                                                                                   bthousetracker__Component_Part__c = 'testPart',
                                                                                   bthousetracker__Status__c = 'Pending',
                                                                                   bthousetracker__isDelete__c = false,
                                                                                   bthousetracker__Reason_For_Delete__c = 'testDelete1',
                                                                                   bthousetracker__Planing_To_Fulfil_Orders__c = false);
                    supplierComponentList.add(supplierComponent);
                }else{
                    supplierComponent = new bthousetracker__Supplier_Components__c(Name = 'test Supplier Component '+i,
                                                                                   bthousetracker__Component_Part__c = 'testPart',
                                                                                   bthousetracker__Status__c = 'Active',
                                                                                   bthousetracker__isDelete__c = false,
                                                                                   bthousetracker__Reason_For_Delete__c = 'testDelete2',
                                                                                   bthousetracker__Planing_To_Fulfil_Orders__c = false);
                    supplierComponentList.add(supplierComponent);
                    
                }
            }
            
            INSERT supplierComponentList;
            
            bthousetracker__Supplier_Component_Types__c supplierComponentType = new bthousetracker__Supplier_Component_Types__c(bthousetracker__BBNA_Product_Option__c = supplierComponent.Id,
                                                                                                                                bthousetracker__Description__c = 'Test Description',
                                                                                                                                bthousetracker__Supplier_Id__c = account.Id);
            
            INSERT supplierComponentType;      
            
            bthousetracker__Supplier_Door_Products__c supplierDoorProduct = new bthousetracker__Supplier_Door_Products__c(Name = 'Supplier Door Product',
                                                                                                                          bthousetracker__Lead_Time__c = 10,
                                                                                                                          bthousetracker__Supplier__c = account.Id,
                                                                                                                          bthousetracker__Supplier_Product_Catalog__c = newSupplierProductCatalog.Id,
                                                                                                                          bthousetracker__Sourcing_Facility__c = 'Chicago',
                                                                                                                          bthousetracker__Supplier_Part__c = '10');
                
           INSERT supplierDoorProduct;
        }

        @isTest
        private static void positiveTest(){
            
            bthousetracker__Supplier_Product_Catalog__c catalogRec = [SELECT Id, Name 
                                                                      FROM bthousetracker__Supplier_Product_Catalog__c 
                                                                      LIMIT 1];
        
            bthousetracker__Supplier_Component_Types__c supplierComponentTypeRec = [SELECT Id, Name 
                                                                             FROM bthousetracker__Supplier_Component_Types__c
                                                                             LIMIT 1];
            
            List<bthousetracker__Supplier_Components__c> supplierComponentRecList = [SELECT Id, Name, bthousetracker__Component_Part__c, bthousetracker__Status__c
                                                                                     FROM bthousetracker__Supplier_Components__c];
            
            
            Account accountRec = [SELECT Id, Name 
                                  FROM account
                                  LIMIT 1]; 
            
            SPComN_Wrapper.Response wrapperResponseObj = new SPComN_Wrapper.Response();
                                                                             
            Test.startTest();
            PageReference pageRef = Page.SPComN_CatalogComponentsPage;
            pageRef.getParameters().put('componentTypeId',supplierComponentTypeRec.Id);
            pageRef.getParameters().put('catalogId',catalogRec.Id);   
            pageRef.getParameters().put('status','Pending'); 
            pageRef.getParameters().put('componentId',supplierComponentRecList[0].Id); 
            Test.setCurrentPage(pageRef);
           
            
            SPComN_CatalogComponentsPageCntrl productCatalogCtrlObject = new SPComN_CatalogComponentsPageCntrl();
            productCatalogCtrlObject.redirectToCatCompPage();
            productCatalogCtrlObject.redirectToCompDetailPage();
            productCatalogCtrlObject.redirectToCatProductPage();
            SPComN_CatalogComponentsPageCntrl.redirectToCatDetailPage();
            SPComN_CatalogComponentsPageCntrl.getComponetTypes(supplierComponentTypeRec.Id);
            SPComN_CatalogComponentsPageCntrl.getImpactedOrders();
            //getComponets
            wrapperResponseObj = SPComN_CatalogComponentsPageCntrl.getComponets(accountRec.Id,catalogRec.Id,supplierComponentTypeRec.Id);
            System.assertEquals('Successfully fetched the data', wrapperResponseObj.MessagingStr);
            System.assertEquals(true, wrapperResponseObj.isSuccess);
            
            wrapperResponseObj = SPComN_CatalogComponentsPageCntrl.getComponets('','','');
            System.assertEquals('Error while fetching records', wrapperResponseObj.MessagingStr);
            System.assertEquals(false, wrapperResponseObj.isSuccess);
            
            
            String JsonData1 = '{"recordId":"'+supplierComponentRecList[0].Id+'","deactivateDate":"08/08/2017","reasonToDelete":"testDelete1","fulfilOrders":false}';
            wrapperResponseObj = SPComN_CatalogComponentsPageCntrl.requestForDelete(supplierComponentRecList[0].Id, JsonData1);
            System.assertEquals('This is the only component for this null. Please add another component before deleting this one.', wrapperResponseObj.MessagingStr);
            System.assertEquals(false, wrapperResponseObj.isSuccess);
            
               
            String JsonData2 = '{"recordId":"'+supplierComponentRecList[1].Id+'","deactivateDate":"08/08/2017","reasonToDelete":"testDelete2","fulfilOrders":false}';          
            wrapperResponseObj = SPComN_CatalogComponentsPageCntrl.requestForDelete(supplierComponentRecList[1].Id, JsonData2);
            System.assertEquals('Request has been submitted!', wrapperResponseObj.MessagingStr);
            System.assertEquals(true, wrapperResponseObj.isSuccess);
            
            //productCatalogCtrlObject.redirectToDetailPage();
            Test.stopTest();
        }   
    
}