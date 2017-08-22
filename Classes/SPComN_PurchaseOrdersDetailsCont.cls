public Class SPComN_PurchaseOrdersDetailsCont {

    public PageVariables variables {get; set;}
    
    public SPComN_PurchaseOrdersDetailsCont(){
        variables = new PageVariables();
        
        String purchaseOrderId = ApexPages.currentPage().getParameters().get('poId');
        
        if(String.isNotBlank(purchaseOrderId)){
            variables.purchaseOrderId = purchaseOrderId;         
        }
        
        variables.supplierId = SPComN_Utils.getSupplierAccount(); 
    }
    
    @remoteAction
    public static SPComN_Wrapper.Response getPurchaseOrderDetails(String purchaseOrderId){
        bthousetracker__Purchase_Orders__c purchaseOrder;
        //--Purchase Order
        //try{
            purchaseOrder = [SELECT bthousetracker__PO__c, bthousetracker__Date_Issued__c, bthousetracker__Revision_Date__c,
                                    bthousetracker__Bill_To__c, bthousetracker__Status__c, bthousetracker__Property__c, bthousetracker__Property__r.bthousetracker__Job_Number__c, 
                                    bthousetracker__Total_PO_Amount__c, bthousetracker__Freight__c, bthousetracker__Total__c,
                                    bthousetracker__Total_Quantity__c, bthousetracker__Project_Name__c, bthousetracker__Job_Number__c,
                                    bthousetracker__Ship_To__c, bthousetracker__Shipping_Method__c, bthousetracker__Desired_Ship_Date__c,
                                    bthousetracker__Weight_lbs__c, bthousetracker__Shipped__c, bthousetracker__Buyer_Name__c, 
                                    bthousetracker__Buyer_Name__r.Name  
                               FROM bthousetracker__Purchase_Orders__c
                               WHERE Id =: purchaseOrderId];
        //}catch(Exception ex){
       //     System.debug('Exception : '+ ex.getMessage());
        //}
        
        
        //--Purchase Order Line Item
        List<bthousetracker__Purchase_Order_Details__c> listdetailItems ;
        
        listdetailItems = [SELECT Id, Name, bthousetracker__Line_Number__c, bthousetracker__Order_Qty__c, bthousetracker__Long_Description__c ,
                                  bthousetracker__Order_UOM__c, bthousetracker__Supplier_Door_Product__c, 
                                  bthousetracker__Ext_Price__c, bthousetracker__Line_Status__c, bthousetracker__Quantity_Shipped__c,
                                  bthousetracker__Quantity_Billed__c, bthousetracker__Quantity_Cancelled__c, 
                                  bthousetracker__Quantity_Due__c, bthousetracker__Requested_Ship_Date__c, 
                                  bthousetracker__Schedule_Ship_Date__c, bthousetracker__Shipped__c, 
                                  bthousetracker__Purchase_Order__c, bthousetracker__Unit_Price__c
                           FROM bthousetracker__Purchase_Order_Details__c
                           WHERE bthousetracker__Purchase_Order__c =: purchaseOrderId];
                           
                           
        List<SPComN_Wrapper.PurchaseOrderDetails> poLineItems = new List<SPComN_Wrapper.PurchaseOrderDetails>();
        
        Set<Id> productIds = new Set<Id>();
        for(bthousetracker__Purchase_Order_Details__c detailItem : listdetailItems){
            if(detailItem.bthousetracker__Supplier_Door_Product__c != null){
                productIds.add(detailItem.bthousetracker__Supplier_Door_Product__c);
            }
            SPComN_Wrapper.PurchaseOrderDetails lineItem = new SPComN_Wrapper.PurchaseOrderDetails(detailItem);
            poLineItems.add(lineItem);
        }
                                      
        Map<Id, bthousetracker__Supplier_Door_Products__c> productMap;
        
        productMap = new Map<Id, bthousetracker__Supplier_Door_Products__c>(
                            [SELECT Id, Name, bthousetracker__Door_Size__c,
                                    bthousetracker__Series__c, bthousetracker__Type__c, bthousetracker__Rating__c, 
                                    bthousetracker__Assembly__c, bthousetracker__Active_Leafs__c, 
                                    bthousetracker__Product_Category__c,
                                    bthousetracker__Supplier_Part__c
                                    
                            FROM bthousetracker__Supplier_Door_Products__c
                            WHERE Id =: productIds]); 
        System.debug('productMap '+productMap );
                   
        for(bthousetracker__Purchase_Order_Details__c detailItem : listdetailItems){           
            SPComN_Wrapper.PurchaseOrderDetails lineItem = new SPComN_Wrapper.PurchaseOrderDetails(detailItem);
            
            System.debug('detailItem.bthousetracker__Supplier_Door_Product__c : '+detailItem.bthousetracker__Supplier_Door_Product__c);
            if(detailItem.bthousetracker__Supplier_Door_Product__c != null){
                SPComN_Wrapper.ProductInfoWrapper product = new SPComN_Wrapper.ProductInfoWrapper(
                                                                    productMap.get(detailItem.bthousetracker__Supplier_Door_Product__c));
                lineItem.product = product;
            }
            System.debug('lineItem.product : '+lineItem.product);
            
            poLineItems.add(lineItem);
        }
        
        SPComN_wrapper.PurchaseOrder poWrapper = new SPComN_wrapper.PurchaseOrder(purchaseOrder);
        SPComN_wrapper.Response response = new SPComN_wrapper.Response();
        response.record = poWrapper ;
        response.records = poLineItems;
        response.isSuccess = true;
        return response;                                   
    }
    
    @remoteAction
    public static SPComN_Wrapper.Response saveShipment(String shipmentJson, String poId, String supplierId){
        SPComN_Wrapper.ShipmentWrapper shipmentData = (SPComN_Wrapper.ShipmentWrapper) JSON.deserialize(shipmentJson, SPComN_Wrapper.ShipmentWrapper.class);
         
        //create Shipment record
        bthousetracker__Shipments__c shipment = new bthousetracker__Shipments__c();
        shipment.bthousetracker__Builder_Account__c = supplierId;
        shipment.bthousetracker__BT_Purchase_Order__c = poId;
        shipment.bthousetracker__Ship_Date__c = Date.parse(shipmentData.shipDate);
        shipment.bthousetracker__Ship_Id__c = shipmentData.shipId;
        
        try{
            Insert shipment;
        }catch(exception ex){
            System.debug('Exception : '+ ex.getMessage());
            return new SPComN_Wrapper.Response(false, ex.getMessage() , null);
        }
        
        if(shipment != null){
            List<bthousetracker__Shipment_Details__c> shipmentDetails =  getShipmentDetails(shipment.id, shipmentData.lineItems); 
            
            if(shipmentDetails != null && !shipmentDetails.isEmpty()){
               
                try{
                    Insert shipmentDetails;                    
                }catch(exception ex){
                    System.debug('Exception : '+ ex.getMessage());
                    return new SPComN_Wrapper.Response(false, ex.getMessage() , null);
                }
            }
            return new SPComN_Wrapper.Response(true, 'Shipment has been created successfully!', shipment, null);
        }
        
        
        return null;
    }
    
    public static List<bthousetracker__Shipment_Details__c> getShipmentDetails(String shipmentId, List<SPComN_Wrapper.PurchaseOrderDetails> poLines){
        
        List<bthousetracker__Shipment_Details__c> shipmentLines = new List<bthousetracker__Shipment_Details__c>();
        
        for(SPComN_Wrapper.PurchaseOrderDetails poLineItem : poLines) {
            bthousetracker__Shipment_Details__c shipLine = new bthousetracker__Shipment_Details__c();
            shipLine.bthousetracker__Purchase_Order_Details__c = shipLine.id;
            shipLine.bthousetracker__Shipment__c = shipmentId;
            //shipLine.bthousetracker__Due_Quantity__c = Decimal.valueOf(poLineItem.qtyToShip);
            
            shipLine.bthousetracker__Qty_Billed__c = String.isNotBlank(poLineItem.qtyBilled) ?  Integer.valueOf(poLineItem.qtyBilled) : null;              
            shipLine.bthousetracker__Qty_Cancelled__c = String.isNotBlank(poLineItem.qtyCancelled) ? Integer.valueOf(poLineItem.qtyCancelled) : null; 
            shipLine.bthousetracker__Qty_Due__c = String.isNotBlank(poLineItem.qtyDue) ? Integer.valueOf(poLineItem.qtyDue) : null;
            shipLine.bthousetracker__Qty_Shipped__c = String.isNotBlank(poLineItem.qtyShipped) ? Integer.valueOf(poLineItem.qtyShipped) : null;
            
            shipLine.bthousetracker__Supplier_Door_Product__c =  poLineItem.product != null ? poLineItem.product.id : null;
            shipLine.bthousetracker__UOM__c = poLineItem.product != null && String.isNotBlank(poLineItem.product.uom) ? poLineItem.product.uom : null;
            shipLine.bthousetracker__Weight__c = poLineItem.product != null && String.isNotBlank(poLineItem.product.weight) ? Integer.valueOf(poLineItem.product.weight) : null;
            shipLine.bthousetracker__Description__c = poLineItem.product != null ? poLineItem.product.name : null;
            shipLine.bthousetracker__Part_Number__c  = poLineItem.product != null && String.isNotBlank(poLineItem.product.partNumber) ? poLineItem.product.partNumber : null;
            shipLine.bthousetracker__Line__c = String.isNotBlank(poLineItem.lineNumber) ? Integer.valueOf(poLineItem.lineNumber) : null;
            
            shipmentLines.add(shipLine);
            
        }
        return shipmentLines ;
    }
    
    
    @RemoteAction
    public static String uploadAttachment(String shipmentId, String attachmentBody, String attachmentName, String attachmentId) {
        if(String.isNotBlank(shipmentId)) {
            //Account acct = getAccount(acctId);
            //if(acct != null) {
                if(attachmentBody != null) {
                    Attachment att = getAttachment(attachmentId);
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    if(attachmentId == null) {
                        att.Name = attachmentName;
                        att.parentId = shipmentId;
                    }
                    upsert att;
                    return att.Id;
                } else {
                    return 'Attachment Body was null';
                }
            /*} else {
                return 'Account could not be found';
            }*/
        } else {
            return 'Account Id was null';
        }
    }
    
    public static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
    
    public Class PageVariables {
        public String supplierId {get; set;}
        public String catalogId {get; set;}
        public String purchaseOrderId {get; set;}
        
        public PageVariables (){}
    }
}