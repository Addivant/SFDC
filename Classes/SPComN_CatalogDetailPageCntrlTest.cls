/**
    Purpose : Test class for SPComN_CatalogDetailPageCntrl 
*/
@isTest
public class SPComN_CatalogDetailPageCntrlTest {
    
    @testSetup
    private static void createSetUpData(){        
        
        
        SPComN_DoorProductDetailCntrlTest.createTestSetupData();
        
        List<bthousetracker__Supplier_Product_Catalog__c> listSupplierProductCatalog = [SELECT Id, Name, bthousetracker__BBNA_Status__c, bthousetracker__Status__c, bthousetracker__Approval_Status__c,
                                                                                        	   CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, bthousetracker__BBNA_Product_Category__r.Name
                                                                                         FROM bthousetracker__Supplier_Product_Catalog__c];
        
        
        List<bthousetracker__Supplier_Zones__c> supplierZoneList = new List<bthousetracker__Supplier_Zones__c>();
        
        bthousetracker__Supplier_Zones__c supplierZone; 
        
        for(Integer i = 0; i < 5; i++){
            
           supplierZone = new bthousetracker__Supplier_Zones__c(Name = 'Supplier '+i);
           supplierZoneList.add(supplierZone); 
            
        }
        
        INSERT supplierZoneList;
        
        List<bthousetracker__Supplier_Tier__c> supplierTierList = new List<bthousetracker__Supplier_Tier__c>();
        
        bthousetracker__Supplier_Tier__c supplierTier;
        
        for(Integer i = 0; i < 5; i++){
            
            supplierTier = new bthousetracker__Supplier_Tier__c(bthousetracker__Supplier_Product_Catalog__c = listSupplierProductCatalog[0].Id,
                                                                bthousetracker__Min_Qty__c = 5);
            
            supplierTierList.add(supplierTier);
        }
        
        INSERT supplierTierList;
    }
    
    
    @isTest
    private static void testRecord(){
        
        Map<Id, bthousetracker__Supplier_Components__c> supplierComponentsMap = new Map<Id, bthousetracker__Supplier_Components__c>();
        Map<Id, bthousetracker__Supplier_Door_Products__c> supplierDoorProductMap = new Map<Id, bthousetracker__Supplier_Door_Products__c>();
        
        
        List<bthousetracker__Supplier_Product_Catalog__c> listSupplierProductCatalog = [SELECT  Id, Name, bthousetracker__BBNA_Status__c, bthousetracker__Status__c, bthousetracker__Approval_Status__c,
                                                                                        	    CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, bthousetracker__BBNA_Product_Category__r.Name
                                                                                         FROM bthousetracker__Supplier_Product_Catalog__c];
        
        List<bthousetracker__Supplier_Components__c> supplierComponentList = [SELECT Id, bthousetracker__Status__c, bthousetracker__Supplier_Product_Catalog__c
                                                                              FROM bthousetracker__Supplier_Components__c];
        
        
        List<bthousetracker__Supplier_Door_Products__c> supplieDoorProductList = [SELECT Id 
                                                                                  FROM bthousetracker__Supplier_Door_Products__c];
        
        
        for(bthousetracker__Supplier_Components__c supplierComponent : supplierComponentList){
            supplierComponentsMap.put(supplierComponent.Id, supplierComponent);
        }
        
        
        for(bthousetracker__Supplier_Door_Products__c supplierDoorProduct : supplieDoorProductList){
            supplierDoorProductMap.put(supplierDoorProduct.Id, supplierDoorProduct);
        }
        
        
        List<bthousetracker__Supplier_Products_Components__c> supplierProductsComponentList = [SELECT Id, bthousetracker__Supplier_Component__c
                                                                                               FROM bthousetracker__Supplier_Products_Components__c];
        
        List<bthousetracker__Lead_Time__c> leadTimeList = [SELECT Id, bthousetracker__Supplier_Component__c
                                                           FROM bthousetracker__Lead_Time__c];
        
        
        User newUser = [SELECT Id, Name 
                        FROM User
                        WHERE FirstName = 'Tony'
                        LIMIT 1];
        
        System.debug('newUser=='+newUser);
        
        SPComN_Wrapper.response SPComNWrapperObj = new SPComN_Wrapper.response();
        
        List<ProcessInstance> processInstanceRecords = new List<ProcessInstance>();
        
        ProcessDefinition processDefinitionObject = [SELECT Id, TableEnumOrId 
                                                     FROM ProcessDefinition 
                                                     WHERE TableEnumOrId = 'bthousetracker__Supplier_Product_Catalog__c'
                                                     LIMIT 1];
        
        SPComN_Wrapper.Response wrappperResponseObject = new SPComN_Wrapper.Response();
        
        
        Test.startTest();
        //getCatalogDetail
        Approval.ProcessSubmitRequest ApprovalRequestObj = new Approval.ProcessSubmitRequest(); 
        ApprovalRequestObj.setObjectId(listSupplierProductCatalog[0].Id);
        ApprovalRequestObj.setProcessDefinitionNameOrId('Product_Catalog_Approval_process_new');

        //ApprovalRequestObj.setSubmitterId(newUser.Id);//Product_Catalog_Approval_process_new
        Approval.ProcessResult result = Approval.process(ApprovalRequestObj);
        
        ApprovalRequestObj = new Approval.ProcessSubmitRequest();
        ApprovalRequestObj.setObjectId(supplierComponentList[0].Id);
        ApprovalRequestObj.setProcessDefinitionNameOrId('Component_Approval');
        Approval.ProcessResult result1 = Approval.process(ApprovalRequestObj);
        
        Set<Id> processInstanceIds = new Set<Id>();
        List<ProcessInstance> processInstaceList = new List<ProcessInstance>();
        
        for(ProcessInstance processInstanceRecord : [SELECT Id, TargetObjectId
                                                     FROM ProcessInstance]){
                                                          processInstanceIds.add(processInstanceRecord.Id);
                                                          processInstaceList.add(processInstanceRecord);
                                                      }

        
        SPComNWrapperObj = SPComN_CatalogDetailPageCntrl.getCatalogDetail(listSupplierProductCatalog[0].Id);
        
        
        //updateCatalogName
        SPComNWrapperObj = SPComN_CatalogDetailPageCntrl.updateCatalogName(listSupplierProductCatalog[0].Id, 'supplierProduct123');
        System.assertEquals('Succesfully updated the record', SPComNWrapperObj.MessagingStr);
        System.assertEquals(true, SPComNWrapperObj.isSuccess);
        
        SPComNWrapperObj = SPComN_CatalogDetailPageCntrl.updateCatalogName('', '');
        System.assertEquals('Error: Somthing went wrong with catalog Id or catalog Name', SPComNWrapperObj.MessagingStr);
        System.assertEquals(false, SPComNWrapperObj.isSuccess);
        
        //getCatalogPartsCount
        SPComN_Wrapper.catalogInfoWrraper sPComCatlogInfoWrapper = new SPComN_Wrapper.catalogInfoWrraper();
        sPComCatlogInfoWrapper = SPComN_CatalogDetailPageCntrl.getCatalogPartsCount(listSupplierProductCatalog[0].Id);
        System.assertEquals(true,sPComCatlogInfoWrapper.isSucess);
        System.assertEquals('Successfully fetched the records', sPComCatlogInfoWrapper.message);
        
        sPComCatlogInfoWrapper = SPComN_CatalogDetailPageCntrl.getCatalogPartsCount(''); 
        System.assertEquals(false,sPComCatlogInfoWrapper.isSucess);
        System.assertEquals('Could not find the catalog', sPComCatlogInfoWrapper.message);
        
        
        //getPricingCount
        sPComCatlogInfoWrapper = SPComN_CatalogDetailPageCntrl.getPricingCount(listSupplierProductCatalog[0].Id);
        System.assertEquals(true,sPComCatlogInfoWrapper.isSucess);
        System.assertEquals('Successfully fetched the records', sPComCatlogInfoWrapper.message);
        
        sPComCatlogInfoWrapper = SPComN_CatalogDetailPageCntrl.getPricingCount('');
        System.assertEquals(false,sPComCatlogInfoWrapper.isSucess);
        System.assertEquals('Could not find the catalog', sPComCatlogInfoWrapper.message);
        
        
        //getPricingZoneDetails
        sPComCatlogInfoWrapper = SPComN_CatalogDetailPageCntrl.getPricingZoneDetails(listSupplierProductCatalog[0].Id);
        System.assertEquals(true,sPComCatlogInfoWrapper.isSucess);
        System.assertEquals('Successfully fetched the records', sPComCatlogInfoWrapper.message);
        
        sPComCatlogInfoWrapper = SPComN_CatalogDetailPageCntrl.getPricingZoneDetails('');
        System.assertEquals(false,sPComCatlogInfoWrapper.isSucess);
        System.assertEquals('Could not find the catalog', sPComCatlogInfoWrapper.message);
        
        
        //getPricingTiersDetails
        sPComCatlogInfoWrapper = SPComN_CatalogDetailPageCntrl.getPricingTiersDetails(listSupplierProductCatalog[0].Id);
        System.assertEquals(true,sPComCatlogInfoWrapper.isSucess);
        System.assertEquals('Successfully fetched the records', sPComCatlogInfoWrapper.message);
        
        sPComCatlogInfoWrapper = SPComN_CatalogDetailPageCntrl.getPricingTiersDetails('');
        System.assertEquals(false,sPComCatlogInfoWrapper.isSucess);
        System.assertEquals('Could not find the catalog', sPComCatlogInfoWrapper.message);
        
        
        
        //doApproval
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.doApproval(listSupplierProductCatalog[0].Id, '07/08/2017');
        System.assertEquals(true,wrappperResponseObject.isSuccess);
        System.assertEquals('Request has been submitted.', wrappperResponseObject.MessagingStr);
        
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.doApproval('','');
        System.assertEquals(false,wrappperResponseObject.isSuccess);
        System.assertEquals('Could not find the catalog.', wrappperResponseObject.MessagingStr);
        
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.doApproval(listSupplierProductCatalog[0].Id,'');
        System.assertEquals(false, wrappperResponseObject.isSuccess);
        System.assertEquals('Could not find the catalog.', wrappperResponseObject.MessagingStr);
        
        
        //archiveCatalog
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.archiveCatalog(listSupplierProductCatalog[0].Id);
        
        
        //saveCatalog
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.saveCatalog(listSupplierProductCatalog[0].Id, 'newSupplierProductCatalog', '07/08/2017');
        System.assertEquals('Successfully cloned the catalog', wrappperResponseObject.MessagingStr);
        System.assertEquals(true, wrappperResponseObject.isSuccess);
        
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.saveCatalog('', '', '');
        System.assertEquals('Catalog Id not present', wrappperResponseObject.MessagingStr);
        System.assertEquals(false, wrappperResponseObject.isSuccess);
        
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.saveCatalog(listSupplierProductCatalog[0].Id, 'newSupplierProductCatalog', '');
        System.assertEquals('Catalog Name Already Present For Given Supplier', wrappperResponseObject.MessagingStr);
        System.assertEquals(false, wrappperResponseObject.isSuccess);    
        
        
        //reparentingComponentAndProduct
        SPComN_CatalogDetailPageCntrl.reparentingComponentAndProduct(listSupplierProductCatalog[0].Id, supplierComponentList, supplieDoorProductList);
        
        //reparentingProductRuleAndLeadTime
        SPComN_CatalogDetailPageCntrl.reparentingProductRuleAndLeadTime(supplierProductsComponentList, leadTimeList, supplierComponentsMap, supplierDoorProductMap);
        
        List<bthousetracker__Supplier_Pricing_Table__c> listSupplierPricingTable = [SELECT Id, bthousetracker__Supplier_Component__c, bthousetracker__Supplier_Product__c 
                                                                                    FROM bthousetracker__Supplier_Pricing_Table__c];
        
        //reparentingPricing
        listSupplierPricingTable = SPComN_CatalogDetailPageCntrl.reparentingPricing(listSupplierProductCatalog[0].Id, listSupplierPricingTable, 
                                                                                    supplierComponentsMap, supplierDoorProductMap);
        
       
        //redirectToDetailPage
        PageReference pageRef = Page.SPComN_CatalogDetailPage;
        Test.setCurrentPage(pageRef);
        SPComN_CatalogDetailPageCntrl catalogDetailPage = new SPComN_CatalogDetailPageCntrl();
        pageRef.getParameters().put('catalogId',listSupplierProductCatalog[0].Id); 
        catalogDetailPage.redirectToDetailPage();
        catalogDetailPage.redirectTopartsPage();
        catalogDetailPage.redirectToPricingPage();
       
        
        
        //getPartsHistory    //process instance coverage is remain
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.getPartsHistory(listSupplierProductCatalog[0].Id);
        System.assertEquals('Successful: In getting par histroy', wrappperResponseObject.MessagingStr);
        System.assertEquals(true, wrappperResponseObject.isSuccess);
        System.assertEquals(null, wrappperResponseObject.record);
        
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.getPartsHistory('');
        System.assertEquals('Error: In getting par histroy CatalogId not present', wrappperResponseObject.MessagingStr);
        System.assertEquals(false, wrappperResponseObject.isSuccess);
        System.assertEquals(null, wrappperResponseObject.record);
        
        //getApprovalHistroyCmp //remain due to process instance
        Map<DateTime, String> getApprovalHistory = SPComN_CatalogDetailPageCntrl.getApprovalHistroyCmp(processInstanceIds, processInstaceList);
        
        //getApprovalHistroyPro //remain due to process instance
         Map<DateTime, String> getApprovalHistoryPro = SPComN_CatalogDetailPageCntrl.getApprovalHistroyPro(processInstanceIds, processInstaceList);
        
        //getPartsIds
        Set<Id> getPartsIds = SPComN_CatalogDetailPageCntrl.getPartsIds(listSupplierProductCatalog[0].Id);
        getPartsIds = SPComN_CatalogDetailPageCntrl.getPartsIds('');
        
        
        //getPricingHistoryInfo
        Map<DateTime, String> getPricingHistoryMap = SPComN_CatalogDetailPageCntrl.getPricingHistoryInfo(listSupplierProductCatalog[0].Id);
        
        //getZonehistoryInfo
        Map<DateTime, String> getZonehistoryMap = SPComN_CatalogDetailPageCntrl.getZonehistoryInfo(listSupplierProductCatalog[0].Id);
        
        //getTiershistoryInfo
        Map<DateTime, String> getTiershistoryInfoMap = SPComN_CatalogDetailPageCntrl.getTiershistoryInfo(listSupplierProductCatalog[0].Id);
        
        
        //getPricingHistory
    	wrappperResponseObject = SPComN_CatalogDetailPageCntrl.getPricingHistory(listSupplierProductCatalog[0].Id);
        System.assertEquals(true, wrappperResponseObject.isSuccess);
        System.assertEquals('Successful: In getting Pricing histroy', wrappperResponseObject.MessagingStr);
        
        wrappperResponseObject = SPComN_CatalogDetailPageCntrl.getPricingHistory('');
        System.assertEquals(false, wrappperResponseObject.isSuccess);
        System.assertEquals('Error: In getting par histroy CatalogId not present', wrappperResponseObject.MessagingStr);
        
        
		SPComN_CatalogDetailPageCntrl.catalogWrapper partCatalogWrapperObj = new SPComN_CatalogDetailPageCntrl.catalogWrapper();
		
            partCatalogWrapperObj.id = listSupplierProductCatalog[0].Id;
            partCatalogWrapperObj.name = listSupplierProductCatalog[0].Name;
            //partCatalogWrapperObj.category = listSupplierProductCatalog[0].bthousetracker__BBNA_Product_Category__r.Name;
            partCatalogWrapperObj.status = listSupplierProductCatalog[0].bthousetracker__Status__c;
            partCatalogWrapperObj.approvalStatus = listSupplierProductCatalog[0].bthousetracker__Approval_Status__c;
            partCatalogWrapperObj.BBNAStatus = listSupplierProductCatalog[0].bthousetracker__BBNA_Status__c;
            partCatalogWrapperObj.createdDate = String.valueof(listSupplierProductCatalog[0].CreatedDate);
            partCatalogWrapperObj.createdBy = listSupplierProductCatalog[0].CreatedBy.Name;
            /*partCatalogWrapperObj.submitedDate;
            partCatalogWrapperObj.submitedBy;
            partCatalogWrapperObj.completedDate;
            partCatalogWrapperObj.approverStatus;
            partCatalogWrapperObj.actulApprover; */
            partCatalogWrapperObj.lastUpdatedDate = String.valueof(listSupplierProductCatalog[0].LastModifiedDate);
            partCatalogWrapperObj.updatedBy = listSupplierProductCatalog[0].LastModifiedBy.Name;	
        
        	//partCatalogWrapperObj = new SPComN_CatalogDetailPageCntrl.catalogWrapper(listSupplierProductCatalog[0], '');
        	
        	SPComN_CatalogDetailPageCntrl.historyInfoWrapper historyInfoWrapperObj = new SPComN_CatalogDetailPageCntrl.historyInfoWrapper();
        
        	historyInfoWrapperObj.historydate = String.valueOf(Date.today());
        	historyInfoWrapperObj.historyStr = 'test history str';
        
         Test.stopTest();
       

        
    }

}