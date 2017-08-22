@isTest
public class SPComN_PurchaseOrdersDetailsContTest {
    
    @testSetup
    private static void createTestRecord(){
        SPComN_PurchaseOrdersContTest.createRecords();
        
        Account accountRecord = [SELECT Id
                                 FROM Account
                                 LIMIT 1];
        
        bthousetracker__Supplier_Door_Products__c supplierDoorProductRecord = [SELECT Id
                                                                              FROM bthousetracker__Supplier_Door_Products__c
                                                                              LIMIT 1];
        
        bthousetracker__Purchase_Orders__c purchaseOrderRecord = [SELECT Id, Name, bthousetracker__Supplier__c
                                                                  FROM bthousetracker__Purchase_Orders__c];
        
        bthousetracker__Purchase_Order_Details__c purchaseOrderDetailRecord = new bthousetracker__Purchase_Order_Details__c();
        
        purchaseOrderDetailRecord.Name = 'test Purchase Order Detail';
        purchaseOrderDetailRecord.bthousetracker__Purchase_Order__c = purchaseOrderRecord.Id;
        purchaseOrderDetailRecord.bthousetracker__Ship_To__c = accountRecord.Id;
        purchaseOrderDetailRecord.bthousetracker__Order_Source__c = 'test Order Source';
        purchaseOrderDetailRecord.bthousetracker__Part_Number__c = 'test part number';
        purchaseOrderDetailRecord.bthousetracker__Order_Qty__c = 10;
        purchaseOrderDetailRecord.bthousetracker__Unit_Price__c = 100;
        purchaseOrderDetailRecord.bthousetracker__Unit_Cost__c = 10;
        purchaseOrderDetailRecord.bthousetracker__Unit_Weight__c = 15;
        purchaseOrderDetailRecord.bthousetracker__Weight_UOM__c = 'test UOM Weight';
        purchaseOrderDetailRecord.bthousetracker__Template_Name__c = 'test Template';
        purchaseOrderDetailRecord.bthousetracker__Vendor_Name__c = accountRecord.Id;
        purchaseOrderDetailRecord.bthousetracker__Currency_Code__c = 'USD';
        purchaseOrderDetailRecord.bthousetracker__Category_Concat_Segments__c = 'test Category Concat Segments';
        purchaseOrderDetailRecord.bthousetracker__Line_Number__c = 10;
        purchaseOrderDetailRecord.bthousetracker__Request_Date__c = System.today();
        purchaseOrderDetailRecord.bthousetracker__Schedule_Ship_Date__c = System.today();
        purchaseOrderDetailRecord.bthousetracker__Promise_Date__c = System.today();
        purchaseOrderDetailRecord.bthousetracker__Ship_From__c = 'test Ship From';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_Country__c = 'US';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_Address1__c = 'test Bill Address 1';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_Address2__c = 'test Bill Address 2';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_Address3__c = 'test Bill Address 3';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_Address4__c = 'test Bill Address 4';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_City__c = 'New York';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_Postal_Code__c = '10001';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_State__c = 'New York';
        purchaseOrderDetailRecord.bthousetracker__Bill_To_Province__c = 'test Bill to Province';
        purchaseOrderDetailRecord.bthousetracker__Supplier_Door_Product__c = supplierDoorProductRecord.Id;
        
        INSERT purchaseOrderDetailRecord;
        
        bthousetracker__Shipments__c shipMent = new bthousetracker__Shipments__c(Name = 'test Shipment');
        
        INSERT shipMent;
        
        bthousetracker__Shipment_Details__c shipMentDetail = new bthousetracker__Shipment_Details__c(Name = 'Shipment detail',
                                                                                                     bthousetracker__Shipment__c = shipMent.Id);
        
        INSERT shipMentDetail;
    }
    
    @isTest
    private static void testRecord(){
        
        Account accountRecord = [SELECT Id
                                 FROM Account
                                 LIMIT 1];
        
        bthousetracker__Shipments__c shipMentRecord = [SELECT Id, Name
                                                       FROM bthousetracker__Shipments__c 
                                                       LIMIT 1];
        
        
        bthousetracker__Purchase_Orders__c purchaseOrderRecord = [SELECT Id, Name, bthousetracker__Supplier__c
                                                                  FROM bthousetracker__Purchase_Orders__c];
        
        bthousetracker__Supplier_Door_Products__c supplierproduct = [SELECT Id
                                                                    FROM bthousetracker__Supplier_Door_Products__c
                                                                    LIMIT 1];
        
        
        SPComN_Wrapper.Response wrapperResponse = new SPComN_Wrapper.Response();
        
        PageReference pageRef = Page.SPComN_PurchaseOrder_Details;
        pageRef.getParameters().put('poId',purchaseOrderRecord.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        SPComN_PurchaseOrdersDetailsCont purchaseOrderDetailObj = new SPComN_PurchaseOrdersDetailsCont();
        
        //getPurchaseOrderDetails
        wrapperResponse = SPComN_PurchaseOrdersDetailsCont.getPurchaseOrderDetails(purchaseOrderRecord.Id);
        System.assertEquals(null, wrapperResponse.MessagingStr);
        System.assertEquals(true, wrapperResponse.isSuccess);
        
        //saveShipment
        String shipmentJson = '{"shipId":"'+shipMentRecord.Id+'","shipDate":"10/08/2017","lineItems":[{ "shipId":"'+shipMentRecord.Id+'","lineNumber":"10","orderQty":"10","uom":"test UOM Weight","price":"100","qtyShipped":"15","qtyBilled":"100","qtyCancelled":"10","qtyDue":"5","product":{"id":"'+supplierproduct.Id+'","uom":"testUOM","weight":"10","name":"15","partNumber":"10","lineNumber":"10"}}]}';
        wrapperResponse = SPComN_PurchaseOrdersDetailsCont.saveShipment(shipmentJson, purchaseOrderRecord.Id, accountRecord.Id);
        System.debug('wrapperResponse=='+wrapperResponse);
        
        Test.stopTest();
    }
    
}