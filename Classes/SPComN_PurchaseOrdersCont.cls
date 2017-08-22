/*
*/
public Class SPComN_PurchaseOrdersCont{
    
    public PageVariables variables {get; set;}
    public String PurchaseOrderId {get; set;}
    
    public SPComN_PurchaseOrdersCont(){
        variables = new PageVariables();     
        
        variables.supplierId = SPComN_Utils.getSupplierAccount(); 
        System.debug('variables.supplierId '+variables.supplierId) ;       
    }        
    
    @remoteAction
    public static SPComN_Wrapper.Response getPurchaseOrders(String paramJson){
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';        
        System.debug('Supplier Id: '+ supplierId);
        
        List<PurchaseOrdersWrapper> PurchaseOrdersWrapperList = new List<PurchaseOrdersWrapper>();
        
        if(String.isNotBlank(supplierId)){        
            List<bthousetracker__Purchase_Orders__c> purchaseOrderList = new List<bthousetracker__Purchase_Orders__c>();        
            
            String query = 'SELECT bthousetracker__PO__c, bthousetracker__Status__c,  bthousetracker__Date_Issued__c, bthousetracker__Property__r.Name, ' +                         
                           'bthousetracker__Supplier__r.Name, bthousetracker__Shipping_Address__r.Name, bthousetracker__Latest_Ship_Date__c, ' +
                           'bthousetracker__Quote__c, bthousetracker__Total_Ext_Price__c, bthousetracker__Freight_Costs__c, '  +
                           'bthousetracker__Total_PO_Amount__c, bthousetracker__Weight_lbs__c '  +
                           'FROM bthousetracker__Purchase_Orders__c WHERE bthousetracker__Supplier__c =: supplierId ';
                             
            System.debug('query '+ query);
            
            try{
                purchaseOrderList = Database.query(query);
            }catch(Exception ex){
                System.debug('error: '+ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Error: In getting Records '+ ex.getMessage(), null);
            }
            
            for(bthousetracker__Purchase_Orders__c currPO : purchaseOrderList){
                PurchaseOrdersWrapperList.add(new PurchaseOrdersWrapper(currPO));    
            }
            
            return new SPComN_Wrapper.Response(true, 'Success In getting Records', PurchaseOrdersWrapperList);
            
        } 
        
        return new SPComN_Wrapper.Response(false, 'Error: In getting Records', null);

    }
    
    /*
        @ Purpose     : Method to redirect to page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference viewPoDetails() {
        Map<String, String> paramMap = new Map<String, String>();       
            
        if(String.isNotBlank(PurchaseOrderId))
            paramMap.put('poId', PurchaseOrderId);

        return SPComN_Utils.routeTo('SPComN_PurchaseOrder_Details', paramMap);
    }

    
    public static Map<String, String> deserializeParam(String paramJson){    
        Map<String, String> mapParams = (Map<String, String>)JSON.deserialize(paramJson, Map<String, String>.class);
        return mapParams;
    }
    
    public Class PageVariables{
        public String supplierId {get; set;}
        public String catalogId {get; set;}
        public String productId {get; set;}
        
        public PageVariables (){}
    }
    
    public Class PurchaseOrdersWrapper{
        public String id;
        public String poNumber;
        public String Status;
        public String poDate;
        
        public String project;
        public String builder;
        public String shipTo;
        
        public String shipDate;
        public String qoute;
        public String amount;
        
        public String freights;
        public String total;
        public String wgt;
        
        public PurchaseOrdersWrapper(bthousetracker__Purchase_Orders__c poRec){
            id = poRec.Id;
            poNumber = poRec.bthousetracker__PO__c != null? String.valueOf(poRec.bthousetracker__PO__c) : '';
            Status = poRec.bthousetracker__Status__c != null? String.valueOf(poRec.bthousetracker__Status__c) : '';
            poDate = poRec.bthousetracker__Date_Issued__c != null? String.valueOf(poRec.bthousetracker__Date_Issued__c.format()) : '';
            
            project = poRec.bthousetracker__Property__r.Name != null? String.valueOf(poRec.bthousetracker__Property__r.Name) : '';    
            builder = poRec.bthousetracker__Supplier__r.Name != null? String.valueOf(poRec.bthousetracker__Supplier__r.Name) : '';    
            shipTo = poRec.bthousetracker__Shipping_Address__r.Name != null? String.valueOf(poRec.bthousetracker__Shipping_Address__r.Name) : '';    
            shipDate = poRec.bthousetracker__Latest_Ship_Date__c != null? String.valueOf(poRec.bthousetracker__Latest_Ship_Date__c.format()) : '';    
    
            qoute = poRec.bthousetracker__Quote__c != null? String.valueOf(poRec.bthousetracker__Quote__c) : '';    
            amount = poRec.bthousetracker__Total_Ext_Price__c != null? String.valueOf(poRec.bthousetracker__Total_Ext_Price__c.round()) : '';    
            freights = poRec.bthousetracker__Freight_Costs__c != null? String.valueOf(poRec.bthousetracker__Freight_Costs__c.round()) : '';    
            total = poRec.bthousetracker__Total_PO_Amount__c != null? String.valueOf(poRec.bthousetracker__Total_PO_Amount__c.round()) : '';    
    
            wgt = poRec.bthousetracker__Weight_lbs__c != null? String.valueOf(poRec.bthousetracker__Weight_lbs__c ) : '';    
        }
    }
}