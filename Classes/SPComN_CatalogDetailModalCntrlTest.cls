@isTest
public class SPComN_CatalogDetailModalCntrlTest {
    
    @isTest
    private static void testRecord(){
        
        SPComN_ProductCatalogCntrlTest.testSetupRecord();
        
        bthousetracker__Supplier_Product_Catalog__c newSupplierProductCatalog = [SELECT Id, Name FROM bthousetracker__Supplier_Product_Catalog__c LIMIT 1];
        
        PageReference myVfPage = Page.SPComN_CatalogDetailPage;
        myVfPage.getParameters().put('catalogId',newSupplierProductCatalog.Id);
		Test.setCurrentPage(myVfPage);
        
        SPComN_CatalogDetailModalCntrl CatalogDetailModelObject = new SPComN_CatalogDetailModalCntrl();
        
        CatalogDetailModelObject.catalogName = newSupplierProductCatalog.Name; 
    }

}