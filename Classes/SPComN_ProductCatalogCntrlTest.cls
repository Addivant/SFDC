/*
@ Purpose : Test class for SPComN_ProductCatalogCntrl.
@ Created Date : 31-07-2017.

*/

@isTest
public class SPComN_ProductCatalogCntrlTest {
    
    @TestSetup
    public static void testSetupRecord(){//used this method in SPComN_DoorProductDetailCntrlTest class
        
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
        
        User getUser = [SELECT Id, Name 
                        FROM User 
                        WHERE FirstName = 'Tony' LIMIT 1];
        
        Account account = new Account(Name = 'Buildertek',
                                      Type = 'Owner',
                                      CurrencyIsoCode = 'USD',
                                      CAM__c = getUser.Id,
                                      Territory__c = 'North America',
                                      Physical_Country__c = 'United States');
        
        INSERT account;
        
        List<bthousetracker__Supplier_Product_Category__c>  listSupplierProductCategory = new List<bthousetracker__Supplier_Product_Category__c>();
    
        
        for(Integer i=0;i<4;i++){
            
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
                                                                                                                             bthousetracker__BBNA_Status__c = 'Pending',
                                                                                                                             bthousetracker__Activate_Date__c = System.today(),
                                                                                                                             bthousetracker__Supplier__c = account.Id);
        
        listsSupplierProductCatalog.add(supplierProductCatalog);
        bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog1 = new bthousetracker__Supplier_Product_Catalog__c(Name = 'testproduct'+2,
                                                                                                                              bthousetracker__BBNA_Product_Category__c = listSupplierProductCategory[1].Id,
                                                                                                                              bthousetracker__Status__c = 'Active',
                                                                                                                              bthousetracker__BBNA_Status__c = 'Approved',
                                                                                                                              bthousetracker__Activate_Date__c = System.today(),
                                                                                                                              bthousetracker__Supplier__c = account.Id);
        listsSupplierProductCatalog.add(supplierProductCatalog1);
        
        bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog2 = new bthousetracker__Supplier_Product_Catalog__c(Name = 'Supplier Product Catalog 3',
                                                                                                                             bthousetracker__BBNA_Product_Category__c = listSupplierProductCategory[2].Id,
                                                                                                                             bthousetracker__Status__c = 'Pending',
                                                                                                                             bthousetracker__Activate_Date__c = System.today(),
                                                                                                                             bthousetracker__Supplier__c = account.Id);
        
        listsSupplierProductCatalog.add(supplierProductCatalog2);
        bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog3 = new bthousetracker__Supplier_Product_Catalog__c(Name = 'Supplier Product Catalog 4',
                                                                                                                              bthousetracker__BBNA_Product_Category__c = listSupplierProductCategory[3].Id,
                                                                                                                              bthousetracker__Status__c = 'Active',
                                                                                                                              bthousetracker__Activate_Date__c = System.today(),
                                                                                                                              bthousetracker__Supplier__c = account.Id);
        listsSupplierProductCatalog.add(supplierProductCatalog3);
        
        INSERT supplierProductCatalog;
        INSERT supplierProductCatalog1;
        System.debug('listsSupplierProductCatalog=='+listsSupplierProductCatalog.size());
        
    }
    
    //
    @isTest
    private static void testRecord(){
        
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        
        bthousetracker__Supplier_Product_Category__c categoryRec = [SELECT Id, Name 
                                                                    FROM bthousetracker__Supplier_Product_Category__c 
                                                                    LIMIT 1];
        
        List<bthousetracker__Supplier_Product_Catalog__c> listSupplierProductCatalog = [SELECT Id, Name, 
                                                                                        bthousetracker__BBNA_Product_Category__c,
                                                                                        bthousetracker__Status__c, 
                                                                                        bthousetracker__Activate_Date__c
                                                                                        FROM bthousetracker__Supplier_Product_Catalog__c];
        
        
        SPComN_Wrapper.Response wrapperResponse;
        
        Test.startTest();
        
        //getCatalogs
        wrapperResponse = SPComN_ProductCatalogCntrl.getCatalogs(acc.Id, listSupplierProductCatalog[0].Id,
                                                                 listSupplierProductCatalog[0].bthousetracker__BBNA_Product_Category__c);
        System.assertEquals('Successfully fetched the data', wrapperResponse.MessagingStr);
        System.assertEquals(true, wrapperResponse.isSuccess);
        wrapperResponse = SPComN_ProductCatalogCntrl.getCatalogs('', '', '');
        System.assertEquals('Error in Fetching records', wrapperResponse.MessagingStr);
        System.assertEquals(false, wrapperResponse.isSuccess);
        
        
      	//updateCatalogProducts
        String jsonRecord = '[{"id":"'+listSupplierProductCatalog[0].Id+'","name":"'+listSupplierProductCatalog[0].Name+'","activeDate":"07/08/2017"},{"id":"'+listSupplierProductCatalog[1].Id+'","name":"'+listSupplierProductCatalog[1].Name+'","activeDate":"07/08/2017"}]';
        wrapperResponse = SPComN_ProductCatalogCntrl.updateCatalogProducts(jsonRecord);
 
        
        //redirectToDetailPage
        PageReference pageRef = Page.SPComN_ProductCatalog;
        pageRef.getParameters().put('status1',listSupplierProductCatalog[0].bthousetracker__Status__c);
        pageRef.getParameters().put('catalogId1',listSupplierProductCatalog[0].Id);        
        Test.setCurrentPage(pageRef);
        SPComN_ProductCatalogCntrl productCatalogCtrlObject = new SPComN_ProductCatalogCntrl();
        productCatalogCtrlObject.catalogId = listSupplierProductCatalog[0].Id;
        productCatalogCtrlObject.redirectToDetailPage();
        
               
        //doApproval
        for(bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog : listSupplierProductCatalog){
                                                                                      
            wrapperResponse = SPComN_ProductCatalogCntrl.doApproval(supplierProductCatalog.Id);
             
            System.assertEquals('Request has been submitted.', wrapperResponse.MessagingStr);
            System.assertEquals(true, wrapperResponse.isSuccess);
            System.assertEquals(null, wrapperResponse.record);
            
        }
        
        wrapperResponse = SPComN_ProductCatalogCntrl.doApproval('');
        
        
        
        //archiveCatalog
        for(bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog : listSupplierProductCatalog){
            
            //SPComN_Wrapper.Response wrapperResponse;
            if(supplierProductCatalog.bthousetracker__Status__c == 'Pending'){
                
                wrapperResponse = SPComN_ProductCatalogCntrl.archiveCatalog(supplierProductCatalog.Id);
                System.assertEquals('Catalog has been deleted.', wrapperResponse.MessagingStr);
                System.assertEquals(true, wrapperResponse.isSuccess);
                System.assertEquals(null, wrapperResponse.record);
            }
            else{
                wrapperResponse = SPComN_ProductCatalogCntrl.archiveCatalog(supplierProductCatalog.Id);
                System.assertEquals('Only pending catalogs can be deleted.', wrapperResponse.MessagingStr);
                System.assertEquals(false, wrapperResponse.isSuccess);
                System.assertEquals(null, wrapperResponse.record);
            }
        }
        wrapperResponse = SPComN_ProductCatalogCntrl.archiveCatalog('');
        System.assertEquals('unable to find catalog..', wrapperResponse.MessagingStr);
        System.assertEquals(false, wrapperResponse.isSuccess);
        System.assertEquals(null, wrapperResponse.record);
        wrapperResponse = SPComN_ProductCatalogCntrl.archiveCatalog(categoryRec.Id);
        
       
        //saveCatalog
        for(bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog : listSupplierProductCatalog){
             wrapperResponse = SPComN_ProductCatalogCntrl.saveCatalog(supplierProductCatalog.Id, supplierProductCatalog.Name, '07/11/2017');
        }
        
        Test.stopTest();
       
    }
    
}