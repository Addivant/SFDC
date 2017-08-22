@isTest
public class SPComN_UtilsTest {

    
    @TestSetup
    private static void createTestSetUpData(){
     
        SPComN_DoorProductDetailCntrlTest.createTestSetupData();
        
        
        INSERT new bthousetracker__BBNA_Supplier__c(bthousetracker__Supplier__c = 'Supplier'); 
    }
    
    @isTest
    private static void testRecord(){
        
        SPComN_Wrapper.Response catalogProductPageObj;
        
        bthousetracker__Supplier_Door_Products__c suppplierDoorProductRecord = [SELECT Id, Name, bthousetracker__Supplier__c, bthousetracker__Door_Description__c, 
                                                                                    bthousetracker__Status__c, bthousetracker__Supplier_Part__c, bthousetracker__BBNA_Status__c,bthousetracker__Supplier_Product_Catalog__c,
                                                                                    bthousetracker__Archived_Date__c, bthousetracker__Effective_Date__c, bthousetracker__Active_Date__c,
                                                                                    bthousetracker__Product_Category__c,
                                                                                    bthousetracker__warranty__c, bthousetracker__Active_Leafs_Picklist__c, bthousetracker__UOM__c,
                                                                                    bthousetracker__Type__c, bthousetracker__Assembly__c, bthousetracker__rating__c, bthousetracker__series__c,
                                                                                    bthousetracker__Door_Size__c, bthousetracker__markup__c, bthousetracker__weight__c,
                                                                                    bthousetracker__paint_color__c, bthousetracker__paint_Type__c, bthousetracker__Sub_Category__c
                                                                                FROM bthousetracker__Supplier_Door_Products__c
                                                                                WHERE Name LIKE 'Supplier%' 
                                                                                LIMIT 1];
        
        bthousetracker__Supplier_Door_Products__c newSuppplierDoorProductRecord;
        
        bthousetracker__Supplier_Components__c supplierComponentRecord = [SELECT Id FROM bthousetracker__Supplier_Components__c LIMIT 1];
        
        bthousetracker__Supplier_Component_Types__c supplierComponentTypes = [SELECT Id FROM bthousetracker__Supplier_Component_Types__c LIMIT 1];
        
        String JsonData = '{ "recordId":"'+suppplierDoorProductRecord.Id+'", "deactivateDate":"07/11/2017", "reasonToDelete":"testReason",  "reasonForNotFulfulling":"reasonNotFullfiltest", "fulfilOrders":"no"}';
        
        //to test getSupplierAccount Method.
        catalogProductPageObj = SPComN_CatalogProductPageCntrl.requestForDelete(suppplierDoorProductRecord.Id, JsonData);
        
        //to test routeTo page method.
        PageReference pageRef = Page.SPComN_DoorProductDetailPage;
        pageRef.getParameters().put('status','Pending');
        pageRef.getParameters().put('productId',suppplierDoorProductRecord.Id);
        pageRef.getParameters().put('catalogId1',supplierComponentTypes.Id); 
        
        Test.setCurrentPage(pageRef);
        
        SPComN_DoorProductDetailCntrl doorProductDetailObject = new SPComN_DoorProductDetailCntrl();
        SPComN_DoorProductDetailCntrl.redirectToCatCompPage();
        doorProductDetailObject.redirectToCatProductPage();
        
        //to test getPicklistValues page method.
        catalogProductPageObj = SPComN_AddPartFlowCont.getProductPicklists();
        
        SPComN_Wrapper.ProductruleWrapper productrulWrapperObject = new SPComN_Wrapper.ProductruleWrapper();
        
        productrulWrapperObject.isDefault = 'yes';
        productrulWrapperObject.isSelectedForProduct = true;
        productrulWrapperObject.isModified = false;
        productrulWrapperObject.supplier = supplierComponentRecord.Id;
        
        //deserializeProductRule method
        bthousetracker__Supplier_Products_Components__c supplierProductComponent = SPComN_Utils.deserializeProductRule(productrulWrapperObject);
        
        //deserializeProduct Method
        SPComN_Wrapper.ProductInfoWrapper productInfoWrapperObject = new SPComN_Wrapper.ProductInfoWrapper();
        
        productInfoWrapperObject.Id = suppplierDoorProductRecord.Id;
        productInfoWrapperObject.name = suppplierDoorProductRecord.Name;
        productInfoWrapperObject.warranty = 'Yes';
        productInfoWrapperObject.partNumber =  suppplierDoorProductRecord.bthousetracker__Supplier_Part__c;
        productInfoWrapperObject.activeDate = String.valueOf(Date.today());
        productInfoWrapperObject.archiveDate = String.valueOf(Date.today());
        productInfoWrapperObject.effectiveDate = String.valueOf(Date.today());
        productInfoWrapperObject.catalogId = suppplierDoorProductRecord.bthousetracker__Supplier_Product_Catalog__c;
        productInfoWrapperObject.bbnaStatus = suppplierDoorProductRecord.bthousetracker__BBNA_Status__c;
        productInfoWrapperObject.status = suppplierDoorProductRecord.bthousetracker__Status__c;
        productInfoWrapperObject.supplier = suppplierDoorProductRecord.bthousetracker__Supplier__c;
        productInfoWrapperObject.category = 'Base';
        productInfoWrapperObject.leafs = '1';
        productInfoWrapperObject.uom = '1 Gallon';
        productInfoWrapperObject.type = 'Fire';
        productInfoWrapperObject.assembly = 'Knocked-Down';
        productInfoWrapperObject.rating = '45 Min';
        productInfoWrapperObject.series = 'Premium';
        productInfoWrapperObject.subCategory = 'Exterior';
        productInfoWrapperObject.size = '6 x 7';
        productInfoWrapperObject.markup = '10';
        productInfoWrapperObject.weight = '50';
        productInfoWrapperObject.paintColor = 'Custom Black';    
        productInfoWrapperObject.paintType = 'Custom';      
        
        newSuppplierDoorProductRecord = SPComN_Utils.deserializeProduct(productInfoWrapperObject);
           
        
       //deserializeLeadTime
        bthousetracker__Lead_Time__c leadTimeRecord =[SELECT Id, bthousetracker__Man_Lead_Time__c, bthousetracker__Supplier_Component__c,
                                                                 bthousetracker__Supplier_Door_Product__c, bthousetracker__Sourcing_Facility_Single__c
                                                     FROM bthousetracker__Lead_Time__c
                                                     LIMIT 1];
        
        SPComN_Wrapper.LeadTimeWrapper leadTimeWrapperObj = new SPComN_Wrapper.LeadTimeWrapper();
        
        leadTimeWrapperObj.plant = 'Chicago';
        leadTimeWrapperObj.days = '7';
        leadTimeWrapperObj.id = leadTimeRecord.Id;
        leadTimeWrapperObj.productId = leadTimeRecord.bthousetracker__Supplier_Door_Product__c;
        leadTimeWrapperObj.componentId = leadTimeRecord.bthousetracker__Supplier_Component__c;
            
        bthousetracker__Lead_Time__c leadTimeObj = SPComN_Utils.deserializeLeadTime(leadTimeWrapperObj);
        
        //deserializePricing
        bthousetracker__Supplier_Pricing_Table__c pricingRecord = [SELECT Id, bthousetracker__Cost__c, bthousetracker__Supplier_Product_Catalog__c, 
                                                                    bthousetracker__Supplier__c, bthousetracker__Supplier_Product__c, 
                                                                    bthousetracker__Status__c, bthousetracker__Proposed_Cost__c, 
                                                                    bthousetracker__Supplier_Component__c, bthousetracker__Supplier_Tier__c, 
                                                                    bthousetracker__Supplier_Zone__c 
                                                                   FROM bthousetracker__Supplier_Pricing_Table__c
                                                                   LIMIT 1];
        
        System.debug('pricingRecord=='+pricingRecord);
                
        SPComN_Wrapper.PricingWrapper pricingWrapperObj = new SPComN_Wrapper.PricingWrapper();
        
        pricingWrapperObj.id = pricingRecord.Id;
        pricingWrapperObj.cost = '50';
        pricingWrapperObj.catalogId = suppplierDoorProductRecord.bthousetracker__Supplier_Product_Catalog__c;
        pricingWrapperObj.componentId = pricingRecord.bthousetracker__Supplier_Component__c;
        pricingWrapperObj.productId = pricingRecord.bthousetracker__Supplier_Product__c;
        pricingWrapperObj.status = pricingRecord.bthousetracker__Status__c;
        pricingWrapperObj.proposedCost = '55'; 
        pricingWrapperObj.supplierId = pricingRecord.bthousetracker__Supplier__c;
        
        bthousetracker__Supplier_Pricing_Table__c pricingTableObj = SPComN_Utils.deserializePricing(pricingWrapperObj);
        
        //getSourcingFacilties
        SPComN_Utils.getSourcingFacilties();
        
        //checkDuplicatePart
        String exceptionMsg = 'There is already a Component with given Product Name in this catalog. Please change and save again.';
        String exceptionMsgresult = SPComN_Utils.checkDuplicatePart(exceptionMsg);
        System.assertEquals('There is already a Component with given Product Name in this catalog. Please change and save again.',exceptionMsgresult);
        
        exceptionMsg = 'There is already a Component with given Part Number in this catalog. Please change and save again.';
        exceptionMsgresult = SPComN_Utils.checkDuplicatePart(exceptionMsg);
        System.assertEquals('There is already a Component with given Part Number in this catalog. Please change and save again.',exceptionMsgresult);
        
        exceptionMsg = 'There is already a Product with given Product Name in this catalog. Please change and save again.';
        exceptionMsgresult = SPComN_Utils.checkDuplicatePart(exceptionMsg);
        System.assertEquals('There is already a Product with given Product Name in this catalog. Please change and save again.',exceptionMsgresult);
        
        exceptionMsg = 'There is already a Product with given Part Number in this catalog. Please change and save again.';
        exceptionMsgresult = SPComN_Utils.checkDuplicatePart(exceptionMsg);
        System.assertEquals('There is already a Product with given Part Number in this catalog. Please change and save again.',exceptionMsgresult);
        
        exceptionMsg = 'There is already a Component with given Component Name in this catalog. Please change and save again.';
        exceptionMsgresult  = SPComN_Utils.checkDuplicatePart(exceptionMsg);
        System.assertEquals('There is already a Component with given Component Name in this catalog. Please change and save again.',exceptionMsgresult);
        
        exceptionMsg = 'There is already a Product with given Component Name in this catalog. Please change and save again.';
        exceptionMsgresult = SPComN_Utils.checkDuplicatePart(exceptionMsg);
        System.assertEquals('There is already a Product with given Component Name in this catalog. Please change and save again.',exceptionMsgresult);
        
        //discardRecord
        SPComN_Wrapper.Response WrapperResponse = new SPComN_Wrapper.Response();
        
        String objectName = 'bthousetracker__Supplier_Door_Products__c';
        WrapperResponse = SPComN_Utils.discardRecord(suppplierDoorProductRecord.Id, objectName);
        System.assertEquals('Success: In discarding record', WrapperResponse.MessagingStr);
        System.assertEquals(true,  WrapperResponse.isSuccess);
        
        objectName = 'bthousetracker__Supplier_Components__c';
        WrapperResponse = SPComN_Utils.discardRecord(supplierComponentRecord.Id, objectName);
        System.assertEquals('Success: In discarding record', WrapperResponse.MessagingStr);
        System.assertEquals(true,  WrapperResponse.isSuccess);
        
        WrapperResponse = SPComN_Utils.discardRecord('', '');
        System.assertEquals('Error: In discarding record recordId not present', WrapperResponse.MessagingStr);
        System.assertEquals(false,  WrapperResponse.isSuccess);
    }
}