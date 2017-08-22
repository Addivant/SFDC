/*
 * purpose :-  This is test class of SPComN_PurchaseOrdersCont
 * 
 */
@isTest
public class SPComN_PurchaseOrdersContTest {

    @TestSetup//This method is used in SPComN_PurchaseOrdersDetailsContTest class
    public static void createRecords(){
        
        
        SPComN_DoorProductDetailCntrlTest.createTestSetupData();
        
        Account accountRecord = [SELECT Id
                                 FROM Account
                                 LIMIT 1];
        
        System.debug('accountRecord=='+accountRecord);
        
        bthousetracker__Purchase_Orders__c purchaseOrder = new bthousetracker__Purchase_Orders__c(Name = 'test Purchase Order',
                                                                                                  bthousetracker__Supplier__c = accountRecord.Id);
        
        INSERT purchaseOrder;
    }
    
    @isTest
    private static void testRecord(){
        
         bthousetracker__Purchase_Orders__c purchaseOrderRecord = [SELECT Id, Name, bthousetracker__Supplier__c
                                                                  FROM bthousetracker__Purchase_Orders__c];
        
        SPComN_PurchaseOrdersCont purchaseOrderContObj = new SPComN_PurchaseOrdersCont();
        purchaseOrderContObj.PurchaseOrderId = purchaseOrderRecord.Id;
        
        SPComN_Wrapper.Response wrapperResponseObj;
        
        Account accountRecord = [SELECT Id
                                 FROM Account
                                 LIMIT 1];
        
        String jsonString =  '{ "supplierId":"'+accountRecord.Id+'"}';   
        
        wrapperResponseObj = SPComN_PurchaseOrdersCont.getPurchaseOrders(jsonString);
        System.assertEquals('Success In getting Records', wrapperResponseObj.MessagingStr);
        System.assertEquals(true, wrapperResponseObj.isSuccess);
        
        PageReference pageRef = Page.SPComN_PurchaseOrders;
        Test.setCurrentPage(pageRef);
        purchaseOrderContObj.viewPoDetails();
        
    }
}